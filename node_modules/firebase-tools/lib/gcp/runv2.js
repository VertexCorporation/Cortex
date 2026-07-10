"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FIREBASE_FUNCTION_METADTA_ANNOTATION = exports.FUNCTION_SIGNATURE_TYPE_ENV = exports.FUNCTION_TARGET_ENV = exports.FUNCTION_ID_ANNOTATION = exports.FUNCTION_TARGET_ANNOTATION = exports.TRIGGER_TYPE_ANNOTATION = exports.CLIENT_NAME_LABEL = exports.RUNTIME_LABEL = exports.API_VERSION = void 0;
exports.submitBuild = submitBuild;
exports.updateService = updateService;
exports.createService = createService;
exports.deleteService = deleteService;
exports.getService = getService;
exports.listServices = listServices;
exports.endpointFromService = endpointFromService;
exports.serviceFromEndpoint = serviceFromEndpoint;
const apiv2_1 = require("../apiv2");
const error_1 = require("../error");
const api_1 = require("../api");
const proto = require("./proto");
const metaprogramming_1 = require("../metaprogramming");
const operation_poller_1 = require("../operation-poller");
const backend = require("../deploy/functions/backend");
const constants_1 = require("../functions/constants");
const k8s_1 = require("./k8s");
const supported_1 = require("../deploy/functions/runtimes/supported");
const logger_1 = require("../logger");
const functional_1 = require("../functional");
exports.API_VERSION = "v2";
const client = new apiv2_1.Client({
    urlPrefix: (0, api_1.runOrigin)(),
    auth: true,
    apiVersion: exports.API_VERSION,
});
(0, metaprogramming_1.assertImplements)();
async function submitBuild(projectId, location, build) {
    const res = await client.post(`/projects/${projectId}/locations/${location}/builds`, build);
    if (res.status !== 200) {
        throw new error_1.FirebaseError(`Failed to submit build: ${res.status} ${res.body}`);
    }
    await (0, operation_poller_1.pollOperation)({
        apiOrigin: (0, api_1.cloudbuildOrigin)(),
        apiVersion: "v1",
        operationResourceName: res.body.buildOperation,
    });
}
async function updateService(service) {
    const fieldMask = proto.fieldMasks(service, "labels", "annotations", "tags");
    fieldMask.push("template.revision");
    const res = await client.patch(service.name, service, {
        queryParams: {
            updateMask: fieldMask.join(","),
        },
    });
    const svc = await (0, operation_poller_1.pollOperation)({
        apiOrigin: (0, api_1.runOrigin)(),
        apiVersion: exports.API_VERSION,
        operationResourceName: res.body.name,
    });
    return svc;
}
async function createService(projectId, location, serviceId, service) {
    const { name, ...serviceBody } = service;
    const res = await client.post(`/projects/${projectId}/locations/${location}/services`, serviceBody, {
        queryParams: {
            serviceId,
        },
    });
    const svc = await (0, operation_poller_1.pollOperation)({
        apiOrigin: (0, api_1.runOrigin)(),
        apiVersion: exports.API_VERSION,
        operationResourceName: res.body.name,
    });
    return svc;
}
async function deleteService(projectId, location, serviceId) {
    const name = `projects/${projectId}/locations/${location}/services/${serviceId}`;
    const res = await client.delete(name);
    await (0, operation_poller_1.pollOperation)({
        apiOrigin: (0, api_1.runOrigin)(),
        apiVersion: exports.API_VERSION,
        operationResourceName: res.body.name,
    });
}
async function getService(projectId, location, serviceId) {
    const name = `projects/${projectId}/locations/${location}/services/${serviceId}`;
    const res = await client.get(name);
    return res.body;
}
async function listServices(projectId) {
    const allServices = [];
    let pageToken = undefined;
    do {
        const queryParams = {};
        if (pageToken) {
            queryParams["pageToken"] = pageToken;
        }
        const res = await client.get(`/projects/${projectId}/locations/-/services`, { queryParams });
        if (res.status !== 200) {
            throw new error_1.FirebaseError(`Failed to list services. HTTP Error: ${res.status}`, {
                original: res.body,
            });
        }
        if (res.body.services) {
            for (const service of res.body.services) {
                if (service.labels?.[exports.CLIENT_NAME_LABEL] === "cloud-functions" ||
                    service.labels?.[exports.CLIENT_NAME_LABEL] === "cloudfunctions" ||
                    service.labels?.[exports.CLIENT_NAME_LABEL] === "firebase-functions") {
                    allServices.push(service);
                }
            }
        }
        pageToken = res.body.nextPageToken;
    } while (pageToken);
    return allServices;
}
function functionNameToServiceName(id) {
    return id.toLowerCase().replace(/_/g, "-");
}
exports.RUNTIME_LABEL = "goog-cloudfunctions-runtime";
exports.CLIENT_NAME_LABEL = "goog-managed-by";
exports.TRIGGER_TYPE_ANNOTATION = "cloudfunctions.googleapis.com/trigger-type";
exports.FUNCTION_TARGET_ANNOTATION = "run.googleapis.com/build-function-target";
exports.FUNCTION_ID_ANNOTATION = "cloudfunctions.googleapis.com/function-id";
exports.FUNCTION_TARGET_ENV = "FUNCTION_TARGET";
exports.FUNCTION_SIGNATURE_TYPE_ENV = "FUNCTION_SIGNATURE_TYPE";
exports.FIREBASE_FUNCTION_METADTA_ANNOTATION = "firebase-functions-metadata";
function endpointFromService(service) {
    const [, project, , location, , svcId] = service.name.split("/");
    const metadata = JSON.parse(service.annotations?.[exports.FIREBASE_FUNCTION_METADTA_ANNOTATION] || "{}");
    const [env, secretEnv] = (0, functional_1.partition)(service.template.containers[0].env || [], (e) => "value" in e);
    const id = metadata.functionId ||
        service.annotations?.[exports.FUNCTION_ID_ANNOTATION] ||
        service.annotations?.[exports.FUNCTION_TARGET_ANNOTATION] ||
        env.find((e) => e.name === exports.FUNCTION_TARGET_ENV)?.value ||
        svcId;
    const memory = (0, k8s_1.mebibytes)(service.template.containers[0].resources.limits.memory);
    if (!backend.isValidMemoryOption(memory)) {
        logger_1.logger.debug("Converting a service to an endpoint with an invalid memory option", memory);
    }
    const cpu = Number(service.template.containers[0].resources.limits.cpu);
    const endpoint = {
        platform: service.labels?.[exports.CLIENT_NAME_LABEL] === "cloud-functions" ||
            service.labels?.[exports.CLIENT_NAME_LABEL] === "cloudfunctions"
            ? "gcfv2"
            : "run",
        id,
        project,
        labels: { ...service.labels, "deployment-tool": "cli-firebase" },
        region: location,
        runtime: service.labels?.[exports.RUNTIME_LABEL] || (0, supported_1.latest)("nodejs"),
        availableMemoryMb: memory,
        cpu: cpu,
        entryPoint: env.find((e) => e.name === exports.FUNCTION_TARGET_ENV)?.value ||
            service.annotations?.[exports.FUNCTION_TARGET_ANNOTATION] ||
            service.annotations?.[exports.FUNCTION_ID_ANNOTATION] ||
            id,
        timeoutSeconds: service.template.timeout
            ? proto.secondsFromDuration(service.template.timeout)
            : 60,
        serviceAccount: service.template.serviceAccount || null,
        ingressSettings: (service.annotations?.["run.googleapis.com/ingress"] === "internal"
            ? "ALLOW_INTERNAL_ONLY"
            : service.annotations?.["run.googleapis.com/ingress"] === "internal-and-cloud-load-balancing"
                ? "ALLOW_INTERNAL_AND_GCLB"
                : "ALLOW_ALL"),
        ...(!service.annotations?.[exports.TRIGGER_TYPE_ANNOTATION] ||
            service.annotations?.[exports.TRIGGER_TYPE_ANNOTATION] === "HTTP_TRIGGER"
            ? { httpsTrigger: {} }
            : {
                eventTrigger: {
                    eventType: service.annotations?.[exports.TRIGGER_TYPE_ANNOTATION] || "unknown",
                    retry: false,
                },
            }),
    };
    proto.renameIfPresent(endpoint, service.template, "concurrency", "maxInstanceRequestConcurrency");
    proto.renameIfPresent(endpoint, service.labels || {}, "codebase", constants_1.CODEBASE_LABEL);
    proto.renameIfPresent(endpoint, service.scaling || {}, "minInstances", "minInstanceCount");
    proto.renameIfPresent(endpoint, service.scaling || {}, "maxInstances", "maxInstanceCount");
    endpoint.environmentVariables = env.reduce((acc, e) => {
        acc[e.name] = e.value;
        return acc;
    }, {});
    endpoint.secretEnvironmentVariables = secretEnv.map((e) => {
        const [, projectId, , secret] = e.valueSource.secretKeyRef.secret.split("/");
        return {
            key: e.name,
            projectId,
            secret,
            version: e.valueSource.secretKeyRef.version || "latest",
        };
    });
    if (service.template.vpcAccess) {
        endpoint.vpc = {
            connector: service.template.vpcAccess.connector || "",
            egressSettings: service.template.vpcAccess.egress || null,
        };
    }
    return endpoint;
}
function serviceFromEndpoint(endpoint, image) {
    const labels = {
        ...endpoint.labels,
        ...(endpoint.runtime ? { [exports.RUNTIME_LABEL]: endpoint.runtime } : {}),
        [exports.CLIENT_NAME_LABEL]: "firebase-functions",
    };
    delete labels["deployment-tool"];
    if (endpoint.codebase) {
        labels[constants_1.CODEBASE_LABEL] = endpoint.codebase;
    }
    const annotations = {
        [exports.FIREBASE_FUNCTION_METADTA_ANNOTATION]: JSON.stringify({
            functionId: endpoint.id,
        }),
    };
    const template = {
        annotations: {
            "run.googleapis.com/client-name": "cli-firebase",
        },
        containers: [
            {
                name: "worker",
                image,
                env: [
                    ...Object.entries(endpoint.environmentVariables || {}).map(([name, value]) => ({
                        name,
                        value,
                    })),
                    ...(endpoint.secretEnvironmentVariables || []).map((secret) => ({
                        name: secret.key,
                        valueSource: {
                            secretKeyRef: {
                                secret: secret.secret,
                                version: secret.version,
                            },
                        },
                    })),
                    {
                        name: exports.FUNCTION_TARGET_ENV,
                        value: endpoint.entryPoint,
                    },
                    {
                        name: exports.FUNCTION_SIGNATURE_TYPE_ENV,
                        value: backend.isEventTriggered(endpoint) ? "cloudevent" : "http",
                    },
                ],
                resources: {
                    limits: {
                        cpu: String(endpoint.cpu || 1),
                        memory: `${endpoint.availableMemoryMb || 256}Mi`,
                    },
                    cpuIdle: true,
                    startupCpuBoost: true,
                },
                ...(endpoint.baseImageUri ? { baseImageUri: endpoint.baseImageUri } : {}),
                ...(endpoint.command ? { command: endpoint.command } : {}),
                ...(endpoint.args ? { args: endpoint.args } : {}),
            },
        ],
        maxInstanceRequestConcurrency: endpoint.concurrency || backend.DEFAULT_CONCURRENCY,
    };
    proto.renameIfPresent(template, endpoint, "maxInstanceRequestConcurrency", "concurrency");
    const service = {
        name: `projects/${endpoint.project}/locations/${endpoint.region}/services/${functionNameToServiceName(endpoint.id)}`,
        labels,
        annotations,
        template,
        client: "cli-firebase",
    };
    if (endpoint.minInstances || endpoint.maxInstances) {
        service.scaling = {};
        proto.renameIfPresent(service.scaling, endpoint, "minInstanceCount", "minInstances");
        proto.renameIfPresent(service.scaling, endpoint, "maxInstanceCount", "maxInstances");
    }
    if (endpoint.serviceAccount) {
        template.serviceAccount = endpoint.serviceAccount;
    }
    if (endpoint.timeoutSeconds) {
        template.timeout = proto.durationFromSeconds(endpoint.timeoutSeconds);
    }
    if (endpoint.vpc) {
        template.vpcAccess = {
            connector: endpoint.vpc.connector,
            egress: endpoint.vpc.egressSettings || undefined,
        };
    }
    if (endpoint.ingressSettings) {
        const ingressAnnotation = endpoint.ingressSettings === "ALLOW_INTERNAL_ONLY"
            ? "internal"
            : endpoint.ingressSettings === "ALLOW_INTERNAL_AND_GCLB"
                ? "internal-and-cloud-load-balancing"
                : "all";
        service.annotations = {
            ...service.annotations,
            "run.googleapis.com/ingress": ingressAnnotation,
        };
    }
    return service;
}
