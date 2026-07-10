import * as oas3 from 'openapi3-ts';
import { ExegesisCompiledOptions } from '../options';
/**
 * A path to an object within a JSON document.
 */
export type JsonPath = string[];
export type ReadOnlyJsonPath = readonly string[];
/**
 * This has common stuff that we want to pass all the way down through the OAS
 * heirarchy.  This also keeps track of the `path` that a given object was
 * generated from.
 */
export default class Oas3CompileContext {
    readonly path: JsonPath;
    readonly jsonPointer: string;
    readonly openApiDoc: oas3.OpenAPIObject;
    readonly options: ExegesisCompiledOptions;
    /**
     * Create a new Oas3CompileContext.
     *
     * @param openApiDoc - A fully resolved OpenAPI document, with no $refs.
     * @param path - The path to the object represented by this context.
     * @param options - Options.
     */
    constructor(openApiDoc: oas3.OpenAPIObject, path: ReadOnlyJsonPath, options: ExegesisCompiledOptions);
    constructor(parent: Oas3CompileContext, relativePath: ReadOnlyJsonPath);
    childContext(relativePath: JsonPath | string): Oas3CompileContext;
    resolveRef(ref: string | any): any;
}
