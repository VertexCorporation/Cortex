"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resourceTemplates = exports.resources = void 0;
exports.resolveResource = resolveResource;
exports.markdownDocsOfResources = markdownDocsOfResources;
const docs_1 = require("./docs");
const app_id_1 = require("./guides/app_id");
const init_ai_1 = require("./guides/init_ai");
const init_auth_1 = require("./guides/init_auth");
const init_backend_1 = require("./guides/init_backend");
const init_firestore_1 = require("./guides/init_firestore");
const init_firestore_rules_1 = require("./guides/init_firestore_rules");
const init_hosting_1 = require("./guides/init_hosting");
const crashlytics_investigations_1 = require("./guides/crashlytics_investigations");
const track_1 = require("../../track");
const crashlytics_issues_1 = require("./guides/crashlytics_issues");
const crashlytics_reports_1 = require("./guides/crashlytics_reports");
const update_environment_ui_1 = require("./update_environment_ui");
const deploy_ui_1 = require("./deploy_ui");
const init_ui_1 = require("./init_ui");
exports.resources = [
    app_id_1.app_id,
    crashlytics_investigations_1.crashlytics_investigations,
    crashlytics_issues_1.crashlytics_issues,
    crashlytics_reports_1.crashlytics_reports,
    init_backend_1.init_backend,
    init_ai_1.init_ai,
    init_firestore_1.init_firestore,
    init_firestore_rules_1.init_firestore_rules,
    init_auth_1.init_auth,
    init_hosting_1.init_hosting,
    update_environment_ui_1.update_environment_ui,
    deploy_ui_1.deploy_ui,
    init_ui_1.init_ui,
];
exports.resourceTemplates = [docs_1.docs];
async function resolveResource(uri, ctx, track = true) {
    const resource = exports.resources.find((r) => r.mcp.uri === uri);
    if (resource) {
        if (track)
            void (0, track_1.trackGA4)("mcp_read_resource", { resource_name: uri });
        const result = await resource.fn(uri, ctx);
        return { type: "resource", mcp: resource.mcp, result };
    }
    const template = exports.resourceTemplates.find((rt) => rt.match(uri));
    if (template) {
        if (track)
            void (0, track_1.trackGA4)("mcp_read_resource", { resource_name: uri });
        const result = await template.fn(uri, ctx);
        return { type: "template", mcp: template.mcp, result };
    }
    if (track)
        void (0, track_1.trackGA4)("mcp_read_resource", { resource_name: uri, not_found: "true" });
    return null;
}
function markdownDocsOfResources() {
    const allResources = [...exports.resources, ...exports.resourceTemplates];
    const headings = `
| Resource Name | Description |
| ------------- | ----------- |`;
    const resourceRows = allResources.map((res) => {
        let desc = res.mcp.title ? `${res.mcp.title}: ` : "";
        desc += res.mcp.description || "";
        desc = desc.replaceAll("\n", "<br>");
        return `
| ${res.mcp.name} | ${desc} |`;
    });
    return headings + resourceRows.join("");
}
