"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.V2_FREE_TIER = exports.V1_FREE_TIER = exports.V2_RATES = exports.V1_RATES = void 0;
exports.canCalculateMinInstanceCost = canCalculateMinInstanceCost;
exports.monthlyMinInstanceCost = monthlyMinInstanceCost;
const backend = require("./backend");
const V1_REGION_TO_TIER = {
    "us-central1": 1,
    "us-east1": 1,
    "us-east4": 1,
    "europe-west1": 1,
    "europe-west2": 1,
    "asia-east2": 1,
    "asia-northeast1": 1,
    "asia-northeast2": 1,
    "us-west2": 2,
    "us-west3": 2,
    "us-west4": 2,
    "northamerica-northeast1": 2,
    "southamerica-east1": 2,
    "europe-west3": 2,
    "europe-west6": 2,
    "europe-central2": 2,
    "australia-southeast1": 2,
    "asia-south1": 2,
    "asia-southeast2": 2,
    "asia-northeast3": 2,
};
const V2_REGION_TO_TIER = {
    "africa-south1": 1,
    "asia-east1": 1,
    "asia-northeast1": 1,
    "asia-northeast2": 1,
    "europe-north1": 1,
    "europe-southwest1": 1,
    "europe-west1": 1,
    "europe-west4": 1,
    "europe-west8": 1,
    "europe-west9": 1,
    "me-west1": 1,
    "us-central1": 1,
    "us-east1": 1,
    "us-east4": 1,
    "us-east5": 1,
    "us-south1": 1,
    "us-west1": 1,
    "asia-east2": 2,
    "asia-northeast3": 2,
    "asia-south1": 2,
    "asia-south2": 2,
    "asia-southeast1": 2,
    "asia-southeast2": 2,
    "australia-southeast1": 2,
    "australia-southeast2": 2,
    "europe-central2": 2,
    "europe-west2": 2,
    "europe-west3": 2,
    "europe-west6": 2,
    "europe-west10": 2,
    "europe-west12": 2,
    "me-central1": 2,
    "me-central2": 2,
    "northamerica-northeast1": 2,
    "northamerica-northeast2": 2,
    "southamerica-east1": 2,
    "southamerica-west1": 2,
    "us-west2": 2,
    "us-west3": 2,
    "us-west4": 2,
};
exports.V1_RATES = {
    invocations: 4e-7,
    memoryGb: {
        1: 0.0000025,
        2: 0.0000035,
    },
    cpuGhz: {
        1: 0.00001,
        2: 0.000014,
    },
    idleCpuGhz: {
        1: 0.000001,
        2: 0.00000145,
    },
    egress: 0.12,
};
exports.V2_RATES = {
    invocations: 4e-7,
    memoryGb: {
        1: 0.0000025,
        2: 0.0000035,
    },
    vCpu: {
        1: 0.000024,
        2: 0.0000336,
    },
    idleVCpu: {
        1: 0.0000025,
        2: 0.0000035,
    },
};
exports.V1_FREE_TIER = {
    invocations: 2000000,
    memoryGb: 400000,
    cpuGhz: 200000,
    egress: 5,
};
exports.V2_FREE_TIER = {
    invocations: 2000000,
    memoryGb: 360000,
    vCpu: 180000,
    egress: 1,
};
const VCPU_TO_GHZ = 2.4;
const MB_TO_GHZ = {
    128: 0.2,
    256: 0.4,
    512: 0.8,
    1024: 1.4,
    2048: 1 * VCPU_TO_GHZ,
    4096: 2 * VCPU_TO_GHZ,
    8192: 2 * VCPU_TO_GHZ,
    16384: 4 * VCPU_TO_GHZ,
    32768: 8 * VCPU_TO_GHZ,
};
function canCalculateMinInstanceCost(endpoint) {
    if (endpoint.minInstances === undefined || endpoint.minInstances === null) {
        return true;
    }
    if (endpoint.platform === "gcfv1") {
        if (!MB_TO_GHZ[endpoint.availableMemoryMb || backend.DEFAULT_MEMORY]) {
            return false;
        }
        if (!V1_REGION_TO_TIER[endpoint.region]) {
            return false;
        }
        return true;
    }
    if (!V2_REGION_TO_TIER[endpoint.region]) {
        return false;
    }
    return true;
}
const SECONDS_PER_MONTH = 30 * 24 * 60 * 60;
function monthlyMinInstanceCost(endpoints) {
    const usage = {
        gcfv1: { 1: { ram: 0, cpu: 0 }, 2: { ram: 0, cpu: 0 } },
        gcfv2: { 1: { ram: 0, cpu: 0 }, 2: { ram: 0, cpu: 0 } },
        run: { 1: { ram: 0, cpu: 0 }, 2: { ram: 0, cpu: 0 } },
    };
    for (const endpoint of endpoints) {
        if (endpoint.minInstances === undefined || endpoint.minInstances === null) {
            continue;
        }
        const ramMb = endpoint.availableMemoryMb || backend.DEFAULT_MEMORY;
        const ramGb = ramMb / 1024;
        if (endpoint.platform === "gcfv1") {
            const cpu = MB_TO_GHZ[ramMb];
            const tier = V1_REGION_TO_TIER[endpoint.region];
            usage["gcfv1"][tier].ram =
                usage["gcfv1"][tier].ram + ramGb * SECONDS_PER_MONTH * endpoint.minInstances;
            usage["gcfv1"][tier].cpu =
                usage["gcfv1"][tier].cpu + cpu * SECONDS_PER_MONTH * endpoint.minInstances;
        }
        else {
            const tier = V2_REGION_TO_TIER[endpoint.region];
            usage[endpoint.platform][tier].ram =
                usage[endpoint.platform][tier].ram + ramGb * SECONDS_PER_MONTH * endpoint.minInstances;
            usage[endpoint.platform][tier].cpu =
                usage[endpoint.platform][tier].cpu +
                    endpoint.cpu * SECONDS_PER_MONTH * endpoint.minInstances;
        }
    }
    let v1MemoryBill = usage["gcfv1"][1].ram * exports.V1_RATES.memoryGb[1] + usage["gcfv1"][2].ram * exports.V1_RATES.memoryGb[2];
    v1MemoryBill -= exports.V1_FREE_TIER.memoryGb * exports.V1_RATES.memoryGb[1];
    v1MemoryBill = Math.max(v1MemoryBill, 0);
    let v1CpuBill = usage["gcfv1"][1].cpu * exports.V1_RATES.idleCpuGhz[1] + usage["gcfv1"][2].cpu * exports.V1_RATES.idleCpuGhz[2];
    v1CpuBill -= exports.V1_FREE_TIER.cpuGhz * exports.V1_RATES.cpuGhz[1];
    v1CpuBill = Math.max(v1CpuBill, 0);
    let v2MemoryBill = usage["gcfv2"][1].ram * exports.V2_RATES.memoryGb[1] + usage["gcfv2"][2].ram * exports.V2_RATES.memoryGb[2];
    v2MemoryBill -= exports.V2_FREE_TIER.memoryGb * exports.V2_RATES.memoryGb[1];
    v2MemoryBill = Math.max(v2MemoryBill, 0);
    let v2CpuBill = usage["gcfv2"][1].cpu * exports.V2_RATES.idleVCpu[1] + usage["gcfv2"][2].cpu * exports.V2_RATES.idleVCpu[2];
    v2CpuBill -= exports.V2_FREE_TIER.vCpu * exports.V2_RATES.vCpu[1];
    v2CpuBill = Math.max(v2CpuBill, 0);
    let runMemoryBill = usage["run"][1].ram * exports.V2_RATES.memoryGb[1] + usage["run"][2].ram * exports.V2_RATES.memoryGb[2];
    runMemoryBill -= exports.V2_FREE_TIER.memoryGb * exports.V2_RATES.memoryGb[1];
    runMemoryBill = Math.max(runMemoryBill, 0);
    let runCpuBill = usage["run"][1].cpu * exports.V2_RATES.idleVCpu[1] + usage["run"][2].cpu * exports.V2_RATES.idleVCpu[2];
    runCpuBill -= exports.V2_FREE_TIER.vCpu * exports.V2_RATES.vCpu[1];
    runCpuBill = Math.max(runCpuBill, 0);
    return v1MemoryBill + v1CpuBill + v2MemoryBill + v2CpuBill + runMemoryBill + runCpuBill;
}
