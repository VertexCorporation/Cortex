import * as oas3 from 'openapi3-ts';
import Oas3CompileContext from './Oas3CompileContext';
import { IValidationError, HttpHeaders } from '../types';
export default class Responses {
    readonly context: Oas3CompileContext;
    private readonly _responseValidators;
    private readonly _hasResponses;
    private readonly _location;
    constructor(context: Oas3CompileContext, response: oas3.ResponseObject);
    validateResponse(statusCode: number, headers: HttpHeaders, body: any): IValidationError[] | null;
}
