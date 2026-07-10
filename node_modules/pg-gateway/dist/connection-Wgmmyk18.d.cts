/**
 * Binary data reader tuned for decoding the Postgres wire protocol.
 *
 * @see https://github.com/brianc/node-postgres/blob/54eb0fa216aaccd727765641e7d1cf5da2bc483d/packages/pg-protocol/src/buffer-reader.ts
 */
declare class BufferReader {
    private offset;
    private buffer;
    private decoder;
    constructor(offset?: number);
    setBuffer(buffer: Uint8Array, offset?: number): void;
    int16(): number;
    byte(): number;
    int32(): number;
    string(length: number): string;
    cstring(): string;
    bytes(length: number): Uint8Array;
}

/**
 * binary data  BufferWriter tuned for encoding binary specific to the postgres binary protocol
 *
 * @see https://github.com/brianc/node-postgres/blob/54eb0fa216aaccd727765641e7d1cf5da2bc483d/packages/pg-protocol/src/buffer- BufferWriter.ts
 */
declare class BufferWriter {
    private size;
    private buffer;
    private offset;
    private headerPosition;
    private encoder;
    constructor(size?: number);
    private ensure;
    addInt32(num: number): BufferWriter;
    addInt16(num: number): BufferWriter;
    addCString(string: string): BufferWriter;
    addString(string?: string): BufferWriter;
    add(otherBuffer: Uint8Array): BufferWriter;
    private join;
    flush(code?: number): Uint8Array;
}

type ClientParameters = {
    user: string;
    [key: string]: string;
};
type TlsInfo = {
    serverName?: string;
    clientCertificate?: Uint8Array;
};
declare const ServerStep: {
    readonly AwaitingInitialMessage: "AwaitingInitialMessage";
    readonly PerformingAuthentication: "PerformingAuthentication";
    readonly ReadyForQuery: "ReadyForQuery";
};
type ServerStep = (typeof ServerStep)[keyof typeof ServerStep];
type ConnectionState = {
    hasStarted: boolean;
    isAuthenticated: boolean;
    clientParams?: ClientParameters;
    tlsInfo?: TlsInfo;
    step: ServerStep;
};

declare const tlsUpgradeSignal: unique symbol;
declare const closeSignal: unique symbol;
type TlsUpgradeSignal = typeof tlsUpgradeSignal;
type CloseSignal = typeof closeSignal;
type ConnectionSignal = TlsUpgradeSignal | CloseSignal;

interface AuthFlow {
    createInitialAuthMessage(): Uint8Array | undefined;
    handleClientMessage(message: BufferSource): AsyncGenerator<Uint8Array | ConnectionSignal>;
    isCompleted: boolean;
}
declare abstract class BaseAuthFlow implements AuthFlow {
    protected reader: BufferReader;
    protected writer: BufferWriter;
    protected connectionState: ConnectionState;
    constructor(params: {
        reader: BufferReader;
        writer: BufferWriter;
        connectionState: ConnectionState;
    });
    abstract createInitialAuthMessage(): Uint8Array | undefined;
    abstract handleClientMessage(message: BufferSource): AsyncGenerator<Uint8Array | ConnectionSignal>;
    abstract get isCompleted(): boolean;
}

type CertAuthOptions = {
    method: 'cert';
    validateCredentials?: (credentials: {
        username: string;
        certificate: Uint8Array;
    }, connectionState: ConnectionState) => boolean | Promise<boolean>;
};

type Md5AuthOptions = {
    method: 'md5';
    validateCredentials?: (credentials: {
        username: string;
        preHashedPassword: string;
        salt: Uint8Array;
        hashedPassword: string;
    }, connectionState: ConnectionState) => boolean | Promise<boolean>;
    getPreHashedPassword: (credentials: {
        username: string;
    }, connectionState: ConnectionState) => string | Promise<string>;
};
declare class Md5AuthFlow extends BaseAuthFlow {
    private auth;
    private username;
    private salt;
    private completed;
    constructor(params: {
        auth: Md5AuthOptions;
        username: string;
        reader: BufferReader;
        writer: BufferWriter;
        connectionState: ConnectionState;
    });
    handleClientMessage(message: Uint8Array): AsyncGenerator<Uint8Array | typeof closeSignal, void, unknown>;
    createInitialAuthMessage(): Uint8Array;
    get isCompleted(): boolean;
    /**
     * Creates the authentication response.
     *
     * @see https://www.postgresql.org/docs/current/protocol-flow.html#PROTOCOL-FLOW-START-UP
     */
    private createAuthenticationMD5Password;
}
/**
 * Hashes a password using Postgres' nested MD5 algorithm.
 *
 * @see https://www.postgresql.org/docs/current/protocol-flow.html#PROTOCOL-FLOW-START-UP
 */
