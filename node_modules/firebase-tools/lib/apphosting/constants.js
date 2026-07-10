"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CLOUD_RUN_SIZE_LIMIT_BYTES = exports.LOCAL_BUILD_DIR_NAME = exports.ALLOWED_DEPLOY_METHODS = exports.DEFAULT_DEPLOY_METHOD = exports.DEFAULT_LOCATION = void 0;
exports.DEFAULT_LOCATION = "us-east4";
exports.DEFAULT_DEPLOY_METHOD = "github";
exports.ALLOWED_DEPLOY_METHODS = [{ name: "Deploy using github", value: "github" }];
exports.LOCAL_BUILD_DIR_NAME = ".local_build";
exports.CLOUD_RUN_SIZE_LIMIT_BYTES = 250 * 1024 * 1024;
