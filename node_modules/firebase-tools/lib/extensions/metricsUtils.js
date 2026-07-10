"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseTimeseriesResponse = parseTimeseriesResponse;
exports.parseBucket = parseBucket;
exports.buildMetricsTableRow = buildMetricsTableRow;
const semver = require("semver");
const clc = require("colorette");
function parseTimeseriesResponse(series) {
    const ret = [];
    for (const s of series) {
        const ref = buildRef(s);
        if (ref === undefined) {
            continue;
        }
        let valueToday;
        let value7dAgo;
        let value28dAgo;
        if (s.points.length >= 28 && s.points[27].value.int64Value !== undefined) {
            value28dAgo = parseBucket(s.points[27].value.int64Value);
        }
        if (s.points.length >= 7 && s.points[6].value.int64Value !== undefined) {
            value7dAgo = parseBucket(s.points[6].value.int64Value);
        }
        if (s.points.length >= 1 && s.points[0].value.int64Value !== undefined) {
            valueToday = parseBucket(s.points[0].value.int64Value);
        }
        ret.push({
            ref,
            valueToday,
            value7dAgo,
            value28dAgo,
        });
    }
    ret.sort((a, b) => {
        if (a.ref.version === "all") {
            return 1;
        }
        if (b.ref.version === "all") {
            return -1;
        }
        return semver.lt(a.ref.version, b.ref.version) ? 1 : -1;
    });
    return ret;
}
function parseBucket(value) {
    const v = Number(value);
    if (v >= 200) {
        return { low: v - 100, high: v };
    }
    if (v >= 10) {
        return { low: v - 10, high: v };
    }
    return { low: 0, high: 0 };
}
function buildMetricsTableRow(metric) {
    const ret = [metric.ref.version];
    if (metric.valueToday) {
        ret.push(`${metric.valueToday.low} - ${metric.valueToday.high}`);
    }
    else {
        ret.push("Insufficient data");
    }
    ret.push(renderChangeCell(metric.value7dAgo, metric.valueToday));
    ret.push(renderChangeCell(metric.value28dAgo, metric.valueToday));
    return ret;
}
function renderChangeCell(before, after) {
    if (!(before && after)) {
        return "Insufficient data";
    }
    if (before.high === after.high) {
        return "-";
    }
    if (before.high > after.high) {
        const diff = before.high - after.high;
        const tolerance = diff < 100 ? 10 : 100;
        return clc.red("▼ ") + `-${diff} (±${tolerance})`;
    }
    else {
        const diff = after.high - before.high;
        const tolerance = diff < 100 ? 10 : 100;
        return clc.green("▲ ") + `${diff} (±${tolerance})`;
    }
}
function buildRef(ts) {
    const publisherId = ts.resource.labels["publisher"];
    const extensionId = ts.resource.labels["extension"];
    const version = ts.resource.labels["version"];
    if (!(publisherId && extensionId && version)) {
        return undefined;
    }
    return {
        publisherId,
        extensionId,
        version,
    };
}
