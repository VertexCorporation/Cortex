"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.InlineLayoutError = void 0;
// eslint-disable-next-line max-classes-per-file
const Indentation_js_1 = __importDefault(require("./Indentation.js"));
const Layout_js_1 = __importStar(require("./Layout.js"));
/**
 * Like Layout, but only formats single-line expressions.
 *
 * Throws InlineLayoutError:
 * - when encountering a newline
 * - when exceeding configured expressionWidth
 */
class InlineLayout extends Layout_js_1.default {
    constructor(expressionWidth) {
        super(new Indentation_js_1.default('')); // no indentation in inline layout
        this.expressionWidth = expressionWidth;
        this.length = 0;
        // Keeps track of the trailing whitespace,
        // so that we can decrease length when encountering WS.NO_SPACE,
        // but only when there actually is a space to remove.
        this.trailingSpace = false;
    }
    add(...items) {
        items.forEach(item => this.addToLength(item));
        if (this.length > this.expressionWidth) {
            // We have exceeded the allowable width
            throw new InlineLayoutError();
        }
        super.add(...items);
    }
    addToLength(item) {
        if (typeof item === 'string') {
            this.length += item.length;
            this.trailingSpace = false;
        }
        else if (item === Layout_js_1.WS.MANDATORY_NEWLINE || item === Layout_js_1.WS.NEWLINE) {
            // newlines not allowed within inline block
            throw new InlineLayoutError();
        }
        else if (item === Layout_js_1.WS.INDENT || item === Layout_js_1.WS.SINGLE_INDENT || item === Layout_js_1.WS.SPACE) {
            if (!this.trailingSpace) {
                this.length++;
                this.trailingSpace = true;
            }
        }
        else if (item === Layout_js_1.WS.NO_NEWLINE || item === Layout_js_1.WS.NO_SPACE) {
            if (this.trailingSpace) {
                this.trailingSpace = false;
                this.length--;
            }
        }
    }
}
exports.default = InlineLayout;
/**
 * Thrown when block of SQL can't be formatted as a single line.
 */
class InlineLayoutError extends Error {
}
exports.InlineLayoutError = InlineLayoutError;
//# sourceMappingURL=InlineLayout.js.map