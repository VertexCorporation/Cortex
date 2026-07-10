# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
npm install       # install dependencies
make test         # run all tests (also: npm test)
./node_modules/.bin/mocha test/pageview.js   # run a single test file
```

Enable debug output during development:
```bash
DEBUG=universal-analytics node yourscript.js
```

## Architecture

This is a Node.js client library that sends tracking hits to Google's Universal Analytics [Measurement Protocol](https://developers.google.com/analytics/devguides/collection/protocol/v1/) via HTTPS POST.

**Entry point:** `index.js` re-exports `lib/index.js`.

**Core flow:**

1. `ua(tid, cid, options)` creates a `Visitor` instance (`lib/index.js`)
2. Tracking methods (`pageview`, `event`, `transaction`, `item`, `exception`, `timing`, `screenview`) validate required params, merge `_persistentParams` and `_context`, then call `_enqueue(type, params, fn)`
3. `_enqueue` adds the serialized hit to `this._queue` and calls `send()` immediately if a callback was provided
4. `send()` drains the queue via `lib/request.js`, which uses Node's built-in `http`/`https` modules (no third-party HTTP client)

**Batching:** Enabled by default (`config.batching = true`, `config.batchSize = 10`). Multiple queued hits are sent to `/batch` as newline-delimited querystrings; a single hit goes to `/collect`.

**Daisy-chaining & context:** Each tracking call returns a new `Visitor` via `_withContext(params)`, sharing the same `_queue` reference. This allows subsequent calls to inherit parameters (e.g. `dp` from a `pageview`) without repeating them.

**Parameter translation:** `config.parametersMap` maps human-readable keys (e.g. `"eventCategory"`) to GA Measurement Protocol short codes (e.g. `"ec"`). `_translateParams` applies this mapping before every enqueue.

**Key files:**
- `lib/index.js` — `Visitor` class with all tracking methods
- `lib/config.js` — protocol constants, accepted parameter list, and the full `parametersMap`
- `lib/request.js` — thin wrapper around `http`/`https` for POST requests
- `lib/utils.js` — UUID/CID validation helpers
- `test/` — Mocha tests; `sinon.stub(request, "post")` is the standard pattern for intercepting outbound requests in tests
