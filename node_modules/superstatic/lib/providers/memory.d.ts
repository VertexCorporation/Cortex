declare function _exports(options: any): {
    (req: any, pathname: any): Promise<null> | Promise<{
        modified: any;
        stream: Readable;
        size: any;
        etag: string;
    }>;
    store: any;
};
export = _exports;
import Readable_1 = require("stream");
import Readable = Readable_1.Readable;
