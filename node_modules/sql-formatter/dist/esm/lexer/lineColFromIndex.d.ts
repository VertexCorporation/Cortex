/**
 * Determines line and column number of character index in source code.
 */
export declare function lineColFromIndex(source: string, index: number): LineCol;
export interface LineCol {
    line: number;
    col: number;
}
