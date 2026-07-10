#!/usr/bin/env node

import {EOL} from 'node:os';
import {promises as fsp} from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import {promisify} from 'node:util';
import http from 'node:http';
import https from 'node:https';
import {spawnSync} from 'node:child_process';

const isHttp = /^http:\/\//i;

/** @type {import('child_process').SpawnSyncOptions} */
const spawnOptions = {encoding: 'utf8', env: process.env};
const getPlatform = () => {
  const platform = process.platform;
  if (platform !== 'linux') return platform;
  // detecting musl using algorithm from https://github.com/lovell/detect-libc under Apache License 2.0
  let result = spawnSync('getconf', ['GNU_LIBC_VERSION'], spawnOptions);
  if (!result.status && !result.signal) return platform;
  result = spawnSync('ldd', ['--version'], spawnOptions);
  if (result.signal) return platform;
  if ((!result.status && result.stdout.toString().indexOf('musl') >= 0) || (result.status === 1 && result.stderr.toString().indexOf('musl') >= 0))
    return platform + '-musl';
  return platform;
};
const platform = getPlatform();

const getParam = (name, defaultValue = '') => {
  const index = process.argv.indexOf('--' + name);
  if (index > 0) return process.argv[index + 1] || '';
  return defaultValue;
};

const cleanOptions = options => {
  const result = {};
  for (const [key, value] of Object.entries(options)) {
    if (value === undefined || value === null) continue;
    if (key === 'headers') {
      result.headers = cleanOptions(value);
      continue;
    }
    result[key] = value;
  }
  return result;
};

const io = (url, options = {}, data) =>
  new Promise((resolve, reject) => {
    let buffer = null;
    options = cleanOptions(options);
    const httpLib = isHttp.test(typeof url === 'string' ? url : url.href) ? http : https;
    const req = httpLib
      .request(url, options, res => {
        if (res.statusCode >= 300 && res.statusCode < 400 && res.headers && res.headers.location) {
          io(res.headers.location, options, data).then(resolve, reject);
          return;
        }
        if (res.statusCode < 200 || res.statusCode >= 300) {
          reject(Error(`Status ${res.statusCode} for ${url}`));
          return;
        }
        res.on('data', data => {
          if (buffer) {
            buffer = Buffer.concat([buffer, data]);
          } else {
            buffer = data;
          }
        });
        res.on('end', () => resolve({data: buffer, res}));
      })
      .on('error', error => reject(error));
    data && req.write(data);
    req.end();
  });
const get = (url, options) => io(url, {agent: false, ...options, method: 'GET'});
const post = (url, options, data) => io(url, {agent: false, ...options, method: 'POST'}, data);

const withParams = (url, params) => {
  const result = new URL(url);
  for (const [key, value] of Object.entries(params)) {
    result.searchParams.append(key, value);
  }
  return result;
};

const artifactPath = getParam('artifact'),
  prefix = getParam('prefix'),
  suffix = getParam('suffix'),
  format = getParam('format', 'br'),
  requestedFormats = new Set(format.toLowerCase().split(/\s*,\s*/)),
  skipBrotli = !zlib.brotliCompress || !requestedFormats.has('br'),
  skipGzip = !zlib.gzip || !requestedFormats.has('gz'),
  skipUncompressed = !requestedFormats.has('none'),
  napiDirect = getParam('napi'),
  napiEnvVar = getParam('napi-var') || 'DOWNLOAD_NAPI';

const napiLevel = napiDirect || process.env[napiEnvVar] || '';
const abiSlot = napiLevel ? `napi-v${napiLevel}` : process.versions.modules;

const main = async () => {
  const [OWNER, REPO] = process.env.GITHUB_REPOSITORY.split('/'),
    TAG = /^refs\/tags\/(.*)$/.exec(process.env.GITHUB_REF)[1],
    TOKEN = process.env.GITHUB_TOKEN,
    PERSONAL_TOKEN = process.env.PERSONAL_TOKEN;

  const fileName = `${prefix}${platform}-${process.arch}-${abiSlot}${suffix}`;

  console.log('Preparing artifact', fileName, '...');

  const apiBase = process.env.GITHUB_API_URL || 'https://api.github.com';
  const releaseUrl = new URL(`/repos/${encodeURIComponent(OWNER)}/${encodeURIComponent(REPO)}/releases/tags/${encodeURIComponent(TAG)}`, apiBase);
  const [data, uploadUrl] = await Promise.all([
    fsp.readFile(path.normalize(artifactPath)),
    get(releaseUrl, {
      auth: TOKEN ? OWNER + ':' + TOKEN : null,
      headers: {
        Accept: 'application/vnd.github.v3+json',
        'User-Agent': 'uhop/install-artifact-from-github',
        Authorization: !TOKEN && PERSONAL_TOKEN ? 'Bearer ' + PERSONAL_TOKEN : null
      }
    }).then(response => {
      const data = JSON.parse(response.data.toString()),
        p = data.upload_url.indexOf('{');
      return p > 0 ? data.upload_url.substr(0, p) : data.upload_url;
    })
  ]);

  const postArtifact = (name, label, data, contentType = 'application/octet-stream') =>
    post(
      withParams(uploadUrl, {name, label}),
      {
        auth: TOKEN ? OWNER + ':' + TOKEN : null,
        headers: {
          Accept: 'application/vnd.github.v3+json',
          'Content-Type': contentType,
          'Content-Length': data.length,
          'User-Agent': 'uhop/install-artifact-from-github',
          Authorization: !TOKEN && PERSONAL_TOKEN ? 'Bearer ' + PERSONAL_TOKEN : null
        }
      },
      data
    );

  console.log('Compressing and uploading ...');

  await Promise.all([
    (async () => {
      if (skipBrotli) return null;
      const compressed = await promisify(zlib.brotliCompress)(data, {params: {[zlib.constants.BROTLI_PARAM_QUALITY]: zlib.constants.BROTLI_MAX_QUALITY}}),
        name = fileName + '.br',
        label = `Binary artifact: ${artifactPath} (${platform}, ${process.arch}, ${abiSlot}, brotli).`;
      return postArtifact(name, label, compressed, 'application/brotli')
        .then(({res}) => console.log('Uploaded BR:', res.statusCode))
        .catch(error => console.error('BR has failed to upload:', error));
    })(),
    (async () => {
      if (skipGzip) return null;
      const compressed = await promisify(zlib.gzip)(data, {level: zlib.constants.Z_BEST_COMPRESSION}),
        name = fileName + '.gz',
        label = `Binary artifact: ${artifactPath} (${platform}, ${process.arch}, ${abiSlot}, gzip).`;
      return postArtifact(name, label, compressed, 'application/gzip')
        .then(({res}) => console.log('Uploaded GZ:', res.statusCode))
        .catch(error => console.error('GZ has failed to upload:', error));
    })(),
    (async () => {
      if (skipUncompressed) return null;
      const label = `Binary artifact: ${artifactPath} (${platform}, ${process.arch}, ${abiSlot}, uncompressed).`;
      return postArtifact(fileName, label, data)
        .then(({res}) => console.log('Uploaded Uncompressed:', res.statusCode))
        .catch(error => console.error('Uncompressed has failed to upload:', error));
    })()
  ]);
  if (process.env.GITHUB_ENV) await fsp.appendFile(process.env.GITHUB_ENV, 'CREATED_ASSET_NAME=' + fileName + EOL);
  console.log('Done.');
};

main().catch(error => {
  console.log('::error::' + ((error && error.message) || 'save-to-github-cache has failed'));
  process.exit(1);
});
