"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.crc32c = crc32c;
exports.crc32cToString = crc32cToString;
function makeCRCTable(poly) {
    let c;
    const crcTable = [];
    for (let n = 0; n < 256; n++) {
        c = n;
        for (let k = 0; k < 8; k++) {
            c = c & 1 ? poly ^ (c >>> 1) : c >>> 1;
        }
        crcTable[n] = c;
    }
    return crcTable;
}
const CRC32C_TABLE = makeCRCTable(0x82f63b78);
function crc32c(bytes) {
    let crc = 0 ^ -1;
    for (let i = 0; i < bytes.length; i++) {
        const byte = bytes[i];
        const nLookupIndex = (crc ^ byte) & 0xff;
        crc = (crc >>> 8) ^ CRC32C_TABLE[nLookupIndex];
    }
    return (crc ^ -1) >>> 0;
}
function crc32cToString(crc32cValue) {
    const value = typeof crc32cValue === "string" ? Number.parseInt(crc32cValue) : crc32cValue;
    const buffer = Buffer.alloc(4);
    buffer.writeUint32BE(value);
    return buffer.toString("base64");
}
