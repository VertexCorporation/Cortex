/**
 * Performs expandSinglePhrase() on array
 */
export declare const expandPhrases: (phrases: string[]) => string[];
/**
 * Expands a syntax description like
 *
 *     "CREATE [OR REPLACE] [TEMP|TEMPORARY] TABLE"
 *
 * into an array of all possible combinations like:
 *
 *     [ "CREATE TABLE",
 *       "CREATE TEMP TABLE",
 *       "CREATE TEMPORARY TABLE",
 *       "CREATE OR REPLACE TABLE",
 *       "CREATE OR REPLACE TEMP TABLE",
 *       "CREATE OR REPLACE TEMPORARY TABLE" ]
 *
 * The [] and {} parenthesis can also be nested like
 *
 *     "FOR [OF {UNIQUE | MANDATORY} TABLES]"
 *
 * resulting in:
 *
 *     [ "FOR",
 *       "FOR OF UNIQUE TABLES",
 *       "FOR OF MANDATORY TABLES" ]
 */
export declare const expandSinglePhrase: (phrase: string) => string[];
