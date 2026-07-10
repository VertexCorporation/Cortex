import { Authenticators, BodyParser, Controllers, CustomFormats, ExegesisOptions, ResponseValidationCallback, StringParser } from './types';
import { HandleErrorFunction } from './types/options';
import { MimeTypeRegistry } from './utils/mime';
export interface ExegesisCompiledOptions {
    customFormats: CustomFormats;
    controllers: Controllers;
    authenticators: Authenticators;
    bodyParsers: MimeTypeRegistry<BodyParser>;
    parameterParsers: MimeTypeRegistry<StringParser>;
    defaultMaxBodySize: number;
    ignoreServers: boolean;
    allowMissingControllers: boolean;
    autoHandleHttpErrors: boolean | HandleErrorFunction;
    onResponseValidationError: ResponseValidationCallback;
    validateDefaultResponses: boolean;
    allErrors: boolean;
    treatReturnedJsonAsPure: boolean;
    strictValidation: boolean;
    lazyCompileValidationSchemas: boolean;
}
export declare function compileOptions(options?: ExegesisOptions): ExegesisCompiledOptions;
