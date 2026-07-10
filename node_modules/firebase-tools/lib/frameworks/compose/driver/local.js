"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.LocalDriver = void 0;
const fs = require("node:fs");
const spawn = require("cross-spawn");
const hooks_1 = require("./hooks");
class LocalDriver {
    constructor(spec) {
        this.spec = spec;
    }
    execCmd(cmd, args) {
        const ret = spawn.sync(cmd, args, {
            env: { ...process.env, ...this.spec.environmentVariables },
            stdio: ["pipe", "inherit", "inherit"],
        });
        if (ret.error) {
            throw ret.error;
        }
    }
    install() {
        if (this.spec.installCommand) {
            if (this.spec.packageManagerInstallCommand) {
                const [cmd, ...args] = this.spec.packageManagerInstallCommand.split(" ");
                this.execCmd(cmd, args);
            }
            const [cmd, ...args] = this.spec.installCommand.split(" ");
            this.execCmd(cmd, args);
        }
    }
    build() {
        if (this.spec.detectedCommands?.build) {
            const [cmd, ...args] = this.spec.detectedCommands.build.cmd.split(" ");
            this.execCmd(cmd, args);
        }
    }
    export(bundle) {
    }
    execHook(bundle, hook) {
        const script = (0, hooks_1.genHookScript)(bundle, hook);
        this.execCmd("node", ["-e", script]);
        if (!fs.existsSync(hooks_1.BUNDLE_PATH)) {
            console.warn(`Expected hook to generate app bundle at ${hooks_1.BUNDLE_PATH} but got nothing.`);
            console.warn("Returning original bundle.");
            return bundle;
        }
        const newBundle = JSON.parse(fs.readFileSync(hooks_1.BUNDLE_PATH, "utf8"));
        return newBundle;
    }
}
exports.LocalDriver = LocalDriver;
