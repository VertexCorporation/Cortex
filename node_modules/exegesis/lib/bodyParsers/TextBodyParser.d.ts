import http from 'http';
import { MimeTypeParser, Callback } from '../types';
export default class TextBodyParser implements MimeTypeParser {
    private _bodyParserMiddlware;
    constructor(maxBodySize: number);
    parseString(value: string): string;
    parseReq(req: http.IncomingMessage, res: http.ServerResponse, done: Callback<void>): void;
}
