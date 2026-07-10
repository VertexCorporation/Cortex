import { ApiInterface, ExegesisRunner, ResponseValidationCallback, ExegesisOptions } from '../types';
import PluginsManager from './PluginsManager';
import { HandleErrorFunction } from '../types/options';
/**
 * Returns a `(req, res) => Promise<boolean>` function, which handles incoming
 * HTTP requests.  The returned function will return true if the request was
 * handled, and false otherwise.
 *
 * @returns runner function.
 */
export default function generateExegesisRunner<T>(api: ApiInterface<T>, options: {
    autoHandleHttpErrors: boolean | HandleErrorFunction;
    plugins: PluginsManager;
    onResponseValidationError?: ResponseValidationCallback;
    validateDefaultResponses: boolean;
    originalOptions: ExegesisOptions;
}): Promise<ExegesisRunner>;
