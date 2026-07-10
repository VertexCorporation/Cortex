"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Separator = void 0;
exports.guard = guard;
exports.input = input;
exports.confirm = confirm;
exports.checkbox = checkbox;
exports.select = select;
exports.number = number;
exports.password = password;
exports.search = search;
const inquirer = require("@inquirer/prompts");
const error_1 = require("./error");
var prompts_1 = require("@inquirer/prompts");
Object.defineProperty(exports, "Separator", { enumerable: true, get: function () { return prompts_1.Separator; } });
function guard(opts) {
    if (!opts.nonInteractive) {
        return { shouldReturn: false, value: undefined };
    }
    if (typeof opts.default !== "undefined") {
        return { shouldReturn: true, value: opts.default };
    }
    throw new error_1.FirebaseError(`Question "${opts.message}" does not have a default and cannot be answered in non-interactive mode`);
}
async function input(opts) {
    if (typeof opts === "string") {
        opts = { message: opts };
    }
    else {
        const { shouldReturn, value } = guard(opts);
        if (shouldReturn) {
            return value;
        }
    }
    return inquirer.input(opts);
}
async function confirm(opts) {
    if (typeof opts === "string") {
        opts = { message: opts };
    }
    else {
        if (opts.force) {
            return true;
        }
        const { shouldReturn, value } = guard(opts);
        if (shouldReturn) {
            return value;
        }
    }
    return inquirer.confirm(opts);
}
async function checkbox(opts) {
    const { shouldReturn, value } = guard(opts);
    if (shouldReturn) {
        return value;
    }
    return inquirer.checkbox({
        ...opts,
        loop: true,
    });
}
async function select(opts) {
    const { shouldReturn, value } = guard(opts);
    if (shouldReturn) {
        return value;
    }
    return inquirer.select({
        ...opts,
        loop: false,
    });
}
async function number(opts) {
    if (typeof opts === "string") {
        opts = { message: opts };
    }
    else {
        const { shouldReturn, value } = guard(opts);
        if (shouldReturn) {
            return value;
        }
    }
    return await inquirer.number({ required: true, ...opts });
}
async function password(opts) {
    if (typeof opts === "string") {
        opts = { message: opts };
    }
    else {
        guard(opts);
    }
    return inquirer.password({
        ...opts,
        mask: "",
    });
}
async function search(opts) {
    const { shouldReturn, value } = guard(opts);
    if (shouldReturn) {
        return value;
    }
    return inquirer.search(opts);
}
