import { RawValues } from './types';
import * as exegesisTypes from '../../types';
export declare function generateDelimitedParser(delimiter: string): (location: exegesisTypes.ParameterLocation, rawParamValues: RawValues) => string[] | undefined;
export declare const pipeDelimitedParser: (location: exegesisTypes.ParameterLocation, rawParamValues: RawValues) => string[] | undefined;
export declare const spaceDelimitedParser: (location: exegesisTypes.ParameterLocation, rawParamValues: RawValues) => string[] | undefined;
