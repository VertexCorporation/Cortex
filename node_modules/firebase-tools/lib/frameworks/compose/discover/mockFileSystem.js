"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MockFileSystem = void 0;
class MockFileSystem {
    constructor(fileSys) {
        this.fileSys = fileSys;
        this.existsCache = {};
        this.contentCache = {};
    }
    exists(path) {
        if (!(path in this.existsCache)) {
            this.existsCache[path] = path in this.fileSys;
        }
        return Promise.resolve(this.existsCache[path]);
    }
    read(path) {
        if (!(path in this.contentCache)) {
            if (!(path in this.fileSys)) {
                const err = new Error("File path not found");
                err.cause = "ENOENT";
                throw err;
            }
            else {
                this.contentCache[path] = this.fileSys[path];
            }
        }
        return Promise.resolve(this.contentCache[path]);
    }
    getContentCache(path) {
        return this.contentCache[path];
    }
    getExistsCache(path) {
        return this.existsCache[path];
    }
}
exports.MockFileSystem = MockFileSystem;
