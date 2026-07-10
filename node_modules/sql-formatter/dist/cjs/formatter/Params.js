"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * Handles placeholder replacement with given params.
 */
class Params {
    constructor(params) {
        this.params = params;
        this.index = 0;
    }
    /**
     * Returns param value that matches given placeholder with param key.
     */
    get({ key, text }) {
        if (!this.params) {
            return text;
        }
        if (key) {
            return this.params[key];
        }
        return this.params[this.index++];
    }
    /**
     * Returns index of current positional parameter.
     */
    getPositionalParameterIndex() {
        return this.index;
    }
    /**
     * Sets index of current positional parameter.
     */
    setPositionalParameterIndex(i) {
        this.index = i;
    }
}
exports.default = Params;
//# sourceMappingURL=Params.js.map