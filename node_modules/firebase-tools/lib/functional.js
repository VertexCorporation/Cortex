"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.nullsafeVisitor = exports.zipIn = void 0;
exports.flattenObject = flattenObject;
exports.flattenArray = flattenArray;
exports.flatten = flatten;
exports.reduceFlat = reduceFlat;
exports.zip = zip;
exports.assertExhaustive = assertExhaustive;
exports.partition = partition;
exports.partitionRecord = partitionRecord;
exports.mapObject = mapObject;
exports.optionalValueMatches = optionalValueMatches;
function* flattenObject(obj) {
    function* helper(path, obj) {
        for (const [k, v] of Object.entries(obj)) {
            if (typeof v !== "object" || v === null) {
                yield [[...path, k].join("."), v];
            }
            else {
                yield* helper([...path, k], v);
            }
        }
    }
    yield* helper([], obj);
}
function* flattenArray(arr) {
    for (const val of arr) {
        if (Array.isArray(val)) {
            yield* flattenArray(val);
        }
        else {
            yield val;
        }
    }
}
function flatten(objOrArr) {
    if (Array.isArray(objOrArr)) {
        return flattenArray(objOrArr);
    }
    else {
        return flattenObject(objOrArr);
    }
}
function reduceFlat(accum, next) {
    return [...(accum || []), ...flatten([next])];
}
function* zip(left, right) {
    if (left.length !== right.length) {
        throw new Error("Cannot zip between two lists of differen lengths");
    }
    for (let i = 0; i < left.length; i++) {
        yield [left[i], right[i]];
    }
}
const zipIn = (other) => (elem, ndx) => {
    return [elem, other[ndx]];
};
exports.zipIn = zipIn;
function assertExhaustive(val, message) {
    throw new Error(message || `Never has a value (${val}).`);
}
function partition(arr, predicate) {
    return arr.reduce((acc, elem) => {
        acc[predicate(elem) ? 0 : 1].push(elem);
        return acc;
    }, [[], []]);
}
function partitionRecord(rec, predicate) {
    return Object.entries(rec).reduce((acc, [key, val]) => {
        acc[predicate(key, val) ? 0 : 1][key] = val;
        return acc;
    }, [{}, {}]);
}
function mapObject(input, transform) {
    const result = {};
    for (const [k, v] of Object.entries(input)) {
        result[k] = transform(v);
    }
    return result;
}
const nullsafeVisitor = (func, ...rest) => (first) => {
    if (first === null) {
        return null;
    }
    return func(first, ...rest);
};
exports.nullsafeVisitor = nullsafeVisitor;
function optionalValueMatches(lhs, rhs, defaultValue) {
    lhs = lhs === undefined ? defaultValue : lhs;
    rhs = rhs === undefined ? defaultValue : rhs;
    return lhs === rhs;
}
