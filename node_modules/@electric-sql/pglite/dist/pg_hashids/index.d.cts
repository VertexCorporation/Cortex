import { d as PGliteInterface } from '../pglite-CntadC_p.cjs';

declare const pg_hashids: {
    name: string;
    setup: (_pg: PGliteInterface, emscriptenOpts: any) => Promise<{
        emscriptenOpts: any;
        bundlePath: URL;
    }>;
};

export { pg_hashids };
