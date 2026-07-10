import { ParametersMap, ParameterLocation } from '../../types';
import { ParameterParser, RawValues, ParameterDescriptor } from './types';
export * from './types';
export declare function generateParser(parameterDescriptor: ParameterDescriptor): ParameterParser;
export declare function parseParameterGroup(params: {
    location: ParameterLocation;
    parser: ParameterParser;
}[], rawValues: RawValues): ParametersMap<any>;
export declare function parseQueryParameters(params: {
    location: ParameterLocation;
    parser: ParameterParser;
}[], query: string | undefined): ParametersMap<any>;
