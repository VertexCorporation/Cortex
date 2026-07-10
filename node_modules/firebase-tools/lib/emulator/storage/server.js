"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createApp = createApp;
const cors = require("cors");
const express = require("express");
const emulatorLogger_1 = require("../emulatorLogger");
const types_1 = require("../types");
const bodyParser = require("body-parser");
const gcloud_1 = require("./apis/gcloud");
const firebase_1 = require("./apis/firebase");
const errors_1 = require("../auth/errors");
function createApp(defaultProjectId, emulator) {
    const { storageLayer } = emulator;
    const app = express();
    emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.STORAGE).log("DEBUG", `Temp file directory for storage emulator: ${storageLayer.dirPath}`);
    app.use("/", (req, res, next) => {
        if (req.headers["access-control-request-private-network"]) {
            res.setHeader("access-control-allow-private-network", "true");
        }
        next();
    });
    app.use(cors({
        origin: true,
        exposedHeaders: [
            "content-type",
            "x-firebase-storage-version",
            "X-Goog-Upload-Size-Received",
            "x-goog-upload-url",
            "x-goog-upload-command",
            "x-gupload-uploadid",
            "x-goog-upload-header-content-length",
            "x-goog-upload-header-content-type",
            "x-goog-upload-protocol",
            "x-goog-upload-status",
            "x-goog-upload-chunk-granularity",
            "x-goog-upload-control-url",
        ],
    }));
    app.use(bodyParser.raw({ limit: "130mb", type: "application/x-www-form-urlencoded" }));
    app.use(bodyParser.raw({ limit: "130mb", type: "multipart/related" }));
    app.use(express.json({
        type: ["application/json"],
    }));
    app.post("/internal/export", async (req, res) => {
        const initiatedBy = req.body.initiatedBy || "unknown";
        const path = req.body.path;
        if (!path) {
            res.status(400).send("Export request body must include 'path'.");
            return;
        }
        await storageLayer.export(path, { initiatedBy });
        res.sendStatus(200);
    });
    app.put("/internal/setRules", async (req, res) => {
        const rulesRaw = req.body.rules;
        if (!(rulesRaw && Array.isArray(rulesRaw.files) && rulesRaw.files.length > 0)) {
            res.status(400).json({
                message: "Request body must include 'rules.files' array",
            });
            return;
        }
        const { files } = rulesRaw;
        function parseRulesFromFiles(files) {
            if (files.length === 1) {
                const file = files[0];
                if (!isRulesFile(file)) {
                    throw new errors_1.InvalidArgumentError("Each member of 'rules.files' array must contain 'name' and 'content'");
                }
                return { name: file.name, content: file.content };
            }
            const rules = [];
            for (const file of files) {
                if (!isRulesFile(file) || !file.resource) {
                    throw new errors_1.InvalidArgumentError("Each member of 'rules.files' array must contain 'name', 'content', and 'resource'");
                }
                rules.push({ resource: file.resource, rules: { name: file.name, content: file.content } });
            }
            return rules;
        }
        let rules;
        try {
            rules = parseRulesFromFiles(files);
        }
        catch (err) {
            if (err instanceof errors_1.InvalidArgumentError) {
                res.status(400).json({ message: err.message });
                return;
            }
            throw err;
        }
        const issues = await emulator.replaceRules(rules);
        if (issues.errors.length > 0) {
            res.status(400).json({
                message: "There was an error updating rules, see logs for more details",
            });
            return;
        }
        res.status(200).json({
            message: "Rules updated successfully",
        });
    });
    app.post("/internal/reset", (req, res) => {
        emulator.reset();
        res.sendStatus(200);
    });
    app.use("/v0", (0, firebase_1.createFirebaseEndpoints)(emulator));
    app.use("/", (0, gcloud_1.createCloudEndpoints)(emulator));
    return Promise.resolve(app);
}
function isRulesFile(file) {
    return (typeof file.name === "string" && typeof file.content === "string");
}
