"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.init_data_connect = void 0;
const resource_1 = require("../../resource");
exports.init_data_connect = (0, resource_1.resource)({
    uri: "firebase://guides/init/data_connect",
    name: "data_connect_init_guide",
    title: "Firebase SQL Connect Init Guide",
    description: "guides the coding agent through configuring SQL Connect for PostgreSQL access in the current project",
}, async (uri) => {
    return {
        contents: [
            {
                uri,
                type: "text",
                text: `
Create a file called \`data-connect.ts\`:

\`\`\`ts
import { initializeApp } from "firebase/app";
import { getDataConnect } from "firebase/data-connect";

const app = initializeApp({...});
const db = getDataConnect(app);
\`\`\`
`.trim(),
            },
        ],
    };
});
