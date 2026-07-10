import * as oas3 from 'openapi3-ts';
import Oas3CompileContext from './Oas3CompileContext';
import { ResponseValidationResult, HttpHeaders } from '../types';
export default class Responses {
    readonly context: Oas3CompileContext;
    private readonly _responses;
    private readonly _location;
    constructor(context: Oas3CompileContext, responses: oas3.ResponsesObject);
    validateResponse(statusCode: number, headers: HttpHeaders, body: any, validateDefaultResponses: boolean): ResponseValidationResult;
}
