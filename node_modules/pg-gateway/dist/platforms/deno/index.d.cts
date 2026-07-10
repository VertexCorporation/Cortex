import { b as PostgresConnectionOptions, P as PostgresConnection } from '../../connection-Wgmmyk18.cjs';

/**
 * Creates a `PostgresConnection` from a Deno TCP/Unix `Conn`.
 *
 * Note Postgres `SSLRequest` upgrades are not yet supported in Deno.
 * This feature depends on:
 * - https://github.com/denoland/deno/issues/18451
 * - https://github.com/denoland/deno/issues/23233
 */
declare function fromDenoConn(conn: Deno.Conn, options?: PostgresConnectionOptions): Promise<PostgresConnection>;

export { fromDenoConn };
