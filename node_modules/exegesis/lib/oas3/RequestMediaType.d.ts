import * as oas3 from 'openapi3-ts';
import { ValidatorFunction, ParameterLocation, BodyParser } from '../types';
import Oas3CompileContext from './Oas3CompileContext';
export default class RequestMediaType {
    readonly context: Oas3CompileContext;
    readonly oaMediaType: oas3.MediaTypeObject;
    readonly parser: BodyParser;
    readonly validator: ValidatorFunction;
    constructor(context: Oas3CompileContext, oaMediaType: oas3.MediaTypeObject, mediaType: string, parameterLocation: ParameterLocation, parameterRequired: boolean);
}
