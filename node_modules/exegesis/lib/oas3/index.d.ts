import oas3 from 'openapi3-ts';
import OpenApi from './OpenApi';
import { ExegesisCompiledOptions } from '../options';
export { OpenApi };
/**
 * Reads an OpenAPI document from a YAML or JSON file.
 *
 * @param openApiDocFile - The file containing the OpenAPI document.
 * @returns - Returns the parsed OpenAPI document.
 */
export declare function compile(openApiDoc: oas3.OpenAPIObject, options: ExegesisCompiledOptions): Promise<OpenApi>;
