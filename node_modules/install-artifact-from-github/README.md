# install-artifact-from-github [![NPM version][npm-img]][npm-url]

[npm-img]: https://img.shields.io/npm/v/install-artifact-from-github.svg
[npm-url]: https://npmjs.org/package/install-artifact-from-github

This is a no-dependency micro helper for developers of binary addons for Node. It is literally three small one-file utilities integrated with [GitHub releases](https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/about-releases):

- [save-to-github-cache](https://github.com/uhop/install-artifact-from-github/wiki/save‐to‐github‐cache) saves a binary artifact to a GitHub release according to the platform, architecture, and Node ABI (or N-API level).
  - Designed to be used with [GitHub actions](https://github.com/features/actions).
- [install-from-cache](https://github.com/uhop/install-artifact-from-github/wiki/install‐from‐cache) retrieves a previously saved artifact, optionally verifies its integrity, tests if it works properly, and rebuilds a project from sources in the case of failure.
- _(since 1.7.0)_ [hash-github-cache](https://github.com/uhop/install-artifact-from-github/wiki/hash‐github‐cache) records the SHA-256 of each published artifact into the addon's `package.json` so `install-from-cache` can verify downloads against it.

In general, it can save your users from a long recompilation and, in some cases, even save them from installing build tools.
By using GitHub facilities ([Releases](https://docs.github.com/en/github/administering-a-repository/about-releases)
and [Actions](https://github.com/features/actions)) the whole process of publishing and subsequent installations are secure,
transparent, painless, inexpensive, or even free for public repositories.

## How to install

Installation:

```
npm install --save install-artifact-from-github
```

## How to use

In your `package.json` (pseudo-code with comments):

```js
{
  // your custom package.json stuff
  // ...
  "scripts": {
    // your scripts go here
    // ...

    // saves an artifact
    "save-to-github": "save-to-github-cache --artifact build/Release/ABC.node",

    // installs using pre-created artifacts
    "install": "install-from-cache --artifact build/Release/ABC.node",

    // used by "install" to test the artifact
    "verify-build": "node scripts/verify-build.js",

    // used by "install" to rebuild from sources
    "rebuild": "node-gyp rebuild"
  }
}
```

Examples of GitHub actions can be found in the documentation.

## Verifying downloads (since 1.7.0)

`install-from-cache` can check that a downloaded binary is byte-for-byte the one you published &mdash; closing the gap where a network-downloaded artifact is trusted with no integrity check. It is opt-in and adds no dependency.

You pin a hash bag in your addon's `package.json` and let `hash-github-cache` maintain it, typically from a `prepublishOnly` hook:

```json
{
  "scripts": {
    "prepublishOnly": "hash-github-cache --write"
  }
}
```

On `npm publish`, `hash-github-cache` hashes the release's assets and stamps an `artifactHashes` map (`{"linux-x64-137": "sha256:...", ...}`) into the packed `package.json`. Because that map ships in your **immutable npm tarball**, someone who swaps a GitHub release asset after publish cannot also rewrite the expected hash &mdash; so `install-from-cache` rejects the swapped binary and rebuilds from source instead. Verification runs only for downloads from GitHub itself; a custom mirror (`--host` / `DOWNLOAD_HOST`) serves the deployer's own build and is intentionally not checked.

To skip the prebuilt download entirely and always build from source (trusting only npm plus your own toolchain), set `--force-build` (or the `DOWNLOAD_FORCE_BUILD` environment variable).

See [Verifying artifacts](https://github.com/uhop/install-artifact-from-github/wiki/Verifying-artifacts) for the full picture.

## npm 12: install scripts require approval

Starting with npm 12 (July 2026), npm does not run dependency lifecycle scripts by default &mdash; and `install-from-cache` runs as your package's `install` script. Users of your addon have to approve it once (`npm approve-scripts <your-package>`), or neither the prebuilt download nor the `node-gyp` fallback will run. Document that step in your install instructions. See [NPM 12 and install scripts](https://github.com/uhop/install-artifact-from-github/wiki/NPM-12-and-install-scripts) for the full story.

## Documentation

The full documentation is available in the [wiki](https://github.com/uhop/install-artifact-from-github/wiki).

## Release history

- 1.7.0 _added optional artifact integrity verification: a new `hash-github-cache` bin records each published binary's SHA-256 into the addon's `package.json` (`artifactHashes`), and `install-from-cache` verifies downloads against it before use. Added `--force-build` / `--force-build-var` / `DOWNLOAD_FORCE_BUILD` to skip the download and build from sources._
- 1.6.0 _added N-API support: `--napi` / `--napi-var` / `DOWNLOAD_NAPI` swap the URL slot from `${abi}` to `napi-v${level}`, collapsing the per-Node-major build matrix._
- 1.5.0 _added optional proxy support via `--agent` / `--agent-var` / `DOWNLOAD_AGENT`; converted to ESM; added an automated test suite; minimum Node bumped to 18._
- 1.4.0 _added support for uncompresed artifacts and selective compression format._
- 1.3.5 _propagated the previous timeout fix to the saving utility._
- 1.3.4 _minor fixes + a timeout fix: use a new default agent for GET. Thx, [Laura Hausmann](https://github.com/zotanmew)._
- 1.3.3 _minor refactor, added support for a personal token._
- 1.3.2 _added support for the 204 response and error logging._
- 1.3.1 _added a way to specify a custom build, thx [Grisha Pushkov](https://github.com/reepush) + a test._
- 1.3.0 _enhanced support for custom mirrors._

The full release history with dates is in the wiki: [Release notes](https://github.com/uhop/install-artifact-from-github/wiki/Release-notes).

## License

BSD-3-Clause &mdash; see [LICENSE](./LICENSE).
