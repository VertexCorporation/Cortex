import Oas3CompileContext from '../Oas3CompileContext';
import Path from '../Path';
import { ParametersMap } from '../../types';
export interface ResolvedPath {
    path: Path;
    pathKey: string;
    rawPathParams: ParametersMap<string | string[]> | undefined;
}
export default class Paths {
    private readonly _pathResolver;
    constructor(context: Oas3CompileContext, exegesisController: string | undefined);
    /**
     * Given a `pathname` from a URL (e.g. "/foo/bar") this will return the
     * PathObject from the OpenAPI document's `paths` section.
     *
     * @param urlPathname - The pathname to search for.  Note that any
     *   URL prefix defined by the `servers` section of the OpenAPI doc needs
     *   to be stripped before calling this.
     * @returns A `{path, rawPathParams}` object.
     *   `rawPathParams` will be an object where keys are parameter names from path
     *   templating.  If the path cannot be resolved, returns null, although
     *   note that if the path is resolved and the operation is not found, this
     *   will return an object with a null `operationObject`.
     */
    resolvePath(urlPathname: string): ResolvedPath | undefined;
}
