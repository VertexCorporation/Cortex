"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.templateWithSubbedResolverId = templateWithSubbedResolverId;
function templateWithSubbedResolverId(resolverId, template) {
    let replaced = template;
    const resolverIdWithUnderscores = resolverId.replaceAll("-", "_");
    replaced = replaced.replace("__resolverId__", resolverId);
    replaced = replaced.replace("__resolverIdWithUnderscores__", resolverIdWithUnderscores);
    return replaced;
}
