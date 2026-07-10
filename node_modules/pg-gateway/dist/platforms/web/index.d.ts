import { b as PostgresConnectionOptions, P as PostgresConnection, D as DuplexStream } from '../../connection-Wgmmyk18.js';

/**
 * Creates a `PostgresConnection` from a `WebSocketStream`.
 *
 * Note Postgres `SSLRequest` upgrades are not supported in a `WebSocketStream`.
 */
declare function fromWebSocketStream(wss: WebSocketStream, options?: PostgresConnectionOptions): Promise<PostgresConnection>;
/**
 * Creates a `DuplexStream<Uint8Array>` from a `WebSocketStream`.
 */
declare function duplexFromWebSocketStream(wss: WebSocketStream): Promise<DuplexStream<Uint8Array>>;

export { duplexFromWebSocketStream, fromWebSocketStream };
