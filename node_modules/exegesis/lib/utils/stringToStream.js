"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = stringToStream;
const stream_1 = require("stream");
function stringToStream(str, encoding = 'utf-8') {
    return new stream_1.Readable({
        read() {
            this.push(str, encoding);
            this.push(null);
        },
    });
}
//# sourceMappingURL=stringToStream.js.map