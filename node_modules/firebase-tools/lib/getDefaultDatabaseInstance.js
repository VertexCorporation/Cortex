"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getDefaultDatabaseInstance = getDefaultDatabaseInstance;
const projects_1 = require("./management/projects");
async function getDefaultDatabaseInstance(project) {
    const projectDetails = await (0, projects_1.getFirebaseProject)(project);
    return projectDetails.resources?.realtimeDatabaseInstance || "";
}
