import { Token } from './token.js';
/**
 * Ensures that no keyword token (RESERVED_*) is preceded or followed by a dot (.)
 * or any other property-access operator.
 *
 * Ensures that all RESERVED_FUNCTION_NAME tokens are followed by "(".
 * If they're not, converts the token to IDENTIFIER.
 *
 * Converts RESERVED_DATA_TYPE tokens followed by "(" to RESERVED_PARAMETERIZED_DATA_TYPE.
 *
 * When IDENTIFIER or RESERVED_DATA_TYPE token is followed by "["
 * converts it to ARRAY_IDENTIFIER or ARRAY_KEYWORD accordingly.
 *
 * This is needed to avoid ambiguity in parser which expects function names
 * to always be followed by open-paren, and to distinguish between
 * array accessor `foo[1]` and array literal `[1, 2, 3]`.
 */
export declare function disambiguateTokens(tokens: Token[]): Token[];