declare function hashPreHashedPassword(preHashedPassword: string, salt: Uint8Array): Promise<string>;
/**
 * Computes the MD5 hash of the given value.
 */
declare function md5(value: string | Uint8Array): Promise<string>;
/**
 * Generates a random 4-byte salt for MD5 hashing.
 */
declare function generateMd5Salt(): Uint8Array;
declare function createPreHashedPassword(username: string, password: string): Promise<string>;

type ClearTextPassword = string;
type PasswordAuthOptions = {
    method: 'password';
    validateCredentials?: (credentials: {
        username: string;
        password: string;
        clearTextPassword: ClearTextPassword;
    }, connectionState: ConnectionState) => boolean | Promise<boolean>;
    getClearTextPassword: (params: {
        username: string;
    }, connectionState: ConnectionState) => ClearTextPassword | Promise<ClearTextPassword>;
};

declare class SaslMechanism {
    writer: BufferWriter;
    constructor(params: {
        writer: BufferWriter;
    });
    createAuthenticationSASL(): Uint8Array;
    createAuthenticationSASLContinue(message: string): Uint8Array;
    createAuthenticationSASLFinal(message: string): Uint8Array;
}

type ScramSha256Data = {
    salt: string;
    iterations: number;
    storedKey: string;
    serverKey: string;
};
type ScramSha256AuthOptions = {
    method: 'scram-sha-256';
    validateCredentials?: (params: {
        authMessage: string;
        clientProof: string;
        username: string;
        scramSha256Data: ScramSha256Data;
    }, connectionState: ConnectionState) => boolean | Promise<boolean>;
    getScramSha256Data: (params: {
        username: string;
    }, connectionState: ConnectionState) => ScramSha256Data | Promise<ScramSha256Data>;
};
/**
 * Creates scram-sha-256 data for password authentication.
 * @see https://www.postgresql.org/docs/current/sasl-authentication.html
 */
declare function createScramSha256Data(password: string, iterations?: number): Promise<ScramSha256Data>;
/**
 * Verifies a scram-sha-256 password using the provided parameters.
 * @see https://www.postgresql.org/docs/current/sasl-authentication.html
 */
declare function verifyScramSha256Password(params: {
    authMessage: string;
    clientProof: string;
    storedKey: string;
}): Promise<boolean>;
declare const ScramSha256Step: {
    readonly Initial: "Initial";
    readonly ServerFirstMessage: "ServerFirstMessage";
    readonly ServerFinalMessage: "ServerFinalMessage";
    readonly Completed: "Completed";
};
type ScramSha256Step = (typeof ScramSha256Step)[keyof typeof ScramSha256Step];
declare class ScramSha256AuthFlow extends SaslMechanism implements AuthFlow {
    auth: ScramSha256AuthOptions & {
        validateCredentials: NonNullable<ScramSha256AuthOptions['validateCredentials']>;
    };
    username: string;
    clientFirstMessageBare?: string;
    serverFirstMessage?: string;
    serverNonce?: string;
    step: ScramSha256Step;
    reader: BufferReader;
    scramSha256Data?: ScramSha256Data;
    connectionState: ConnectionState;
    constructor(params: {
        auth: ScramSha256AuthOptions;
        username: string;
        reader: BufferReader;
        writer: BufferWriter;
        connectionState: ConnectionState;
    });
    /**
     * Get the scram-sha-256 data for the username.
     * This function is cached to always return the same data as we are generating random values in createScramSha256Data.
     */
    getScramSha256Data(params: {
        username: string;
    }): Promise<ScramSha256Data>;
    createInitialAuthMessage(): Uint8Array;
    handleClientMessage(message: BufferSource): AsyncGenerator<Uint8Array | typeof closeSignal, void, unknown>;
    handleClientFirstMessage(message: BufferSource): AsyncGenerator<Uint8Array | typeof closeSignal, void, unknown>;
    createServerFirstMessage(clientFirstMessage: string): Promise<string>;
    handleClientFinalMessage(message: BufferSource): AsyncGenerator<Uint8Array | typeof closeSignal, void, unknown>;
    get isCompleted(): boolean;
    createServerFinalMessage(message: BufferSource): Promise<string>;
}

