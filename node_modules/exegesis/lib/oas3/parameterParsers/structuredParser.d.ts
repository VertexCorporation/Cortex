import { ParameterParser, RawValues } from './types';
import { ParameterLocation } from '../../types';
/**
 * A structured parser is a parser that handles RFC6570 path-style and
 * form-style query expansions.
 *
 * @param schema - The JSON Schema this parser is expecting.
 * @param explode - True if this is a parser for an "exploded" expansion.
 */
export declare function generateStructuredParser(schema: any, explode: boolean): ParameterParser;
export declare function structuredStringParser(location: ParameterLocation, rawParamValues: RawValues): string | string[] | undefined;
export declare function structuredArrayParser(location: ParameterLocation, rawParamValues: RawValues): string | string[] | undefined;
export declare function explodedStructuredArrayParser(location: ParameterLocation, rawParamValues: RawValues): string | string[] | undefined;
