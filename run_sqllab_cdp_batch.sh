#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo "Usage: $0 SQL_DIRECTORY" >&2
  exit 2
fi

SQL_DIR="$1"
RUN_DATE="${RUN_DATE:-$(date +%d%m%Y)}"
OUTPUT_ROOT="${OUTPUT_ROOT:-output}"
OUTPUT_DIR="$OUTPUT_ROOT/$RUN_DATE"
CDP_URL="${CDP_URL:-http://127.0.0.1:9222}"
CHROME_USER_DATA_DIR="${CHROME_USER_DATA_DIR:-$HOME/.chrome-sqllab-cdp}"
CHROME_LOG="${CHROME_LOG:-/tmp/sqllab-chrome.log}"
CDP_WAIT_SECONDS="${CDP_WAIT_SECONDS:-30}"
PAGE_SIZE="${PAGE_SIZE:-9000}"

shopt -s nullglob
SQL_FILES=("$SQL_DIR"/*.sql)
if [[ ${#SQL_FILES[@]} -eq 0 ]]; then
  echo "No .sql files found in $SQL_DIR" >&2
  exit 1
fi

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

read -r -p "Log in/check SQL Lab in Chrome, then press Enter to run all queries... "

for sql_path in "${SQL_FILES[@]}"; do
  query_name="$(basename "$sql_path" .sql)"
  merged_csv="$OUTPUT_DIR/${query_name}_${RUN_DATE}.csv"

  if [[ -f "$merged_csv" && "${FORCE:-0}" != "1" ]]; then
    echo "Skipping completed query: $sql_path"
    continue
  fi

  echo "Running query: $sql_path"
  resume_args=()
  if [[ "${FORCE:-0}" == "1" ]]; then
    query_run_dir="$OUTPUT_DIR/$query_name"
    if [[ -d "$query_run_dir/pages" ]]; then
      find "$query_run_dir/pages" -maxdepth 1 -type f \( -name 'page-*.csv' -o -name 'page-*.json' \) -delete
    fi
    rm -f "$query_run_dir/checkpoint.json"
    resume_args=(--no-resume)
  fi

  uv run python fetch_sqllab.py \
    --sql "$sql_path" \
    --output-dir "$OUTPUT_DIR" \
    --cdp-url "$CDP_URL" \
    --pagination limit \
    --page-size "$PAGE_SIZE" \
    --merged-csv "$merged_csv" \
    --timeout "${TIMEOUT:-900}" \
    --reload-after "${RELOAD_AFTER:-360}" \
    --reload-wait-min "${RELOAD_WAIT_MIN:-3}" \
    --reload-wait-max "${RELOAD_WAIT_MAX:-15}" \
    --delay "${DELAY:-15}" \
    --max-retries "${MAX_RETRIES:-20}" \
    "${resume_args[@]}"

  echo "Finished: $merged_csv"
done

echo "All SQL queries completed."
