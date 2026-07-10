"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.OperationPoller = void 0;
exports.pollOperation = pollOperation;
const apiv2_1 = require("./apiv2");
const error_1 = require("./error");
const queue_1 = require("./throttler/queue");
const DEFAULT_INITIAL_BACKOFF_DELAY_MILLIS = 250;
const DEFAULT_MASTER_TIMEOUT_MILLIS = 30000;
class OperationPoller {
    async poll(options) {
        const queue = new queue_1.Queue({
            name: options.pollerName || "LRO Poller",
            concurrency: 1,
            retries: Number.MAX_SAFE_INTEGER,
            maxBackoff: options.maxBackoff,
            backoff: options.backoff || DEFAULT_INITIAL_BACKOFF_DELAY_MILLIS,
        });
        const masterTimeout = options.masterTimeout || DEFAULT_MASTER_TIMEOUT_MILLIS;
        const { response, error } = await queue.run(this.getPollingTask(options), masterTimeout);
        queue.close();
        if (error) {
            throw error instanceof error_1.FirebaseError
                ? error
                : new error_1.FirebaseError(error.message, { status: error.code, original: error });
        }
        return response;
    }
    getPollingTask(options) {
        const apiClient = new apiv2_1.Client({
            urlPrefix: options.apiOrigin,
            apiVersion: options.apiVersion,
            auth: true,
        });
        return async () => {
            let res;
            try {
                res = await apiClient.get(options.operationResourceName, {
                    headers: options.headers,
                });
            }
            catch (err) {
                if (err.status === 500 || err.status === 503) {
                    throw err;
                }
                return { error: err };
            }
            if (options.onPoll) {
                options.onPoll(res.body);
            }
            if (options.doneFn) {
                const done = options.doneFn(res.body);
                if (!done) {
                    throw new Error("Polling incomplete, should trigger retry with backoff");
                }
            }
            else if (!res.body.done) {
                throw new Error("Polling incomplete, should trigger retry with backoff");
            }
            return res.body;
        };
    }
}
exports.OperationPoller = OperationPoller;
function pollOperation(options) {
    return new OperationPoller().poll(options);
}
