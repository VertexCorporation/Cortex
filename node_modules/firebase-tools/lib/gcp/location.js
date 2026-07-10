"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.STORAGE_MULTI_REGION_TO_REGION_MAPPING = exports.FIRESTORE_DUAL_REGION_TO_REGION_MAPPING = exports.DUAL_REGION_MAPPING = exports.MULTI_REGION_MAPPING = void 0;
exports.regionInLocation = regionInLocation;
exports.isUSRegion = isUSRegion;
exports.MULTI_REGION_MAPPING = {
    "us-central1": "us",
    "us-east1": "us",
    "us-east4": "us",
    "us-west1": "us",
    "us-west2": "us",
    "us-west3": "us",
    "us-west4": "us",
    "europe-central2": "eu",
    "europe-north1": "eu",
    "europe-west1": "eu",
    "europe-west3": "eu",
    "europe-west4": "eu",
    "europe-west5": "eu",
    "asia-east1": "asia",
    "asia-east2": "asia",
    "asia-northeast1": "asia",
    "asia-northeast2": "asia",
    "asia-northeast3": "asia",
    "asia-south1": "asia",
    "asia-south2": "asia",
    "asia-southeast1": "asia",
    "asia-southeast2": "asia",
};
exports.DUAL_REGION_MAPPING = {
    "asia-northeast1": "asia1",
    "asia-northeast2": "asia1",
    "europe-north1": "eur4",
    "europe-west4": "eur4",
    "us-central1": "nam4",
    "us-east1": "nam4",
};
exports.FIRESTORE_DUAL_REGION_TO_REGION_MAPPING = {
    nam5: "us-central1",
    nam7: "us-central1",
    eur3: "europe-west1",
};
exports.STORAGE_MULTI_REGION_TO_REGION_MAPPING = {
    us: "us-east1",
    eu: "europe-west1",
    asia: "asia-east1",
};
function regionInLocation(region, location) {
    region = region.toLowerCase();
    location = location.toLowerCase();
    if (exports.MULTI_REGION_MAPPING[region] === location || exports.DUAL_REGION_MAPPING[region] === location) {
        return true;
    }
    return false;
}
function isUSRegion(region) {
    const lower = region.toLowerCase();
    return lower === "us" || lower.startsWith("nam") || lower.startsWith("us-");
}
