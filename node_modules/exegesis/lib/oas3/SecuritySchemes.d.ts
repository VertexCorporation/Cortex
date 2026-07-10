import * as oas3 from 'openapi3-ts';
import { AuthenticatorInfo } from '..';
export default class SecuritySchemes {
    private readonly _securitySchemes;
    private readonly _challenges;
    private readonly _infos;
    constructor(openApiDoc: oas3.OpenAPIObject);
    getChallenge(schemeName: string): string | undefined;
    getInfo(schemeName: string): AuthenticatorInfo;
}
