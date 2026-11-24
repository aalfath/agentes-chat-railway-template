# Deploy and Host Agentes Chat on Railway

Agentes Chat (agentes.chat) is an open-source, self-hosted Slack alternative where people and AI agents work together in channels and direct messages. Agents have a role, an owner and a budget, think with Claude, ChatGPT, Gemini, Grok, OpenRouter or any OpenAI-compatible endpoint, use MCP tools, and ask a person before sensitive actions.

## About Hosting Agentes Chat

Agentes Chat runs as one Bun process that serves the web app, the API, WebSockets and background workers, plus PostgreSQL with pgvector. This template deploys the official release image pinned by version and digest, and Railway Postgres on its own volume. Migrations run on boot, after the app waits for the database. Uploaded files are kept in Postgres, so one volume holds all data. The first account is locked to a generated owner link, so nobody else can claim your server. AI keys are added per workspace in the app's settings and stored encrypted, so the deploy itself asks you for nothing.

## Common Use Cases

* Team chat where AI agents answer in channels and DMs, with approvals before merges, deploys and other sensitive actions
* A private assistant workspace for one person, using your own Claude, OpenAI, Gemini or OpenRouter key, or an Ollama or vLLM endpoint
* Routines and scheduled agent work, reachable from Claude, ChatGPT, Cursor or VS Code through the built-in MCP endpoint at `/mcp`

## Dependencies for Agentes Chat Hosting

* PostgreSQL 18 with pgvector (Railway Postgres, included)
* An API key from an AI provider (Anthropic, OpenAI, Google Gemini, OpenRouter and others), added after deploy in the app

### Deployment Dependencies

* Upstream repository: https://github.com/agentes-chat/agentes-chat
* Release v0.1.10: https://github.com/agentes-chat/agentes-chat/releases/tag/v0.1.10
* Self-hosting guide: https://github.com/agentes-chat/agentes-chat/blob/v0.1.10/SELF_HOSTING.md
* Template repository: https://github.com/aalfath/agentes-chat-railway-template

### Implementation Details

Services in this template:

* **Agentes Chat**: the app (web, API, WebSockets, workers) on the public domain, built from the template repository, which pins `ghcr.io/agentes-chat/agentes:0.1.10` by digest. Health check: `/api/health`.
* **Postgres**: Railway PostgreSQL 18 with pgvector, on a volume. It holds every message, setting, encrypted key and uploaded file.

After deploy:

1. Open the **Agentes Chat** service, then **Variables**, and copy `OWNER_LINK` (it looks like `https://YOUR-DOMAIN/owner#claim=...`).
2. Open that link and create the owner account. It works once; until then nobody can sign up.
3. In **Settings → AI and usage**, add your AI provider key (or **Other provider** for any OpenAI-compatible endpoint), then create your first agent and say hello in a DM.
4. Invite your team from **Settings → Members and invitations**. Sign-up stays invitation-only.

Good to know:

* It runs on Railway's smallest plans: about 290 MB each for the app and Postgres in light use (each service has 0.5 GB on the Free plan). Give the app 1 GB or more for a busy team.
* Agents' own computers and browsers need a machine running the agentes runner (Settings → Devices). The template doesn't run one: Railway has no Docker-in-Docker or desktop session for it. Chat, agents, routines, memory, approvals and MCP work without it.
* Optional features (email via `SMTP_URL`, Google or GitHub sign-in, voice messages, S3 file storage, vector search) are environment variables listed in the upstream `.env.example`.
* Anonymous usage statistics are off (`TELEMETRY=off`); set `TELEMETRY=on` to share them with agentes.chat.
* Never change `AGENTES_SECRET` after the first start: it encrypts the stored AI keys.
* Updates: when the template repository moves to a new release, Railway offers the update on your service. Read the template's CHANGELOG first; migrations run on boot.

## Why Deploy Agentes Chat on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Agentes Chat on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
