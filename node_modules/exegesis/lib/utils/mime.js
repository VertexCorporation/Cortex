"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MimeTypeRegistry = void 0;
exports.parseMimeType = parseMimeType;
// A mime-type, per RFC 7231 section 3.1.1.1
const TCHAR = "[!#$%&'*+-.^_`|~A-Za-z0-9]";
const TOKEN = `${TCHAR}+`;
const OWS = '[ \t]*';
const MIME_TYPE_REGEX = new RegExp(`^(${TOKEN})/(${TOKEN})${OWS}(.*)$`);
/**
 * Parses a mimeType into a `{type, subtype}` object.
 * Parameters provided with the mimeType are ignored.
 */
function parseMimeType(mimeType) {
    const match = MIME_TYPE_REGEX.exec(mimeType);
    if (!match) {
        throw new Error(`Invalid MIME type: "${mimeType}"`);
    }
    if (match[3] && match[3][0] !== ';') {
        throw new Error(`Invalid MIME type: "${mimeType}"`);
    }
    return { type: match[1].toLowerCase(), subtype: match[2].toLowerCase() };
}
function isParsedMimeType(val) {
    return !!(val.type && val.subtype);
}
class MimeTypeRegistry {
    constructor(map) {
        // This is a registry of mime types with no wildcards.
        this._staticMimeTypes = Object.create(null);
        // This is a registry of "types" for mime types where the subtype was wildcarded.
        this._wildcardSubtypes = Object.create(null);
        if (map) {
            for (const mimeType of Object.keys(map)) {
                const t = map[mimeType];
                if (t) {
                    this.set(mimeType, t);
                }
            }
        }
    }
    set(mimeType, value) {
        const { type, subtype } = isParsedMimeType(mimeType) ? mimeType : parseMimeType(mimeType);
        if (type === '*' && subtype === '*') {
            this._defaultMimeType = value;
        }
        else if (subtype === '*') {
            this._wildcardSubtypes[type] = value;
        }
        else if (type === '*') {
            throw new Error(`Do not allow wildcarding mime "type" unless also wildcarding "subtype": ${mimeType}`);
        }
        else {
            this._staticMimeTypes[`${type}/${subtype}`] = value;
        }
    }
    get(mimeType) {
        const { type, subtype } = isParsedMimeType(mimeType) ? mimeType : parseMimeType(mimeType);
        return (this._staticMimeTypes[`${type}/${subtype}`] ||
            this._wildcardSubtypes[type] ||
            this._defaultMimeType);
    }
    getRegisteredTypes() {
        const answer = Object.keys(this._staticMimeTypes).concat(Object.keys(this._wildcardSubtypes).map((type) => `${type}/*`));
        if (this._defaultMimeType) {
            answer.push('*/*');
        }
        return answer;
    }
}
exports.MimeTypeRegistry = MimeTypeRegistry;
//# sourceMappingURL=mime.js.map