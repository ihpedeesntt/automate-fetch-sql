#!/usr/bin/env bash
set -euo pipefail

SQL_FILE="${SQL_FILE:-ASSIGNMENT_STATUS_KELUARGA.sql}"
OUTPUT_DIR="${OUTPUT_DIR:-output/ASSIGNMENT_STATUS/13072026}"
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
  echo "Close all Chrome windows first, then rerun this script." >&2
  echo "Chrome log tail:" >&2
  tail -40 "$CHROME_LOG" >&2 || true
  echo "Debug commands:" >&2
  echo "  cat $CHROME_LOG" >&2
  echo "  curl $CDP_URL/json/version" >&2
  exit 1
fi

echo "Starting SQL Lab fetcher..."
uv run python fetch_sqllab.py \
  --sql "$SQL_FILE" \
  --output-dir "$OUTPUT_DIR" \
  --cdp-url "$CDP_URL" \
  --page-size "${PAGE_SIZE:-9000}" \
  --timeout "${TIMEOUT:-900}" \
  --reload-after "${RELOAD_AFTER:-360}" \
  --reload-wait-min "${RELOAD_WAIT_MIN:-3}" \
  --reload-wait-max "${RELOAD_WAIT_MAX:-15}" \
  --delay "${DELAY:-15}" \
  --manual-start
c
