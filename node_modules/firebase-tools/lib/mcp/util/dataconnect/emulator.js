"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getDataConnectEmulatorClient = getDataConnectEmulatorClient;
const types_1 = require("../../../emulator/types");
const apiv2_1 = require("../../../apiv2");
const dataplaneClient_1 = require("../../../dataconnect/dataplaneClient");
async function getDataConnectEmulatorClient(host) {
    const emulatorUrl = await host.getEmulatorUrl(types_1.Emulators.DATACONNECT);
    const apiClient = new apiv2_1.Client({
        urlPrefix: emulatorUrl,
        apiVersion: dataplaneClient_1.DATACONNECT_API_VERSION,
    });
    return apiClient;
}
