#!/usr/bin/env node

import {promises as fsp} from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import {promisify} from 'node:util';
import http from 'node:http';
import https from 'node:https';
import {createHash} from 'node:crypto';

const isParamPresent = name => process.argv.indexOf('--' + name) > 0;

const getParam = (name, defaultValue = '') => {
  const index = process.argv.indexOf('--' + name);
  if (index > 0) return process.argv[index + 1] || '';
  return defaultValue;
};

// A flag that takes an optional value: `--x` (present, empty) vs `--x v` (present, "v").
// A following token that itself starts with `--` is a separate flag, not this one's value.
const getOptionalParam = name => {
  const index = process.argv.indexOf('--' + name);
  if (index < 0) return undefined;
  const next = process.argv[index + 1];
  return next && !next.startsWith('--') ? next : '';
};

const prefix = getParam('prefix'),
  suffix = getParam('suffix');

const parseUrl = [
  /^(?:https?|git|git\+ssh|git\+https?):\/\/github.com\/([^\/]+)\/([^\/\.]+)(?:\/|\.git\b|$)/i,
  /^github:([^\/]+)\/([^#]+)(?:#|$)/i,
  /^([^:\/]+)\/([^#]+)(?:#|$)/i
];

const getRepo = url => {
  if (!url) return null;
  for (const re of parseUrl) {
    const result = re.exec(url);
    if (result) return result;
  }
  return null;
};

// Recognize an uploaded binary asset and recover its slot; returns null for anything else
// (source archives, checksum files, ...). The slot is `<name> - prefix - suffix - compression`.
const compressionRank = {br: 3, gz: 2, none: 1};
const parseAsset = name => {
  let base = name,
    compression = 'none';
  if (base.endsWith('.br')) ((base = base.slice(0, -3)), (compression = 'br'));
  else if (base.endsWith('.gz')) ((base = base.slice(0, -3)), (compression = 'gz'));
  if (prefix && !base.startsWith(prefix)) return null;
  if (suffix && !base.endsWith(suffix)) return null;
  const slot = base.slice(prefix.length, suffix ? base.length - suffix.length : base.length);
  // platform-arch-abi is the minimal shape (musl / N-API add components); guards non-binary uploads.
  if (slot.split('-').length < 3) return null;
  return {slot, compression};
};

const decompress = (buffer, compression) =>
  compression === 'br' ? promisify(zlib.brotliDecompress)(buffer) : compression === 'gz' ? promisify(zlib.gunzip)(buffer) : Promise.resolve(buffer);

const hash = buffer => 'sha256:' + createHash('sha256').update(buffer).digest('hex');

const httpGet = (url, headers = {}) =>
  new Promise((resolve, reject) => {
    const target = typeof url === 'string' ? url : url.href;
    const httpLib = /^http:\/\//i.test(target) ? http : https;
    httpLib
      .get(url, {headers: {'User-Agent': 'uhop/install-artifact-from-github', ...headers}}, res => {
        if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
          // Drop auth on redirect: asset URLs bounce to a separate CDN host (avoids leaking a token).
          httpGet(res.headers.location).then(resolve, reject);
          return;
        }
        if (res.statusCode < 200 || res.statusCode >= 300) {
          reject(Error(`Status ${res.statusCode} for ${target}`));
          return;
        }
        const chunks = [];
        res.on('data', c => chunks.push(c));
        res.on('end', () => resolve(Buffer.concat(chunks)));
      })
      .on('error', reject);
  });

// Keep one asset per slot, preferring the smallest download; all formats decode to the same bytes.
const pickBestPerSlot = entries => {
  const bySlot = new Map();
  for (const entry of entries) {
    const parsed = parseAsset(entry.name);
    if (!parsed) continue;
    const current = bySlot.get(parsed.slot);
    if (!current || compressionRank[parsed.compression] > compressionRank[current.compression]) {
      bySlot.set(parsed.slot, {...entry, compression: parsed.compression});
    }
  }
  return bySlot;
};

const collectFromDir = async dir => {
  const names = await fsp.readdir(dir);
  const bySlot = pickBestPerSlot(names.map(name => ({name})));
  const bag = {};
  for (const [slot, {name, compression}] of bySlot) {
    bag[slot] = hash(await decompress(await fsp.readFile(path.join(dir, name)), compression));
  }
  return bag;
};

const collectFromRelease = async (owner, repo, tag) => {
  const apiBase = process.env.GITHUB_API_URL || 'https://api.github.com';
  const releaseUrl = new URL(`/repos/${encodeURIComponent(owner)}/${encodeURIComponent(repo)}/releases/tags/${encodeURIComponent(tag)}`, apiBase);
  const token = process.env.GITHUB_TOKEN || process.env.PERSONAL_TOKEN;
  const headers = {Accept: 'application/vnd.github.v3+json'};
  if (token) headers.Authorization = 'Bearer ' + token;
  const release = JSON.parse((await httpGet(releaseUrl, headers)).toString());
  const bySlot = pickBestPerSlot((release.assets || []).map(a => ({name: a.name, url: a.browser_download_url})));
  const bag = {};
  for (const [slot, {url, compression}] of bySlot) {
    bag[slot] = hash(await decompress(await httpGet(url), compression));
  }
  return bag;
};

const sortByKey = bag => Object.fromEntries(Object.entries(bag).sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0)));

const diffBag = (current, computed) => {
  const out = [];
  for (const key of Object.keys(computed)) {
    if (!(key in current)) out.push(`missing: ${key}`);
    else if (current[key] !== computed[key]) out.push(`mismatch: ${key}`);
  }
  for (const key of Object.keys(current)) {
    if (!(key in computed)) out.push(`stale (not in release): ${key}`);
  }
  return out;
};

const main = async () => {
  const write = isParamPresent('write'),
    check = isParamPresent('check');
  if (write === check) {
    console.error('Specify exactly one of --write or --check.');
    process.exit(2);
  }

  const pkgPath = path.resolve(getParam('package') || 'package.json');
  const pkg = JSON.parse(await fsp.readFile(pkgPath, 'utf8'));

  const fromDir = getParam('from');
  let bag;
  if (fromDir) {
    bag = await collectFromDir(fromDir);
  } else {
    const tag = getOptionalParam('from-release') || pkg.version;
    const repo = getRepo(pkg.github || (pkg.repository && pkg.repository.type === 'git' && pkg.repository.url));
    let owner = repo && repo[1],
      name = repo && repo[2];
    if ((!owner || !name) && process.env.GITHUB_REPOSITORY) [owner, name] = process.env.GITHUB_REPOSITORY.split('/');
    if (!owner || !name) {
      console.error('Could not determine the GitHub repository (package.json "github" / "repository", or GITHUB_REPOSITORY).');
      process.exit(2);
    }
    bag = await collectFromRelease(owner, name, tag);
  }

  bag = sortByKey(bag);
  const count = Object.keys(bag).length;
  if (!count) {
    console.error('No artifacts found to hash.');
    process.exit(1);
  }

  if (write) {
    pkg.artifactHashes = bag;
    await fsp.writeFile(pkgPath, JSON.stringify(pkg, null, 2) + '\n');
    console.log(`Wrote ${count} artifact ${count === 1 ? 'hash' : 'hashes'} to ${pkgPath}.`);
    return;
  }

  const diffs = diffBag(pkg.artifactHashes || {}, bag);
  if (diffs.length) {
    console.error(`Hash bag in ${pkgPath} does not match the artifacts:`);
    for (const line of diffs) console.error('  ' + line);
    process.exit(1);
  }
  console.log(`Hash bag matches the artifacts (${count}).`);
};

main().catch(error => {
  console.error((error && error.message) || 'hash-github-cache has failed');
  process.exit(1);
});
