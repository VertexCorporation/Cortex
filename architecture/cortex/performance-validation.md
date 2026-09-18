# Client performance changes and verification

This change preserves model weights, sampling, prompt contents, retrieval scores,
features, authentication and billing behavior. It is not a claim that every
operation is faster on every device.

| Path | Previous work | New work | Regression coverage |
|---|---|---|---|
| Model lookup | Scan catalogue and variants on each lookup; rebuild variant entity | Lazy ID/parent indexes and 128-entry LRU for resolved variants | Exact-ID precedence, mutation invalidation, language changes |
| Catalogue hydration | Yield after every five models regardless of cost | Existing AdaptiveBatcher targets short event-loop slices | Existing batching implementation; catalogue lookup tests |
| RAG result selection | Sort every matching chunk | Bounded heap retains top K; final sort only K | Independent full BM25 reference, ties, repeated terms, zero/large K |
| Office extraction | Decode ZIP/XML/workbooks on main isolate | Worker isolate reads path and returns extracted text | DOCX Unicode, PPTX text, XLSX values, corrupt file |
| Streaming scroll | Every token waits for the same frame and starts an animation | Coalesce requests waiting for one frame; reject replaced controller work | Bursts, subsequent frames, controller replacement |
| Local CPU threads | Infer 2/4/6 threads from RAM | Logical-core policy, UI headroom, cap 6 | Single/dual/quad/octacore, invalid count, upper bound |

Office workers receive only file paths. PDF extraction stays on its existing
native/plugin path. Existing ingestion size checks and caller concurrency limits
remain in force. Moving parsing does not remove its memory cost; a document can
still require substantial memory inside the worker.

Catalogue indexes are invalidated on hydration, locale rebuild, add/remove,
entity update and cache clear. These assume mutations use ModelService's existing
mutation methods; callers must not mutate the returned catalogue list or nested
variant maps directly. Variant cache entries contain no user chat content.

Android and iOS still use their existing backend choices. No Vulkan assumption,
KV-cache protocol, context resizing, speculative decoding or warm-up is added.
CPU core count does not identify performance versus efficiency cores; physical
mobile-device measurements are required before more aggressive thread policies.

## Reproducible verification

The App performance regression checks workflow runs changed-file analysis,
regression tests, full-repository analysis and an Android debug/native build.
It uses Flutter 3.47.2 from the existing release workflow and Java 21, matching
android/llama's configured Java/Kotlin target. It does not use release signing
secrets or publish an app.

For device profiling, use the same device, model GGUF, prompts and documents for
both main d87b19b and this branch. Keep power/thermal conditions comparable.
Record at least five warm runs plus a cold run, reporting medians separately:

- Cold launch and model-library opening: first useful frame and slow frames.
- Stream a long answer: UI/raster frame times, auto-scroll and manual scrolling.
- DOCX/XLSX/PPTX ingestion: wall time, peak memory, responsiveness while typing.
- BM25: identical selected document IDs/query/topK; compare ordered chunk IDs and
  scores before considering latency results.
- Offline model: load time, first token and token/s; check UI responsiveness and
  thermals on small and large core-count devices.

No device benchmark or percentage speedup is asserted by this PR. Microbenchmarks
must be identified as such and cannot stand in for end-to-end mobile timings.
