# RAG Architecture

Pipeline: validation -> extraction -> chunking -> local storage -> BM25 retrieval -> context injection -> chat. Everything runs on-device except a server fallback for legacy binary formats.

## Ingestion (rag/ingestion.dart)

`RagIngestionService` orchestrates document ingestion. `isIndexable` checks existence, the 10 MB size cap and a supported extension. `indexFile` reuses the existing document record when re-indexing the same path (deletes old chunks first) and drives the status machine `pending -> indexed/failed`.

Concurrent requests for the same file path are coalesced into one extraction/indexing operation. Existing records are found with a direct `filePath` query instead of loading the whole document table. Large chunk-entity lists are constructed through `AdaptiveBatcher`, which periodically yields and adjusts its batch size toward a small event-loop slice.

Extraction runs on-device through `DocTextExtractor` (extractors.dart). Legacy binary formats (.doc, .xls, .odt, ...) fall back to the server: `_parseViaServer` uploads the file, base64-encoded, to the authenticated `read_document` hosted tool (the `executetool` endpoint) and unwraps the response (`ServerDocParser` handles the server format). The fallback reuses one configured Dio client rather than allocating a new client for every document.

## Chunking and storage

`DocumentChunker` (chunker.dart) splits extracted text into chunks. `RagStorageService` (storage.dart) persists documents and chunks locally. Domain models live in models.dart: `RagDocument`, `RagChunk`, `RagRetrievalResult`, `RagDocumentStatus`.

Multi-document metadata and chunk loads are batched into SQLite `IN (...)` queries. Batches stay below a conservative bind-variable ceiling, replacing the previous one-query-per-document path while preserving caller order for deterministic retrieval behavior.

## Retrieval (rag/retrieval.dart + rag/bm25_index.dart)

`RetrievalEngine` remains a small interface (`query`, `warmup`) so a semantic (embedding-based) engine can be swapped in later without touching callers. The current implementation is `Bm25RetrievalEngine` — Okapi BM25 with k1 = 1.5, b = 0.75 and default topK = 4, restricted to documents with `indexed` status.

Retrieval now keeps an in-memory postings index per indexed document. A `Bm25DocumentIndex` stores token lengths, document frequency and term postings. `Bm25IndexCache` reuses that index while the document's `updatedAt` and `chunkCount` revision is unchanged; changed/re-indexed documents rebuild only their own entry. SQLite remains the source of truth, so process restart simply rebuilds the in-memory cache.

At query time, only postings for the query terms are visited. Non-matching chunks are not rescored and the final sort contains only matched chunks. This removes the old behavior of tokenizing every selected chunk and rebuilding corpus term-frequency/document-frequency maps on every chat turn.

`RagTokenizer` is Turkish-aware: Unicode letter/digit splitting, combining-mark (diacritic) folding, and a Turkish + English stop-word list; tokens shorter than two characters are dropped.

`PerfTrace` records local debug/aggregate timings for RAG indexing, warmup and query paths. It does not send telemetry over the network.

## Injection and chat

`RagContextInjector` (injector.dart) formats retrieved chunks into the prompt. `RagChatService` (chat.dart) coordinates retrieval during chat; `SendService._buildRagContext` is the integration point into the send pipeline (see `chat.md`).

Attached document paths are de-duplicated. At most two independent attachment-indexing operations run concurrently, avoiding both fully serial multi-file preparation and unbounded CPU/storage pressure. Fallback first-chunk context uses bulk document/chunk reads.

## UI and state

`RagProvider` (provider.dart) holds the document library state. Concurrent `loadDocuments()` callers share one storage read, and materially identical lists do not trigger another provider notification. `DocumentLibraryScreen` (screens/documents.dart) lists and manages documents. `_RagStatusChip` (chat/screen/widgets/bottom/input/rag.dart) shows RAG status in the input bar.

## Verification boundary

Current source visibly implements BM25 on-device retrieval; the product PDF's vector-database and native-engine statements need backend/native verification before being treated as implemented. Performance caches are accelerators only and never replace SQLite as the RAG source of truth.
