"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RecurrenceType = exports.DatabaseEdition = exports.DataAccessMode = exports.RealtimeUpdatesMode = exports.PointInTimeRecoveryEnablement = exports.DatabaseDeleteProtectionState = exports.EnablementOption = exports.DatabaseType = exports.StateTtl = exports.State = exports.TextMatchType = exports.TextIndexType = exports.ArrayConfig = exports.Order = exports.Density = exports.ApiScope = exports.QueryScope = exports.Mode = void 0;
exports.validateEnablementOption = validateEnablementOption;
const error_1 = require("../error");
var Mode;
(function (Mode) {
    Mode["ASCENDING"] = "ASCENDING";
    Mode["DESCENDING"] = "DESCENDING";
    Mode["ARRAY_CONTAINS"] = "ARRAY_CONTAINS";
})(Mode || (exports.Mode = Mode = {}));
var QueryScope;
(function (QueryScope) {
    QueryScope["COLLECTION"] = "COLLECTION";
    QueryScope["COLLECTION_GROUP"] = "COLLECTION_GROUP";
})(QueryScope || (exports.QueryScope = QueryScope = {}));
var ApiScope;
(function (ApiScope) {
    ApiScope["ANY_API"] = "ANY_API";
    ApiScope["DATASTORE_MODE_API"] = "DATASTORE_MODE_API";
    ApiScope["MONGODB_COMPATIBLE_API"] = "MONGODB_COMPATIBLE_API";
})(ApiScope || (exports.ApiScope = ApiScope = {}));
var Density;
(function (Density) {
    Density["DENSITY_UNSPECIFIED"] = "DENSITY_UNSPECIFIED";
    Density["SPARSE_ALL"] = "SPARSE_ALL";
    Density["SPARSE_ANY"] = "SPARSE_ANY";
    Density["DENSE"] = "DENSE";
})(Density || (exports.Density = Density = {}));
var Order;
(function (Order) {
    Order["ASCENDING"] = "ASCENDING";
    Order["DESCENDING"] = "DESCENDING";
})(Order || (exports.Order = Order = {}));
var ArrayConfig;
(function (ArrayConfig) {
    ArrayConfig["CONTAINS"] = "CONTAINS";
})(ArrayConfig || (exports.ArrayConfig = ArrayConfig = {}));
var TextIndexType;
(function (TextIndexType) {
    TextIndexType["TEXT_INDEX_TYPE_UNSPECIFIED"] = "TEXT_INDEX_TYPE_UNSPECIFIED";
    TextIndexType["TOKENIZED"] = "TOKENIZED";
})(TextIndexType || (exports.TextIndexType = TextIndexType = {}));
var TextMatchType;
(function (TextMatchType) {
    TextMatchType["TEXT_MATCH_TYPE_UNSPECIFIED"] = "TEXT_MATCH_TYPE_UNSPECIFIED";
    TextMatchType["MATCH_GLOBALLY"] = "MATCH_GLOBALLY";
})(TextMatchType || (exports.TextMatchType = TextMatchType = {}));
var State;
(function (State) {
    State["CREATING"] = "CREATING";
    State["READY"] = "READY";
    State["NEEDS_REPAIR"] = "NEEDS_REPAIR";
})(State || (exports.State = State = {}));
var StateTtl;
(function (StateTtl) {
    StateTtl["CREATING"] = "CREATING";
    StateTtl["ACTIVE"] = "ACTIVE";
    StateTtl["NEEDS_REPAIR"] = "NEEDS_REPAIR";
})(StateTtl || (exports.StateTtl = StateTtl = {}));
var DatabaseType;
(function (DatabaseType) {
    DatabaseType["DATASTORE_MODE"] = "DATASTORE_MODE";
    DatabaseType["FIRESTORE_NATIVE"] = "FIRESTORE_NATIVE";
})(DatabaseType || (exports.DatabaseType = DatabaseType = {}));
var EnablementOption;
(function (EnablementOption) {
    EnablementOption["ENABLED"] = "ENABLED";
    EnablementOption["DISABLED"] = "DISABLED";
})(EnablementOption || (exports.EnablementOption = EnablementOption = {}));
var DatabaseDeleteProtectionState;
(function (DatabaseDeleteProtectionState) {
    DatabaseDeleteProtectionState["ENABLED"] = "DELETE_PROTECTION_ENABLED";
    DatabaseDeleteProtectionState["DISABLED"] = "DELETE_PROTECTION_DISABLED";
})(DatabaseDeleteProtectionState || (exports.DatabaseDeleteProtectionState = DatabaseDeleteProtectionState = {}));
var PointInTimeRecoveryEnablement;
(function (PointInTimeRecoveryEnablement) {
    PointInTimeRecoveryEnablement["ENABLED"] = "POINT_IN_TIME_RECOVERY_ENABLED";
    PointInTimeRecoveryEnablement["DISABLED"] = "POINT_IN_TIME_RECOVERY_DISABLED";
})(PointInTimeRecoveryEnablement || (exports.PointInTimeRecoveryEnablement = PointInTimeRecoveryEnablement = {}));
var RealtimeUpdatesMode;
(function (RealtimeUpdatesMode) {
    RealtimeUpdatesMode["ENABLED"] = "REALTIME_UPDATES_MODE_ENABLED";
    RealtimeUpdatesMode["DISABLED"] = "REALTIME_UPDATES_MODE_DISABLED";
})(RealtimeUpdatesMode || (exports.RealtimeUpdatesMode = RealtimeUpdatesMode = {}));
var DataAccessMode;
(function (DataAccessMode) {
    DataAccessMode["UNSPECIFIED"] = "DATA_ACCESS_MODE_UNSPECIFIED";
    DataAccessMode["ENABLED"] = "DATA_ACCESS_MODE_ENABLED";
    DataAccessMode["DISABLED"] = "DATA_ACCESS_MODE_DISABLED";
})(DataAccessMode || (exports.DataAccessMode = DataAccessMode = {}));
var DatabaseEdition;
(function (DatabaseEdition) {
    DatabaseEdition["DATABASE_EDITION_UNSPECIFIED"] = "DATABASE_EDITION_UNSPECIFIED";
    DatabaseEdition["STANDARD"] = "STANDARD";
    DatabaseEdition["ENTERPRISE"] = "ENTERPRISE";
})(DatabaseEdition || (exports.DatabaseEdition = DatabaseEdition = {}));
var RecurrenceType;
(function (RecurrenceType) {
    RecurrenceType["DAILY"] = "DAILY";
    RecurrenceType["WEEKLY"] = "WEEKLY";
})(RecurrenceType || (exports.RecurrenceType = RecurrenceType = {}));
function validateEnablementOption(optionValue, flagName, helpCommandText) {
    if (optionValue &&
        optionValue !== EnablementOption.ENABLED &&
        optionValue !== EnablementOption.DISABLED) {
        throw new error_1.FirebaseError(`Invalid value for flag --${flagName}. ${helpCommandText}`);
    }
}
