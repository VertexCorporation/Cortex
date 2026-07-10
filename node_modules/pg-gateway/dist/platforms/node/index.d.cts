import { Socket } from 'node:net';
import { b as PostgresConnectionOptions, P as PostgresConnection, D as DuplexStream } from '../../connection-Wgmmyk18.cjs';

/**
 * Creates a `PostgresConnection` from a Node.js TCP/Unix `Socket`.
 *
 * `PostgresConnection` operates on web streams, so this helper
 * converts a `Socket` to/from the respective web streams.
 *
 * Also implements `upgradeTls()`, which makes Postgres `SSLRequest`
 * upgrades available in Node.js environments.
 */
declare function fromNodeSocket(socket: Socket, options?: PostgresConnectionOptions): Promise<PostgresConnection>;
/**
 * Creates a `PostgresConnection` from a `DuplexStream` with
 * Node.js adapters like `upgradeTls()` included.
 *
 * Useful in Node.js environments when you start from a
 * non-Socket stream but want Node.js TLS adapters.
 */
declare function fromDuplexStream(duplex: DuplexStream<Uint8Array>, options?: PostgresConnectionOptions): Promise<PostgresConnection>;

export { fromDuplexStream, fromNodeSocket };
