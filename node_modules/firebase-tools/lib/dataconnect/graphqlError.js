"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.prettify = prettify;
exports.prettifyTable = prettifyTable;
const Table = require("cli-table3");
function prettify(err) {
    let message = err.message;
    let header = err.extensions?.file ?? "";
    if (err.locations && err.locations.length) {
        const line = err.locations[0]?.line ?? "";
        if (line) {
            header += `:${line}`;
        }
    }
    if (err.path && err.path.length) {
        let pathStr = "On ";
        for (let i = 0; i < err.path.length; i++) {
            if (typeof err.path[i] === "string") {
                if (i === 0) {
                    pathStr += err.path[i];
                }
                else {
                    pathStr = `${pathStr}.${err.path[i]}`;
                }
            }
            else {
                pathStr = `${pathStr}[${err.path[i]}]`;
            }
        }
        message = `${pathStr}: ${message}`;
    }
    return header.length ? `${header}: ${message}` : message;
}
function splitIssueMessage(err) {
    const msg = err.message.split(": ");
    if (msg.length >= 2) {
        return [msg[0], msg.slice(1).join(":")];
    }
    return ["", err.message];
}
function prettifyTable(errs) {
    const table = new Table({
        head: ["Type", "Issue", "Workaround", "Reason"],
        style: { head: ["yellow"] },
        colWidths: [20, 50, 50, 50],
        wordWrap: true,
    });
    errs.sort((a, b) => a.message.localeCompare(b.message));
    for (const e of errs) {
        const msg = splitIssueMessage(e);
        e.message = msg[1];
        if (!e.extensions?.workarounds?.length) {
            table.push([msg[0], prettify(e), "", ""]);
        }
        else {
            const workarounds = e.extensions.workarounds;
            for (let i = 0; i < workarounds.length; i++) {
                if (i === 0) {
                    table.push([msg[0], prettify(e), workarounds[i].description, workarounds[i].reason]);
                }
                else {
                    table.push(["", "", workarounds[i].description, workarounds[i].reason]);
                }
            }
        }
    }
    return table.toString();
}
