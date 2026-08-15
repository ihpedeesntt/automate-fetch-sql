#!/usr/bin/env bash
set -euo pipefail

SQL_FILE="${1:-${SQL_FILE:-}}"
if [[ -z "$SQL_FILE" || $# -gt 1 || ! -f "$SQL_FILE" ]]; then
  echo "Usage: $0 QUERY.sql" >&2
  exit 2
fi

RUN_DATE="${RUN_DATE:-$(date +%d%m%Y)}"
OUTPUT_ROOT="${OUTPUT_ROOT:-output}"
OUTPUT_DIR="$OUTPUT_ROOT/$RUN_DATE"
QUERY_NAME="$(basename "$SQL_FILE" .sql)"
CDP_URL="${CDP_URL:-http://127.0.0.1:9222}"
CHROME_USER_DATA_DIR="${CHROME_USER_DATA_DIR:-$HOME/.chrome-sqllab-cdp}"
CHROME_LOG="${CHROME_LOG:-/tmp/sqllab-chrome.log}"
CDP_WAIT_SECONDS="${CDP_WAIT_SECONDS:-30}"

echo "Starting Chrome with CDP..."
echo "Chrome log: $CHROME_LOG"
echo "Chrome profile: $CHROME_USER_DATA_DIR"
google-chrome \
  --remote-debugging-port=9222 \
  --user-data-dir="$CHROME_USER_DATA_DIR" \
  >"$CHROME_LOG" 2>&1 &

echo "Waiting for CDP at $CDP_URL..."
for _ in $(seq 1 "$CDP_WAIT_SECONDS"); do
  if curl -sf "$CDP_URL/json/version" >/dev/null; then
    echo "CDP ready."
    break
  fi
  sleep 1
done

if ! curl -sf "$CDP_URL/json/version" >/dev/null; then
  echo "CDP did not start within ${CDP_WAIT_SECONDS}s." >&2
  tail -40 "$CHROME_LOG" >&2 || true
  exit 1
fi

read -r -p "Log in/check SQL Lab in Chrome, then press Enter to run... "

uv run python fetch_sqllab.py \
  --sql "$SQL_FILE" \
  --output-dir "$OUTPUT_DIR" \
  --cdp-url "$CDP_URL" \
  --pagination "${PAGINATION:-auto}" \
  --page-size "${PAGE_SIZE:-9000}" \
  --merged-csv "$OUTPUT_DIR/${QUERY_NAME}_${RUN_DATE}.csv" \
  --timeout "${TIMEOUT:-900}" \
  --reload-after "${RELOAD_AFTER:-360}" \
  --reload-wait-min "${RELOAD_WAIT_MIN:-3}" \
  --reload-wait-max "${RELOAD_WAIT_MAX:-15}" \
  --delay "${DELAY:-15}" \
  --max-retries "${MAX_RETRIES:-20}"
