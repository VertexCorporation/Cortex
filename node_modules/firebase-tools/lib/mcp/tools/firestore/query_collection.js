"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.query_collection = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const firestore_1 = require("../../../gcp/firestore");
const converter_1 = require("./converter");
const types_1 = require("../../../emulator/types");
exports.query_collection = (0, tool_1.tool)("firestore", {
    name: "query_collection",
    description: "Use this to retrieve one or more Firestore documents from a collection in a database in the current project by a collection with a full document path. Use this if you know the exact path of a collection and the filtering clause you would like for the document.",
    inputSchema: zod_1.z.object({
        database: zod_1.z
            .string()
            .optional()
            .describe("Database id to use. Defaults to `(default)` if unspecified."),
        collection_path: zod_1.z
            .string()
            .describe("A collection path (e.g. `collectionName/` or `parentCollection/parentDocument/collectionName`)"),
        filters: zod_1.z
            .object({
            compare_value: zod_1.z
                .object({
                string_value: zod_1.z.string().optional().describe("The string value to compare against."),
                boolean_value: zod_1.z
                    .string()
                    .optional()
                    .describe("The boolean value to compare against."),
                string_array_value: zod_1.z
                    .array(zod_1.z.string())
                    .optional()
                    .describe("The string value to compare against."),
                integer_value: zod_1.z
                    .number()
                    .optional()
                    .describe("The integer value to compare against."),
                double_value: zod_1.z.number().optional().describe("The double value to compare against."),
            })
                .describe("One and only one value may be specified per filters object."),
            field: zod_1.z.string().describe("the field searching against"),
            op: zod_1.z
                .enum([
                "OPERATOR_UNSPECIFIED",
                "LESS_THAN",
                "LESS_THAN_OR_EQUAL",
                "GREATER_THAN",
                "GREATER_THAN_OR_EQUAL",
                "EQUAL",
                "NOT_EQUAL",
                "ARRAY_CONTAINS",
                "ARRAY_CONTAINS_ANY",
                "IN",
                "NOT_IN",
            ])
                .describe("the equality evaluator to use"),
        })
            .array()
            .describe("the multiple filters to use in querying against the existing collection."),
        order: zod_1.z
            .object({
            orderBy: zod_1.z.string().describe("the field to order by"),
            orderByDirection: zod_1.z
                .enum(["ASCENDING", "DESCENDING"])
                .describe("the direction to order values"),
        })
            .optional()
            .describe("Specifies the field and direction to order the results. If not provided, the order is undefined."),
        limit: zod_1.z
            .number()
            .describe("The maximum amount of records to return. Default is 10.")
            .optional(),
        use_emulator: zod_1.z.boolean().default(false).describe("Target the Firestore emulator if true."),
    }),
    annotations: {
        title: "Query Firestore collection",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
    },
}, async ({ collection_path, filters, order, limit, database, use_emulator }, { projectId, host }) => {
    if (!collection_path || !collection_path.length)
        return (0, util_1.mcpError)("Must supply at least one collection path.");
    const structuredQuery = {
        from: [{ collectionId: collection_path, allDescendants: false }],
    };
    if (filters) {
        structuredQuery.where = {
            compositeFilter: {
                op: "AND",
                filters: filters.map((f) => {
                    if (f.compare_value.boolean_value &&
                        f.compare_value.double_value &&
                        f.compare_value.integer_value &&
                        f.compare_value.string_array_value &&
                        f.compare_value.string_value) {
                        throw (0, util_1.mcpError)("One and only one value may be specified per filters object.");
                    }
                    const out = Object.entries(f.compare_value).filter(([, value]) => {
                        return value !== null && value !== undefined;
                    });
                    return {
                        fieldFilter: {
                            field: { fieldPath: f.field },
                            op: f.op,
                            value: (0, converter_1.convertInputToValue)(out[0][1]),
                        },
                    };
                }),
            },
        };
    }
    if (order) {
        structuredQuery.orderBy = [
            {
                field: { fieldPath: order.orderBy },
                direction: order.orderByDirection,
            },
        ];
    }
    structuredQuery.limit = limit ? limit : 10;
    let emulatorUrl;
    if (use_emulator) {
        emulatorUrl = await host.getEmulatorUrl(types_1.Emulators.FIRESTORE);
    }
    const { documents } = await (0, firestore_1.queryCollection)(projectId, structuredQuery, database, emulatorUrl);
    const docs = documents.map(converter_1.firestoreDocumentToJson);
    const docsContent = (0, util_1.toContent)({ documents: docs });
    return docsContent;
});
