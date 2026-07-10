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
import { IpAddressTypes, selectIpAddress } from './ip-addresses.js';
import { isSameInstance, resolveInstanceName, } from './parse-instance-connection-name.js';
import { resolveARecord } from './dns-lookup.js';
import { generateKeys } from './crypto.js';
import { getRefreshInterval, isExpirationTimeValid } from './time.js';
import { AuthTypes } from './auth-types.js';
import { CloudSQLConnectorError } from './errors.js';
export class CloudSQLInstance {
    static async getCloudSQLInstance(options) {
        const instanceInfo = await resolveInstanceName(options.instanceConnectionName, options.domainName);
        const instance = new CloudSQLInstance({
            options: options,
            instanceInfo,
        });
        await instance.refresh();
        return instance;
    }
    constructor({ options, instanceInfo, }) {
        this.establishedConnection = false;
        this.scheduledRefreshID = undefined;
        this.checkDomainID = undefined;
        this.closed = false;
        this.sockets = new Set();
        this.port = 3307;
        this.serverCaMode = '';
        this.dnsName = '';
        this.instanceInfo = instanceInfo;
        this.authType = options.authType || AuthTypes.PASSWORD;
        this.ipType = options.ipType || IpAddressTypes.PUBLIC;
        this.limitRateInterval = options.limitRateInterval || 30 * 1000; // 30 seconds
        this.sqlAdminFetcher = options.sqlAdminFetcher;
        this.failoverPeriod = options.failoverPeriod || 30 * 1000; // 30 seconds
    }
    // p-throttle library has to be initialized in an async scope in order to
    // use dynamic import so that it's also compatible with CommonJS
    async initializeRateLimiter() {
        if (this.throttle) {
            return;
        }
        const pThrottle = (await import('p-throttle')).default;
        this.throttle = pThrottle({
            limit: 1,
            interval: this.limitRateInterval,
            strict: true,
        });
    }
    forceRefresh() {
        // if a refresh is already ongoing, just await for its promise to fulfill
        // so that a new instance info is available before reconnecting
        if (this.next) {
            return new Promise(resolve => {
                if (this.next) {
                    this.next.finally(resolve);
                }
                else {
                    resolve();
                }
            });
        }
        this.cancelRefresh();
        this.scheduleRefresh(0);
        return new Promise(resolve => {
            // setTimeout() to yield execution to allow other refresh background
            // task to start.
            setTimeout(() => {
                if (this.next) {
                    // If there is a refresh promise in progress, resolve this promise
                    // when the refresh is complete.
                    this.next.finally(resolve);
                }
                else {
                    // Else resolve immediately.
                    resolve();
                }
            }, 0);
        });
    }
    refresh() {
        var _a;
        if (this.closed) {
            this.scheduledRefreshID = undefined;
            this.next = undefined;
            return Promise.reject('closed');
        }
        // Lazy instantiation of the checkDomain interval on the first refresh
        // This avoids issues with test cases that instantiate a CloudSqlInstance.
        // If failoverPeriod is 0 (or negative) don't check for DNS updates.
        if (((_a = this === null || this === void 0 ? void 0 : this.instanceInfo) === null || _a === void 0 ? void 0 : _a.domainName) &&
            !this.checkDomainID &&
            this.failoverPeriod > 0) {
            this.checkDomainID = setInterval(() => {
                this.checkDomainChanged();
            }, this.failoverPeriod);
        }
        const currentRefreshId = this.scheduledRefreshID;
        // Since forceRefresh might be invoked during an ongoing refresh
        // we keep track of the ongoing promise in order to be able to await
        // for it in the forceRefresh method.
        // In case the throttle mechanism is already initialized, we add the
        // extra wait time `limitRateInterval` in order to limit the rate of
        // requests to Cloud SQL Admin APIs.
        this.next = (this.throttle && this.scheduledRefreshID
            ? this.throttle(this.performRefresh).call(this)
            : this.performRefresh())
            // These needs to be part of the chain of promise referenced in
            // next in order to avoid race conditions
            .then((nextValues) => {
            var _a;
            // in case the id at the moment of starting this refresh cycle has
            // changed, that means that it has been canceled
            if (currentRefreshId !== this.scheduledRefreshID) {
                return;
            }
            // In case the performRefresh method succeeded
            // then we go ahead and update values
            this.updateValues(nextValues);
            const refreshInterval = getRefreshInterval(
            /* c8 ignore next */
            String((_a = this.ephemeralCert) === null || _a === void 0 ? void 0 : _a.expirationTime));
            this.scheduleRefresh(refreshInterval);
            // This is the end of the successful refresh chain, so now
            // we release the reference to the next
            this.next = undefined;
        })
            .catch((err) => {
            // In case there's already an active connection we won't throw
            // refresh errors to the final user, scheduling a new
            // immediate refresh instead.
            if (this.establishedConnection) {
                if (currentRefreshId === this.scheduledRefreshID) {
                    this.scheduleRefresh(0);
                }
            }
            else {
                throw err;
            }
            // This refresh cycle has failed, releases ref to next
            this.next = undefined;
        })
            // The rate limiter needs to be initialized _after_ assigning a ref
            // to next in order to avoid race conditions with
            // the forceRefresh check that ensures a refresh cycle is not ongoing
            .then(() => {
            this.initializeRateLimiter();
        });
        return this.next;
    }
    // The performRefresh method will perform all the necessary async steps
    // in order to get a new set of values for an instance that can then be
    // used to create new connections to a Cloud SQL instance. It throws in
    // case any of the internal steps fails.
    async performRefresh() {
        if (this.closed) {
            // The connector may be closed while the rate limiter delayed
            // a call to performRefresh() so check this.closed before continuing.
            return Promise.reject('closed');
        }
        const rsaKeys = await generateKeys();
        const metadata = await this.sqlAdminFetcher.getInstanceMetadata(this.instanceInfo);
        const ephemeralCert = await this.sqlAdminFetcher.getEphemeralCertificate(this.instanceInfo, rsaKeys.publicKey, this.authType);
        let host;
        if (this.instanceInfo && this.instanceInfo.domainName) {
            try {
                const ips = await resolveARecord(this.instanceInfo.domainName);
                if (ips && ips.length > 0) {
                    host = ips[0];
                }
            }
            catch (e) {
                // ignore error, fallback to metadata IP
            }
        }
        if (!host) {
            host = selectIpAddress(metadata.ipAddresses, this.ipType);
        }
        const privateKey = rsaKeys.privateKey;
        const serverCaCert = metadata.serverCaCert;
        this.serverCaMode = metadata.serverCaMode;
        this.dnsName = metadata.dnsName;
        const currentValues = {
            ephemeralCert: this.ephemeralCert,
            host: this.host,
            privateKey: this.privateKey,
            serverCaCert: this.serverCaCert,
        };
        const nextValues = {
            ephemeralCert,
            host,
            privateKey,
            serverCaCert,
        };
        // In the rather odd case that the current ephemeral certificate is still
        // valid while we get an invalid result from the API calls, then preserve
        // the current metadata.
        if (this.isValid(currentValues) && !this.isValid(nextValues)) {
            return currentValues;
        }
        return nextValues;
    }
    isValid({ ephemeralCert, host, privateKey, serverCaCert, }) {
        if (!ephemeralCert || !host || !privateKey || !serverCaCert) {
            return false;
        }
        return isExpirationTimeValid(ephemeralCert.expirationTime);
    }
    updateValues(nextValues) {
        const { ephemeralCert, host, privateKey, serverCaCert } = nextValues;
        this.ephemeralCert = ephemeralCert;
        this.host = host;
        this.privateKey = privateKey;
        this.serverCaCert = serverCaCert;
    }
    scheduleRefresh(delay) {
        if (this.closed) {
            return;
        }
        this.scheduledRefreshID = setTimeout(() => this.refresh(), delay);
    }
    cancelRefresh() {
        // If refresh has not yet started, then cancel the setTimeout
        if (this.scheduledRefreshID) {
            clearTimeout(this.scheduledRefreshID);
        }
        this.scheduledRefreshID = null;
    }
    // Mark this instance as having an active connection. This is important to
    // ensure any possible errors thrown during a future refresh cycle should
    // not be thrown to the final user.
    setEstablishedConnection() {
        this.establishedConnection = true;
    }
    // close stops any refresh process in progress and prevents future refresh
    // connections.
    close() {
        this.closed = true;
        this.cancelRefresh();
        if (this.checkDomainID) {
            clearInterval(this.checkDomainID);
            this.checkDomainID = null;
        }
        for (const socket of this.sockets) {
            socket.destroy(new CloudSQLConnectorError({
                code: 'ERRCLOSED',
                message: 'The connector was closed.',
            }));
        }
    }
    isClosed() {
        return this.closed;
    }
    async checkDomainChanged() {
        if (!this.instanceInfo.domainName) {
            return;
        }
        const newInfo = await resolveInstanceName(undefined, this.instanceInfo.domainName);
        if (!isSameInstance(this.instanceInfo, newInfo)) {
            // Domain name changed. Close and remove, then create a new map entry.
            this.close();
        }
    }
    addSocket(socket) {
        if (!this.instanceInfo.domainName) {
            // This was not connected by domain name. Ignore all sockets.
            return;
        }
        // Add the socket to the list
        this.sockets.add(socket);
        // When the socket is closed, remove it.
        socket.once('closed', () => {
            this.sockets.delete(socket);
        });
    }
}
//# sourceMappingURL=cloud-sql-instance.js.map