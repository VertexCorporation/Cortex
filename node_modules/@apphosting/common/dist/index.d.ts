export interface OutputBundleConfig {
    version: "v1";
    runConfig: RunConfig;
    metadata: Metadata;
    outputFiles?: OutputFiles;
}
export interface RunConfig {
    runCommand: string;
    environmentVariables?: EnvVarConfig[];
    concurrency?: number;
    cpu?: number;
    memoryMiB?: number;
    minInstances?: number;
    maxInstances?: number;
}
export interface Metadata {
    adapterPackageName: string;
    adapterVersion: string;
    framework: string;
    frameworkVersion?: string;
}
export interface ApphostingConfig {
    runconfig?: ApphostingRunConfig;
    env?: EnvVarConfig[];
    scripts?: Script;
    outputFiles?: OutputFiles;
}
export interface ApphostingRunConfig {
    minInstances?: number;
    maxInstances?: number;
    concurrency?: number;
}
export interface Script {
    buildCommand?: string;
    runCommand?: string;
}
export interface OutputFiles {
    serverApp: ServerApp;
}
interface ServerApp {
    include: string[];
}
export interface EnvVarConfig {
    variable: string;
    value: string;
    availability: Availability[];
}
export declare enum Availability {
    Runtime = "RUNTIME",
    Build = "BUILD"
}
export interface BuildOptions {
    buildCommand: string;
    buildArgs: string[];
    projectDirectory: string;
    projectName?: string;
}
export interface BuildResult {
    stdout?: string;
    stderr?: string;
}
export declare const DEFAULT_COMMAND = "npm";
export declare function runBuild(opts?: BuildOptions): Promise<BuildResult>;
export declare function getBuildOptions(): BuildOptions;
/**
 * Updates or creates a .gitignore file with the given entries in the given path
 */
export declare function updateOrCreateGitignore(dirPath: string, entries: string[]): void;
export {};
