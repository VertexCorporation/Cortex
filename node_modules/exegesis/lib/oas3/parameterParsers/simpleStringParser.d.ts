import { RawStringParameterParser } from './types';
export declare function getSimpleStringParser(schema: any, explode: boolean): RawStringParameterParser;
export declare function simpleStringParser(value: string | undefined): string | string[] | undefined;
export declare function simpleArrayParser(value: string | undefined): string[] | undefined;
export declare function simpleStringArrayParser(value: string | undefined): string | string[] | undefined;
export declare function generateGenericSimpleParser(schema: any, explode: boolean): (value: string | undefined) => any;
