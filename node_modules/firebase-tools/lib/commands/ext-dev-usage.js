"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const Table = require("cli-table3");
const clc = require("colorette");
const utils = require("../utils");
const command_1 = require("../command");
const cloudmonitoring_1 = require("../gcp/cloudmonitoring");
const requireAuth_1 = require("../requireAuth");
const checkMinRequiredVersion_1 = require("../checkMinRequiredVersion");
const metricsUtils_1 = require("../extensions/metricsUtils");
const publisherApi_1 = require("../extensions/publisherApi");
const extensionsHelper_1 = require("../extensions/extensionsHelper");
const error_1 = require("../error");
const logger_1 = require("../logger");
const prompt_1 = require("../prompt");
exports.command = new command_1.Command("ext:dev:usage <publisherId>")
    .description("get usage statistics for an extension")
    .help("use this command to get the usage of extensions you published. " +
    "Specify the publisher ID you used to publish your extensions, " +
    "or the extension ref of your published extension")
    .before(requireAuth_1.requireAuth)
    .before(checkMinRequiredVersion_1.checkMinRequiredVersion, "extDevMinVersion")
    .action(async (input) => {
    const extensionRefRegex = /^[\w\d-]+\/[\w\d-]+$/;
    let extensionName;
    let publisherId;
    if (extensionRefRegex.test(input)) {
        [publisherId, extensionName] = input.split("/");
    }
    else {
        publisherId = input;
        let extensions;
        try {
            extensions = await (0, publisherApi_1.listExtensions)(publisherId);
        }
        catch (err) {
            throw new error_1.FirebaseError((0, error_1.getErrMsg)(err));
        }
        if (extensions.length < 1) {
            throw new error_1.FirebaseError(`There are no published extensions associated with publisher ID ${clc.bold(publisherId)}. This could happen for two reasons:\n` +
                "  - The publisher ID doesn't exist or could be misspelled\n" +
                "  - This publisher has not published any extensions\n\n" +
                "If you are expecting some extensions to appear, please make sure you have the correct publisher ID and try again.");
        }
        extensionName = await (0, prompt_1.select)({
            message: "Which published extension do you want to view the stats for?",
            choices: extensions.map((e) => {
                const [_, name] = e.ref.split("/");
                return {
                    name,
                    value: name,
                };
            }),
        });
    }
    const profile = await (0, publisherApi_1.getPublisherProfile)("-", publisherId);
    const projectNumber = (0, extensionsHelper_1.getPublisherProjectFromName)(profile.name);
    const past45d = new Date();
    past45d.setDate(past45d.getDate() - 45);
    const query = {
        filter: `metric.type="firebaseextensions.googleapis.com/extension/version/active_instances" ` +
            `resource.type="firebaseextensions.googleapis.com/ExtensionVersion" ` +
            `resource.labels.extension="${extensionName}"`,
        "interval.endTime": new Date().toJSON(),
        "interval.startTime": past45d.toJSON(),
        view: cloudmonitoring_1.TimeSeriesView.FULL,
        "aggregation.alignmentPeriod": (60 * 60 * 24).toString() + "s",
        "aggregation.perSeriesAligner": cloudmonitoring_1.Aligner.ALIGN_MAX,
    };
    let response;
    try {
        response = await (0, cloudmonitoring_1.queryTimeSeries)(query, projectNumber);
    }
    catch (err) {
        throw new error_1.FirebaseError(`Error occurred when fetching usage data for extension ${extensionName}`, {
            original: (0, error_1.getError)(err),
        });
    }
    if (!response) {
        throw new error_1.FirebaseError(`Couldn't find any usage data for extension ${extensionName}`);
    }
    const metrics = (0, metricsUtils_1.parseTimeseriesResponse)(response);
    const table = new Table({
        head: ["Version", "Active Instances", "Changes last 7 Days", "Changes last 28 Days"],
        style: {
            head: ["yellow"],
        },
        colAligns: ["left", "right", "right", "right"],
    });
    metrics.forEach((m) => {
        table.push((0, metricsUtils_1.buildMetricsTableRow)(m));
    });
    utils.logLabeledBullet(extensionsHelper_1.logPrefix, `showing usage stats for ${clc.bold(extensionName)}:`);
    logger_1.logger.info(table.toString());
    utils.logLabeledBullet(extensionsHelper_1.logPrefix, `How to read this table:`);
    logger_1.logger.info(`* Due to privacy considerations, numbers are reported as ranges.`);
    logger_1.logger.info(`* In the absence of significant changes, we will render a '-' symbol.`);
    logger_1.logger.info(`* You will need more than 10 installs over a period of more than 28 days to render sufficient data.`);
});
async function buildCloudMonitoringLink(args) {
    const pageState = {
        xyChart: {
            dataSets: [
                {
                    timeSeriesFilter: {
                        filter: `metric.type="firebaseextensions.googleapis.com/extension/version/active_instances"` +
                            ` resource.type="firebaseextensions.googleapis.com/ExtensionVersion"` +
                            ` resource.label.extension="${args.extensionName}"`,
                        minAlignmentPeriod: "86400s",
                        aggregations: [
                            {
                                perSeriesAligner: "ALIGN_MEAN",
                                crossSeriesReducer: "REDUCE_MAX",
                                alignmentPeriod: "86400s",
                                groupByFields: ['resource.label."extension"', 'resource.label."version"'],
                            },
                            {
                                crossSeriesReducer: "REDUCE_NONE",
                                alignmentPeriod: "60s",
                                groupByFields: [],
                            },
                        ],
                    },
                },
            ],
        },
        isAutoRefresh: true,
        timeSelection: {
            timeRange: "4w",
        },
    };
    let uri = `https://console.cloud.google.com/monitoring/metrics-explorer?project=${args.projectNumber}` +
        `&pageState=${JSON.stringify(pageState)}`;
    uri = encodeURI(uri);
    return uri;
}
