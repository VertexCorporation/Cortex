"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isTabularStyle = exports.indentString = void 0;
// Utility functions for config options
/**
 * Creates a string to use for one step of indentation.
 */
function indentString(cfg) {
    if (cfg.indentStyle === 'tabularLeft' || cfg.indentStyle === 'tabularRight') {
        return ' '.repeat(10);
    }
    if (cfg.useTabs) {
        return '\t';
    }
    return ' '.repeat(cfg.tabWidth);
}
exports.indentString = indentString;
/**
 * True when indentStyle is one of the tabular ones.
 */
function isTabularStyle(cfg) {
    return cfg.indentStyle === 'tabularLeft' || cfg.indentStyle === 'tabularRight';
}
exports.isTabularStyle = isTabularStyle;
//# sourceMappingURL=config.js.map