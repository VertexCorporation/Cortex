"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generatePromptSection = generatePromptSection;
exports.updateFirebaseSection = updateFirebaseSection;
exports.replaceFirebaseFile = replaceFirebaseFile;
exports.getFeatureContent = getFeatureContent;
exports.generateFeaturePromptSection = generateFeaturePromptSection;
const crypto = require("crypto");
const fs = require("fs");
const path = require("path");
const prompt_1 = require("../../../prompt");
const utils = require("../../../utils");
const logger_1 = require("../../../logger");
const vsCodeUtils_1 = require("../../../vsCodeUtils");
const CLI_PROMPTS_DIR = path.join(__dirname, "../../../../prompts");
const VSCODE_PROMPTS_DIR = path.join(__dirname, "./prompts");
const FIREBASE_TAG_REGEX = /<firebase_prompts(?:\s+hash="([^"]+)")?>([\s\S]*?)<\/firebase_prompts>/;
const PROMPT_FILES = {
    base: "FIREBASE.md",
    functions: "FIREBASE_FUNCTIONS.md",
};
function calculateHash(content) {
    return crypto.createHash("sha256").update(content.trim()).digest("hex").substring(0, 8);
}
function generatePromptSection(enabledFeatures, options) {
    let fullContent = getFeatureContent("base");
    for (const feature of enabledFeatures) {
        if (feature !== "base" && PROMPT_FILES[feature]) {
            fullContent += "\n\n" + getFeatureContent(feature);
        }
    }
    const hash = calculateHash(fullContent);
    const innerContent = options?.customContent ?? fullContent;
    const wrapped = `<firebase_prompts hash="${hash}">
<!-- Firebase Tools Context - Auto-generated, do not edit -->
${innerContent}
</firebase_prompts>`;
    return { content: wrapped, hash };
}
async function updateFirebaseSection(config, filePath, enabledFeatures, options) {
    const { content: newSection, hash: newHash } = generatePromptSection(enabledFeatures);
    let currentContent = "";
    try {
        currentContent = config.readProjectFile(filePath) || "";
    }
    catch {
    }
    const match = currentContent.match(FIREBASE_TAG_REGEX);
    if (match && match[1] === newHash) {
        return { updated: false };
    }
    if (options?.interactive && currentContent) {
        const fileName = filePath.split("/").pop();
        logger_1.logger.info();
        utils.logBullet(`Update available for ${fileName}`);
        const shouldUpdate = await (0, prompt_1.confirm)({
            message: `Update Firebase section in ${fileName}?`,
            default: true,
        });
        if (!shouldUpdate) {
            return { updated: false };
        }
    }
    let finalContent;
    if (!currentContent) {
        finalContent = options?.header ? `${options.header}\n\n${newSection}` : newSection;
    }
    else if (match) {
        finalContent =
            currentContent.substring(0, match.index) +
                newSection +
                currentContent.substring(match.index + match[0].length);
    }
    else {
        const separator = currentContent.endsWith("\n") ? "\n" : "\n\n";
        finalContent = currentContent + separator + newSection;
    }
    config.writeProjectFile(filePath, finalContent);
    return { updated: true };
}
async function replaceFirebaseFile(config, filePath, content) {
    try {
        const existing = config.readProjectFile(filePath);
        if (existing === content) {
            return { updated: false };
        }
    }
    catch {
    }
    config.writeProjectFile(filePath, content);
    return { updated: true };
}
function getFeatureContent(feature) {
    const filename = PROMPT_FILES[feature];
    if (!filename)
        return "";
    const PROMPTS_DIR = (0, vsCodeUtils_1.isVSCodeExtension)() ? VSCODE_PROMPTS_DIR : CLI_PROMPTS_DIR;
    const content = fs.readFileSync(path.join(PROMPTS_DIR, filename), "utf8");
    return content;
}
function generateFeaturePromptSection(feature) {
    const content = getFeatureContent(feature);
    if (!content)
        return "";
    const hash = calculateHash(content);
    return `<firebase_${feature}_prompts hash="${hash}">
<!-- Firebase ${feature.charAt(0).toUpperCase() + feature.slice(1)} Context - Auto-generated, do not edit -->
${content}
</firebase_${feature}_prompts>`;
}
