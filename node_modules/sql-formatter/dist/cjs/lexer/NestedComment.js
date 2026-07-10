"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.NestedComment = void 0;
const START = /\/\*/uy; // matches: /*
const ANY_CHAR = /[\s\S]/uy; // matches single character
const END = /\*\//uy; // matches: */
/**
 * An object mimicking a regular expression,
 * for matching nested block-comments.
 */
class NestedComment {
    constructor() {
        this.lastIndex = 0;
    }
    exec(input) {
        let result = '';
        let match;
        let nestLevel = 0;
        if ((match = this.matchSection(START, input))) {
            result += match;
            nestLevel++;
        }
        else {
            return null;
        }
        while (nestLevel > 0) {
            if ((match = this.matchSection(START, input))) {
                result += match;
                nestLevel++;
            }
            else if ((match = this.matchSection(END, input))) {
                result += match;
                nestLevel--;
            }
            else if ((match = this.matchSection(ANY_CHAR, input))) {
                result += match;
            }
            else {
                return null;
            }
        }
        return [result];
    }
    matchSection(regex, input) {
        regex.lastIndex = this.lastIndex;
        const matches = regex.exec(input);
        if (matches) {
            this.lastIndex += matches[0].length;
        }
        return matches ? matches[0] : null;
    }
}
exports.NestedComment = NestedComment;
//# sourceMappingURL=NestedComment.js.map