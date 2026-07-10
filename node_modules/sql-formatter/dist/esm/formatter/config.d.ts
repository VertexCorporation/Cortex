import { FormatOptions } from '../FormatOptions.js';
/**
 * Creates a string to use for one step of indentation.
 */
export declare function indentString(cfg: FormatOptions): string;
/**
 * True when indentStyle is one of the tabular ones.
 */
export declare function isTabularStyle(cfg: FormatOptions): boolean;
