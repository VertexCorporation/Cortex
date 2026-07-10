"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FunctionsEmulatorShell = void 0;
const crypto_1 = require("crypto");
const utils = require("../utils");
const functionsEmulator_1 = require("./functionsEmulator");
const logger_1 = require("../logger");
const error_1 = require("../error");
class FunctionsEmulatorShell {
    constructor(emu) {
        this.emu = emu;
        this.urls = {};
        this.triggers = emu.getTriggerDefinitions();
        this.emulatedFunctions = this.triggers.map((t) => t.id);
        const entryPoints = this.triggers.map((t) => t.entryPoint);
        utils.logLabeledBullet("functions", `Loaded functions: ${entryPoints.join(", ")}`);
        for (const trigger of this.triggers) {
            if (trigger.httpsTrigger) {
                this.urls[trigger.id] = functionsEmulator_1.FunctionsEmulator.getHttpFunctionUrl(this.emu.getProjectId(), trigger.name, trigger.region, this.emu.getInfo());
            }
        }
    }
    createLegacyEvent(eventTrigger, data, opts) {
        let resource = opts.resource;
        if (typeof resource === "object" && resource.name) {
            resource = resource.name;
        }
        return {
            eventId: (0, crypto_1.randomUUID)(),
            timestamp: new Date().toISOString(),
            eventType: eventTrigger.eventType,
            resource: resource,
            params: opts.params,
            auth: { admin: opts.auth?.admin || false, variable: opts.auth?.variable },
            data,
        };
    }
    createCloudEvent(eventTrigger, data, opts) {
        const ce = {
            specversion: "1.0",
            datacontenttype: "application/json",
            id: (0, crypto_1.randomUUID)(),
            type: eventTrigger.eventType,
            time: new Date().toISOString(),
            source: "",
            data,
        };
        if (eventTrigger.eventType.startsWith("google.cloud.storage")) {
            ce.source = `projects/_/buckets/${eventTrigger.eventFilters?.bucket}`;
        }
        else if (eventTrigger.eventType.startsWith("google.cloud.pubsub")) {
            ce.source = eventTrigger.eventFilters.topic;
            data = { ...data, messageId: (0, crypto_1.randomUUID)() };
        }
        else if (eventTrigger.eventType.startsWith("google.cloud.firestore")) {
            ce.source = `projects/_/databases/(default)`;
            if (opts.resource) {
                ce.document = opts.resource;
            }
        }
        else if (eventTrigger.eventType.startsWith("google.firebase.database")) {
            ce.source = `projects/_/locations/_/instances/${eventTrigger.eventFilterPathPatterns?.instance}`;
            if (opts.resource) {
                ce.ref = opts.resource;
            }
        }
        return ce;
    }
    call(trigger, data, opts) {
        logger_1.logger.debug(`shell:${trigger.name}: trigger=${JSON.stringify(trigger)}`);
        logger_1.logger.debug(`shell:${trigger.name}: opts=${JSON.stringify(opts)}, data=${JSON.stringify(data)}`);
        const eventTrigger = trigger.eventTrigger;
        if (!eventTrigger) {
            throw new error_1.FirebaseError(`Function ${trigger.name} is not a background function`);
        }
        let body;
        if (trigger.platform === "gcfv1") {
            body = this.createLegacyEvent(eventTrigger, data, opts);
        }
        else {
            body = this.createCloudEvent(eventTrigger, data, opts);
        }
        this.emu.sendRequest(trigger, body);
    }
}
exports.FunctionsEmulatorShell = FunctionsEmulatorShell;
