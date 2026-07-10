"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const pathLib = require("path");
const removeRemote_1 = require("./removeRemote");
const listRemote_1 = require("./listRemote");
const stack_1 = require("../throttler/stack");
function chunkList(ls, chunkSize) {
    const chunks = [];
    for (let i = 0; i < ls.length; i += chunkSize) {
        chunks.push(ls.slice(i, i + chunkSize));
    }
    return chunks;
}
const INITIAL_DELETE_BATCH_SIZE = 25;
const INITIAL_LIST_NUM_SUB_PATH = 100;
const MAX_LIST_NUM_SUB_PATH = 204800;
class DatabaseRemove {
    constructor(instance, path, host, disableTriggers) {
        this.path = path;
        this.remote = new removeRemote_1.RTDBRemoveRemote(instance, host, disableTriggers);
        this.deleteJobStack = new stack_1.Stack({
            name: "delete stack",
            concurrency: 1,
            retries: 3,
        });
        this.listRemote = new listRemote_1.RTDBListRemote(instance, host);
        this.listStack = new stack_1.Stack({
            name: "list stack",
            concurrency: 1,
            retries: 3,
        });
    }
    async execute() {
        await this.deletePath(this.path);
    }
    async deletePath(path) {
        if (await this.deleteJobStack.run(() => this.remote.deletePath(path))) {
            return true;
        }
        let listNumSubPath = INITIAL_LIST_NUM_SUB_PATH;
        let batchSizeLow = 1;
        let batchSizeHigh = MAX_LIST_NUM_SUB_PATH + 1;
        let batchSize = INITIAL_DELETE_BATCH_SIZE;
        while (true) {
            const subPathList = await this.listStack.run(() => this.listRemote.listPath(path, listNumSubPath));
            if (subPathList.length === 0) {
                return false;
            }
            const chunks = chunkList(subPathList, batchSize);
            let nSmallChunks = 0;
            for (const chunk of chunks) {
                if (await this.deleteSubPath(path, chunk)) {
                    nSmallChunks += 1;
                }
            }
            if (nSmallChunks > chunks.length / 2) {
                batchSizeLow = batchSize;
                batchSize = Math.floor(Math.min(batchSize * 2, (batchSizeHigh + batchSize) / 2));
            }
            else {
                batchSizeHigh = batchSize;
                batchSize = Math.floor((batchSizeLow + batchSize) / 2);
            }
            if (listNumSubPath * 2 <= MAX_LIST_NUM_SUB_PATH) {
                listNumSubPath = listNumSubPath * 2;
            }
            else {
                listNumSubPath = Math.floor(MAX_LIST_NUM_SUB_PATH / batchSize) * batchSize;
            }
        }
    }
    async deleteSubPath(path, subPaths) {
        if (subPaths.length === 0) {
            throw new Error("deleteSubPath is called with empty subPaths list");
        }
        if (subPaths.length === 1) {
            return this.deletePath(pathLib.join(path, subPaths[0]));
        }
        if (await this.deleteJobStack.run(() => this.remote.deleteSubPath(path, subPaths))) {
            return true;
        }
        const mid = Math.floor(subPaths.length / 2);
        await this.deleteSubPath(path, subPaths.slice(0, mid));
        await this.deleteSubPath(path, subPaths.slice(mid));
        return false;
    }
}
exports.default = DatabaseRemove;
