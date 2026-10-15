#!/usr/bin/env bash
# One-time setup: shared key -> Worker + GitHub, deploy Worker in external mode,
# create the public fetcher repo, start the first run.
set -euo pipefail
REPO=37xltd/shopify-catalogue-fetcher
WORKER_URL=https://shopify-catalogue-37x.rewardspy.workers.dev
KEY=$(openssl rand -hex 32)

cd ~/atlas-staging/shopify-catalogue
printf %s "$KEY" | npx wrangler secret put INGEST_KEY
npx wrangler deploy

cd ~/atlas-staging/shopify-catalogue-fetcher
[ -d .git ] || git init -b main
git add -A
git commit -m "Nightly Shopify catalogue fetcher for shopify-catalogue-37x

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01VsZYrRZ6usLS262VEty4yy" || true
gh repo view "$REPO" >/dev/null 2>&1 || gh repo create "$REPO" --public --source . --push
git push -u origin main || true
gh variable set WORKER_URL -R "$REPO" -b "$WORKER_URL"
printf %s "$KEY" | gh secret set INGEST_KEY -R "$REPO"
sleep 5
gh workflow run nightly.yml -R "$REPO"
echo "Started. Watch: gh run watch -R $REPO"
