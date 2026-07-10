"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendFileBytes = sendFileBytes;
const zlib_1 = require("zlib");
const crc_1 = require("../crc");
const rfc_1 = require("../rfc");
function sendFileBytes(md, data, req, res) {
    let didGunzip = false;
    if (md.contentEncoding === "gzip") {
        const acceptEncoding = req.header("accept-encoding") || "";
        const shouldGunzip = !acceptEncoding.includes("gzip");
        if (shouldGunzip) {
            data = (0, zlib_1.gunzipSync)(data);
            didGunzip = true;
        }
    }
    res.setHeader("Accept-Ranges", "bytes");
    res.setHeader("Content-Type", md.contentType || "application/octet-stream");
    const fileName = md.name.split("/").pop();
    res.setHeader("Content-Disposition", `${md.contentDisposition || "attachment"}; filename*=${(0, rfc_1.encodeRFC5987)(fileName)}`);
    if (didGunzip) {
        res.setHeader("Transfer-Encoding", "chunked");
    }
    else {
        res.setHeader("Content-Encoding", md.contentEncoding || "");
    }
    res.setHeader("ETag", md.etag);
    res.setHeader("Cache-Control", md.cacheControl || "");
    res.setHeader("x-goog-generation", `${md.generation}`);
    res.setHeader("x-goog-metadatageneration", `${md.metageneration}`);
    res.setHeader("x-goog-storage-class", md.storageClass);
    res.setHeader("x-goog-hash", `crc32c=${(0, crc_1.crc32cToString)(md.crc32c)},md5=${md.md5Hash}`);
    const shouldRespectContentRange = !didGunzip;
    if (shouldRespectContentRange) {
        const byteRange = req.range(data.byteLength, { combine: true });
        if (Array.isArray(byteRange) && byteRange.type === "bytes" && byteRange.length > 0) {
            const range = byteRange[0];
            res.setHeader("Content-Range", `${byteRange.type} ${range.start}-${range.end}/${data.byteLength}`);
            res.status(206).end(data.slice(range.start, range.end + 1));
            return;
        }
    }
    res.end(data);
}
