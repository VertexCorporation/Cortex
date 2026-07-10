"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ThreadState = exports.Signal = exports.State = exports.SessionEventType = exports.FormFactor = exports.TrackType = exports.ErrorType = void 0;
var ErrorType;
(function (ErrorType) {
    ErrorType["ERROR_TYPE_UNSPECIFIED"] = "ERROR_TYPE_UNSPECIFIED";
    ErrorType["FATAL"] = "FATAL";
    ErrorType["NON_FATAL"] = "NON_FATAL";
    ErrorType["ANR"] = "ANR";
})(ErrorType || (exports.ErrorType = ErrorType = {}));
var TrackType;
(function (TrackType) {
    TrackType["TRACK_TYPE_UNSPECIFIED"] = "TRACK_TYPE_UNSPECIFIED";
    TrackType["TRACK_TYPE_PROD"] = "TRACK_TYPE_PROD";
    TrackType["TRACK_TYPE_INTERNAL"] = "TRACK_TYPE_INTERNAL";
    TrackType["TRACK_TYPE_OPEN_TESTING"] = "TRACK_TYPE_OPEN_TESTING";
    TrackType["TRACK_TYPE_CLOSED_TESTING"] = "TRACK_TYPE_CLOSED_TESTING";
    TrackType["TRACK_TYPE_EARLY_ACCESS"] = "TRACK_TYPE_EARLY_ACCESS";
})(TrackType || (exports.TrackType = TrackType = {}));
var FormFactor;
(function (FormFactor) {
    FormFactor["FORM_FACTOR_UNSPECIFIED"] = "FORM_FACTOR_UNSPECIFIED";
    FormFactor["PHONE"] = "PHONE";
    FormFactor["TABLET"] = "TABLET";
    FormFactor["DESKTOP"] = "DESKTOP";
    FormFactor["TV"] = "TV";
    FormFactor["WATCH"] = "WATCH";
})(FormFactor || (exports.FormFactor = FormFactor = {}));
var SessionEventType;
(function (SessionEventType) {
    SessionEventType["SESSION_EVENT_TYPE_UNKNOWN"] = "SESSION_EVENT_TYPE_UNKNOWN";
    SessionEventType["SESSION_START"] = "SESSION_START";
})(SessionEventType || (exports.SessionEventType = SessionEventType = {}));
var State;
(function (State) {
    State["STATE_UNSPECIFIED"] = "STATE_UNSPECIFIED";
    State["OPEN"] = "OPEN";
    State["CLOSED"] = "CLOSED";
    State["MUTED"] = "MUTED";
})(State || (exports.State = State = {}));
var Signal;
(function (Signal) {
    Signal["SIGNAL_UNSPECIFIED"] = "SIGNAL_UNSPECIFIED";
    Signal["SIGNAL_EARLY"] = "SIGNAL_EARLY";
    Signal["SIGNAL_FRESH"] = "SIGNAL_FRESH";
    Signal["SIGNAL_REGRESSED"] = "SIGNAL_REGRESSED";
    Signal["SIGNAL_REPETITIVE"] = "SIGNAL_REPETITIVE";
})(Signal || (exports.Signal = Signal = {}));
var ThreadState;
(function (ThreadState) {
    ThreadState["STATE_UNSPECIFIED"] = "STATE_UNSPECIFIED";
    ThreadState["THREAD_STATE_TERMINATED"] = "THREAD_STATE_TERMINATED";
    ThreadState["THREAD_STATE_RUNNABLE"] = "THREAD_STATE_RUNNABLE";
    ThreadState["THREAD_STATE_TIMED_WAITING"] = "THREAD_STATE_TIMED_WAITING";
    ThreadState["THREAD_STATE_BLOCKED"] = "THREAD_STATE_BLOCKED";
    ThreadState["THREAD_STATE_WAITING"] = "THREAD_STATE_WAITING";
    ThreadState["THREAD_STATE_NEW"] = "THREAD_STATE_NEW";
    ThreadState["THREAD_STATE_NATIVE_RUNNABLE"] = "THREAD_STATE_NATIVE_RUNNABLE";
    ThreadState["THREAD_STATE_NATIVE_WAITING"] = "THREAD_STATE_NATIVE_WAITING";
})(ThreadState || (exports.ThreadState = ThreadState = {}));
