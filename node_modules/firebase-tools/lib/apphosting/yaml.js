"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppHostingYamlConfig = void 0;
exports.toEnvMap = toEnvMap;
exports.toEnvList = toEnvList;
const path_1 = require("path");
const utils_1 = require("../utils");
const config_1 = require("./config");
const yaml = require("yaml");
const jsYaml = require("js-yaml");
const path = require("path");
const fsutils_1 = require("../fsutils");
const error_1 = require("../error");
class AppHostingYamlConfig {
    constructor() {
        this.env = {};
    }
    static async loadFromFile(filePath) {
        if (!(0, fsutils_1.fileExistsSync)(filePath)) {
            throw new error_1.FirebaseError(`Cannot load ${filePath} from given path, it doesn't exist`);
        }
        const config = new AppHostingYamlConfig();
        const file = await (0, utils_1.readFileFromDirectory)((0, path_1.dirname)(filePath), (0, path_1.basename)(filePath));
        config.filename = path.basename(filePath);
        const loadedAppHostingYaml = (await (0, utils_1.wrappedSafeLoad)(file.source)) ?? {};
        if (loadedAppHostingYaml.env) {
            config.env = toEnvMap(loadedAppHostingYaml.env);
        }
        return config;
    }
    static empty() {
        return new AppHostingYamlConfig();
    }
    merge(other, allowSecretsToBecomePlaintext = true) {
        if (!allowSecretsToBecomePlaintext) {
            const wereSecrets = Object.entries(this.env)
                .filter(([, env]) => env.secret)
                .map(([key]) => key);
            if (wereSecrets.some((key) => other.env[key]?.value)) {
                throw new error_1.FirebaseError(`Cannot convert secret to plaintext in ${other.filename ?? "apphosting yaml"}`);
            }
        }
        this.env = {
            ...this.env,
            ...other.env,
        };
    }
    async upsertFile(filePath) {
        let yamlConfigToWrite = {};
        if ((0, fsutils_1.fileExistsSync)(filePath)) {
            const file = await (0, utils_1.readFileFromDirectory)((0, path_1.dirname)(filePath), (0, path_1.basename)(filePath));
            yamlConfigToWrite = await (0, utils_1.wrappedSafeLoad)(file.source);
        }
        yamlConfigToWrite.env = toEnvList(this.env);
        (0, config_1.store)(filePath, yaml.parseDocument(jsYaml.dump(yamlConfigToWrite)));
    }
}
exports.AppHostingYamlConfig = AppHostingYamlConfig;
function toEnvMap(envs) {
    return Object.fromEntries(envs.map((env) => {
        const { variable, ...rest } = env;
        return [variable, rest];
    }));
}
function toEnvList(envs) {
    return Object.entries(envs).map(([variable, env]) => {
        return { ...env, variable };
    });
}
