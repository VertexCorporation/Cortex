# Document tools

The online chat tool loop advertises `read_document`, `create_document` and
`edit_document`. Binary attachments get opaque scopes; bytes are encoded only
when the read tool runs. Created files receive a new scope and a document card.
The model receives a summary rather than the local artifact path.

`DocumentArtifactService` writes PDF, DOCX, XLSX, PPTX, TXT, Markdown, CSV and
JSON in the app document directory. The share action checks the canonical path
and rejects private files or links escaping the artifact directory. Concurrent
outputs get separate directories. Edits produce a new copy and preserve the
source, including failed edits.

PDF, DOCX and PPTX editing reconstructs extracted text and reports a warning;
it does not preserve complex layout, images, forms or animations. Scanned PDFs
require OCR, which this feature does not supply. XLSX retains cell types and
supports cell updates, appended rows and text replacements. PowerPoint reading
uses numeric slide order, including presentations with more than nine slides.

This branch includes current main changes. CI generates localization, analyzes
the application, runs document safety/round-trip/attachment regressions and
compiles Android arm64 debug. Round-trip tests check Office/text formats and
original preservation; the PDF test checks its container signature and trailer.
They do not establish visual fidelity in Office viewers or native PDF reading.
Physical-device sharing, live model tool calls and iOS compilation need separate
verification. Source-size limits do not bound decompressed OOXML expansion.
