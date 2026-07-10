export class ConfigError extends Error {
}
export function validateConfig(cfg) {
    const removedOptions = [
        'multilineLists',
        'newlineBeforeOpenParen',
        'newlineBeforeCloseParen',
        'aliasAs',
        'commaPosition',
        'tabulateAlias',
    ];
    for (const optionName of removedOptions) {
        if (optionName in cfg) {
            throw new ConfigError(`${optionName} config is no more supported.`);
        }
    }
    if (cfg.expressionWidth <= 0) {
        throw new ConfigError(`expressionWidth config must be positive number. Received ${cfg.expressionWidth} instead.`);
    }
    if (cfg.params && !validateParams(cfg.params)) {
        // eslint-disable-next-line no-console
        console.warn('WARNING: All "params" option values should be strings.');
    }
    if (cfg.paramTypes && !validateParamTypes(cfg.paramTypes)) {
        throw new ConfigError('Empty regex given in custom paramTypes. That would result in matching infinite amount of parameters.');
    }
    return cfg;
}
function validateParams(params) {
    const paramValues = params instanceof Array ? params : Object.values(params);
    return paramValues.every(p => typeof p === 'string');
}
function validateParamTypes(paramTypes) {
    if (paramTypes.custom && Array.isArray(paramTypes.custom)) {
        return paramTypes.custom.every(p => p.regex !== '');
    }
    return true;
}
//# sourceMappingURL=validateConfig.js.map