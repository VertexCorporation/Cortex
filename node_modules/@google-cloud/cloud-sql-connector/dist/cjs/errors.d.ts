interface CloudSQLConnectorErrorOptions {
    code: string;
    errors?: Error[];
    message: string;
}
export declare class CloudSQLConnectorError extends Error {
    readonly code: string;
    readonly errors: Error[];
    readonly message: string;
    readonly name = "CloudSQLConnectorError";
    constructor({ code, errors, message }: CloudSQLConnectorErrorOptions);
}
export {};
//# sourceMappingURL=errors.d.ts.map