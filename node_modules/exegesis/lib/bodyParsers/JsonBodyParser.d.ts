import http from 'http';
import { MimeTypeParser, Callback } from '../types';
export default class JsonBodyParser implements MimeTypeParser {
    private _bodyParserMiddlware;
    constructor(maxBodySize: number);
    parseString(value: string): any;
    parseReq(req: http.IncomingMessage, res: http.ServerResponse, done: Callback<void>): void;
}
