import { JSONSchema6, JSONSchema4 } from 'json-schema';
/**
 * Extracts a subtree from a JSON document, fixing any "$ref" JSON refs so they
 * now
 *
 * @param document - The document to extract a subtree from.
 * @param subtree - A JSON ref to the subtree to extract, or a child node of `document`.
 * @param [options.resolveRef] - A function which, given a JSON reference, resolves the node
 *   it refers to.
 * @param [options.skipUnknownRefs] - If true, skip any unknown refs instead of
 *   throwing an error.
 * @returns the extracted document.  The returned document is a copy, and shares
 *   no children with the original document.
 */
export declare function extractSchema(document: any, subtreeRef: string, options?: {
    resolveRef?: (ref: string) => any | undefined;
    skipUnknownRefs?: boolean;
}): JSONSchema4 | JSONSchema6;
