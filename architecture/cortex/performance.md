# Cortex Runtime Performance Architecture

This document describes the client-side runtime performance layer introduced by `lib/performance/`. It follows the existing Cortex layering rules: widgets render, providers own reactive state, services orchestrate work, and repositories/storage own I/O. The performance layer contains reusable primitives only; it does not become a second business-logic layer.

## Goals

The runtime performance work targets repeated work on mobile hot paths rather than synthetic line-count growth:

- avoid repeated filesystem syscalls during rebuilds;
- coalesce identical asynchronous work;
- cap concurrency instead of choosing between fully serial work and unbounded `Future.wait`;
- collapse replaceable cache writes;
- prevent high-frequency sensors/streams from rebuilding faster than the display can render;
- retain reusable RAG token/index state across queries;
- expose lightweight timing primitives for debug/profiling without adding a telemetry backend.

## Core primitives (`lib/performance/`)

### `AsyncKeyedCoalescer` / `AsyncCoalescer`

Deduplicates concurrent asynchronous operations. A key remains in-flight only until its current future completes; failures release the key so a later request can retry. Use for fetches, initialization and cache hydration where concurrent callers need the same result.

`OperationGeneration` is a small stale-result guard for operations that cannot be physically cancelled. `SerialExecutor` preserves ordering for mutation pipelines where parallel writes would be unsafe. `MicrotaskCoalescer` folds same-turn invalidations.

### `TtlLruCache`

Bounded in-memory cache with lazy TTL expiry and LRU eviction. It intentionally allocates no timer per entry. Reads refresh LRU order but not TTL. Optional weights allow byte-like or cost-like capacity limits.

### `FileProbeCache`

Short-lived cache around filesystem existence/stat probes. Hot widgets may need a synchronous answer to choose an image provider; repeating `existsSync()` every rebuild can hit storage repeatedly. Writers can call explicit invalidation or `noteWritten`/`noteDeleted` so correctness does not depend solely on TTL expiry.

### `FrameCoalescer`

Restricts visual invalidation to at most one callback per rendered frame. It is appropriate for microphone levels, progress streams and similar visual state where intermediate values arriving faster than the screen refresh rate cannot be displayed anyway. Terminal state changes should still notify immediately.

### `BoundedPool` / `AsyncSemaphore`

Runs independent I/O with a fixed concurrency ceiling. This avoids slow serial pipelines without creating the connection, memory and callback burst of unbounded parallelism. The semaphore hands permits directly to queued waiters to preserve fairness.

### `LatestWriteQueue`

Write-behind for *replaceable cache state*. New values replace pending older values, while a value that arrives during an active write is flushed immediately afterwards. This must not be used for transaction logs, billing events or any mutation where every intermediate state is meaningful.

### `StableFingerprint`

Fast deterministic fingerprint of JSON-like data. Map key order is normalized. It is not cryptographic and must never be used as an authentication or integrity primitive. Its purpose is to suppress redundant provider/persistence work for materially unchanged snapshots.

### `PerfTrace`

Local aggregate timing instrumentation and a small debug-only recent-sample ring. It performs no network upload. Slow-operation logging is debug-gated by default.

### `AdaptiveBatcher`

Processes CPU-light collections in chunks and adjusts chunk size toward a target event-loop slice. It replaces arbitrary fixed “yield every N records” patterns where collection cost varies by device/data.

## Integrated hot paths

### RAG retrieval

Old query behavior rebuilt term-frequency/document-frequency maps by tokenizing every selected chunk on every query. Storage also loaded chunks one document at a time.

The new path adds `Bm25DocumentIndex`, `Bm25IndexCache` and `Bm25Scorer`:

1. Indexed document metadata is loaded.
2. Only documents whose `updatedAt` / `chunkCount` revision changed load their chunks and rebuild token/posting state.
3. Query terms address posting lists directly.
4. Only matched chunks are scored and sorted.
5. `RagStorageService` batches multi-document reads with `IN (...)` queries below SQLite's common bind-variable ceiling.

The in-memory index is a cache. SQLite remains the source of truth and a process restart simply rebuilds the cache.

### RAG attachment preparation

Attached document paths are de-duplicated and indexed with bounded concurrency of two. Existing documents are looked up by path directly instead of loading the entire RAG document table for every attachment. Fallback first-chunk reads use bulk document/chunk reads.

### User provider snapshots

Firestore can deliver equivalent cache/server snapshots. `UserProvider` fingerprints accepted user data before firing `notifyListeners` or serializing it again. Replaceable cached user JSON uses a short write-behind window. Sign-out flushes pending writes *before* deleting cached account data so an older deferred write cannot repopulate signed-out state.

Account identity checks remain authoritative; fingerprints are only an optimization.

### Speech level rendering

Microphone level callbacks update the latest value immediately but request visual notification at most once per frame. Start/stop/error state still notifies immediately. Remote level listeners are detached when the remote recognizer closes or the provider is disposed.

### Model image path persistence and local image widgets

`ModelImageCache` keeps the newest path snapshot in memory while replaceable SharedPreferences writes are coalesced. `addAll` is available for bulk synchronization; destructive removals flush durably. Two frequently rebuilt image widgets use `FileProbeCache` instead of issuing a fresh synchronous filesystem existence check on every build.

## Correctness boundaries

Performance caches must not become authorization or billing authorities. Entitlements still come from the server-owned subscription state; purchase verification remains in the billing path; the RAG SQLite database remains source of truth; image files remain source of truth after cache expiry/invalidation.

A failed coalesced operation must be retryable. A deferred cache write must never resurrect signed-out account state. Bounded parallelism must preserve result ordering where callers depend on it. Visual coalescing must not delay terminal state transitions.

## Validation

Regression tests cover:

- same-key async work sharing and retry after failure;
- serial executor ordering;
- TTL expiry, LRU and weight eviction;
- bounded pool concurrency and semaphore fairness;
- write-behind collapse/error recovery;
- stable fingerprint semantics;
- BM25 cache revision replacement, ranking, top-K and retain/invalidation behavior.

Full Flutter analyzer/tests and device profiling should still be run in CI or a development checkout with the Flutter SDK. Device benchmarking should compare the same dataset and workflow before/after; no percentage speedup should be claimed from code inspection alone.
