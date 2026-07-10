import { ParameterLocation, ValidatorFunction } from '../../types';
import Oas3CompileContext from '../Oas3CompileContext';
export declare function _fixNullables(schema: any): any;
export declare function _filterRequiredProperties(schema: any, propNameToFilter: string): void;
export declare function generateRequestValidator(schemaContext: Oas3CompileContext, parameterLocation: ParameterLocation, parameterRequired: boolean, mediaType: string): ValidatorFunction;
export declare function generateResponseValidator(schemaContext: Oas3CompileContext, parameterLocation: ParameterLocation, parameterRequired: boolean): ValidatorFunction;
