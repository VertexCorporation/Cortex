"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.HTTPS_SENTINEL = void 0;
const crypto_1 = require("crypto");
const encodeFirestoreValue_1 = require("./firestore/encodeFirestoreValue");
const utils = require("./utils");
const apiv2_1 = require("./apiv2");
exports.HTTPS_SENTINEL = "Request sent to function.";
class LocalFunction {
    constructor(trigger, urls, controller) {
        this.trigger = trigger;
        this.controller = controller;
        this.paramWildcardRegex = new RegExp("{[^/{}]*}", "g");
        this.url = urls[trigger.id];
    }
    substituteParams(resource, params) {
        if (!params) {
            return resource;
        }
        return resource.replace(this.paramWildcardRegex, (wildcard) => {
            const wildcardNoBraces = wildcard.slice(1, -1);
            const sub = params?.[wildcardNoBraces];
            return sub || wildcardNoBraces + utils.randomInt(1, 9);
        });
    }
    constructCallableFunc(data, opts) {
        opts = opts || {};
        const headers = {};
        if (opts.instanceIdToken) {
            headers["Firebase-Instance-ID-Token"] = opts.instanceIdToken;
        }
        if (!this.url) {
            throw new Error("No URL provided");
        }
        const client = new apiv2_1.Client({ urlPrefix: this.url, auth: false });
        void client
            .post("", data, { headers })
            .then((res) => {
            this.requestCallBack(undefined, res, res.body);
        })
            .catch((err) => {
            this.requestCallBack(err);
        });
    }
    constructHttpsFunc() {
        if (!this.url) {
            throw new Error("No URL provided");
        }
        const callClient = new apiv2_1.Client({ urlPrefix: this.url, auth: false });
        const verbFactory = (hasRequestBody, method) => {
            return async (pathOrOptions, options) => {
                const { path, opts } = this.extractArgs(pathOrOptions, options);
                try {
                    const res = hasRequestBody
                        ? await method(path, opts.body, toClientVerbOptions(opts))
                        : await method(path, toClientVerbOptions(opts));
                    this.requestCallBack(undefined, res, res.body);
                }
                catch (err) {
                    this.requestCallBack(err);
                }
                return exports.HTTPS_SENTINEL;
            };
        };
        const shim = verbFactory(true, (path, json, opts) => {
            const req = Object.assign(opts || {}, {
                path: path,
                body: json,
                method: opts?.method || "GET",
            });
            return callClient.request(req);
        });
        const verbs = {
            post: verbFactory(true, (path, json, opts) => callClient.post(path, json, opts)),
            put: verbFactory(true, (path, json, opts) => callClient.put(path, json, opts)),
            patch: verbFactory(true, (path, json, opts) => callClient.patch(path, json, opts)),
            get: verbFactory(false, (path, opts) => callClient.get(path, opts)),
            del: verbFactory(false, (path, opts) => callClient.delete(path, opts)),
            delete: verbFactory(false, (path, opts) => callClient.delete(path, opts)),
            options: verbFactory(false, (path, opts) => callClient.options(path, opts)),
        };
        return Object.assign(shim, verbs);
    }
    extractArgs(pathOrOptions, options) {
        if (!pathOrOptions && !options) {
            return { path: "/", opts: {} };
        }
        if (typeof pathOrOptions === "string") {
            return { path: pathOrOptions, opts: options || {} };
        }
        if (typeof pathOrOptions !== "string" && !!pathOrOptions && !options) {
            return { path: "/", opts: pathOrOptions };
        }
        if (typeof pathOrOptions !== "string" || !options) {
            throw new Error(`Invalid argument combination: Expected a string and/or HttpsOptions, got ${typeof pathOrOptions} and ${typeof options}`);
        }
        return { path: "/", opts: {} };
    }
    constructAuth(auth, authType) {
        if (auth?.admin || auth?.variable) {
            return {
                admin: auth.admin || false,
                variable: auth.variable,
            };
        }
        if (authType) {
            switch (authType) {
                case "USER":
                    return {
                        admin: false,
                        variable: {
                            uid: auth?.uid ?? "",
                            token: auth?.token ?? {},
                        },
                    };
                case "ADMIN":
                    if (auth?.uid || auth?.token) {
                        throw new Error("authType and auth are incompatible.");
                    }
                    return { admin: true };
                case "UNAUTHENTICATED":
                    if (auth?.uid || auth?.token) {
                        throw new Error("authType and auth are incompatible.");
                    }
                    return { admin: false };
                default:
                    throw new Error("Unrecognized authType, valid values are: " + "ADMIN, USER, and UNAUTHENTICATED");
            }
        }
        if (auth) {
            return {
                admin: false,
                variable: {
                    uid: auth.uid ?? "",
                    token: auth.token || {},
                },
            };
        }
        return { admin: true };
    }
    makeFirestoreValue(input) {
        if (typeof input === "undefined" ||
            input === null ||
            (typeof input === "object" && Object.keys(input).length === 0)) {
            return {};
        }
        if (typeof input !== "object") {
            throw new Error("Firestore data must be key-value pairs.");
        }
        const currentTime = new Date().toISOString();
        return {
            fields: (0, encodeFirestoreValue_1.encodeFirestoreValue)(input),
            createTime: currentTime,
            updateTime: currentTime,
        };
    }
    requestCallBack(err, response, body) {
        if (err) {
            return console.warn("\nERROR SENDING REQUEST: " + err);
        }
        const status = response ? response.status + ", " : "";
        let bodyString = body;
        if (typeof bodyString === "string") {
            try {
                bodyString = JSON.stringify(JSON.parse(bodyString), null, 2);
            }
            catch (e) {
            }
        }
        else {
            bodyString = JSON.stringify(body, null, 2);
        }
        return console.log("\nRESPONSE RECEIVED FROM FUNCTION: " + status + bodyString);
    }
    isDatabaseFn(eventTrigger) {
        return utils.getFunctionsEventProvider(eventTrigger.eventType) === "Database";
    }
    isFirestoreFunc(eventTrigger) {
        return utils.getFunctionsEventProvider(eventTrigger.eventType) === "Firestore";
    }
    isPubsubFunc(eventTrigger) {
        return utils.getFunctionsEventProvider(eventTrigger.eventType) === "PubSub";
    }
    triggerEvent(data, opts) {
        opts = opts || {};
        let operationType;
        let dataPayload;
        if (this.trigger.httpsTrigger) {
            this.controller.call(this.trigger, data || {}, opts);
        }
        else if (this.trigger.eventTrigger) {
            if (this.isDatabaseFn(this.trigger.eventTrigger)) {
                operationType = utils.last(this.trigger.eventTrigger.eventType.split("."));
                switch (operationType) {
                    case "create":
                    case "created":
                        dataPayload = {
                            data: null,
                            delta: data,
                        };
                        break;
                    case "delete":
                    case "deleted":
                        dataPayload = {
                            data: data,
                            delta: null,
                        };
                        break;
                    default:
                        dataPayload = {
                            data: data.before,
                            delta: data.after,
                        };
                }
                const resource = this.trigger.eventTrigger.resource ??
                    this.trigger.eventTrigger.eventFilterPathPatterns?.ref;
                opts.resource = this.substituteParams(resource, opts.params);
                opts.auth = this.constructAuth(opts.auth, opts.authType);
                this.controller.call(this.trigger, dataPayload, opts);
            }
            else if (this.isFirestoreFunc(this.trigger.eventTrigger)) {
                operationType = utils.last(this.trigger.eventTrigger.eventType.split("."));
                switch (operationType) {
                    case "create":
                    case "created":
                        dataPayload = {
                            value: this.makeFirestoreValue(data),
                            oldValue: {},
                        };
                        break;
                    case "delete":
                    case "deleted":
                        dataPayload = {
                            value: {},
                            oldValue: this.makeFirestoreValue(data),
                        };
                        break;
                    default:
                        dataPayload = {
                            value: this.makeFirestoreValue(data.after),
                            oldValue: this.makeFirestoreValue(data.before),
                        };
                }
                const resource = this.trigger.eventTrigger.resource ??
                    this.trigger.eventTrigger.eventFilterPathPatterns?.document;
                opts.resource = this.substituteParams(resource, opts.params);
                this.controller.call(this.trigger, dataPayload, opts);
            }
            else if (this.isPubsubFunc(this.trigger.eventTrigger)) {
                dataPayload = data;
                if (this.trigger.platform === "gcfv2") {
                    dataPayload = {
                        message: { ...data, messageId: (0, crypto_1.randomUUID)() },
                    };
                }
                this.controller.call(this.trigger, dataPayload || {}, opts);
            }
            else {
                this.controller.call(this.trigger, data || {}, opts);
            }
        }
        return "Successfully invoked function.";
    }
    makeFn() {
        if (this.trigger.httpsTrigger) {
            const isCallable = !!this.trigger.labels?.["deployment-callable"];
            if (isCallable) {
                return (data, opt) => this.constructCallableFunc(data, opt);
            }
            else {
                return this.constructHttpsFunc();
            }
        }
        else {
            return (data, opt) => this.triggerEvent(data, opt);
        }
    }
}
exports.default = LocalFunction;
function toClientVerbOptions(opts) {
    return {
        method: opts.method,
        headers: opts.headers,
        queryParams: opts.qs,
    };
}
