import { MimeTypeRegistry } from '../../utils/mime';
import RequestMediaType from '../RequestMediaType';
import * as oas3 from 'openapi3-ts';
import Oas3CompileContext from '../Oas3CompileContext';
import { ParameterLocation } from '../..';
export declare function isSpecificationExtension(key: string): boolean;
export declare function isReferenceObject(obj: any): obj is oas3.ReferenceObject;
/**
 *
 * @param openApiDoc - The openApiDocument this `content` object is from.
 * @param path - The path to the `content` object.
 * @param content - The `content` object.
 */
export declare function contentToRequestMediaTypeRegistry(context: Oas3CompileContext, parameterLocation: ParameterLocation, parameterRequired: boolean, content?: oas3.ContentObject): MimeTypeRegistry<RequestMediaType>;
