"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.init = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const database_1 = require("../../../init/features/database");
const index_1 = require("../../../init/index");
const freeTrial_1 = require("../../../dataconnect/freeTrial");
const error_1 = require("../../../error");
const utils_1 = require("../../../init/features/ailogic/utils");
const projects_1 = require("../../../management/projects");
const dataconnect_1 = require("../../../init/features/dataconnect");
exports.init = (0, tool_1.tool)("core", {
    name: "init",
    description: "Use this to initialize selected Firebase services in the workspace (Cloud Firestore database, Firebase SQL Connect, Firebase Realtime Database, Firebase AI Logic). All services are optional; specify only the products you want to set up. " +
        "You can initialize new features into an existing project directory, but re-initializing an existing feature may overwrite configuration. " +
        "To deploy the initialized features, run the `firebase deploy` command after `firebase_init` tool.",
    inputSchema: zod_1.z.object({
        features: zod_1.z.object({
            database: zod_1.z
                .object({
                rules_filename: zod_1.z
                    .string()
                    .optional()
                    .default("database.rules.json")
                    .describe("The file to use for Realtime Database Security Rules."),
                rules: zod_1.z
                    .string()
                    .optional()
                    .default(database_1.DEFAULT_RULES)
                    .describe("The security rules to use for Realtime Database Security Rules."),
            })
                .optional()
                .describe("Provide this object to initialize Firebase Realtime Database in this project directory."),
            firestore: zod_1.z
                .object({
                database_id: zod_1.z
                    .string()
                    .optional()
                    .default("(default)")
                    .describe("The database ID to use for Firestore."),
                location_id: zod_1.z
                    .string()
                    .optional()
                    .default("nam5")
                    .describe("The GCP region ID to set up the Firestore database."),
                rules_filename: zod_1.z
                    .string()
                    .optional()
                    .default("firestore.rules")
                    .describe("The file to use for Firestore Security Rules."),
                rules: zod_1.z
                    .string()
                    .optional()
                    .describe("The security rules to use for Firestore Security Rules. Default to open rules that expire in 30 days."),
            })
                .optional()
                .describe("Provide this object to initialize Cloud Firestore in this project directory."),
            dataconnect: zod_1.z
                .object({
                service_id: zod_1.z
                    .string()
                    .optional()
                    .describe("The Firebase SQL Connect service ID to initialize. Default to match the current folder name."),
                location_id: zod_1.z
                    .string()
                    .optional()
                    .default(dataconnect_1.FDC_DEFAULT_REGION)
                    .describe("The GCP region ID to set up the Firebase SQL Connect service."),
                cloudsql_instance_id: zod_1.z
                    .string()
                    .optional()
                    .describe("The GCP Cloud SQL instance ID to use in the Firebase SQL Connect service. By default, use <serviceId>-fdc. " +
                    "\nSet `provision_cloudsql` to true to start Cloud SQL provisioning."),
                cloudsql_database: zod_1.z
                    .string()
                    .optional()
                    .default("fdcdb")
                    .describe("The Postgres database ID to use in the Firebase SQL Connect service."),
                provision_cloudsql: zod_1.z
                    .boolean()
                    .optional()
                    .default(false)
                    .describe("If true, provision the Cloud SQL instance if `cloudsql_instance_id` does not exist already. " +
                    `\nThe first Cloud SQL instance in the project will use the SQL Connect no-cost trial. See its terms of service: ${(0, freeTrial_1.freeTrialTermsLink)()}.`),
            })
                .optional()
                .describe("Provide this object to initialize Firebase SQL Connect with Cloud SQL Postgres in this project directory.\n" +
                "It installs SQL Connect Generated SDKs in all detected apps in the folder."),
            storage: zod_1.z
                .object({
                rules_filename: zod_1.z
                    .string()
                    .optional()
                    .default("storage.rules")
                    .describe("The file to use for Firebase Storage Security Rules."),
                rules: zod_1.z
                    .string()
                    .optional()
                    .describe("The security rules to use for Firebase Storage Security Rules. Default to closed rules that deny all access."),
            })
                .optional()
                .describe("Provide this object to initialize Firebase Storage in this project directory."),
            ailogic: zod_1.z
                .object({
                app_id: zod_1.z
                    .string()
                    .describe("Firebase app ID (format: 1:PROJECT_NUMBER:PLATFORM:APP_ID). Must be an existing app in your Firebase project."),
            })
                .optional()
                .describe("Enable Firebase AI Logic feature for existing app"),
            hosting: zod_1.z
                .object({
                site_id: zod_1.z
                    .string()
                    .optional()
                    .describe("The ID of the hosting site to configure. If omitted and there is a default hosting site, that will be used."),
                public_directory: zod_1.z
                    .string()
                    .optional()
                    .default("public")
                    .describe("The directory containing public files that will be served. If using a build tool, this likely should be the output directory of that tool."),
                single_page_app: zod_1.z
                    .boolean()
                    .optional()
                    .default(false)
                    .describe("Configure as a single-page app."),
            })
                .optional()
                .describe("Provide this object to initialize Firebase Hosting in this project directory."),
            auth: zod_1.z
                .object({
                providers: zod_1.z.object({
                    emailPassword: zod_1.z
                        .boolean()
                        .optional()
                        .describe("Enable Email/Password authentication."),
                    anonymous: zod_1.z.boolean().optional().describe("Enable Anonymous authentication."),
                    googleSignIn: zod_1.z
                        .object({
                        oAuthBrandDisplayName: zod_1.z
                            .string()
                            .describe("The display name for the OAuth brand."),
                        supportEmail: zod_1.z.string().describe("The support email for the OAuth brand."),
                    })
                        .optional()
                        .describe("Configure Google Sign-In."),
                }),
            })
                .optional()
                .describe("Provide this object to initialize Firebase Authentication."),
        }),
    }),
    annotations: {
        title: "Initialize Firebase Products",
        readOnlyHint: false,
        idempotentHint: true,
    },
    _meta: {
        requiresProject: false,
        requiresAuth: false,
        ui: {
            resourceUri: "ui://core/init/mcp-app.html",
        },
    },
}, async ({ features }, { projectId, config, rc }) => {
    const featuresList = [];
    const featureInfo = {};
    if (features.database) {
        featuresList.push("database");
        featureInfo.database = {
            rulesFilename: features.database.rules_filename,
            rules: features.database.rules,
            writeRules: true,
        };
    }
    if (features.firestore) {
        featuresList.push("firestore");
        featureInfo.firestore = {
            databaseId: features.firestore.database_id,
            locationId: features.firestore.location_id,
            rulesFilename: features.firestore.rules_filename,
            rules: features.firestore.rules || "",
            writeRules: true,
            indexesFilename: "",
            indexes: "",
            writeIndexes: true,
        };
    }
    if (features.dataconnect) {
        featuresList.push("dataconnect");
        featureInfo.dataconnectSource = "mcp_init";
        featureInfo.dataconnect = {
            flow: "",
            appDescription: "",
            serviceId: features.dataconnect.service_id || "",
            locationId: features.dataconnect.location_id || "",
            cloudSqlInstanceId: features.dataconnect.cloudsql_instance_id || "",
            cloudSqlDatabase: features.dataconnect.cloudsql_database || "",
            shouldProvisionCSQL: !!features.dataconnect.provision_cloudsql,
        };
        featureInfo.dataconnectSdk = {
            apps: [],
        };
    }
    if (features.ailogic) {
        if (!projectId) {
            throw new error_1.FirebaseError("AI Logic feature requires a Firebase project. Please specify a project ID.", { exit: 1 });
        }
        const appInfo = (0, utils_1.parseAppId)(features.ailogic.app_id);
        const projectInfo = await (0, projects_1.getFirebaseProject)(projectId);
        (0, utils_1.validateProjectNumberMatch)(appInfo, projectInfo);
        const appData = await (0, utils_1.validateAppExists)(appInfo, projectId);
        featuresList.push("ailogic");
        featureInfo.ailogic = {
            appId: features.ailogic.app_id,
            displayName: appData.displayName,
        };
    }
    if (features.hosting) {
        featuresList.push("hosting");
        featureInfo.hosting = {
            newSiteId: features.hosting.site_id,
            public: features.hosting.public_directory,
            spa: features.hosting.single_page_app,
        };
    }
    if (features.auth) {
        featuresList.push("auth");
        featureInfo.auth = {
            providers: {
                anonymous: features.auth.providers.anonymous,
                emailPassword: features.auth.providers.emailPassword,
                googleSignIn: features.auth.providers.googleSignIn,
            },
        };
    }
    const setup = {
        config: config?.src,
        rcfile: rc?.data,
        projectId: projectId,
        features: [...featuresList],
        featureInfo: featureInfo,
        instructions: [],
    };
    await (0, index_1.actuate)(setup, config, { force: true });
    config.writeProjectFile("firebase.json", setup.config);
    config.writeProjectFile(".firebaserc", setup.rcfile);
    if (featureInfo.dataconnectSdk && !featureInfo.dataconnectSdk.apps.length) {
        setup.instructions.push(`No app is found in the current folder. We recommend you create an app (web, ios, android) first, then re-run the 'firebase_init' MCP tool with the same input without app_description to add SQL Connect SDKs to your apps.
  Consider popular commands like 'npx create-react-app my-app', 'npx create-next-app my-app', 'flutter create my-app', etc`);
    }
    return (0, util_1.toContent)(`Successfully setup those features: ${featuresList.join(", ")}

To get started:

- ${setup.instructions.join("\n\n- ")}
`);
});
