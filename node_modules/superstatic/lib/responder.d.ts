export = Responder;
declare class Responder {
    private constructor();
    isNotModified(stats: any): boolean;
    handle(item: any, next: any): any;
    _handle(item: any): any;
    handleError(err: any): void;
    handleStack(stack: any): any;
    handleFile(file: any): any;
    handleFileStream(file: any, result: any): Promise<boolean>;
    streamedFile: any;
    handleNotModified(): boolean;
    handleRedirect(redirect: any): Promise<boolean>;
    handleMiddleware(middleware: any): Promise<any>;
    handleRewrite(item: any): any;
    handleData(data: any): Promise<boolean>;
}
