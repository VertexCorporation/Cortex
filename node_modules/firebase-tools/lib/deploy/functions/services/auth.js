"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthBlockingService = void 0;
const backend = require("../backend");
const identityPlatform = require("../../../gcp/identityPlatform");
const events = require("../../../functions/events");
const error_1 = require("../../../error");
const utils_1 = require("../../../utils");
const index_1 = require("./index");
class AuthBlockingService {
    constructor() {
        this.name = "authblocking";
        this.api = "identitytoolkit.googleapis.com";
        this.triggerQueue = Promise.resolve();
        this.ensureTriggerRegion = index_1.noop;
    }
    validateTrigger(endpoint, wantBackend) {
        if (!backend.isBlockingTriggered(endpoint)) {
            return;
        }
        const blockingEndpoints = backend
            .allEndpoints(wantBackend)
            .filter((ep) => backend.isBlockingTriggered(ep));
        if (blockingEndpoints.find((ep) => ep.blockingTrigger.eventType === endpoint.blockingTrigger.eventType &&
            ep.id !== endpoint.id)) {
            throw new error_1.FirebaseError(`Can only create at most one Auth Blocking Trigger for ${endpoint.blockingTrigger.eventType} events`);
        }
    }
    configChanged(newConfig, config) {
        if (newConfig.triggers?.beforeCreate?.functionUri !==
            config.triggers?.beforeCreate?.functionUri ||
            newConfig.triggers?.beforeSignIn?.functionUri !==
                config.triggers?.beforeSignIn?.functionUri ||
            newConfig.triggers?.beforeSendEmail?.functionUri !==
                config.triggers?.beforeSendEmail?.functionUri ||
            newConfig.triggers?.beforeSendSms?.functionUri !== config.triggers?.beforeSendSms?.functionUri) {
            return true;
        }
        if (!!newConfig.forwardInboundCredentials?.accessToken !==
            !!config.forwardInboundCredentials?.accessToken ||
            !!newConfig.forwardInboundCredentials?.idToken !==
                !!config.forwardInboundCredentials?.idToken ||
            !!newConfig.forwardInboundCredentials?.refreshToken !==
                !!config.forwardInboundCredentials?.refreshToken) {
            return true;
        }
        return false;
    }
    async registerTriggerLocked(endpoint) {
        const newBlockingConfig = await identityPlatform.getBlockingFunctionsConfig(endpoint.project);
        const oldBlockingConfig = (0, utils_1.cloneDeep)(newBlockingConfig);
        if (endpoint.blockingTrigger.eventType === events.v1.BEFORE_CREATE_EVENT) {
            newBlockingConfig.triggers = {
                ...newBlockingConfig.triggers,
                beforeCreate: {
                    functionUri: endpoint.uri,
                },
            };
        }
        else if (endpoint.blockingTrigger.eventType === events.v1.BEFORE_SIGN_IN_EVENT) {
            newBlockingConfig.triggers = {
                ...newBlockingConfig.triggers,
                beforeSignIn: {
                    functionUri: endpoint.uri,
                },
            };
        }
        else if (endpoint.blockingTrigger.eventType === events.v1.BEFORE_SEND_EMAIL_EVENT) {
            newBlockingConfig.triggers = {
                ...newBlockingConfig.triggers,
                beforeSendEmail: {
                    functionUri: endpoint.uri,
                },
            };
        }
        else if (endpoint.blockingTrigger.eventType === events.v1.BEFORE_SEND_SMS_EVENT) {
            newBlockingConfig.triggers = {
                ...newBlockingConfig.triggers,
                beforeSendSms: {
                    functionUri: endpoint.uri,
                },
            };
        }
        else {
            throw new error_1.FirebaseError(`Received invalid blocking trigger event type ${endpoint.blockingTrigger.eventType}`);
        }
        newBlockingConfig.forwardInboundCredentials = {
            ...oldBlockingConfig.forwardInboundCredentials,
            ...endpoint.blockingTrigger.options,
        };
        if (!this.configChanged(newBlockingConfig, oldBlockingConfig)) {
            return;
        }
        await identityPlatform.setBlockingFunctionsConfig(endpoint.project, newBlockingConfig);
    }
    registerTrigger(ep) {
        if (!backend.isBlockingTriggered(ep)) {
            return Promise.resolve();
        }
        this.triggerQueue = this.triggerQueue.then(() => this.registerTriggerLocked(ep));
        return this.triggerQueue;
    }
    async unregisterTriggerLocked(endpoint) {
        const blockingConfig = await identityPlatform.getBlockingFunctionsConfig(endpoint.project);
        if (endpoint.uri !== blockingConfig.triggers?.beforeCreate?.functionUri &&
            endpoint.uri !== blockingConfig.triggers?.beforeSignIn?.functionUri &&
            endpoint.uri !== blockingConfig.triggers?.beforeSendEmail?.functionUri &&
            endpoint.uri !== blockingConfig.triggers?.beforeSendSms?.functionUri) {
            return;
        }
        if (endpoint.uri === blockingConfig.triggers?.beforeCreate?.functionUri) {
            delete blockingConfig.triggers?.beforeCreate;
        }
        if (endpoint.uri === blockingConfig.triggers?.beforeSignIn?.functionUri) {
            delete blockingConfig.triggers?.beforeSignIn;
        }
        if (endpoint.uri === blockingConfig.triggers?.beforeSendEmail?.functionUri) {
            delete blockingConfig.triggers?.beforeSendEmail;
        }
        if (endpoint.uri === blockingConfig.triggers?.beforeSendSms?.functionUri) {
            delete blockingConfig.triggers?.beforeSendSms;
        }
        await identityPlatform.setBlockingFunctionsConfig(endpoint.project, blockingConfig);
    }
    unregisterTrigger(ep) {
        if (!backend.isBlockingTriggered(ep)) {
            return Promise.resolve();
        }
        this.triggerQueue = this.triggerQueue.then(() => this.unregisterTriggerLocked(ep));
        return this.triggerQueue;
    }
    async getDefaultRegion() {
        return "us-east1";
    }
}
exports.AuthBlockingService = AuthBlockingService;
