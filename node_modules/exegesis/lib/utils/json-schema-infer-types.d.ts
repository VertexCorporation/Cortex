import { JSONSchema4, JSONSchema6 } from 'json-schema';
/**
 * Given a JSON Schema, returns a list of types that an object which passes
 * schema validation would be allowed to have.
 *
 * @param schema - A JSON schema.  This is allowed to have `$ref`s, but they
 *   must be internal refs relative to the schema (or to the `rootDocument`
 *   if it is specified).
 * @param [options.rootDocument] - If your JSON schema is embedded in a larger
 *   JSON document, it can be provided here to resolve `$ref`s relative to that
 *   parent document.
 */
export default function inferTypes(schema: JSONSchema4 | JSONSchema6, options?: {
    rootDocument?: any;
}): string[];
