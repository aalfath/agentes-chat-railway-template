#!/bin/sh
# Railway start wrapper for agentes.chat. It only prepares the environment, then hands over to the
# app's own entrypoint with exec, so the app is PID 1 and any crash exits non-zero (Railway restarts it).
set -eu

fail() { echo "agentes-railway: $*" >&2; exit 1; }

[ -n "${DATABASE_URL:-}" ] || fail "DATABASE_URL is empty: reference the Postgres service (\${{Postgres.DATABASE_URL}})."
[ "${#AGENTES_SECRET}" -ge 32 ] 2>/dev/null || fail "AGENTES_SECRET must be at least 32 characters."

# PUBLIC_URL must be the exact origin people open, with no trailing slash.
PUBLIC_URL="${PUBLIC_URL%/}"
case "$PUBLIC_URL" in
  http://?*|https://?*) ;;
  *) fail "PUBLIC_URL ('$PUBLIC_URL') is not an address. Generate a Railway domain for this service and redeploy." ;;
esac
export PUBLIC_URL

# Owner link: while no account exists, only <PUBLIC_URL>/owner#claim=<OWNER_CLAIM_TOKEN> can create the
# first account (the installation's owner). The app wants the token's SHA-256, so derive it here.
if [ -n "${OWNER_CLAIM_TOKEN:-}" ] && [ -z "${OWNER_CLAIM_SHA256:-}" ]; then
  OWNER_CLAIM_SHA256=$(printf %s "$OWNER_CLAIM_TOKEN" | sha256sum | cut -d' ' -f1)
  export OWNER_CLAIM_SHA256
fi
unset OWNER_CLAIM_TOKEN OWNER_LINK

# Each pooled connection costs Postgres 10-20 MB; upstream's 20 pushed Railway Postgres near the Free
# plan's 0.5 GB. 10 is plenty for a small team; raise it (and Postgres's memory) for a busy one.
export DATABASE_POOL_MAX="${DATABASE_POOL_MAX:-10}"

# On a first deploy Postgres can still be starting (or its private DNS name not resolving yet). The app
# exits at once without it, and quick restarts can use up Railway's restart retries, so wait for the
# database port first (up to DB_WAIT_SECONDS, 180 by default), then let the app run its migrations.
bun -e '
const u = new URL(process.env.DATABASE_URL);
const host = u.hostname.replace(/^\[|\]$/g, ""), port = Number(u.port || 5432);
const limit = Date.now() + 1000 * Number(process.env.DB_WAIT_SECONDS || 180);
let said = false;
for (;;) {
  const ok = await new Promise((done) => {
    Bun.connect({ hostname: host, port, socket: { open(s) { s.end(); done(true); }, data() {}, error() { done(false); }, connectError() { done(false); } } })
      .catch(() => done(false));
  });
  if (ok) process.exit(0);
  if (Date.now() > limit) { console.error(`agentes-railway: database ${host}:${port} not reachable, giving up`); process.exit(1); }
  if (!said) { console.log(`agentes-railway: waiting for the database at ${host}:${port}`); said = true; }
  await Bun.sleep(2000);
}
' || exit 1

exec bun /app/apps/server/src/main.ts "$@"
