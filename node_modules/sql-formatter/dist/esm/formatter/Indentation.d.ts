/**
 * Manages indentation levels.
 *
 * There are two types of indentation levels:
 *
 * - BLOCK_LEVEL : increased by open-parenthesis
 * - TOP_LEVEL : increased by RESERVED_CLAUSE words
 */
export default class Indentation {
    private indent;
    private indentTypes;
    /**
     * @param {string} indent A string to indent with
     */
    constructor(indent: string);
    /**
     * Returns indentation string for single indentation step.
     */
    getSingleIndent(): string;
    /**
     * Returns current indentation level
     */
    getLevel(): number;
    /**
     * Increases indentation by one top-level indent.
     */
    increaseTopLevel(): void;
    /**
     * Increases indentation by one block-level indent.
     */
    increaseBlockLevel(): void;
    /**
     * Decreases indentation by one top-level indent.
     * Does nothing when the previous indent is not top-level.
     */
    decreaseTopLevel(): void;
    /**
     * Decreases indentation by one block-level indent.
     * If there are top-level indents within the block-level indent,
     * throws away these as well.
     */
    decreaseBlockLevel(): void;
}
