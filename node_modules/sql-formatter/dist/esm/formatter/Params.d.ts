export type ParamItems = {
    [k: string]: string;
};
/**
 * Handles placeholder replacement with given params.
 */
export default class Params {
    private params;
    private index;
    constructor(params: ParamItems | string[] | undefined);
    /**
     * Returns param value that matches given placeholder with param key.
     */
    get({ key, text }: {
        key?: string;
        text: string;
    }): string;
    /**
     * Returns index of current positional parameter.
     */
    getPositionalParameterIndex(): number;
    /**
     * Sets index of current positional parameter.
     */
    setPositionalParameterIndex(i: number): void;
}
