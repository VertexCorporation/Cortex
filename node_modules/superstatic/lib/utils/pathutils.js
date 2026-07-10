"use strict";
/**
 * Copyright (c) 2022 Google LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.asDirectoryIndex = asDirectoryIndex;
exports.isDirectoryIndex = isDirectoryIndex;
exports.hasTrailingSlash = hasTrailingSlash;
exports.addTrailingSlash = addTrailingSlash;
exports.removeTrailingSlash = removeTrailingSlash;
exports.normalizeMultiSlashes = normalizeMultiSlashes;
exports.removeTrailingString = removeTrailingString;
const INDEX_FILE = "index.html";
/**
 * @param pathname path to check.
 * @return the path with "/index.html" appended, if required.
 */
function asDirectoryIndex(pathname) {
    if (isDirectoryIndex(pathname)) {
        return pathname;
    }
    return normalizeMultiSlashes(`${pathname}/${INDEX_FILE}`);
}
/**
 * @param pathname path to check.
 * @return true if pathname ends with "/index.html".
 */
function isDirectoryIndex(pathname) {
    return pathname.endsWith(`/${INDEX_FILE}`);
}
/**
 * @param pathname path to check.
 * @return true if it ends with a slash.
 */
function hasTrailingSlash(pathname) {
    return pathname.endsWith("/");
}
/**
 * @param pathname path to check.
 * @return pathname with a trailing slash.
 */
function addTrailingSlash(pathname) {
    return hasTrailingSlash(pathname) ? pathname : pathname + "/";
}
/**
 * @param pathname path to check.
 * @return pathname without a trailing slash.
 */
function removeTrailingSlash(pathname) {
    return removeTrailingString(pathname, "/");
}
/**
 * @param pathname path to check.
 * @return pathname with any "//" replaced with "/".
 */
function normalizeMultiSlashes(pathname) {
    return pathname.replace(/\/+/g, "/");
}
/**
 * @param string string to check.
 * @param rm string to search for.
 * @return string with rm removed if it's the end of string. Else, string.
 */
function removeTrailingString(string, rm) {
    if (!string.endsWith(rm)) {
        return string;
    }
    return string.slice(0, string.lastIndexOf(rm));
}
