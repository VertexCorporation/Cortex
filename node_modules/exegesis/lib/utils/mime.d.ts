export interface ParsedMimeType {
    type: string;
    subtype: string;
}
/**
 * Parses a mimeType into a `{type, subtype}` object.
 * Parameters provided with the mimeType are ignored.
 */
export declare function parseMimeType(mimeType: string): ParsedMimeType;
export declare class MimeTypeRegistry<T> {
    private _staticMimeTypes;
    private _wildcardSubtypes;
    private _defaultMimeType;
    constructor(map?: {
        [mimeType: string]: T | undefined;
    } | undefined);
    set(mimeType: string | ParsedMimeType, value: T): void;
    get(mimeType: string | ParsedMimeType): T | undefined;
    getRegisteredTypes(): string[];
}
