"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Resolver = exports.IPV6_UNSPECIFIED = exports.IPV4_UNSPECIFIED = exports.IPV6_LOOPBACK = exports.IPV4_LOOPBACK = void 0;
const node_dns_1 = require("node:dns");
const node_net_1 = require("node:net");
const logger_1 = require("../logger");
exports.IPV4_LOOPBACK = { address: "127.0.0.1", family: 4 };
exports.IPV6_LOOPBACK = { address: "::1", family: 6 };
exports.IPV4_UNSPECIFIED = { address: "0.0.0.0", family: 4 };
exports.IPV6_UNSPECIFIED = { address: "::", family: 6 };
class Resolver {
    constructor(lookup = node_dns_1.promises.lookup) {
        this.lookup = lookup;
        this.cache = new Map([
            ["localhost", [exports.IPV4_LOOPBACK, exports.IPV6_LOOPBACK]],
        ]);
    }
    async lookupFirst(hostname) {
        const addresses = await this.lookupAll(hostname);
        if (addresses.length === 1) {
            return addresses[0];
        }
        const result = addresses[0];
        const discarded = [];
        for (let i = 1; i < addresses.length; i++) {
            discarded.push(result.address);
        }
        logger_1.logger.debug(`Resolved hostname "${hostname}" to the first result "${result.address}" (ignoring candidates: ${discarded.join(",")}).`);
        return result;
    }
    async lookupAll(hostname) {
        const family = (0, node_net_1.isIP)(hostname);
        if (family > 0) {
            return [{ family, address: hostname }];
        }
        const cached = this.cache.get(hostname);
        if (cached) {
            return cached;
        }
        const addresses = await this.lookup(hostname, {
            verbatim: false,
            all: true,
        });
        this.cache.set(hostname, addresses);
        return addresses;
    }
}
exports.Resolver = Resolver;
Resolver.DEFAULT = new Resolver();
