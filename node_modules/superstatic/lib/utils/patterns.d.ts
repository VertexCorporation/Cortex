/**
 * Evaluates whether a configured redirect/rewrite/custom header should
 * be applied to a request against a specific path. All three features
 * are configured with a hash that contains either a Node-like glob path
 * specification as its `source` or `glob` field, or a RE2 regular
 * expression as its `regex` field.
 *
 * Since Javascript lacks a native library for RE2, Superstatic uses the C
 * bindings as an optional dependency, and falls over to PCRE if the import
 * is unavailable. Under most circumstances not involving named capturing
 * groups, the two libraries should have identical behavior.
 *
 * No special consideration is taken if the configuration hash contains both
 * a glob and a regex. normalizeConfig() will error in that case.
 * @param {string} path The URL path from the request.
 * @param {object} config A dictionary from a sanitized JSON configuration.
 * @return {boolean} Whether the config should be applied to the request.
 */
export function configMatcher(path: string, config: object): boolean;
/**
 * Creates either an RE2 or a Javascript RegExp from a provided string
 * pattern, depending on whether or not the RE2 library is available as an
 * import.
 * @param {string} pattern A regular expression pattern to test against.
 * @return {RegExp} A regular expression object, created by either base
 *                  RegExp or RE2, which matches the RegExp prototype
 */
export function createRaw(pattern: string): RegExp;
/**
 * Returns true if RE2, which is an optional dependency, has been loaded.
 * @return {boolean}
 */
export function re2Available(): boolean;
/**
 * Is truthy if the provided raw string pattern contains a RE2 named capture
 * group opening, ?P<, which is not interpretable when Superstatic is falling
 * back on the base Javascript RegExp implementation.
 * @param {string} pattern
 * @return {boolean}
 */
export function containsRE2Capture(pattern: string): boolean;
/**
 * Is truthy if the provided raw string pattern contains a PCRE named capture
 * group opening, ?<, which is not interpretable when Superstatic has loaded
 * the RE2 bindings.
 * @param {string} pattern
 * @return {boolean}
 */
export function containsPCRECapture(pattern: string): boolean;
