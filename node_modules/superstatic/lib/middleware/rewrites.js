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
const slasher = require("glob-slasher"); // eslint-disable-line @typescript-eslint/no-var-requires
const urlParser = require("url"); // eslint-disable-line @typescript-eslint/no-var-requires
const patterns = require("../utils/patterns");
function matcher(rewrites) {
    return function (url) {
        for (const rw of rewrites) {
            if (patterns.configMatcher(url, rw)) {
                return rw;
            }
        }
        return;
    };
}
/**
 * Looks for possible rewrites for the given req.url.
 * @return middleware for handling rewrites.
 */
module.exports = function () {
    return function (req, res, next) {
        const rewrites = matcher(req.superstatic.rewrites ?? []);
        if (!req.url) {
            return next();
        }
        const pathname = urlParser.parse(req.url).pathname;
        const match = rewrites(slasher(pathname));
        if (!match) {
            return next();
        }
        res.statusCode = 200;
        res.superstatic.handle({ rewrite: match }, next);
    };
};
