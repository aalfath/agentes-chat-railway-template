# Changelog

Every entry says which agentes.chat release the template runs. Breaking changes come first in each entry.

## 0.1.10 (2026-11-24)

- First version of the template: agentes.chat `v0.1.10` (`ghcr.io/agentes-chat/agentes:0.1.10@sha256:934922e7e48e2922bf77ab5ee0a5f32c82035dc7632ec7ec3c78fe8b1b14cae6`) with Railway PostgreSQL 18 (pgvector).
- The first account is locked to a generated owner link (`OWNER_LINK`); sign-up is invitation-only after it.
- The start script waits for Postgres before the app starts, so a first deploy doesn't crash-loop while the database boots.
