import { ParameterLocation, ValidatorFunction, oas3 } from '../types';
import Oas3CompileContext from './Oas3CompileContext';
import { ParameterParser } from './parameterParsers';
export default class Parameter {
    readonly context: Oas3CompileContext;
    readonly oaParameter: oas3.ParameterObject;
    readonly location: ParameterLocation;
    readonly validate: ValidatorFunction;
    /**
     * Parameter parser used to parse this parameter.
     */
    readonly name: string;
    readonly parser: ParameterParser;
    constructor(context: Oas3CompileContext, oaParameter: oas3.ParameterObject | oas3.ReferenceObject);
}
