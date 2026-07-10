import { PGlite } from '@electric-sql/pglite';

interface PgDumpOptions {
    pg: PGlite;
    args?: string[];
    fileName?: string;
    verbose?: boolean;
}
/**
 * Execute pg_dump
 */
declare function pgDump({ pg, args, fileName, }: PgDumpOptions): Promise<File>;

export { pgDump };
