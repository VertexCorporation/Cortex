"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listExtensions = listExtensions;
const clc = require("colorette");
const Table = require("cli-table3");
const extensionsApi_1 = require("./extensionsApi");
const logger_1 = require("../logger");
const utils_1 = require("../utils");
const extensionsHelper_1 = require("./extensionsHelper");
const extensionsUtils = require("./utils");
async function listExtensions(projectId) {
    const instances = await (0, extensionsApi_1.listInstances)(projectId);
    if (instances.length < 1) {
        (0, utils_1.logLabeledBullet)(extensionsHelper_1.logPrefix, `there are no extensions installed on project ${clc.bold(projectId)}.`);
        return [];
    }
    const table = new Table({
        head: ["Extension", "Publisher", "Instance ID", "State", "Version", "Your last update"],
        style: { head: ["yellow"] },
    });
    const sorted = instances.sort((a, b) => new Date(b.createTime).valueOf() - new Date(a.createTime).valueOf());
    const formatted = [];
    sorted.forEach((instance) => {
        let extension = instance.config.extensionRef || "";
        let publisher;
        if (extension === "") {
            extension = instance.config.source.spec.name || "";
            publisher = "N/A";
        }
        else {
            publisher = extension.split("/")[0];
        }
        const instanceId = (0, utils_1.last)(instance.name.split("/")) ?? "";
        const state = instance.state +
            ((instance.config.source.state || "ACTIVE") === "DELETED" ? " (UNPUBLISHED)" : "");
        const version = instance?.config?.source?.spec?.version;
        const updateTime = extensionsUtils.formatTimestamp(instance.updateTime);
        table.push([extension, publisher, instanceId, state, version, updateTime]);
        formatted.push({
            extension,
            publisher,
            instanceId,
            state,
            version,
            updateTime,
            params: instance.config.params,
            systemParams: instance.config.systemParams,
        });
    });
    (0, utils_1.logLabeledBullet)(extensionsHelper_1.logPrefix, `list of extensions installed in ${clc.bold(projectId)}:`);
    logger_1.logger.info(table.toString());
    return formatted;
}
