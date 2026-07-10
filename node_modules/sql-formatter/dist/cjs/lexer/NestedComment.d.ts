import { RegExpLike } from './TokenizerEngine.js';
/**
 * An object mimicking a regular expression,
 * for matching nested block-comments.
 */
export declare class NestedComment implements RegExpLike {
    lastIndex: number;
    exec(input: string): string[] | null;
    private matchSection;
}
