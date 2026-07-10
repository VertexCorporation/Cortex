"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DockerDriver = exports.DockerfileBuilder = void 0;
const fs = require("node:fs");
const path = require("node:path");
const spawn = require("cross-spawn");
const hooks_1 = require("./hooks");
const ADAPTER_SCRIPTS_PATH = "./.firebase/adapters";
const DOCKER_STAGE_INSTALL = "installer";
const DOCKER_STAGE_BUILD = "builder";
class DockerfileBuilder {
    constructor() {
        this.dockerfile = "";
        this.lastStage = "";
    }
    from(image, name) {
        this.dockerfile += `FROM ${image}`;
        if (name) {
            this.dockerfile += ` AS ${name}`;
            this.lastStage = name;
        }
        this.dockerfile += "\n";
        return this;
    }
    fromLastStage(name) {
        return this.from(this.lastStage, name);
    }
    tempFrom(image, name) {
        this.dockerfile += `FROM ${image}`;
        if (name) {
            this.dockerfile += ` AS ${name}`;
        }
        this.dockerfile += "\n";
        return this;
    }
    workdir(dir) {
        this.dockerfile += `WORKDIR ${dir}\n`;
        return this;
    }
    copyForFirebase(src, dest, from) {
        if (from) {
            this.dockerfile += `COPY --chown=firebase:firebase --from=${from} ${src} ${dest}\n`;
        }
        else {
            this.dockerfile += `COPY --chown=firebase:firebase ${src} ${dest}\n`;
        }
        return this;
    }
    copyFrom(src, dest, from) {
        this.dockerfile += `COPY --from=${from} ${src} ${dest}\n`;
        return this;
    }
    run(cmd, mount) {
        if (mount) {
            this.dockerfile += `RUN --mount=${mount} ${cmd}\n`;
        }
        else {
            this.dockerfile += `RUN ${cmd}\n`;
        }
        return this;
    }
    env(key, value) {
        this.dockerfile += `ENV ${key}="${value}"\n`;
        return this;
    }
    envs(envs) {
        for (const [key, value] of Object.entries(envs)) {
            this.env(key, value);
        }
        return this;
    }
    cmd(cmds) {
        this.dockerfile += `CMD [${cmds.map((c) => `"${c}"`).join(", ")}]\n`;
        return this;
    }
    user(user) {
        this.dockerfile += `USER ${user}\n`;
        return this;
    }
    toString() {
        return this.dockerfile;
    }
}
exports.DockerfileBuilder = DockerfileBuilder;
class DockerDriver {
    constructor(spec) {
        this.spec = spec;
        this.dockerfileBuilder = new DockerfileBuilder();
        this.dockerfileBuilder.from(spec.baseImage, "base").user("firebase");
    }
    execDockerPush(args) {
        console.debug(JSON.stringify({ message: `executing docker build: ${args.join(" ")}` }));
        console.info(JSON.stringify({ foo: "bar", message: `executing docker build: ${args.join(" ")}` }));
        console.error(JSON.stringify({ message: `executing docker build: ${args.join(" ")}` }));
        return spawn.sync("docker", ["push", ...args], {
            stdio: ["pipe", "inherit", "inherit"],
        });
    }
    execDockerBuild(args, contextDir) {
        console.log(`executing docker build: ${args.join(" ")} ${contextDir}`);
        console.log(this.dockerfileBuilder.toString());
        return spawn.sync("docker", ["buildx", "build", ...args, "-f", "-", contextDir], {
            env: { ...process.env, ...this.spec.environmentVariables },
            input: this.dockerfileBuilder.toString(),
            stdio: ["pipe", "inherit", "inherit"],
        });
    }
    buildStage(stage, contextDir, tag) {
        console.log(`Building stage: ${stage}`);
        const args = ["--target", stage];
        if (tag) {
            args.push("--tag", tag);
        }
        const ret = this.execDockerBuild(args, contextDir);
        if (ret.error || ret.status !== 0) {
            throw new Error(`Failed to execute stage ${stage}: error=${ret.error} status=${ret.status}`);
        }
    }
    exportBundle(stage, contextDir) {
        const exportStage = `${stage}-export`;
        this.dockerfileBuilder
            .tempFrom("scratch", exportStage)
            .copyFrom(hooks_1.BUNDLE_PATH, "/bundle.json", stage);
        const ret = this.execDockerBuild(["--target", exportStage, "--output", ".firebase/.output"], contextDir);
        if (ret.error || ret.status !== 0) {
            throw new Error(`Failed to export bundle ${stage}: error=${ret.error} status=${ret.status}`);
        }
        return JSON.parse(fs.readFileSync("./.firebase/.output/bundle.json", "utf8"));
    }
    install() {
        if (this.spec.installCommand) {
            this.dockerfileBuilder
                .fromLastStage(DOCKER_STAGE_INSTALL)
                .workdir("/home/firebase/app")
                .envs(this.spec.environmentVariables || {})
                .copyForFirebase("package.json", ".");
            if (this.spec.packageManagerInstallCommand) {
                this.dockerfileBuilder.run(this.spec.packageManagerInstallCommand);
            }
            this.dockerfileBuilder.run(this.spec.installCommand);
            this.buildStage(DOCKER_STAGE_INSTALL, ".");
        }
    }
    build() {
        if (this.spec.detectedCommands?.build) {
            this.dockerfileBuilder
                .fromLastStage(DOCKER_STAGE_BUILD)
                .copyForFirebase(".", ".")
                .run(this.spec.detectedCommands.build.cmd);
            this.buildStage(DOCKER_STAGE_BUILD, ".");
        }
    }
    export(bundle) {
        const startCmd = bundle.server?.start.cmd;
        if (startCmd) {
            const exportStage = "exporter";
            this.dockerfileBuilder
                .from(this.spec.baseImage, exportStage)
                .workdir("/home/firebase/app")
                .copyForFirebase("/home/firebase/app", ".", DOCKER_STAGE_BUILD)
                .cmd(startCmd);
            const imageName = `us-docker.pkg.dev/${process.env.PROJECT_ID}/test/demo-nodappe`;
            this.buildStage(exportStage, ".", imageName);
            const ret = this.execDockerPush([imageName]);
            if (ret.error || ret.status !== 0) {
                throw new Error(`Failed to push image ${imageName}: error=${ret.error} status=${ret.status}`);
            }
        }
    }
    execHook(bundle, hook) {
        const hookScript = `hook-${Date.now()}.js`;
        const hookScriptSrc = (0, hooks_1.genHookScript)(bundle, hook);
        if (!fs.existsSync(ADAPTER_SCRIPTS_PATH)) {
            fs.mkdirSync(ADAPTER_SCRIPTS_PATH, { recursive: true });
        }
        fs.writeFileSync(path.join(ADAPTER_SCRIPTS_PATH, hookScript), hookScriptSrc);
        const hookStage = path.basename(hookScript, ".js");
        this.dockerfileBuilder
            .fromLastStage(hookStage)
            .run(`NODE_PATH=./node_modules node /framework/adapters/${hookScript}`, `source=${ADAPTER_SCRIPTS_PATH},target=/framework/adapters`);
        this.buildStage(hookStage, ".");
        return this.exportBundle(hookStage, ".");
    }
}
exports.DockerDriver = DockerDriver;
