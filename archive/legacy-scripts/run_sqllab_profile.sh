#!/usr/bin/env bash
set -euo pipefail

SQL_FILE="${SQL_FILE:-KBLI_LEVEL_5.sql}"
OUTPUT_DIR="${OUTPUT_DIR:-output/KBLI/05072026}"
CHROME_PROFILE="${CHROME_PROFILE:-$HOME/.config/google-chrome}"
CHROME_PROFILE_DIRECTORY="${CHROME_PROFILE_DIRECTORY:-Default}"

uv run python fetch_sqllab.py \
  --sql "$SQL_FILE" \
  --output-dir "$OUTPUT_DIR" \
  --chrome-profile "$CHROME_PROFILE" \
  --chrome-profile-directory "$CHROME_PROFILE_DIRECTORY" \
  --timeout "${TIMEOUT:-900}" \
  --delay "${DELAY:-30}" \
  --batch-pages "${BATCH_PAGES:-3}" \
  --manual-start
