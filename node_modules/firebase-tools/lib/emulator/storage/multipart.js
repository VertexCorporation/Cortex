"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseObjectUploadMultipartRequest = parseObjectUploadMultipartRequest;
const LINE_SEPARATOR = `\r\n`;
function splitBufferByDelimiter(buffer, delimiter, maxResults = -1) {
    let offset = 0;
    let nextDelimiterIndex = buffer.indexOf(delimiter, offset);
    const bufferParts = [];
    while (nextDelimiterIndex !== -1) {
        if (maxResults === 0) {
            return bufferParts;
        }
        else if (maxResults === 1) {
            bufferParts.push(Buffer.from(buffer.slice(offset)));
            return bufferParts;
        }
        bufferParts.push(Buffer.from(buffer.slice(offset, nextDelimiterIndex)));
        offset = nextDelimiterIndex + delimiter.length;
        nextDelimiterIndex = buffer.indexOf(delimiter, offset);
        maxResults -= 1;
    }
    bufferParts.push(Buffer.from(buffer.slice(offset)));
    return bufferParts;
}
function parseMultipartRequestBody(boundaryId, body) {
    const cleanBoundaryId = boundaryId.replace(/^["'](.+(?=["']$))["']$/, "$1");
    const boundaryString = `--${cleanBoundaryId}`;
    const bodyParts = splitBufferByDelimiter(body, boundaryString).map((buf) => {
        return Buffer.from(buf.slice(2));
    });
    const parsedParts = [];
    for (const bodyPart of bodyParts.slice(1, bodyParts.length - 1)) {
        parsedParts.push(parseMultipartRequestBodyPart(bodyPart));
    }
    return parsedParts;
}
function parseMultipartRequestBodyPart(bodyPart) {
    const sections = splitBufferByDelimiter(bodyPart, LINE_SEPARATOR, 3);
    const contentTypeRaw = sections[0].toString().toLowerCase();
    if (!contentTypeRaw.startsWith("content-type: ")) {
        throw new Error(`Failed to parse multipart request body part. Missing content type.`);
    }
    const dataRaw = Buffer.from(sections[2]).slice(0, sections[2].byteLength - LINE_SEPARATOR.length);
    return { contentTypeRaw, dataRaw };
}
function parseObjectUploadMultipartRequest(contentTypeHeader, body) {
    if (!contentTypeHeader.startsWith("multipart/related")) {
        throw new Error(`Bad content type. ${contentTypeHeader}`);
    }
    const boundaryId = contentTypeHeader.split("boundary=")[1];
    if (!boundaryId) {
        throw new Error(`Bad content type. ${contentTypeHeader}`);
    }
    const parsedBody = parseMultipartRequestBody(boundaryId, body);
    if (parsedBody.length !== 2) {
        throw new Error(`Unexpected number of parts in request body`);
    }
    return {
        metadataRaw: parsedBody[0].dataRaw.toString(),
        dataRaw: Buffer.from(parsedBody[1].dataRaw),
    };
}
