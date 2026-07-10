"use strict";
// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
Object.defineProperty(exports, "__esModule", { value: true });
exports.isSameInstance = isSameInstance;
exports.resolveInstanceName = resolveInstanceName;
exports.isValidDomainName = isValidDomainName;
exports.isInstanceConnectionName = isInstanceConnectionName;
exports.resolveDomainName = resolveDomainName;
exports.parseInstanceConnectionName = parseInstanceConnectionName;
const errors_1 = require("./errors");
const dns_lookup_1 = require("./dns-lookup");
function isSameInstance(a, b) {
    return (a.instanceId === b.instanceId &&
        a.regionId === b.regionId &&
        a.projectId === b.projectId &&
        a.domainName === b.domainName);
}
async function resolveInstanceName(instanceConnectionName, domainName) {
    if (!instanceConnectionName && !domainName) {
        throw new errors_1.CloudSQLConnectorError({
            message: 'Missing instance connection name, expected: "PROJECT:REGION:INSTANCE" or a valid domain name.',
            code: 'ENOCONNECTIONNAME',
        });
    }
    else if (instanceConnectionName &&
        isInstanceConnectionName(instanceConnectionName)) {
        return parseInstanceConnectionName(instanceConnectionName);
    }
    else if (domainName && isValidDomainName(domainName)) {
        return await resolveDomainName(domainName);
    }
    else {
        throw new errors_1.CloudSQLConnectorError({
            message: 'Malformed Instance connection name, expected an instance connection name in the form "PROJECT:REGION:INSTANCE" or a valid domain name',
            code: 'EBADCONNECTIONNAME',
        });
    }
}
const connectionNameRegex = /^(?<projectId>[^:]+(:[^:]+)?):(?<regionId>[^:]+):(?<instanceId>[^:]+)$/;
// The domain name pattern in accordance with RFC 1035, RFC 1123 and RFC 2181.
// From Go Connector:
const domainNameRegex = /^(?:[_a-z0-9](?:[_a-z0-9-]{0,61}[a-z0-9])?\.)+(?:[a-z](?:[a-z0-9-]{0,61}[a-z0-9])?)?$/;
function isValidDomainName(name) {
    const matches = String(name).match(domainNameRegex);
    return Boolean(matches);
}
function isInstanceConnectionName(name) {
    const matches = String(name).match(connectionNameRegex);
    return Boolean(matches);
}
async function resolveDomainName(name) {
    const icn = await (0, dns_lookup_1.resolveTxtRecord)(name);
    if (!isInstanceConnectionName(icn)) {
        throw new errors_1.CloudSQLConnectorError({
            message: 'Malformed instance connection name returned for domain ' +
                name +
                ' : ' +
                icn,
            code: 'EBADDOMAINCONNECTIONNAME',
        });
    }
    const info = parseInstanceConnectionName(icn);
    info.domainName = name;
    return info;
}
function parseInstanceConnectionName(instanceConnectionName) {
    if (!instanceConnectionName) {
        throw new errors_1.CloudSQLConnectorError({
            message: 'Missing instance connection name, expected: "PROJECT:REGION:INSTANCE"',
            code: 'ENOCONNECTIONNAME',
        });
    }
    const matches = String(instanceConnectionName).match(connectionNameRegex);
    if (!matches || !matches.groups) {
        throw new errors_1.CloudSQLConnectorError({
            message: 'Malformed instance connection name provided: expected format ' +
                `of "PROJECT:REGION:INSTANCE", got ${instanceConnectionName}`,
            code: 'EBADCONNECTIONNAME',
        });
    }
    return {
        projectId: matches.groups.projectId,
        regionId: matches.groups.regionId,
        instanceId: matches.groups.instanceId,
        domainName: undefined,
    };
}
//# sourceMappingURL=parse-instance-connection-name.js.map