"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.saveEtags = saveEtags;
exports.detectEtagChanges = detectEtagChanges;
function saveEtags(rc, projectId, instances) {
    rc.setEtags(projectId, "extensionInstances", etagsMap(instances));
}
function detectEtagChanges(rc, projectId, instances) {
    const lastDeployedEtags = rc.getEtags(projectId).extensionInstances;
    const currentEtags = etagsMap(instances);
    if (!lastDeployedEtags || !Object.keys(lastDeployedEtags).length) {
        return [];
    }
    const changedExtensionInstances = Object.entries(lastDeployedEtags)
        .filter(([instanceName, etag]) => etag !== currentEtags[instanceName])
        .map((i) => i[0]);
    const newExtensionInstances = Object.keys(currentEtags).filter((instanceName) => !lastDeployedEtags[instanceName]);
    return newExtensionInstances.concat(changedExtensionInstances);
}
function etagsMap(instances) {
    return instances.reduce((acc, i) => {
        if (i.etag) {
            acc[i.instanceId] = i.etag;
        }
        return acc;
    }, {});
}
