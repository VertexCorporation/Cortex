"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.list_backends = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const apphosting_1 = require("../../../gcp/apphosting");
exports.list_backends = (0, tool_1.tool)("apphosting", {
    name: "list_backends",
    description: "Use this to retrieve a list of App Hosting backends in the current project. An empty list means that there are no backends. " +
        "The `uri` is the public URL of the backend. " +
        "A working backend will have a `managed_resources` array that will contain a `run_service` entry. That `run_service.service` " +
        "is the resource name of the Cloud Run service serving the App Hosting backend. The last segment of that name is the service ID. " +
        "`domains` is the list of domains that are associated with the backend. They either have type `CUSTOM` or `DEFAULT`. " +
        "  Every backend should have a `DEFAULT` domain. " +
        "  The actual domain that a user would use to connect to the backend is the last parameter of the domain resource name. " +
        "  If a custom domain is correctly set up, it will have statuses ending in `ACTIVE`.",
    inputSchema: zod_1.z.object({
        location: zod_1.z
            .string()
            .optional()
            .default("-")
            .describe("Limit the listed backends to this region. By default, it will list all backends across all regions."),
    }),
    annotations: {
        title: "List App Hosting backends.",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
    },
}, async ({ location }, { projectId }) => {
    projectId = projectId || "";
    if (!location)
        location = "-";
    const backends = await (0, apphosting_1.listBackends)(projectId, location);
    if (!backends.backends.length) {
        return (0, util_1.toContent)(`No backends exist for project ${projectId}${location !== "-" ? ` in ${location}` : ""}.`);
    }
    const promises = backends.backends.map(async (backend) => {
        const { location, id } = (0, apphosting_1.parseBackendName)(backend.name);
        const [traffic, domains] = await Promise.all([
            (0, apphosting_1.getTraffic)(projectId, location, id),
            (0, apphosting_1.listDomains)(projectId, location, id),
        ]);
        return { ...backend, traffic: traffic, domains: domains };
    });
    const data = await Promise.all(promises);
    return (0, util_1.toContent)(data);
});
