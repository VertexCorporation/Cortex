import Layout, { WS } from './Layout.js';
/**
 * Like Layout, but only formats single-line expressions.
 *
 * Throws InlineLayoutError:
 * - when encountering a newline
 * - when exceeding configured expressionWidth
 */
export default class InlineLayout extends Layout {
    private expressionWidth;
    private length;
    private trailingSpace;
    constructor(expressionWidth: number);
    add(...items: (WS | string)[]): void;
    private addToLength;
}
/**
 * Thrown when block of SQL can't be formatted as a single line.
 */
export declare class InlineLayoutError extends Error {
}
