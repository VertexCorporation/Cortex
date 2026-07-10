import { Controllers, ControllerModule } from '../types';
/**
 * Load a set of controllers.
 *
 * @param folder - The folder to load controllers from.
 * @param [pattern] - A glob pattern for controllers to load.  Defaults to only
 *   .js files.
 * @param [loader] - The function to call to load each controller.  Defaults to
 *   `require`.
 *
 * @example
 *   // Assuming controllers has files "foo.js" and "bar/bar.js", then `controllers`
 *   // will be a `{"foo", "foo.js", "bar/bar.js", "bar/bar"}` object.
 *   const controllers = loadControllersSync('controlers', '**\/*.js');
 */
export declare function loadControllersSync(folder: string, pattern?: string, loader?: (path: string) => ControllerModule): Controllers;
