"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseVersionPredicate = parseVersionPredicate;
const error_1 = require("../error");
function parseVersionPredicate(versionPredicate) {
    const versionPredicateRegex = "^(?<comparator>>=|<=|>|<)?(?<targetSemVer>.*)";
    const matches = versionPredicate.match(versionPredicateRegex);
    if (!matches || !matches.groups.targetSemVer) {
        throw new error_1.FirebaseError("Invalid version predicate.");
    }
    const comparator = matches.groups.comparator || "=";
    return { comparator, targetSemVer: matches.groups.targetSemVer };
}
