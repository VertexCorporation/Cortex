import { ParametersMap } from '../../types';
export type PathParserFunction = (pathname: string) => {
    matched: string;
    rawPathParams: ParametersMap<any>;
} | null;
/**
 * @param path - The path to check.
 * @returns true if the specified path uses templating, false otherwise.
 */
export declare function hasTemplates(path: string): boolean;
/**
 * Given a path containing template parts (e.g. "/foo/{bar}/baz"), returns
 * a regular expression that matches the path, and a list of parameters found.
 *
 * @param path - The path to convert.
 * @param options.openEnded - If true, then the returned `regex` will
 *   accept extra input at the end of the path.
 *
 * @returns A `{regex, params, parser}`, where:
 * - `params` is a list of parameters found in the path.
 * - `regex` is a regular expression that will match the path.  When calling
 *   `match = regex.exec(str)`, each parameter in `params[i]` will be present
 *   in `match[i+1]`.
 * - `parser` is a `fn(str)` that, given a path, will return null if
 *   the string does not match, and a `{matched, pathParams}` object if the
 *   path matches.  `pathParams` is an object where keys are parameter names
 *   and values are strings from the `path`.  `matched` is full string matched
 *   by the regex.
 */
export declare function compileTemplatePath(path: string, options?: {
    openEnded?: boolean;
}): {
    params: string[];
    regex: RegExp;
    parser: PathParserFunction;
};
export default class PathResolver<T> {
    private readonly _staticPaths;
    private readonly _dynamicPaths;
    constructor();
    registerPath(path: string, value: T): void;
    /**
     * Given a `pathname` from a URL (e.g. "/foo/bar") this will return the
     * a static path if one exists, otherwise a path with templates if one
     * exists.
     *
     * @param urlPathname - The pathname to search for.
     * @returns A `{value, rawPathParams} object if a path is matched, or
     *   undefined if there was no match.
     */
    resolvePath(urlPathname: string): {
        value: NonNullable<T>;
        rawPathParams: ParametersMap<string | string[]> | undefined;
        path: string;
    } | undefined;
}
