"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEFAULT_DURATION = exports.MAX_DURATION = exports.Duration = exports.DURATION_REGEX = void 0;
exports.calculateChannelExpireTTL = calculateChannelExpireTTL;
const error_1 = require("../error");
exports.DURATION_REGEX = /^(\d+)([hdm])$/;
var Duration;
(function (Duration) {
    Duration[Duration["MINUTE"] = 60000] = "MINUTE";
    Duration[Duration["HOUR"] = 3600000] = "HOUR";
    Duration[Duration["DAY"] = 86400000] = "DAY";
})(Duration || (exports.Duration = Duration = {}));
const DURATIONS = {
    m: Duration.MINUTE,
    h: Duration.HOUR,
    d: Duration.DAY,
};
exports.MAX_DURATION = 30 * Duration.DAY;
exports.DEFAULT_DURATION = 7 * Duration.DAY;
function calculateChannelExpireTTL(flag) {
    const match = exports.DURATION_REGEX.exec(flag);
    if (!match) {
        throw new error_1.FirebaseError(`"expires" flag must be a duration string (e.g. 24h or 7d) at most 30d`);
    }
    const d = parseInt(match[1], 10) * DURATIONS[match[2]];
    if (isNaN(d)) {
        throw new error_1.FirebaseError(`Failed to parse provided expire time "${flag}"`);
    }
    if (d > exports.MAX_DURATION) {
        throw new error_1.FirebaseError(`"expires" flag may not be longer than 30d`);
    }
    return d;
}
