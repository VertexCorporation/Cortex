"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Duration = exports.DURATION_REGEX = void 0;
exports.calculateRetention = calculateRetention;
const error_1 = require("../error");
exports.DURATION_REGEX = /^(\d+)([hdmw])$/;
var Duration;
(function (Duration) {
    Duration[Duration["MINUTE"] = 60] = "MINUTE";
    Duration[Duration["HOUR"] = 3600] = "HOUR";
    Duration[Duration["DAY"] = 86400] = "DAY";
    Duration[Duration["WEEK"] = 604800] = "WEEK";
})(Duration || (exports.Duration = Duration = {}));
const DURATIONS = {
    m: Duration.MINUTE,
    h: Duration.HOUR,
    d: Duration.DAY,
    w: Duration.WEEK,
};
function calculateRetention(flag) {
    const match = exports.DURATION_REGEX.exec(flag);
    if (!match) {
        throw new error_1.FirebaseError(`"retention" flag must be a duration string (e.g. 24h, 2w, or 7d)`);
    }
    const d = parseInt(match[1], 10) * DURATIONS[match[2]];
    if (isNaN(d)) {
        throw new error_1.FirebaseError(`Failed to parse provided retention time "${flag}"`);
    }
    return d;
}
