"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const csv_parse_1 = require("csv-parse");
const Chain = require("stream-chain");
const clc = require("colorette");
const fs = require("fs-extra");
const Pick = require("stream-json/filters/Pick");
const StreamArray = require("stream-json/streamers/StreamArray");
const command_1 = require("../command");
const error_1 = require("../error");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const requirePermissions_1 = require("../requirePermissions");
const accountImporter_1 = require("../accountImporter");
const MAX_BATCH_SIZE = 1000;
exports.command = new command_1.Command("auth:import [dataFile]")
    .description("import users into your Firebase project from a data file (.csv or .json)")
    .option("--hash-algo <hashAlgo>", "specify the hash algorithm used in password for these accounts")
    .option("--hash-key <hashKey>", "specify the key used in hash algorithm")
    .option("--salt-separator <saltSeparator>", "specify the salt separator which will be appended to salt when verifying password. only used by SCRYPT now.")
    .option("--rounds <rounds>", "specify how many rounds for hash calculation.")
    .option("--mem-cost <memCost>", "specify the memory cost for firebase scrypt, or cpu/memory cost for standard scrypt")
    .option("--parallelization <parallelization>", "specify the parallelization for standard scrypt.")
    .option("--block-size <blockSize>", "specify the block size (normally is 8) for standard scrypt.")
    .option("--dk-len <dkLen>", "specify derived key length for standard scrypt.")
    .option("--hash-input-order <hashInputOrder>", "specify the order of password and salt. Possible values are SALT_FIRST and PASSWORD_FIRST. " +
    "MD5, SHA1, SHA256, SHA512, HMAC_MD5, HMAC_SHA1, HMAC_SHA256, HMAC_SHA512 support this flag.")
    .before(requirePermissions_1.requirePermissions, ["firebaseauth.users.create", "firebaseauth.users.update"])
    .action(async (dataFile, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const checkRes = (0, accountImporter_1.validateOptions)(options);
    if (!checkRes.valid) {
        return checkRes;
    }
    const hashOptions = checkRes;
    if (!dataFile.endsWith(".csv") && !dataFile.endsWith(".json")) {
        throw new error_1.FirebaseError("Data file must end with .csv or .json");
    }
    const stats = await fs.stat(dataFile);
    const fileSizeInBytes = stats.size;
    logger_1.logger.info(`Processing ${clc.bold(dataFile)} (${fileSizeInBytes} bytes)`);
    const batches = [];
    let currentBatch = [];
    let counter = 0;
    let userListArr = [];
    const inStream = fs.createReadStream(dataFile);
    if (dataFile.endsWith(".csv")) {
        userListArr = await new Promise((resolve, reject) => {
            const parser = (0, csv_parse_1.parse)();
            parser
                .on("readable", () => {
                let record = [];
                while ((record = parser.read()) !== null) {
                    counter++;
                    const trimmed = record.map((s) => {
                        const str = s.trim().replace(/^["|'](.*)["|']$/, "$1");
                        return str === "" ? undefined : str;
                    });
                    const user = (0, accountImporter_1.transArrayToUser)(trimmed);
                    const err = user.error;
                    if (err) {
                        return reject(new error_1.FirebaseError(`Line ${counter} (${record.join(",")}) has invalid data format: ${err}`));
                    }
                    currentBatch.push(user);
                    if (currentBatch.length === MAX_BATCH_SIZE) {
                        batches.push(currentBatch);
                        currentBatch = [];
                    }
                }
            })
                .on("end", () => {
                if (currentBatch.length) {
                    batches.push(currentBatch);
                }
                resolve(batches);
            });
            inStream.pipe(parser);
        });
    }
    else {
        userListArr = await new Promise((resolve, reject) => {
            const pipeline = new Chain([
                Pick.withParser({ filter: /^users$/ }),
                StreamArray.streamArray(),
                ({ value }) => {
                    counter++;
                    const user = (0, accountImporter_1.validateUserJson)(value);
                    const err = user.error;
                    if (err) {
                        throw new error_1.FirebaseError(`Validation Error: ${err}`);
                    }
                    currentBatch.push(value);
                    if (currentBatch.length === MAX_BATCH_SIZE) {
                        batches.push(currentBatch);
                        currentBatch = [];
                    }
                },
            ]);
            pipeline.once("error", reject);
            pipeline.on("finish", () => {
                if (currentBatch.length) {
                    batches.push(currentBatch);
                }
                resolve(batches);
            });
            inStream.pipe(pipeline);
        });
    }
    logger_1.logger.debug(`Preparing to import ${counter} user records in ${userListArr.length} batches.`);
    if (userListArr.length) {
        return (0, accountImporter_1.serialImportUsers)(projectId, hashOptions, userListArr, 0);
    }
});
