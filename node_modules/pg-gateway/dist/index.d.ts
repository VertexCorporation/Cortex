export { B as BufferedStream, C as ClientParameters, y as CloseSignal, z as ConnectionSignal, e as ConnectionState, D as DuplexStream, k as Md5AuthFlow, j as Md5AuthOptions, r as MessageBuffer, M as MessageResponse, P as PostgresConnection, c as PostgresConnectionAdapters, b as PostgresConnectionOptions, i as ScramSha256AuthFlow, g as ScramSha256AuthOptions, f as ScramSha256Data, S as ServerStep, d as TlsInfo, T as TlsOptions, a as TlsOptionsCallback, x as TlsUpgradeSignal, w as closeSignal, p as createDuplexPair, o as createPreHashedPassword, h as createScramSha256Data, q as createVirtualServer, n as generateMd5Salt, s as getMessages, l as hashPreHashedPassword, m as md5, u as tlsUpgradeSignal, t as toAsyncIterator, v as verifyScramSha256Password } from './connection-Wgmmyk18.js';

interface BackendErrorParams {
    severity: 'ERROR' | 'FATAL' | 'PANIC';
    code: string;
    message: string;
    detail?: string;
    hint?: string;
    position?: string;
    internalPosition?: string;
    internalQuery?: string;
    where?: string;
    schema?: string;
    table?: string;
    column?: string;
    dataType?: string;
    constraint?: string;
    file?: string;
    line?: string;
    routine?: string;
}
/**
 * Represents a backend error message
 *
 * @see https://www.postgresql.org/docs/current/protocol-message-formats.html#PROTOCOL-MESSAGE-FORMATS-ERRORRESPONSE
 *
 * For error fields, @see https://www.postgresql.org/docs/current/protocol-error-fields.html#PROTOCOL-ERROR-FIELDS
 */
declare class BackendError {
    severity: 'ERROR' | 'FATAL' | 'PANIC';
    code: string;
    message: string;
    detail?: string;
    hint?: string;
    position?: string;
    internalPosition?: string;
    internalQuery?: string;
    where?: string;
    schema?: string;
    table?: string;
    column?: string;
    dataType?: string;
    constraint?: string;
    file?: string;
    line?: string;
    routine?: string;
    constructor(params: BackendErrorParams);
    /**
     * Creates a backend error message
     *
     * @see https://www.postgresql.org/docs/current/protocol-message-formats.html#PROTOCOL-MESSAGE-FORMATS-ERRORRESPONSE
     *
     * For error fields, @see https://www.postgresql.org/docs/current/protocol-error-fields.html#PROTOCOL-ERROR-FIELDS
     */
    static create(params: BackendErrorParams): BackendError;
    flush(): Uint8Array;
}

/**
 * Frontend message codes
 * @see https://www.postgresql.org/docs/current/protocol-message-codes.html
 */
declare const FrontendMessageCode: {
    readonly Query: 81;
    readonly Parse: 80;
    readonly Bind: 66;
    readonly Execute: 69;
    readonly FunctionCall: 70;
    readonly Flush: 72;
    readonly Close: 67;
    readonly Describe: 68;
    readonly CopyFromChunk: 100;
    readonly CopyDone: 99;
    readonly CopyData: 100;
    readonly CopyFail: 102;
    readonly Password: 112;
    readonly Sync: 83;
    readonly Terminate: 88;
};
/**
 * Backend message codes
 * @see https://www.postgresql.org/docs/current/protocol-message-codes.html
 */
declare const BackendMessageCode: {
    readonly DataRow: 68;
    readonly ParseComplete: 49;
    readonly BindComplete: 50;
    readonly CloseComplete: 51;
    readonly CommandComplete: 67;
    readonly ReadyForQuery: 90;
    readonly NoData: 110;
    readonly NotificationResponse: 65;
    readonly AuthenticationResponse: 82;
    readonly ParameterStatus: 83;
    readonly BackendKeyData: 75;
    readonly ErrorMessage: 69;
    readonly NoticeMessage: 78;
    readonly RowDescriptionMessage: 84;
    readonly ParameterDescriptionMessage: 116;
    readonly PortalSuspended: 115;
    readonly ReplicationStart: 87;
    readonly EmptyQuery: 73;
    readonly CopyIn: 71;
    readonly CopyOut: 72;
    readonly CopyDone: 99;
    readonly CopyData: 100;
};
declare function getFrontendMessageName(code: number): string | undefined;
declare function getBackendMessageName(code: number): string | undefined;

export { BackendError, BackendMessageCode, FrontendMessageCode, getBackendMessageName, getFrontendMessageName };
