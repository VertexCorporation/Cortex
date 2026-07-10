"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkListenable = checkListenable;
exports.waitForPortUsed = waitForPortUsed;
exports.resolveHostAndAssignPorts = resolveHostAndAssignPorts;
exports.listenSpecsToString = listenSpecsToString;
const clc = require("colorette");
const tcpport = require("tcp-port-used");
const node_net_1 = require("node:net");
const error_1 = require("../error");
const utils = require("../utils");
const dns_1 = require("./dns");
const types_1 = require("./types");
const constants_1 = require("./constants");
const emulatorLogger_1 = require("./emulatorLogger");
const node_child_process_1 = require("node:child_process");
const RESTRICTED_PORTS = new Set([
    1,
    7,
    9,
    11,
    13,
    15,
    17,
    19,
    20,
    21,
    22,
    23,
    25,
    37,
    42,
    43,
    53,
    77,
    79,
    87,
    95,
    101,
    102,
    103,
    104,
    109,
    110,
    111,
    113,
    115,
    117,
    119,
    123,
    135,
    139,
    143,
    179,
    389,
    427,
    465,
    512,
    513,
    514,
    515,
    526,
    530,
    531,
    532,
    540,
    548,
    556,
    563,
    587,
    601,
    636,
    993,
    995,
    2049,
    3659,
    4045,
    6000,
    6665,
    6666,
    6667,
    6668,
    6669,
    6697,
]);
function isRestricted(port) {
    return RESTRICTED_PORTS.has(port);
}
function suggestUnrestricted(port) {
    if (!isRestricted(port)) {
        return port;
    }
    let newPort = port;
    while (isRestricted(newPort)) {
        newPort++;
    }
    return newPort;
}
async function checkListenable(arg1, port) {
    const addr = port === undefined ? arg1 : listenSpec(arg1, port);
    return new Promise((resolve, reject) => {
        if (process.platform === "darwin") {
            try {
                (0, node_child_process_1.execSync)(`lsof -i :${addr.port} -sTCP:LISTEN`);
                return resolve(false);
            }
            catch (e) {
            }
        }
        const dummyServer = (0, node_net_1.createServer)();
        dummyServer.once("error", (err) => {
            dummyServer.removeAllListeners();
            const e = err;
            if (e.code === "EADDRINUSE" || e.code === "EACCES") {
                resolve(false);
            }
            else {
                reject(e);
            }
        });
        dummyServer.once("listening", () => {
            dummyServer.removeAllListeners();
            dummyServer.close((err) => {
                dummyServer.removeAllListeners();
                if (err) {
                    reject(err);
                }
                else {
                    resolve(true);
                }
            });
        });
        dummyServer.listen({ host: addr.address, port: addr.port, ipv6Only: addr.family === "IPv6" });
    });
}
async function waitForPortUsed(port, host, timeout = 60000) {
    const interval = 200;
    try {
        await tcpport.waitUntilUsedOnHost(port, host, interval, timeout);
    }
    catch (e) {
        throw new error_1.FirebaseError(`TIMEOUT: Port ${port} on ${host} was not active within ${timeout}ms`);
    }
}
const EMULATOR_CAN_LISTEN_ON_PRIMARY_ONLY = {
    database: true,
    firestore: true,
    "firestore.websocket": true,
    pubsub: true,
    "dataconnect.postgres": true,
    dataconnect: false,
    hub: false,
    ui: false,
    auth: true,
    eventarc: true,
    extensions: true,
    functions: true,
    logging: true,
    storage: true,
    tasks: true,
    hosting: true,
    apphosting: true,
};
const MAX_PORT = 65535;
async function resolveHostAndAssignPorts(listenConfig) {
    const lookupForHost = new Map();
    const takenPorts = new Map();
    const result = {};
    const tasks = [];
    for (const name of Object.keys(listenConfig)) {
        const config = listenConfig[name];
        if (!config) {
            continue;
        }
        else if (config instanceof Array) {
            result[name] = config;
            for (const { port } of config) {
                takenPorts.set(port, name);
            }
            continue;
        }
        const { host, port, portFixed } = config;
        let lookup = lookupForHost.get(host);
        if (!lookup) {
            lookup = dns_1.Resolver.DEFAULT.lookupAll(host);
            lookupForHost.set(host, lookup);
        }
        const findAddrs = lookup.then(async (addrs) => {
            const emuLogger = emulatorLogger_1.EmulatorLogger.forEmulator(name === "firestore.websocket"
                ? types_1.Emulators.FIRESTORE
                : name === "dataconnect.postgres"
                    ? types_1.Emulators.DATACONNECT
                    : name);
            if (addrs.some((addr) => addr.address === dns_1.IPV6_UNSPECIFIED.address)) {
                if (!addrs.some((addr) => addr.address === dns_1.IPV4_UNSPECIFIED.address)) {
                    emuLogger.logLabeled("DEBUG", name, `testing listening on IPv4 wildcard in addition to IPv6. To listen on IPv6 only, use "::0" instead.`);
                    addrs.push(dns_1.IPV4_UNSPECIFIED);
                }
            }
            for (let p = port; p <= MAX_PORT; p++) {
                if (takenPorts.has(p)) {
                    continue;
                }
                if (!portFixed && RESTRICTED_PORTS.has(p)) {
                    emuLogger.logLabeled("DEBUG", name, `portUtils: skipping restricted port ${p}`);
                    continue;
                }
                if (p === 5001 && /^hosting/i.exec(name)) {
                    continue;
                }
                const available = [];
                const unavailable = [];
                let i;
                for (i = 0; i < addrs.length; i++) {
                    const addr = addrs[i];
                    const listen = listenSpec(addr, p);
                    let listenable;
                    try {
                        listenable = await checkListenable(listen);
                    }
                    catch (err) {
                        emuLogger.logLabeled("WARN", name, `Error when trying to check port ${p} on ${addr.address}: ${err}`);
                        unavailable.push(addr.address);
                        continue;
                    }
                    if (listenable) {
                        available.push(listen);
                    }
                    else {
                        if (!portFixed) {
                            if (i > 0) {
                                emuLogger.logLabeled("DEBUG", name, `Port ${p} taken on secondary address ${addr.address}, will keep searching to find a better port.`);
                            }
                            break;
                        }
                        unavailable.push(addr.address);
                    }
                }
                if (i === addrs.length) {
                    if (unavailable.length > 0) {
                        if (unavailable[0] === addrs[0].address) {
                            return fixedPortNotAvailable(name, host, port, emuLogger, unavailable);
                        }
                        warnPartiallyAvailablePort(emuLogger, port, available, unavailable);
                    }
                    if (takenPorts.has(p)) {
                        continue;
                    }
                    takenPorts.set(p, name);
                    if (RESTRICTED_PORTS.has(p)) {
                        const suggested = suggestUnrestricted(port);
                        emuLogger.logLabeled("WARN", name, `Port ${port} is restricted by some web browsers, including Chrome. You may want to choose a different port such as ${suggested}.`);
                    }
                    if (p !== port && name !== "firestore.websocket") {
                        emuLogger.logLabeled("WARN", `${portDescription(name)} unable to start on port ${port}, starting on ${p} instead.`);
                    }
                    if (available.length > 1 && EMULATOR_CAN_LISTEN_ON_PRIMARY_ONLY[name]) {
                        emuLogger.logLabeled("DEBUG", name, `${portDescription(name)} only supports listening on one address (${available[0].address}). Not listening on ${addrs
                            .slice(1)
                            .map((s) => s.address)
                            .join(",")}`);
                        result[name] = [available[0]];
                    }
                    else {
                        result[name] = available;
                    }
                    return;
                }
            }
            return utils.reject(`Could not find any open port in ${port}-${MAX_PORT} for ${portDescription(name)}`, {});
        });
        tasks.push(findAddrs);
    }
    await Promise.all(tasks);
    return result;
}
function portDescription(name) {
    return name === "firestore.websocket"
        ? `websocket server for ${types_1.Emulators.FIRESTORE}`
        : name === "dataconnect.postgres"
            ? `postgres server for ${types_1.Emulators.DATACONNECT}`
            : constants_1.Constants.description(name);
}
function warnPartiallyAvailablePort(emuLogger, port, available, unavailable) {
    emuLogger.logLabeled("WARN", `Port ${port} is available on ` +
        available.map((s) => s.address).join(",") +
        ` but not ${unavailable.join(",")}. This may cause issues with some clients.`);
    emuLogger.logLabeled("WARN", `If you encounter connectivity issues, consider switching to a different port or explicitly specifying ${clc.yellow('"host": "<ip address>"')} instead of hostname in firebase.json`);
}
function fixedPortNotAvailable(name, host, port, emuLogger, unavailableAddrs) {
    if (unavailableAddrs.length !== 1 || unavailableAddrs[0] !== host) {
        host = `${host} (${unavailableAddrs.join(",")})`;
    }
    const description = portDescription(name);
    emuLogger.logLabeled("WARN", `Port ${port} is not open on ${host}, could not start ${description}.`);
    if (name === "firestore.websocket") {
        emuLogger.logLabeled("WARN", `To select a different port, specify that port in a firebase.json config file:
      {
        // ...
        "emulators": {
          "${types_1.Emulators.FIRESTORE}": {
            "host": "${clc.yellow("HOST")}",
            ...
            "websocketPort": "${clc.yellow("WEBSOCKET_PORT")}"
          }
        }
      }`);
    }
    else {
        emuLogger.logLabeled("WARN", `To select a different host/port, specify that host/port in a firebase.json config file:
      {
        // ...
        "emulators": {
          "${emuLogger.name}": {
            "host": "${clc.yellow("HOST")}",
            "port": "${clc.yellow("PORT")}"
          }
        }
      }`);
    }
    return utils.reject(`Could not start ${description}, port taken.`, {});
}
function listenSpec(lookup, port) {
    if (lookup.family !== 4 && lookup.family !== 6) {
        throw new Error(`Unsupported address family "${lookup.family}" for address ${lookup.address}.`);
    }
    return {
        address: lookup.address,
        family: lookup.family === 4 ? "IPv4" : "IPv6",
        port: port,
    };
}
function listenSpecsToString(specs) {
    return specs
        .map((spec) => {
        const host = spec.family === "IPv4" ? spec.address : `[${spec.address}]`;
        return `${host}:${spec.port}`;
    })
        .join(",");
}
