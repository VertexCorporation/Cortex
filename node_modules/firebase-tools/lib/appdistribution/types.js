"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UploadReleaseResult = exports.IntegrationState = void 0;
var IntegrationState;
(function (IntegrationState) {
    IntegrationState["AAB_INTEGRATION_STATE_UNSPECIFIED"] = "AAB_INTEGRATION_STATE_UNSPECIFIED";
    IntegrationState["INTEGRATED"] = "INTEGRATED";
    IntegrationState["PLAY_ACCOUNT_NOT_LINKED"] = "PLAY_ACCOUNT_NOT_LINKED";
    IntegrationState["NO_APP_WITH_GIVEN_BUNDLE_ID_IN_PLAY_ACCOUNT"] = "NO_APP_WITH_GIVEN_BUNDLE_ID_IN_PLAY_ACCOUNT";
    IntegrationState["APP_NOT_PUBLISHED"] = "APP_NOT_PUBLISHED";
    IntegrationState["AAB_STATE_UNAVAILABLE"] = "AAB_STATE_UNAVAILABLE";
    IntegrationState["PLAY_IAS_TERMS_NOT_ACCEPTED"] = "PLAY_IAS_TERMS_NOT_ACCEPTED";
})(IntegrationState || (exports.IntegrationState = IntegrationState = {}));
var UploadReleaseResult;
(function (UploadReleaseResult) {
    UploadReleaseResult["UPLOAD_RELEASE_RESULT_UNSPECIFIED"] = "UPLOAD_RELEASE_RESULT_UNSPECIFIED";
    UploadReleaseResult["RELEASE_CREATED"] = "RELEASE_CREATED";
    UploadReleaseResult["RELEASE_UPDATED"] = "RELEASE_UPDATED";
    UploadReleaseResult["RELEASE_UNMODIFIED"] = "RELEASE_UNMODIFIED";
})(UploadReleaseResult || (exports.UploadReleaseResult = UploadReleaseResult = {}));
