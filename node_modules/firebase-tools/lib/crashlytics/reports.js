"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReportInputSchema = exports.CrashlyticsReportSchema = exports.CrashlyticsReport = void 0;
exports.simplifyReport = simplifyReport;
exports.getReport = getReport;
const zod_1 = require("zod");
const lodash_1 = require("lodash");
const logger_1 = require("../logger");
const utils_1 = require("./utils");
const filters_1 = require("./filters");
const error_1 = require("../error");
const DEFAULT_PAGE_SIZE = 10;
var CrashlyticsReport;
(function (CrashlyticsReport) {
    CrashlyticsReport["TOP_ISSUES"] = "topIssues";
    CrashlyticsReport["TOP_VARIANTS"] = "topVariants";
    CrashlyticsReport["TOP_VERSIONS"] = "topVersions";
    CrashlyticsReport["TOP_OPERATING_SYSTEMS"] = "topOperatingSystems";
    CrashlyticsReport["TOP_APPLE_DEVICES"] = "topAppleDevices";
    CrashlyticsReport["TOP_ANDROID_DEVICES"] = "topAndroidDevices";
})(CrashlyticsReport || (exports.CrashlyticsReport = CrashlyticsReport = {}));
exports.CrashlyticsReportSchema = zod_1.z.nativeEnum(CrashlyticsReport);
exports.ReportInputSchema = zod_1.z.object({
    appId: filters_1.ApplicationIdSchema,
    report: exports.CrashlyticsReportSchema,
    filter: filters_1.EventFilterSchema,
    pageSize: zod_1.z.number().optional().describe("Number of rows to return").default(DEFAULT_PAGE_SIZE),
});
function simplifyReport(report) {
    const simplifiedReport = (0, lodash_1.cloneDeep)(report);
    if (!simplifiedReport.groups)
        return report;
    simplifiedReport.groups.forEach((group) => {
        if (group.device) {
            delete group.device.model;
            delete group.device.manufacturer;
        }
        if (group.version) {
            delete group.version.buildVersion;
            delete group.version.displayVersion;
        }
        if (group.operatingSystem) {
            delete group.operatingSystem.displayVersion;
            delete group.operatingSystem.os;
        }
    });
    return simplifiedReport;
}
async function getReport(reportName, appId, filter, pageSize = DEFAULT_PAGE_SIZE) {
    if (!reportName) {
        throw new error_1.FirebaseError("Invalid Crashlytics report " + reportName);
    }
    const requestProjectNumber = (0, utils_1.parseProjectNumber)(appId);
    const queryParams = (0, filters_1.filterToUrlSearchParams)(filter);
    queryParams.set("page_size", `${pageSize}`);
    logger_1.logger.debug(`[crashlytics] report ${reportName} called with appId: ${appId} filter: ${queryParams.toString()}, page_size: ${pageSize}`);
    const response = await utils_1.CRASHLYTICS_API_CLIENT.request({
        method: "GET",
        headers: {
            "Content-Type": "application/json",
        },
        path: `/projects/${requestProjectNumber}/apps/${appId}/reports/${reportName}`,
        queryParams: queryParams,
        timeout: utils_1.TIMEOUT,
    });
    return response.body;
}