type TrustAuthOptions = {
    method: 'trust';
};

type AuthOptions = TrustAuthOptions | PasswordAuthOptions | Md5AuthOptions | ScramSha256AuthOptions | CertAuthOptions;

/**
 * Handles buffering of messages for a connection
 */
declare class MessageBuffer {
    private buffer;
    private bufferLength;
    private bufferOffset;
    /**
     * Merges a new buffer into the existing buffer
     *
     * @see https://github.com/brianc/node-postgres/blob/54eb0fa216aaccd727765641e7d1cf5da2bc483d/packages/pg-protocol/src/parser.ts#L121-L152
     */
    mergeBuffer(newData: Uint8Array): void;
    /**
     * Processes incoming data by buffering it and parsing messages.
     *
     * @see https://github.com/brianc/node-postgres/blob/54eb0fa216aaccd727765641e7d1cf5da2bc483d/packages/pg-protocol/src/parser.ts#L91-L119
     */
    processMessages(hasStarted: boolean): AsyncGenerator<Uint8Array, void, unknown>;
}
declare function getMessages(data: Uint8Array): Generator<Uint8Array, void, unknown>;

interface DuplexStream<T = unknown> {
    readable: ReadableStream<T>;
    writable: WritableStream<T>;
}
/**
 * A passthrough `DuplexStream` that buffers data to support
 * asynchronous reads and writes.
 */
declare class BufferedStream<T> implements DuplexStream<T> {
    readable: ReadableStream<T>;
    writable: WritableStream<T>;
    constructor();
}
/**
 * Creates a pair of linked duplex streams.
 *
 * The returned duplex streams are interconnected such that writing to the
 * writable stream of one duplex will result in the data appearing on the
 * readable stream of the other duplex, and vice versa. This can be useful
 * for simulating a bidirectional communication channel or virtual socket.
 */
declare function createDuplexPair<T>(): [DuplexStream<T>, DuplexStream<T>];
/**
 * Creates a virtual server that can accept multiple duplex stream connections.
 *
 * The server allows clients to connect via a `connect()` method, returning a
 * `DuplexStream` representing the client side of the connection. The server
 * side of each connection can be accessed by reading from the stream returned
 * by the `listen()` method.
 *
 * This is useful for simulating network servers, testing bidirectional
 * communication channels, or creating virtual sockets where data flow
 * can be controlled and observed.
 *
 * @returns An object containing `connect()` to initiate a connection and
 * `listen()` to retrieve the server side of the connections.
 */
declare function createVirtualServer<T>(): {
    listen: () => ReadableStream<DuplexStream<T>>;
    connect: () => Promise<DuplexStream<T>>;
};
/**
 * Converts a `ReadableStream` to an `AsyncIterator`.
 *
 * Note that `ReadableStream` is supposed to implement `AsyncIterable`
 * already, but this isn't true for all environments today (eg. Safari).
 *
 * Use this method as a ponyfill.
 */
declare function toAsyncIterator<R = unknown>(readable: ReadableStream<R>, options?: {
    preventCancel?: boolean;
}): AsyncIterableIterator<R>;

