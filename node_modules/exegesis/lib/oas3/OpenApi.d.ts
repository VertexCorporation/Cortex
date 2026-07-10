import * as http from 'http';
import * as oas3 from 'openapi3-ts';
import { ExegesisCompiledOptions } from '../options';
import { ApiInterface, ResolvedPath, OAS3ApiInfo } from '../types';
export default class OpenApi implements ApiInterface<OAS3ApiInfo> {
    readonly openApiDoc: oas3.OpenAPIObject;
    private readonly _options;
    private _servers?;
    private _paths;
    /**
     * Creates a new OpenApi object.
     *
     * @param openApiDoc - The complete JSON definition of the API.
     *   The passed in definition should be a complete JSON object with no $refs.
     */
    constructor(openApiDoc: oas3.OpenAPIObject, options: ExegesisCompiledOptions);
    resolve(method: string, url: string, headers: http.IncomingHttpHeaders): ResolvedPath<OAS3ApiInfo> | undefined;
}
