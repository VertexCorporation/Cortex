"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.InlineExecutor = exports.QueueExecutor = exports.DEFAULT_RETRY_CODES = void 0;
const queue_1 = require("../../../throttler/queue");
exports.DEFAULT_RETRY_CODES = [429, 409, 503];
function parseErrorCode(err) {
    return (err.status ||
        err.code ||
        err.context?.response?.statusCode ||
        err.original?.code ||
        err.original?.context?.response?.statusCode);
}
async function handler(op) {
    try {
        op.result = await op.func();
    }
    catch (err) {
        const code = parseErrorCode(err);
        if (op.retryCodes.includes(code)) {
            throw err;
        }
        err.code = code;
        op.error = err;
    }
    return;
}
class QueueExecutor {
    constructor(options) {
        this.queue = new queue_1.Queue({ ...options, handler });
    }
    async run(func, opts) {
        const retryCodes = opts?.retryCodes || exports.DEFAULT_RETRY_CODES;
        const op = {
            func,
            retryCodes,
        };
        await this.queue.run(op);
        if (op.error) {
            throw op.error;
        }
        return op.result;
    }
}
exports.QueueExecutor = QueueExecutor;
class InlineExecutor {
    run(func) {
        return func();
    }
}
exports.InlineExecutor = InlineExecutor;
