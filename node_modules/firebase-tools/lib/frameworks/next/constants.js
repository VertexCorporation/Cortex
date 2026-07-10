"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.WEBPACK_LAYERS = exports.ESBUILD_VERSION = exports.CONFIG_FILES = exports.SERVER_REFERENCE_MANIFEST = exports.APP_PATHS_MANIFEST = exports.ROUTES_MANIFEST = exports.PRERENDER_MANIFEST = exports.PAGES_MANIFEST = exports.FUNCTIONS_CONFIG_MANIFEST = exports.MIDDLEWARE_MANIFEST = exports.IMAGES_MANIFEST = exports.EXPORT_MARKER = exports.APP_PATH_ROUTES_MANIFEST = void 0;
exports.APP_PATH_ROUTES_MANIFEST = "app-path-routes-manifest.json";
exports.EXPORT_MARKER = "export-marker.json";
exports.IMAGES_MANIFEST = "images-manifest.json";
exports.MIDDLEWARE_MANIFEST = "middleware-manifest.json";
exports.FUNCTIONS_CONFIG_MANIFEST = "functions-config-manifest.json";
exports.PAGES_MANIFEST = "pages-manifest.json";
exports.PRERENDER_MANIFEST = "prerender-manifest.json";
exports.ROUTES_MANIFEST = "routes-manifest.json";
exports.APP_PATHS_MANIFEST = "app-paths-manifest.json";
exports.SERVER_REFERENCE_MANIFEST = "server-reference-manifest.json";
exports.CONFIG_FILES = [
    "next.config.js",
    "next.config.mjs",
    "next.config.ts",
    "next.config.mts",
];
exports.ESBUILD_VERSION = "^0.19.2";
const WEBPACK_LAYERS_NAMES = {
    shared: "shared",
    reactServerComponents: "rsc",
    serverSideRendering: "ssr",
    actionBrowser: "action-browser",
    api: "api",
    middleware: "middleware",
    edgeAsset: "edge-asset",
    appPagesBrowser: "app-pages-browser",
    appMetadataRoute: "app-metadata-route",
    appRouteHandler: "app-route-handler",
};
exports.WEBPACK_LAYERS = {
    ...WEBPACK_LAYERS_NAMES,
    GROUP: {
        server: [
            WEBPACK_LAYERS_NAMES.reactServerComponents,
            WEBPACK_LAYERS_NAMES.actionBrowser,
            WEBPACK_LAYERS_NAMES.appMetadataRoute,
            WEBPACK_LAYERS_NAMES.appRouteHandler,
        ],
        nonClientServerTarget: [
            WEBPACK_LAYERS_NAMES.middleware,
            WEBPACK_LAYERS_NAMES.api,
        ],
        app: [
            WEBPACK_LAYERS_NAMES.reactServerComponents,
            WEBPACK_LAYERS_NAMES.actionBrowser,
            WEBPACK_LAYERS_NAMES.appMetadataRoute,
            WEBPACK_LAYERS_NAMES.appRouteHandler,
            WEBPACK_LAYERS_NAMES.serverSideRendering,
            WEBPACK_LAYERS_NAMES.appPagesBrowser,
            WEBPACK_LAYERS_NAMES.shared,
        ],
    },
};
