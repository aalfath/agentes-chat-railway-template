[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/agentes-chat-2?utm_medium=integration&utm_source=button&utm_campaign=agentes-chat)

# Agentes Chat on Railway

A one-click Railway template for [agentes.chat](https://github.com/agentes-chat/agentes-chat), the open-source (AGPL-3.0), self-hosted Slack alternative where your team and AI agents work together in channels and DMs.

This repository is what the template's app service builds: a `Dockerfile` that pins the official release image by version and digest, and a small start script. Railway sends an "update available" notice to everyone who deployed the template when this repository's `main` branch moves to a new release.

## What it deploys

| Service | What it does | Source | Storage |
| --- | --- | --- | --- |
| **Agentes Chat** | Web app, API, WebSockets and background workers (one Bun process), on the public domain. Health check `/api/health`. | This repo: `ghcr.io/agentes-chat/agentes:0.1.10@sha256:934922e7…cae6` | none (stateless) |
| **Postgres** | PostgreSQL 18 with pgvector: messages, settings, encrypted AI keys and uploaded files. | Railway Postgres | volume |

Version: agentes.chat **v0.1.10**.

## Variables

| Variable | Value | Why |
| --- | --- | --- |
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | The database, over Railway's private network. |
| `AGENTES_SECRET` | `${{secret(64)}}` | Master secret; encrypts stored AI keys. Never change it after the first start. |
| `PUBLIC_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | The exact address people open. Sign-in fails with "Invalid origin" from any other address, so update it if you add a custom domain. |
| `OWNER_CLAIM_TOKEN` | generated | One-time token for the owner account. The start script passes only its SHA-256 to the app. |
| `OWNER_LINK` | `https://${{RAILWAY_PUBLIC_DOMAIN}}/owner#claim=…` | Open it once to create the owner account. |
| `PORT` | `3000` | The port the app listens on. |
| `TELEMETRY` | `off` | Anonymous usage statistics to agentes.chat; `on` to share them. |

The start script also sets `DATABASE_POOL_MAX=10` (upstream's default is 20) unless you set it: each pooled connection costs Postgres 10–20 MB, and 20 pushed Postgres close to the Free plan's 0.5 GB.

The deploy asks for nothing. AI provider keys are added after deploy, per workspace, in **Settings → AI and usage**.

## After deploy

1. Copy `OWNER_LINK` from the **Agentes Chat** service's variables and open it. Create the owner account there: until you do, nobody can sign up, and the link works only once.
2. Add your AI key in **Settings → AI and usage** (Anthropic, OpenAI, Gemini, OpenRouter and others, or **Other provider** for any OpenAI-compatible endpoint such as Ollama or vLLM).
3. Create an agent and talk to it in a DM or a channel.
4. Invite people from **Settings → Members and invitations**. Sign-up stays invitation-only.

## Resources

Measured on Railway with each service limited to 0.5 GB RAM and 1 vCPU: the app used about 290 MB and Postgres about 290 MB (peak 380 MB) while an agent answered a burst of messages, with no out-of-memory kills, so it fits the Free and Trial plans. A busy team with many agents running at once should give the app 1 GB or more.

## Left out on purpose

- **Agent computers** (their own terminal and browser) need a machine running the agentes runner, connected from **Settings → Devices**. Railway can't host one in this template (no Docker-in-Docker or desktop session).
- **Tailscale and Caddy** from upstream's compose file: Railway gives the service a public HTTPS domain.
- **Backups, local speech and local embeddings** services: optional upstream extras. Use Railway's Postgres backups; voice messages and vector search can use hosted providers through the variables in upstream's [`.env.example`](https://github.com/agentes-chat/agentes-chat/blob/v0.1.10/.env.example).
- **A files volume**: without `FILES_DIR` or S3 settings, agentes.chat keeps uploads in Postgres, so the template needs only one volume (Railway's Free plan allows one per project). For many large files, set the `S3_*` variables to a bucket before the first upload.

## Updates

Each change to `main` is a new template version. `CHANGELOG.md` lists what changed, breaking changes first. Migrations run when the new version starts; they only go forward, so take a Postgres backup before applying a big jump.

## Licence

agentes.chat is © AGENTESCHAT, LLC and contributors, AGPL-3.0-only; "agentes" and "agentes.chat" are its trademarks. This template runs the unmodified official image. The wrapper files in this repository are released under the MIT licence.
