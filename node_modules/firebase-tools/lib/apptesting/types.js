"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CompletionReason = exports.Browser = void 0;
var Browser;
(function (Browser) {
    Browser["BROWSER_UNSPECIFIED"] = "BROWSER_UNSPECIFIED";
    Browser["CHROME"] = "CHROME";
})(Browser || (exports.Browser = Browser = {}));
var CompletionReason;
(function (CompletionReason) {
    CompletionReason[CompletionReason["COMPLETION_REASON_UNSPECIFIED"] = 0] = "COMPLETION_REASON_UNSPECIFIED";
    CompletionReason[CompletionReason["MAX_STEPS_REACHED"] = 1] = "MAX_STEPS_REACHED";
    CompletionReason[CompletionReason["GOAL_FAILED"] = 2] = "GOAL_FAILED";
    CompletionReason[CompletionReason["NO_ACTIONS_REQUIRED"] = 3] = "NO_ACTIONS_REQUIRED";
    CompletionReason[CompletionReason["GOAL_INCONCLUSIVE"] = 4] = "GOAL_INCONCLUSIVE";
    CompletionReason[CompletionReason["TEST_CANCELLED"] = 5] = "TEST_CANCELLED";
    CompletionReason[CompletionReason["GOAL_SUCCEEDED"] = 6] = "GOAL_SUCCEEDED";
})(CompletionReason || (exports.CompletionReason = CompletionReason = {}));
