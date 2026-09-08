# RAG Architecture

Pipeline: validation -> extraction -> chunking -> local storage -> BM25 retrieval -> context injection -> chat. Everything runs on-device except a server fallback for legacy binary formats.

## Ingestion (rag/ingestion.dart)

`RagIngestionService` orchestrates document ingestion. `isIndexable` checks existence, the 10 MB size cap and a supported extension. `indexFile` reuses the existing document record when re-indexing the same path (deletes old chunks first) and drives the status machine `pending -> indexed/failed`.

Extraction runs on-device through `DocTextExtractor` (extractors.dart). Legacy binary formats (.doc, .xls, .odt, ...) fall back to the server: `_parseViaServer` uploads the file, base64-encoded, to the authenticated `read_document` hosted tool (the `executetool` endpoint) and unwraps the response (`ServerDocParser` handles the server format).

## Chunking and storage

`DocumentChunker` (chunker.dart) splits extracted text into chunks. `RagStorageService` (storage.dart) persists documents and chunks locally. Domain models live in models.dart: `RagDocument`, `RagChunk`, `RagRetrievalResult`, `RagDocumentStatus`.

## Retrieval (rag/retrieval.dart)

`RetrievalEngine` is a small interface (`query`, `warmup`) so a semantic (embedding-based) engine can be swapped in later without touching callers. The current implementation is `Bm25RetrievalEngine` — Okapi BM25 over the local chunk index with k1 = 1.5, b = 0.75 and default topK = 4, restricted to documents with `indexed` status.

`RagTokenizer` is Turkish-aware: Unicode letter/digit splitting, combining-mark (diacritic) folding, and a Turkish + English stop-word list; tokens shorter than two characters are dropped.

## Injection and chat

`RagContextInjector` (injector.dart) formats retrieved chunks into the prompt. `RagChatService` (chat.dart) coordinates retrieval during chat; `SendService._buildRagContext` is the integration point into the send pipeline (see `chat.md`).

## UI and state

`RagProvider` (provider.dart) holds the document library state. `DocumentLibraryScreen` (screens/documents.dart) lists and manages documents. `_RagStatusChip` (chat/screen/widgets/bottom/input/rag.dart) shows RAG status in the input bar.

## Verification boundary

Current source visibly implements BM25 on-device retrieval; the product PDF's vector-database and native-engine statements need backend/native verification before being treated as implemented.
