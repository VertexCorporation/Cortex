# Cortex — Agent Working Guide

Cortex is part of a three-system architecture: this Flutter client, the Fulcrum Firebase Functions backend (sibling repo `../Fulcrum`), and the Synapse Cloudflare Workers model catalogue (sibling repo `../Synapse`).

## Required reading protocol

1. Read `architecture/general.md` first — system map, critical data flows, boundaries and the routing table.
2. Open only the architecture documents relevant to the current task:
   - Chat bugs/features → `architecture/cortex/chat.md`
   - RAG/retrieval → `architecture/cortex/rag.md`
   - Model library/downloads → `architecture/cortex/library.md`
   - Login/accounts → `architecture/cortex/auth.md`
   - Purchases/credits → `architecture/cortex/payments.md`
   - Backend generation/SSE → `architecture/fulcrum/generation.md`
   - Backend accounts/billing → `architecture/fulcrum/billing.md`
   - Model catalogue pipeline → `architecture/synapse/*.md`
3. Locate code with `architecture/cortex/file-map.md` (all 304 Dart files with declarations) and `architecture/fulcrum/functions-map.md` instead of scanning the repository.
4. Open only the source files needed for the change. Do not read the whole repository, and do not read every architecture file.

## Project conventions

- Run `flutter analyze` before finishing a change; tests live in `test/`.
- l10n classes are generated — edit the ARB sources, never the generated `app_localizations_*.dart` files.
- Sibling repos (`../Fulcrum`, `../Synapse`) are separate projects with their own toolchains; do not mix their dependencies into this one.
