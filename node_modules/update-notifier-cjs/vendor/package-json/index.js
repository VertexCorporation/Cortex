'use strict';
const ver = Number(process.version.split('.')[0].replace(/v/,''))
const old = ver < 18
if (old || !fetch) {
	require('isomorphic-fetch');
}
const registryUrl = require('registry-url');
const registryAuthToken = require('registry-auth-token');
const semver = require('semver');

class PackageNotFoundError extends Error {
	constructor(packageName) {
		super(`Package \`${packageName}\` could not be found`);
		this.name = 'PackageNotFoundError';
	}
}

class VersionNotFoundError extends Error {
	constructor(packageName, version) {
		super(`Version \`${version}\` for package \`${packageName}\` could not be found`);
		this.name = 'VersionNotFoundError';
	}
}

const packageJson = async (packageName, options) => {
	options = {
		version: 'latest',
		...options
	};

	const scope = packageName.split('/')[0];
	const registryUrl_ = options.registryUrl || registryUrl(scope);
	const packageUrl = new URL(encodeURIComponent(packageName).replace(/^%40/, '@'), registryUrl_);
	const authInfo = registryAuthToken(registryUrl_.toString(), {recursive: true});

	const headers = {
		accept: 'application/vnd.npm.install-v1+json; q=1.0, application/json; q=0.8, */*'
	};

	if (options.fullMetadata) {
		delete headers.accept;
	}

	if (authInfo) {
		headers.authorization = `${authInfo.type} ${authInfo.token}`;
	}

	let data;
	try {
		data = await fetch(packageUrl, { keepAlive: true, keepalive: true, headers }).then(r => r.json());
	} catch (error) {
		if (error.response.statusCode === 404) {
			throw new PackageNotFoundError(packageName);
		}

		throw error;
	}

	if (options.allVersions) {
		return data;
	}

	let {version} = options;
	const versionError = new VersionNotFoundError(packageName, version);

	if (data['dist-tags'][version]) {
		data = data.versions[data['dist-tags'][version]];
	} else if (version) {
		if (!data.versions[version]) {
			const versions = Object.keys(data.versions);
			version = semver.maxSatisfying(versions, version);

			if (!version) {
				throw versionError;
			}
		}

		data = data.versions[version];

		if (!data) {
			throw versionError;
		}
	}

	return data;
};

module.exports = packageJson;
// TODO: remove this in the next major version
module.exports.default = packageJson;
module.exports.PackageNotFoundError = PackageNotFoundError;
module.exports.VersionNotFoundError = VersionNotFoundError;
