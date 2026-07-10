"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.pickHostingSiteName = pickHostingSiteName;
const error_1 = require("../error");
const utils_1 = require("../utils");
const projectUtils_1 = require("../projectUtils");
const api_1 = require("./api");
const prompt_1 = require("../prompt");
const nameSuggestion = new RegExp("try something like `(.+)`");
const prompt = "Please provide an unique, URL-friendly id for your site. Your site's URL will be <site-id>.web.app. " +
    'We recommend using letters, numbers, and hyphens (e.g. "{project-id}-{random-hash}"):';
async function pickHostingSiteName(siteId, options) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    let id = siteId;
    let nameConfirmed = false;
    let suggestion;
    if (!id) {
        const attempt = await trySiteID(projectNumber, projectId);
        if (attempt.available) {
            suggestion = projectId;
        }
        else {
            suggestion = attempt.suggestion;
        }
    }
    while (!nameConfirmed) {
        if (!id || suggestion) {
            id = await (0, prompt_1.input)({
                message: prompt,
                validate: (s) => s.length > 0,
                default: suggestion,
            });
        }
        const attempt = await trySiteID(projectNumber, id, options.nonInteractive);
        nameConfirmed = attempt.available;
        suggestion = attempt.suggestion;
        if (!nameConfirmed)
            id = "";
    }
    return id;
}
async function trySiteID(projectNumber, id, nonInteractive = false) {
    try {
        await (0, api_1.createSite)(projectNumber, id, "", true);
        return { available: true };
    }
    catch (err) {
        if (!(err instanceof error_1.FirebaseError)) {
            throw err;
        }
        if (nonInteractive) {
            throw err;
        }
        const suggestion = getSuggestionFromError(err);
        return { available: false, suggestion };
    }
}
function getSuggestionFromError(err) {
    if (err.status === 400 && err.message.includes("Invalid name:")) {
        const i = err.message.indexOf("Invalid name:");
        (0, utils_1.logWarning)(err.message.substring(i));
        const match = nameSuggestion.exec(err.message);
        if (match) {
            return match[1];
        }
    }
    else {
        (0, utils_1.logWarning)(err.message);
    }
    return;
}
