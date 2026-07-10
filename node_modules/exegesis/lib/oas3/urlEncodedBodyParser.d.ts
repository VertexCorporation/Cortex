import * as oas3 from 'openapi3-ts';
import { MimeTypeParser, ParameterLocation, StringParser } from '../types';
import Oas3CompileContext from './Oas3CompileContext';
export declare function generateStringParser(context: Oas3CompileContext, mediaType: oas3.MediaTypeObject, parameterLocation: ParameterLocation): StringParser;
export declare function generateBodyParser(context: Oas3CompileContext, mediaType: oas3.MediaTypeObject, parameterLocation: ParameterLocation): MimeTypeParser;
