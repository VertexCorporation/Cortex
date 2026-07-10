"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ONEMCP_SERVERS = void 0;
const api_1 = require("../../api");
const onemcp_server_1 = require("./onemcp_server");
exports.ONEMCP_SERVERS = {
    developerknowledge: new onemcp_server_1.OneMcpServer("developerknowledge", (0, api_1.developerKnowledgeOrigin)(), {
        requiresAuth: true,
    }),
    firestore: new onemcp_server_1.OneMcpServer("firestore", (0, api_1.firestoreOrigin)(), {
        requiresAuth: true,
        requiresProject: true,
    }),
};