type TlsOptions = {
    key: ArrayBuffer;
    cert: ArrayBuffer;
    ca?: ArrayBuffer;
    passphrase?: string;
};
type TlsOptionsCallback = (serverName?: string) => TlsOptions | Promise<TlsOptions>;
type PostgresConnectionOptions = {
    /**
     * The server version to send to the frontend.
     */
    serverVersion?: string | ((state: ConnectionState) => string | Promise<string>);
    /**
     * The authentication mode for the server.
     */
    auth?: AuthOptions;
    /**
     * TLS options for when clients send an SSLRequest.
     */
    tls?: TlsOptions | TlsOptionsCallback;
    /**
     * Callback after the connection has been upgraded to TLS.
     *
     * Includes `state` which holds connection information gathered so far like `tlsInfo`.
     *
     * This will be called before the startup message is received from the frontend
     * (if TLS is being used) so is a good place to establish proxy connections if desired.
     */
    onTlsUpgrade?(state: ConnectionState): void | Promise<void>;
    /**
     * Callback after the initial startup message has been received from the frontend.
     *
     * Includes `state` which holds connection information gathered so far like `clientInfo`.
     *
     * This is called after the connection is upgraded to TLS (if TLS is being used)
     * but before authentication messages are sent to the frontend.
     *
     */
    onStartup?(state: ConnectionState): void | Promise<void>;
    /**
     * Callback after a successful authentication has completed.
     *
     * Includes `state` which holds connection information gathered so far.
     */
    onAuthenticated?(state: ConnectionState): void | Promise<void>;
    /**
     * Callback for every message received from the frontend.
     * Use this as an escape hatch to manually handle raw message data.
     *
     * Includes `state` which holds connection information gathered so far and
     * can be used to understand where the protocol is at in its lifecycle.
     *
     * Callback can optionally return raw `Uint8Array` response data that will
     * be sent back to the client. It can also return multiple `Uint8Array`
     * responses via an `Iterable<Uint8Array>` or `AsyncIterable<Uint8Array>`.
     * This means you can turn this hook into a generator function to
     * asynchronously stream responses back to the client.
     *
     * **Warning:** By managing the message yourself (returning data), you bypass further
     * processing by the `PostgresConnection` which means some state may not be collected
     * and hooks won't be called depending on where the protocol is at in its lifecycle.
     * If you wish to hook into messages without bypassing further processing, do not return
     * any data from this callback.
     */
    onMessage?(data: Uint8Array, state: ConnectionState): MessageResponse | Promise<MessageResponse>;
    /**
     * Callback for every frontend query message.
     * Use this to implement query handling.
     *
     * If left `undefined`, an error will be sent to the frontend
     * indicating that queries aren't implemented.
     *
     * TODO: change return signature to be more developer-friendly
     * and then translate to wire protocol.
     */
    onQuery?(query: string, state: ConnectionState): Uint8Array | Promise<Uint8Array>;
};
/**
 * Platform-specific adapters for handling features like TLS upgrades.
 *
 * Some platform helpers like `fromNodeSocket()` will implement these
 * for you.
 */
