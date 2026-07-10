"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.assertFlutterCliExists = assertFlutterCliExists;
exports.getAdditionalBuildArgs = getAdditionalBuildArgs;
exports.getPubSpec = getPubSpec;
const cross_spawn_1 = require("cross-spawn");
const error_1 = require("../../error");
const promises_1 = require("fs/promises");
const fs_extra_1 = require("fs-extra");
const path_1 = require("path");
const yaml = require("yaml");
function assertFlutterCliExists() {
    const process = (0, cross_spawn_1.sync)("flutter", ["--version"], { stdio: "ignore" });
    if (process.status !== 0)
        throw new error_1.FirebaseError("Flutter CLI not found, follow the instructions here https://docs.flutter.dev/get-started/install before trying again.");
}
function getAdditionalBuildArgs(pubSpec) {
    const treeShakePackages = [
        "material_icons_named",
        "material_symbols_icons",
        "material_design_icons_flutter",
        "flutter_iconpicker",
        "font_awesome_flutter",
        "ionicons_named",
    ];
    const hasTreeShakePackage = treeShakePackages.some((pkg) => pubSpec.dependencies?.[pkg]);
    const treeShakeFlags = hasTreeShakePackage ? ["--no-tree-shake-icons"] : [];
    return [...treeShakeFlags];
}
async function getPubSpec(dir) {
    if (!(await (0, fs_extra_1.pathExists)((0, path_1.join)(dir, "pubspec.yaml"))))
        return {};
    if (!(await (0, fs_extra_1.pathExists)((0, path_1.join)(dir, "web"))))
        return {};
    try {
        const pubSpecBuffer = await (0, promises_1.readFile)((0, path_1.join)(dir, "pubspec.yaml"));
        return yaml.parse(pubSpecBuffer.toString());
    }
    catch (error) {
        console.info("Failed to read pubspec.yaml");
        return {};
    }
}
