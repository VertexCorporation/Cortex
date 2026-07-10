"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.expr = expr;
exports.copyField = copyField;
exports.renameField = renameField;
exports.serviceAccount = serviceAccount;
exports.serializeValue = serializeValue;
exports.blockToString = blockToString;
const utils = require("../../utils");
const error_1 = require("../../error");
function expr(string) {
    return { "@type": "HCLExpression", value: string };
}
function copyField(attributes, source, field, transform = (v) => v) {
    renameField(attributes, source, utils.toLowerSnakeCase(field), field, transform);
}
function renameField(attributes, source, attributeField, sourceField, transform = (v) => v) {
    const val = source[sourceField];
    if (val === undefined) {
        return;
    }
    attributes[attributeField] = val === null ? null : transform(val);
}
function serviceAccount(sa) {
    if (sa.endsWith("@")) {
        return `${sa}\${var.project}.iam.gserviceaccount.com`;
    }
    return sa;
}
function serializeValue(value, indentation = 0) {
    if (typeof value === "string") {
        value = value.replace(/{{ *params\.PROJECT_ID *}}/g, "${var.project}");
        if (value.includes("{{ ")) {
            throw new error_1.FirebaseError("Generalized parameterized fields are not supported in terraform yet");
        }
        return JSON.stringify(value);
    }
    else if (typeof value === "number" || typeof value === "boolean") {
        return value.toString();
    }
    else if (value === null || value === undefined) {
        return "null";
    }
    else if (Array.isArray(value)) {
        if (value.some((e) => e !== null &&
            typeof e === "object" &&
            (Array.isArray(e) || e["@type"] !== "HCLExpression"))) {
            return `[\n${value.map((v) => "  ".repeat(indentation + 1) + serializeValue(v, indentation + 1)).join(",\n")}\n${"  ".repeat(indentation)}]`;
        }
        return `[${value.map((v) => serializeValue(v)).join(", ")}]`;
    }
    else if (typeof value === "object") {
        if (value["@type"] === "HCLExpression") {
            return value.value;
        }
        const entries = Object.entries(value).map(([k, v]) => `${"  ".repeat(indentation + 1)}${k} = ${serializeValue(v, indentation + 1)}`);
        return `{\n${entries.join("\n")}\n${"  ".repeat(indentation)}}`;
    }
    throw new error_1.FirebaseError(`Unsupported terraform value type ${typeof value}`, { exit: 1 });
}
const PREFIX_ARGUMENTS = new Set(["count", "for_each", "provider"]);
const SUFFIX_ARGUMENTS = new Set(["lifecycle", "depends_on"]);
const NON_BLOCK_PARAMETERS = {
    google_cloudfunctions_function: new Set([
        "name",
        "runtime",
        "description",
        "available_memory_mb",
        "timeout",
        "entry_point",
        "source_archive_bucket",
        "source_archive_object",
        "trigger_http",
        "environment_variables",
        "vpc_connector",
        "service_account_email",
        "max_instances",
        "min_instances",
        "project",
        "region",
    ]),
    google_cloudfunctions2_function: new Set(["name", "location", "description", "project"]),
    google_cloud_scheduler_job: new Set([
        "name",
        "description",
        "schedule",
        "time_zone",
        "paused",
        "attempt_deadline",
        "region",
        "project",
    ]),
    google_cloud_tasks_queue: new Set(["name", "location", "desired_state", "project"]),
    google_eventarc_trigger: new Set(["name", "location", "project", "service_account"]),
    google_pubsub_topic: new Set([
        "name",
        "project",
        "labels",
        "kms_key_name",
        "message_retention_duration",
    ]),
    google_pubsub_subscription: new Set([
        "name",
        "topic",
        "project",
        "labels",
        "ack_deadline_seconds",
        "message_retention_duration",
        "retain_acked_messages",
        "enable_message_ordering",
        "filter",
    ]),
};
function serializeResourceAttributes(attributes, resourceType, indentation = 0) {
    const nonBlockParams = NON_BLOCK_PARAMETERS[resourceType] || new Set();
    const prefixGroup = [];
    const nonBlockGroup = [];
    const blockGroup = [];
    const suffixGroup = [];
    for (const [k, v] of Object.entries(attributes)) {
        const serialized = `${"  ".repeat(indentation + 1)}${k} = ${serializeValue(v, indentation + 1)}`;
        if (PREFIX_ARGUMENTS.has(k)) {
            prefixGroup.push(serialized);
        }
        else if (nonBlockParams.has(k)) {
            nonBlockGroup.push(serialized);
        }
        else if (SUFFIX_ARGUMENTS.has(k)) {
            suffixGroup.push(serialized);
        }
        else {
            blockGroup.push(serialized);
        }
    }
    const nonemptyGroups = [prefixGroup, nonBlockGroup, blockGroup, suffixGroup].filter((g) => g.length > 0);
    const joinedGroups = nonemptyGroups.map((g) => g.join("\n")).join("\n\n");
    return `{\n${joinedGroups}\n${"  ".repeat(indentation)}}`;
}
function blockToString(block, indentation = 0) {
    const labels = (block.labels || []).map((l) => `"${l}"`).join(" ");
    if (block.type === "resource" && block.labels?.length) {
        const resourceType = block.labels[0];
        return `${"  ".repeat(indentation)}${block.type} ${labels ? labels + " " : ""}${serializeResourceAttributes(block.attributes, resourceType, indentation)}`;
    }
    return `${"  ".repeat(indentation)}${block.type} ${labels ? labels + " " : ""}${serializeValue(block.attributes, indentation)}`;
}
