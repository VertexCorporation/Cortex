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
exports.Connector = void 0;
const node_net_1 = require("node:net");
const node_util_1 = require("node:util");
const cloud_sql_instance_1 = require("./cloud-sql-instance");
const socket_1 = require("./socket");
const ip_addresses_1 = require("./ip-addresses");
const auth_types_1 = require("./auth-types");
const sqladmin_fetcher_1 = require("./sqladmin-fetcher");
const errors_1 = require("./errors");
// CacheEntry holds the promise and resolved instance metadata for
// the connector's instances. The instance field will be set when
// the promise resolves.
class CacheEntry {
    constructor(promise) {
        this.promise = promise;
        this.promise
            .then(inst => (this.instance = inst))
            .catch(err => (this.err = err));
    }
    isResolved() {
        return Boolean(this.instance);
    }
    isError() {
        return Boolean(this.err);
    }
}
// Internal mapping of the CloudSQLInstances that
// adds extra logic to async initialize items.
class CloudSQLInstanceMap extends Map {
    constructor(sqlAdminFetcher) {
        super();
        this.sqlAdminFetcher = sqlAdminFetcher;
    }
    cacheKey(opts) {
        //TODO: for now, the cache key function must be synchronous.
        //  When we implement the async connection info from
        //  https://github.com/GoogleCloudPlatform/cloud-sql-nodejs-connector/pull/426
        //  then the cache key should contain both the domain name
        //  and the resolved instance name.
        return ((opts.instanceConnectionName || opts.domainName) +
            '-' +
            opts.authType +
            '-' +
            opts.ipType);
    }
    async loadInstance(opts) {
        var _a, _b;
        // in case an instance to that connection name has already
        // been setup there's no need to set it up again
        const key = this.cacheKey(opts);
        const entry = this.get(key);
        if (entry) {
            if (entry.isResolved()) {
                await ((_a = entry.instance) === null || _a === void 0 ? void 0 : _a.checkDomainChanged());
                if (!((_b = entry.instance) === null || _b === void 0 ? void 0 : _b.isClosed())) {
                    // The instance is open and the domain has not changed.
                    // use the cached instance.
                    return;
                }
            }
            else if (entry.isError()) {
                // The instance failed it's initial refresh. Remove it from the
                // cache and throw the error.
                this.delete(key);
                throw entry.err;
            }
            else {
                // The instance initial refresh is in progress.
                await entry.promise;
                return;
            }
        }
        // Start the refresh and add a cache entry.
        const promise = cloud_sql_instance_1.CloudSQLInstance.getCloudSQLInstance({
            instanceConnectionName: opts.instanceConnectionName,
            domainName: opts.domainName,
            authType: opts.authType || auth_types_1.AuthTypes.PASSWORD,
            ipType: opts.ipType || ip_addresses_1.IpAddressTypes.PUBLIC,
            limitRateInterval: opts.limitRateInterval || 30 * 1000, // 30 sec
            sqlAdminFetcher: this.sqlAdminFetcher,
            failoverPeriod: opts.failoverPeriod,
        });
        this.set(key, new CacheEntry(promise));
        // Wait for the cache entry to resolve.
        await promise;
    }
    getInstance(opts) {
        const connectionInstance = this.get(this.cacheKey(opts));
        if (!connectionInstance || !connectionInstance.instance) {
            throw new errors_1.CloudSQLConnectorError({
                message: `Cannot find info for instance: ${opts.instanceConnectionName}`,
                code: 'ENOINSTANCEINFO',
            });
        }
        return connectionInstance.instance;
    }
}
// The Connector class is the main public API to interact
// with the Cloud SQL Node.js Connector.
class Connector {
    constructor(opts = {}) {
        this.sqlAdminFetcher = new sqladmin_fetcher_1.SQLAdminFetcher({
            loginAuth: opts.auth,
            sqlAdminAPIEndpoint: opts.sqlAdminAPIEndpoint,
            universeDomain: opts.universeDomain,
            userAgent: opts.userAgent,
        });
        this.instances = new CloudSQLInstanceMap(this.sqlAdminFetcher);
        this.localProxies = new Set();
        this.sockets = new Set();
    }
    // Connector.getOptions is a method that accepts a Cloud SQL instance
    // connection name along with the connection type and returns an object
    // that can be used to configure a driver to be used with Cloud SQL. e.g:
    //
    // const connector = new Connector()
    // const opts = await connector.getOptions({
    //   ipType: 'PUBLIC',
    //   instanceConnectionName: 'PROJECT:REGION:INSTANCE',
    // });
    // const pool = new Pool(opts)
    // const res = await pool.query('SELECT * FROM pg_catalog.pg_tables;')
    async getOptions(opts) {
        const { instances } = this;
        await instances.loadInstance(opts);
        return {
            stream() {
                const cloudSqlInstance = instances.getInstance(opts);
                const { instanceInfo, ephemeralCert, host, port, privateKey, serverCaCert, dnsName, } = cloudSqlInstance;
                if (instanceInfo &&
                    ephemeralCert &&
                    host &&
                    port &&
                    privateKey &&
                    serverCaCert) {
                    const tlsSocket = (0, socket_1.getSocket)({
                        instanceInfo,
                        ephemeralCert,
                        host,
                        port,
                        privateKey,
                        serverCaCert,
                        instanceDnsName: dnsName,
                        serverName: instanceInfo.domainName || dnsName, // use the configured domain name, or the instance dnsName.
                    });
                    tlsSocket.once('error', () => {
                        cloudSqlInstance.forceRefresh();
                    });
                    tlsSocket.once('secureConnect', async () => {
                        cloudSqlInstance.setEstablishedConnection();
                    });
                    cloudSqlInstance.addSocket(tlsSocket);
                    return tlsSocket;
                }
                throw new errors_1.CloudSQLConnectorError({
                    message: 'Invalid Cloud SQL Instance info',
                    code: 'EBADINSTANCEINFO',
                });
            },
        };
    }
    async getTediousOptions({ authType, ipType, instanceConnectionName, }) {
        if (authType === auth_types_1.AuthTypes.IAM) {
            throw new errors_1.CloudSQLConnectorError({
                message: 'Tedious does not support Auto IAM DB Authentication',
                code: 'ENOIAM',
            });
        }
        const driverOptions = await this.getOptions({
            authType,
            ipType,
            instanceConnectionName,
        });
        return {
            async connector() {
                return driverOptions.stream();
            },
            // note: the connector handles a secured encrypted connection
            // with that in mind, the driver encryption is disabled here
            encrypt: false,
        };
    }
    // Connector.startLocalProxy is an alternative to Connector.getOptions that
    // creates a local Unix domain socket to listen and proxy data to and from a
    // Cloud SQL instance. Can be used alongside a database driver or ORM e.g:
    //
    // const path = resolve('.s.PGSQL.5432'); // postgres-required socket filename
    // const connector = new Connector();
    // await connector.startLocalProxy({
    //   instanceConnectionName,
    //   ipType: 'PUBLIC',
    //   listenOptions: {path},
    // });
    // const datasourceUrl =
    //  `postgresql://${user}@localhost/${database}?host=${process.cwd()}`;
    // const prisma = new PrismaClient({ datasourceUrl });
    async startLocalProxy({ authType, ipType, instanceConnectionName, listenOptions, }) {
        const { stream } = await this.getOptions({
            authType,
            ipType,
            instanceConnectionName,
        });
        // Opens a local server that listens
        // to the location defined by `listenOptions`
        const server = (0, node_net_1.createServer)();
        this.localProxies.add(server);
        /* c8 ignore next 3 */
        server.once('error', err => {
            console.error(err);
        });
        // When a connection is established, pipe data from the
        // local proxy server to the secure TCP Socket and vice-versa.
        server.on('connection', c => {
            const s = stream();
            this.sockets.add(s);
            this.sockets.add(c);
            c.pipe(s);
            s.pipe(c);
        });
        const listen = (0, node_util_1.promisify)(server.listen);
        await listen.call(server, {
            path: listenOptions.path,
            readableAll: listenOptions.readableAll,
            writableAll: listenOptions.writableAll,
        });
    }
    // Clear up the event loop from the internal cloud sql
    // instances timeout callbacks that refreshs instance info.
    //
    // Also clear up any local proxy servers and socket connections.
    close() {
        for (const instance of this.instances.values()) {
            instance.promise.then(inst => inst.close());
        }
        for (const server of this.localProxies) {
            server.close();
        }
        for (const socket of this.sockets) {
            socket.destroy();
        }
    }
}
exports.Connector = Connector;
//# sourceMappingURL=connector.js.map