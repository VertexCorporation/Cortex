import http from 'http';
import { MimeTypeParser, StringParser, HttpIncomingMessage, Callback } from '../types';
export default class BodyParserWrapper implements MimeTypeParser {
    private _parser;
    private _maxBodySize;
    constructor(parser: StringParser, maxBodySize: number);
    parseString(value: string): any;
    parseReq(req: HttpIncomingMessage, _res: http.ServerResponse, done: Callback<any>): void;
}
