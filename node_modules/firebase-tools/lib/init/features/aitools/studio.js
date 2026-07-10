"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.studio = void 0;
const promptUpdater_1 = require("./promptUpdater");
const RULES_PATH = ".idx/airules.md";
exports.studio = {
    name: "studio",
    displayName: "Firebase Studio",
    async configure(config, projectPath, enabledFeatures) {
        const files = [];
        const { updated } = await (0, promptUpdater_1.updateFirebaseSection)(config, RULES_PATH, enabledFeatures, {
            interactive: true,
        });
        files.push({ path: RULES_PATH, updated });
        return { files };
    },
};
