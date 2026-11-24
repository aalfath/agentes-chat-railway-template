# Agentes Chat (agentes.chat) for Railway: the official release image, pinned by version and digest.
# Upstream: https://github.com/agentes-chat/agentes-chat (AGPL-3.0), release v0.1.10.
FROM ghcr.io/agentes-chat/agentes:0.1.10@sha256:934922e7e48e2922bf77ab5ee0a5f32c82035dc7632ec7ec3c78fe8b1b14cae6

USER root
COPY start.sh /usr/local/bin/agentes-railway-start
RUN chmod 755 /usr/local/bin/agentes-railway-start
USER bun

ENV NODE_ENV=production \
    WEB_DIR=/app/apps/web/dist \
    PORT=3000

EXPOSE 3000
ENTRYPOINT ["/usr/local/bin/agentes-railway-start"]