type PostgresConnectionAdapters = {
    /**
     * Implements the TLS upgrade logic for the stream.
     */
    upgradeTls?(duplex: DuplexStream<Uint8Array>, options: TlsOptions | TlsOptionsCallback, requestCert?: boolean): Promise<{
        duplex: DuplexStream<Uint8Array>;
        tlsInfo: TlsInfo;
    }>;
};
type MessageResponse = undefined | Uint8Array | Iterable<Uint8Array> | AsyncIterable<Uint8Array>;
declare class PostgresConnection {
    duplex: DuplexStream<Uint8Array>;
    adapters: PostgresConnectionAdapters;
    private step;
    options: PostgresConnectionOptions & {
        auth: NonNullable<PostgresConnectionOptions['auth']>;
    };
    authFlow?: AuthFlow;
    hasStarted: boolean;
    isAuthenticated: boolean;
    detached: boolean;
    bufferWriter: BufferWriter;
    bufferReader: BufferReader;
    clientParams?: ClientParameters;
    tlsInfo?: TlsInfo;
    messageBuffer: MessageBuffer;
    streamWriter?: WritableStreamDefaultWriter<Uint8Array>;
    constructor(duplex: DuplexStream<Uint8Array>, options?: PostgresConnectionOptions, adapters?: PostgresConnectionAdapters);
    get state(): ConnectionState;
    init(duplex: DuplexStream<Uint8Array>): Promise<void>;
    /**
     * Detaches the `PostgresConnection` from the stream.
     * After calling this, data will no longer be buffered
     * and all processing will halt.
     *
     * Useful when proxying. You can detach at a certain point
     * (like TLS upgrade) to prevent further buffering/processing
     * when your goal is to pipe future messages downstream.
     */
    detach(): Promise<DuplexStream<Uint8Array>>;
    processData(duplex: DuplexStream<Uint8Array>): Promise<ConnectionSignal | undefined>;
    handleClientMessage(message: Uint8Array): AsyncGenerator<Uint8Array | ConnectionSignal, void, undefined>;
    handleSslRequest(): AsyncGenerator<Uint8Array | typeof tlsUpgradeSignal, void, unknown>;
    handleStartupMessage(message: BufferSource): AsyncGenerator<Uint8Array | ConnectionSignal, void, unknown>;
    handleAuthenticationMessage(message: BufferSource): AsyncGenerator<Uint8Array | ConnectionSignal, boolean, unknown>;
    private handleRegularMessage;
    /**
     * Checks if the given message is a valid SSL request.
     *
     * @see https://www.postgresql.org/docs/current/protocol-message-formats.html#PROTOCOL-MESSAGE-FORMATS-SSLREQUEST
     */
    private isSslRequest;
    /**
     * Checks if the given message is a valid StartupMessage.
     *
     * @see https://www.postgresql.org/docs/current/protocol-message-formats.html#PROTOCOL-MESSAGE-FORMATS-STARTUPMESSAGE
     */
    private isStartupMessage;
    /**
     * Completes authentication by forwarding the appropriate messages
     * to the frontend.
     */
    completeAuthentication(): AsyncGenerator<Uint8Array, void, unknown>;
    /**
     * Parses a startup message from the frontend.
     *
     * @see https://www.postgresql.org/docs/current/protocol-message-formats.html#PROTOCOL-MESSAGE-FORMATS-STARTUPMESSAGE
     */
    readStartupMessage(): {
        majorVersion: number;
        minorVersion: number;
        parameters: Record<string, string>;
    };
    /**
     * Parses a query message from the frontend.
     *
     * @see https://www.postgresql.org/docs/current/protocol-message-formats.html#PROTOCOL-MESSAGE-FORMATS-QUERY
     */
    readQuery(): {
        query: string;
    };
    /**
     * Creates an "AuthenticationOk" message.
     *
     * @see https://www.postgresql.org/docs/current/protocol-message-formats.html#PROTOCOL-MESSAGE-FORMATS-AUTHENTICATIONOK
     */
    createAuthenticationOk(): Uint8Array;
    /**
     * Creates a "ParameterStatus" message.
     * Informs the frontend about the current setting of backend parameters.
     *
     * @see https://www.postgresql.org/docs/current/protocol-message-formats.html#PROTOCOL-MESSAGE-FORMATS-PARAMETERSTATUS
     * @see https://www.postgresql.org/docs/current/protocol-flow.html#PROTOCOL-ASYNC
     */
    createParameterStatus(name: string, value: string): Uint8Array;
    /**
     * Creates a "ReadyForQuery" message.
     *
     * @see https://www.postgresql.org/docs/current/protocol-message-formats.html#PROTOCOL-MESSAGE-FORMATS-READYFORQUERY
     */
    createReadyForQuery(transactionStatus?: 'idle' | 'transaction' | 'error'): Uint8Array;
    createAuthenticationFailedError(): Uint8Array;
}

export { BufferedStream as B, type ClientParameters as C, type DuplexStream as D, type MessageResponse as M, PostgresConnection as P, ServerStep as S, type TlsOptions as T, type TlsOptionsCallback as a, type PostgresConnectionOptions as b, type PostgresConnectionAdapters as c, type TlsInfo as d, type ConnectionState as e, type ScramSha256Data as f, type ScramSha256AuthOptions as g, createScramSha256Data as h, ScramSha256AuthFlow as i, type Md5AuthOptions as j, Md5AuthFlow as k, hashPreHashedPassword as l, md5 as m, generateMd5Salt as n, createPreHashedPassword as o, createDuplexPair as p, createVirtualServer as q, MessageBuffer as r, getMessages as s, toAsyncIterator as t, tlsUpgradeSignal as u, verifyScramSha256Password as v, closeSignal as w, type TlsUpgradeSignal as x, type CloseSignal as y, type ConnectionSignal as z };
