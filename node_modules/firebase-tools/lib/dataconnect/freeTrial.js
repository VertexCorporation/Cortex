"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.freeTrialTermsLink = freeTrialTermsLink;
exports.checkFreeTrialInstanceUsed = checkFreeTrialInstanceUsed;
exports.upgradeInstructions = upgradeInstructions;
const clc = require("colorette");
const cloudmonitoring_1 = require("../gcp/cloudmonitoring");
function freeTrialTermsLink() {
    return "https://firebase.google.com/pricing";
}
const FREE_TRIAL_METRIC = "sqladmin.googleapis.com/fdc_lifetime_free_trial_per_project";
async function checkFreeTrialInstanceUsed(projectId) {
    const past7d = new Date();
    past7d.setDate(past7d.getDate() - 7);
    const query = {
        filter: `metric.type="serviceruntime.googleapis.com/quota/allocation/usage" AND metric.label.quota_metric = "${FREE_TRIAL_METRIC}"`,
        "interval.endTime": new Date().toJSON(),
        "interval.startTime": past7d.toJSON(),
    };
    let used = true;
    try {
        const ts = await (0, cloudmonitoring_1.queryTimeSeries)(query, projectId);
        if (ts.length) {
            used = ts[0].points.some((p) => p.value.int64Value);
        }
    }
    catch (err) {
        used = false;
    }
    return used;
}
function upgradeInstructions(projectId, trialUsed) {
    return `To provision a ${trialUsed ? "paid CloudSQL Postgres instance" : "CloudSQL Postgres instance on the Firebase SQL Connect no-cost trial"}:

  1. Please upgrade to the pay-as-you-go (Blaze) billing plan. Visit the following page:

      https://console.firebase.google.com/project/${projectId}/usage/details

  2. Run ${clc.bold("firebase deploy --only dataconnect")} to deploy your SQL Connect service.`;
}
