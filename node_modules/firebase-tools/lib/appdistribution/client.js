"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppDistributionClient = void 0;
const utils = require("../utils");
const operationPoller = require("../operation-poller");
const error_1 = require("../error");
const apiv2_1 = require("../apiv2");
const api_1 = require("../api");
class AppDistributionClient {
    constructor() {
        this.appDistroV1Client = new apiv2_1.Client({
            urlPrefix: (0, api_1.appDistributionOrigin)(),
            apiVersion: "v1",
        });
        this.appDistroV1AlphaClient = new apiv2_1.Client({
            urlPrefix: (0, api_1.appDistributionOrigin)(),
            apiVersion: "v1alpha",
        });
    }
    async getAabInfo(appName) {
        const apiResponse = await this.appDistroV1Client.get(`/${appName}/aabInfo`);
        return apiResponse.body;
    }
    async uploadRelease(appName, distribution) {
        const client = new apiv2_1.Client({ urlPrefix: (0, api_1.appDistributionOrigin)() });
        const apiResponse = await client.request({
            method: "POST",
            path: `/upload/v1/${appName}/releases:upload`,
            headers: {
                "X-Goog-Upload-File-Name": encodeURIComponent(distribution.getFileName()),
                "X-Goog-Upload-Protocol": "raw",
                "Content-Type": "application/octet-stream",
            },
            responseType: "json",
            body: distribution.readStream(),
        });
        return apiResponse.body.name;
    }
    async pollUploadStatus(operationName) {
        return operationPoller.pollOperation({
            pollerName: "App Distribution Upload Poller",
            apiOrigin: (0, api_1.appDistributionOrigin)(),
            apiVersion: "v1",
            operationResourceName: operationName,
            masterTimeout: 5 * 60 * 1000,
            backoff: 1000,
            maxBackoff: 10 * 1000,
        });
    }
    async updateReleaseNotes(releaseName, releaseNotes) {
        if (!releaseNotes) {
            utils.logWarning("no release notes specified, skipping");
            return;
        }
        utils.logBullet("updating release notes...");
        const data = {
            name: releaseName,
            releaseNotes: {
                text: releaseNotes,
            },
        };
        const queryParams = { updateMask: "release_notes.text" };
        try {
            await this.appDistroV1Client.patch(`/${releaseName}`, data, { queryParams });
        }
        catch (err) {
            throw new error_1.FirebaseError(`failed to update release notes with ${(0, error_1.getErrMsg)(err)}`);
        }
        utils.logSuccess("added release notes successfully");
    }
    async distribute(releaseName, testerEmails = [], groupAliases = []) {
        if (testerEmails.length === 0 && groupAliases.length === 0) {
            utils.logWarning("no testers or groups specified, skipping");
            return;
        }
        utils.logBullet("distributing to testers/groups...");
        const data = {
            testerEmails,
            groupAliases,
        };
        try {
            await this.appDistroV1Client.post(`/${releaseName}:distribute`, data);
        }
        catch (err) {
            let errorMessage = (0, error_1.getErrMsg)(err);
            const errorStatus = err?.context?.body?.error?.status;
            if (errorStatus === "FAILED_PRECONDITION") {
                errorMessage = "invalid testers";
            }
            else if (errorStatus === "INVALID_ARGUMENT") {
                errorMessage = "invalid groups";
            }
            throw new error_1.FirebaseError(`failed to distribute to testers/groups: ${errorMessage}`, {
                exit: 1,
            });
        }
        utils.logSuccess("distributed to testers/groups successfully");
    }
    async listTesters(projectName, groupName) {
        const testers = [];
        const client = this.appDistroV1Client;
        const filter = groupName ? `groups=${projectName}/groups/${groupName}` : null;
        let pageToken;
        do {
            const queryParams = pageToken ? { pageToken } : {};
            if (filter != null) {
                queryParams["filter"] = filter;
            }
            let apiResponse;
            try {
                apiResponse = await client.get(`${projectName}/testers`, {
                    queryParams,
                });
            }
            catch (err) {
                throw new error_1.FirebaseError(`Client request failed to list testers ${(0, error_1.getErrMsg)(err)}`);
            }
            for (const t of apiResponse.body.testers ?? []) {
                testers.push({
                    name: t.name,
                    displayName: t.displayName,
                    groups: t.groups,
                    lastActivityTime: new Date(t.lastActivityTime),
                });
            }
            pageToken = apiResponse.body.nextPageToken;
        } while (pageToken);
        return testers;
    }
    async addTesters(projectName, emails) {
        try {
            await this.appDistroV1Client.request({
                method: "POST",
                path: `${projectName}/testers:batchAdd`,
                body: { emails: emails },
            });
        }
        catch (err) {
            throw new error_1.FirebaseError(`Failed to add testers ${(0, error_1.getErrMsg)(err)}`);
        }
        utils.logSuccess(`Testers created successfully`);
    }
    async removeTesters(projectName, emails) {
        let apiResponse;
        try {
            apiResponse = await this.appDistroV1Client.request({
                method: "POST",
                path: `${projectName}/testers:batchRemove`,
                body: { emails: emails },
            });
        }
        catch (err) {
            throw new error_1.FirebaseError(`Failed to remove testers ${(0, error_1.getErrMsg)(err)}`);
        }
        return apiResponse.body;
    }
    async listGroups(projectName) {
        const groups = [];
        const client = this.appDistroV1Client;
        let pageToken;
        do {
            const queryParams = pageToken ? { pageToken } : {};
            try {
                const apiResponse = await client.get(`${projectName}/groups`, {
                    queryParams,
                });
                groups.push(...(apiResponse.body.groups ?? []));
                pageToken = apiResponse.body.nextPageToken;
            }
            catch (err) {
                throw new error_1.FirebaseError(`Client failed to list groups ${(0, error_1.getErrMsg)(err)}`);
            }
        } while (pageToken);
        return groups;
    }
    async createGroup(projectName, displayName, alias) {
        let apiResponse;
        try {
            apiResponse = await this.appDistroV1Client.request({
                method: "POST",
                path: alias === undefined ? `${projectName}/groups` : `${projectName}/groups?groupId=${alias}`,
                body: { displayName: displayName },
            });
        }
        catch (err) {
            throw new error_1.FirebaseError(`Failed to create group ${(0, error_1.getErrMsg)(err)}`);
        }
        return apiResponse.body;
    }
    async deleteGroup(groupName) {
        try {
            await this.appDistroV1Client.request({
                method: "DELETE",
                path: groupName,
            });
        }
        catch (err) {
            throw new error_1.FirebaseError(`Failed to delete group ${(0, error_1.getErrMsg)(err)}`);
        }
        utils.logSuccess(`Group deleted successfully`);
    }
    async addTestersToGroup(groupName, emails) {
        try {
            await this.appDistroV1Client.request({
                method: "POST",
                path: `${groupName}:batchJoin`,
                body: { emails: emails },
            });
        }
        catch (err) {
            throw new error_1.FirebaseError(`Failed to add testers to group ${(0, error_1.getErrMsg)(err)}`);
        }
        utils.logSuccess(`Testers added to group successfully`);
    }
    async removeTestersFromGroup(groupName, emails) {
        try {
            await this.appDistroV1Client.request({
                method: "POST",
                path: `${groupName}:batchLeave`,
                body: { emails: emails },
            });
        }
        catch (err) {
            throw new error_1.FirebaseError(`Failed to remove testers from group ${(0, error_1.getErrMsg)(err)}`);
        }
        utils.logSuccess(`Testers removed from group successfully`);
    }
    async createReleaseTest(releaseName, devices, options = {}) {
        try {
            const response = await this.appDistroV1AlphaClient.request({
                method: "POST",
                path: `${releaseName}/tests`,
                body: {
                    deviceExecutions: devices.map((device) => ({ device })),
                    loginCredential: options.loginCredential,
                    testCase: options.testCaseName,
                    aiInstructions: options.aiInstructions,
                    displayName: options.displayName,
                    resultsBucket: options.resultsBucket,
                },
            });
            return response.body;
        }
        catch (err) {
            throw new error_1.FirebaseError(`Failed to create release test ${(0, error_1.getErrMsg)(err)}`);
        }
    }
    async getReleaseTest(releaseTestName) {
        const response = await this.appDistroV1AlphaClient.get(releaseTestName);
        return response.body;
    }
    async listTestCases(appName) {
        const testCases = [];
        const client = this.appDistroV1AlphaClient;
        let pageToken;
        do {
            const queryParams = pageToken ? { pageToken } : {};
            try {
                const apiResponse = await client.get(`${appName}/testCases`, {
                    queryParams,
                });
                testCases.push(...(apiResponse.body.testCases ?? []));
                pageToken = apiResponse.body.nextPageToken;
            }
            catch (err) {
                throw new error_1.FirebaseError(`Client failed to list test cases ${(0, error_1.getErrMsg)(err)}`);
            }
        } while (pageToken);
        return testCases;
    }
    async createTestCase(appName, testCase) {
        try {
            const response = await this.appDistroV1AlphaClient.request({
                method: "POST",
                path: `${appName}/testCases`,
                body: testCase,
            });
            return response.body;
        }
        catch (err) {
            throw new error_1.FirebaseError(`Failed to create test case ${(0, error_1.getErrMsg)(err)}`);
        }
    }
    async batchUpsertTestCases(appName, testCases) {
        try {
            const response = await this.appDistroV1AlphaClient.request({
                method: "POST",
                path: `${appName}/testCases:batchUpdate`,
                body: {
                    requests: testCases.map((tc) => ({
                        testCase: tc,
                        allowMissing: true,
                    })),
                },
            });
            return response.body.testCases;
        }
        catch (err) {
            throw new error_1.FirebaseError(`Failed to upsert test cases ${(0, error_1.getErrMsg)(err)}`);
        }
    }
    async getLatestRelease(appName) {
        try {
            const response = await this.appDistroV1Client.get(`/${appName}/releases`, {
                queryParams: {
                    pageSize: "1",
                    orderBy: "createTime desc",
                },
            });
            if (!response.body.releases?.length) {
                return undefined;
            }
            return response.body.releases[0];
        }
        catch (err) {
            throw new error_1.FirebaseError(`Failed to get latest release for app ${appName}: ${(0, error_1.getErrMsg)(err)}`);
        }
    }
}
exports.AppDistributionClient = AppDistributionClient;
