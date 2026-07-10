export declare const dedupe: (arr: string[]) => string[];
export declare const last: <T>(arr: T[]) => T | undefined;
export declare const sortByLengthDesc: (strings: string[]) => string[];
/** Get length of longest string in list of strings */
export declare const maxLength: (strings: string[]) => number;
export declare const equalizeWhitespace: (s: string) => string;
export declare const isMultiline: (text: string) => boolean;
export type Optional<T, K extends keyof T> = Pick<Partial<T>, K> & Omit<T, K>;
