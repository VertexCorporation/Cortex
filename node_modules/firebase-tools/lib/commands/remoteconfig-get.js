"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const rcGet = require("../remoteconfig/get");
const command_1 = require("../command");
const requireAuth_1 = require("../requireAuth");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const requirePermissions_1 = require("../requirePermissions");
const get_1 = require("../remoteconfig/get");
const utils = require("../utils");
const Table = require("cli-table3");
const fs = require("fs");
const util = require("util");
const error_1 = require("../error");
const tableHead = ["Entry Name", "Value"];
const MAX_DISPLAY_ITEMS = 20;
function checkValidOptionalNumber(versionNumber) {
    if (!versionNumber || typeof Number(versionNumber) === "number") {
        return versionNumber;
    }
    throw new error_1.FirebaseError(`Could not interpret "${versionNumber}" as a valid number.`);
}
exports.command = new command_1.Command("remoteconfig:get")
    .description("get a Firebase project's Remote Config template")
    .option("-v, --version-number <versionNumber>", "grabs the specified version of the template")
    .option("-o, --output [filename]", "write config output to a filename (if omitted, will use the default file path)")
    .before(requireAuth_1.requireAuth)
    .before(requirePermissions_1.requirePermissions, ["cloudconfig.configs.get"])
    .action(async (options) => {
    utils.assertIsStringOrUndefined(options.versionNumber);
    const template = await rcGet.getTemplate((0, projectUtils_1.needProjectId)(options), checkValidOptionalNumber(options.versionNumber));
    const table = new Table({ head: tableHead, style: { head: ["green"] } });
    if (template.conditions) {
        let updatedConditions = template.conditions
            .map((condition) => condition.name)
            .slice(0, MAX_DISPLAY_ITEMS)
            .join("\n");
        if (template.conditions.length > MAX_DISPLAY_ITEMS) {
            updatedConditions += "+more... \n";
        }
        table.push(["conditions", updatedConditions]);
    }
    const updatedParameters = (0, get_1.parseTemplateForTable)(template.parameters);
    table.push(["parameters", updatedParameters]);
    const updatedParameterGroups = (0, get_1.parseTemplateForTable)(template.parameterGroups);
    table.push(["parameterGroups", updatedParameterGroups]);
    table.push(["version", util.inspect(template.version, { showHidden: false, depth: null })]);
    const fileOut = !!options.output;
    if (fileOut) {
        const shouldUseDefaultFilename = options.output === true || options.output === "";
        let filename = undefined;
        if (shouldUseDefaultFilename) {
            filename = options.config.src.remoteconfig.template;
        }
        else {
            utils.assertIsString(options.output);
            filename = options.output;
        }
        const outTemplate = { ...template };
        delete outTemplate.version;
        fs.writeFileSync(filename, JSON.stringify(outTemplate, null, 2));
    }
    else {
        logger_1.logger.info(table.toString());
    }
    return template;
});
