"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.mebibytes = mebibytes;
const BYTES_PER_UNIT = {
    "": 1,
    k: 1e3,
    M: 1e6,
    G: 1e9,
    T: 1e12,
    Ki: 1 << 10,
    Mi: 1 << 20,
    Gi: 1 << 30,
    Ti: 1 << 40,
};
function mebibytes(memory) {
    const re = /^([0-9]+(\.[0-9]*)?)(Ki|Mi|Gi|Ti|k|M|G|T|([eE]([0-9]+)))?$/;
    const matches = re.exec(memory);
    if (!matches) {
        throw new Error(`Invalid memory quantity "${memory}""`);
    }
    const quantity = Number.parseFloat(matches[1]);
    let bytes;
    if (matches[5]) {
        bytes = quantity * Math.pow(10, Number.parseFloat(matches[5]));
    }
    else {
        const suffix = matches[3] || "";
        bytes = quantity * BYTES_PER_UNIT[suffix];
    }
    return bytes / (1 << 20);
}
