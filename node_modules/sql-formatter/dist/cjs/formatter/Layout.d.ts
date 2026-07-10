import Indentation from './Indentation.js';
/** Whitespace modifiers to be used with add() method */
export declare enum WS {
    SPACE = 0,
    NO_SPACE = 1,
    NO_NEWLINE = 2,
    NEWLINE = 3,
    MANDATORY_NEWLINE = 4,
    INDENT = 5,
    SINGLE_INDENT = 6
}
export type LayoutItem = WS.SPACE | WS.SINGLE_INDENT | WS.NEWLINE | WS.MANDATORY_NEWLINE | string;
/**
 * API for constructing SQL string (especially the whitespace part).
 *
 * It hides the internal implementation.
 * Originally it used plain string concatenation, which was expensive.
 * Now it's storing items to array and builds the string only in the end.
 */
export default class Layout {
    indentation: Indentation;
    private items;
    constructor(indentation: Indentation);
    /**
     * Appends token strings and whitespace modifications to SQL string.
     */
    add(...items: (WS | string)[]): void;
    private trimHorizontalWhitespace;
    private trimWhitespace;
    private addNewline;
    private addIndentation;
    /**
     * Returns the final SQL string.
     */
    toString(): string;
    /**
     * Returns the internal layout data
     */
    getLayoutItems(): LayoutItem[];
    /**
     * True when some content has already been added and nothing but indentation
     * has been emitted since the last newline, meaning the next token would be
     * placed at the start of a fresh (non-first) line.
     */
    isAtStartOfLine(): boolean;
    private itemToString;
}
