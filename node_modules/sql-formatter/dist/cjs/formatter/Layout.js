"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.WS = void 0;
const utils_js_1 = require("../utils.js");
/** Whitespace modifiers to be used with add() method */
var WS;
(function (WS) {
    WS[WS["SPACE"] = 0] = "SPACE";
    WS[WS["NO_SPACE"] = 1] = "NO_SPACE";
    WS[WS["NO_NEWLINE"] = 2] = "NO_NEWLINE";
    WS[WS["NEWLINE"] = 3] = "NEWLINE";
    WS[WS["MANDATORY_NEWLINE"] = 4] = "MANDATORY_NEWLINE";
    WS[WS["INDENT"] = 5] = "INDENT";
    WS[WS["SINGLE_INDENT"] = 6] = "SINGLE_INDENT";
})(WS = exports.WS || (exports.WS = {}));
/**
 * API for constructing SQL string (especially the whitespace part).
 *
 * It hides the internal implementation.
 * Originally it used plain string concatenation, which was expensive.
 * Now it's storing items to array and builds the string only in the end.
 */
class Layout {
    constructor(indentation) {
        this.indentation = indentation;
        this.items = [];
    }
    /**
     * Appends token strings and whitespace modifications to SQL string.
     */
    add(...items) {
        for (const item of items) {
            switch (item) {
                case WS.SPACE:
                    this.items.push(WS.SPACE);
                    break;
                case WS.NO_SPACE:
                    this.trimHorizontalWhitespace();
                    break;
                case WS.NO_NEWLINE:
                    this.trimWhitespace();
                    break;
                case WS.NEWLINE:
                    this.trimHorizontalWhitespace();
                    this.addNewline(WS.NEWLINE);
                    break;
                case WS.MANDATORY_NEWLINE:
                    this.trimHorizontalWhitespace();
                    this.addNewline(WS.MANDATORY_NEWLINE);
                    break;
                case WS.INDENT:
                    this.addIndentation();
                    break;
                case WS.SINGLE_INDENT:
                    this.items.push(WS.SINGLE_INDENT);
                    break;
                default:
                    this.items.push(item);
            }
        }
    }
    trimHorizontalWhitespace() {
        while (isHorizontalWhitespace((0, utils_js_1.last)(this.items))) {
            this.items.pop();
        }
    }
    trimWhitespace() {
        while (isRemovableWhitespace((0, utils_js_1.last)(this.items))) {
            this.items.pop();
        }
    }
    addNewline(newline) {
        if (this.items.length > 0) {
            switch ((0, utils_js_1.last)(this.items)) {
                case WS.NEWLINE:
                    this.items.pop();
                    this.items.push(newline);
                    break;
                case WS.MANDATORY_NEWLINE:
                    // keep as is
                    break;
                default:
                    this.items.push(newline);
                    break;
            }
        }
    }
    addIndentation() {
        for (let i = 0; i < this.indentation.getLevel(); i++) {
            this.items.push(WS.SINGLE_INDENT);
        }
    }
    /**
     * Returns the final SQL string.
     */
    toString() {
        return this.items.map(item => this.itemToString(item)).join('');
    }
    /**
     * Returns the internal layout data
     */
    getLayoutItems() {
        return this.items;
    }
    /**
     * True when some content has already been added and nothing but indentation
     * has been emitted since the last newline, meaning the next token would be
     * placed at the start of a fresh (non-first) line.
     */
    isAtStartOfLine() {
        for (let i = this.items.length - 1; i >= 0; i--) {
            const item = this.items[i];
            if (item === WS.SINGLE_INDENT) {
                continue;
            }
            return item === WS.NEWLINE || item === WS.MANDATORY_NEWLINE;
        }
        return false;
    }
    itemToString(item) {
        switch (item) {
            case WS.SPACE:
                return ' ';
            case WS.NEWLINE:
            case WS.MANDATORY_NEWLINE:
                return '\n';
            case WS.SINGLE_INDENT:
                return this.indentation.getSingleIndent();
            default:
                return item;
        }
    }
}
exports.default = Layout;
const isHorizontalWhitespace = (item) => item === WS.SPACE || item === WS.SINGLE_INDENT;
const isRemovableWhitespace = (item) => item === WS.SPACE || item === WS.SINGLE_INDENT || item === WS.NEWLINE;
//# sourceMappingURL=Layout.js.map