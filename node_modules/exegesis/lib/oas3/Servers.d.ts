import * as oas3 from 'openapi3-ts';
import { ParametersMap } from '../types';
export interface ResolvedServer {
    /**
     * The server definition that was matched from the `servers`
     * section of the OpenAPI document.
     */
    oaServer: oas3.ServerObject;
    /**
     * The values of any template parameters defined in
     * the `server.url` of the matching `server` object.
     */
    serverParams: ParametersMap<string | string[]>;
    /** The unmatched portion of the `pathname`. */
    pathnameRest: string;
    /** The matched portion of the `pathname`. */
    baseUrl: string;
}
export default class Servers {
    private readonly _servers;
    constructor(servers: oas3.ServerObject[] | undefined);
    /**
     * Resolve the `server` that's being accessed.
     *
     * @param host - The hostname to match.
     * @param pathname - The URL pathname to match.
     * @returns If a matching `server` is found, returns a
     * `ResolvedServer` object.  Returns `null` if no match was found.
     */
    resolveServer(host: string, pathname: string): ResolvedServer | null;
}
