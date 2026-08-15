# SQL Lab Pager

Automates paged SQL Lab queries by editing SQL Lab, clicking Run, capturing the results response, and exporting each page to CSV.

## Setup

```bash
uv sync
uv run playwright install chrome
```

Optional `.env`:

```env
SQLLAB_CHROME_PROFILE=.chrome-sqllab-profile
# Optional: attach to Chrome started with --remote-debugging-port=9222
SQLLAB_CDP_URL=http://127.0.0.1:9222
```

## Run

```bash
uv run python fetch_sqllab.py --sql T_USAHA_RAW.sql
```

The first run opens Chrome. Log in to SQL Lab there, then rerun if the first request fails before login completes.

Outputs go to:

```text
output/T_USAHA_RAW/pages/page-0000.csv
output/T_USAHA_RAW/checkpoint.json
```

Useful flags:

```bash
--max-pages 1
--batch-pages 3
--manual-start
--delay 30
--no-resume
--save-json
--page-size 9000
--no-sandbox
```

For flagged/fragile sessions, run small batches and resume later:

```bash
uv run python fetch_sqllab.py \
  --sql KBLI_LEVEL_5.sql \
  --output-dir output/KBLI/29062026 \
  --timeout 900 \
  --delay 30 \
  --batch-pages 3 \
  --manual-start
```

To use your existing Chrome profile without CDP, close all Chrome windows first, then run:

```bash
uv run python fetch_sqllab.py \
  --sql KBLI_LEVEL_5.sql \
  --output-dir output/KBLI/29062026 \
  --chrome-profile "$HOME/.config/google-chrome" \
  --chrome-profile-directory Default \
  --timeout 900 \
  --delay 30 \
  --batch-pages 3 \
  --manual-start
```

Chrome may reject CDP on the default profile. Use a dedicated CDP profile and log in there once:

```bash
google-chrome \
  --remote-debugging-port=9222 \
  --user-data-dir="$HOME/.chrome-sqllab-cdp"
```

Verify Chrome is listening:

```bash
curl http://127.0.0.1:9222/json/version
```

Then run:

```bash
uv run python fetch_sqllab.py \
  --sql KBLI_LEVEL_5.sql \
  --output-dir output/KBLI/29062026 \
  --cdp-url http://127.0.0.1:9222 \
  --timeout 900 \
  --delay 30 \
  --batch-pages 3 \
  --manual-start
```

Each OFFSET-based `.sql` file must contain exactly one clause like:

```sql
OFFSET 9000*0 ROWS FETCH NEXT 9000 ROWS ONLY
```

For databases that support comma-form LIMIT syntax, use `--pagination limit` and
one clause like this:

```sql
LIMIT 0, 9000
```

The fetcher changes only the first LIMIT value, producing `LIMIT 0, 9000`,
then `LIMIT 9000, 9000`, then `LIMIT 18000, 9000`. The second value remains the
page size, so pages are contiguous and do not overlap.

The LIMIT wrapper starts Chrome with CDP and defaults to
`Keluarga_Ditemukan_Baru.sql`:

```bash
./run_sqllab_cdp_limit.sh
```

Override the SQL file and output directory when needed:

```bash
SQL_FILE=MY_QUERY.sql \
OUTPUT_DIR=output/MY_QUERY/16072026 \
./run_sqllab_cdp_limit.sh
```

To restart from page 0, remove the run's checkpoint or pass `--no-resume` when
running `fetch_sqllab.py` directly.

## Merge To Excel

Merge one run's CSV pages into one `.xlsx` with all values written as text:

```bash
uv run python merge_csv_to_excel.py output/KBLI/06072026/KBLI_LEVEL_5
uv run python merge_csv_to_excel.py output/T_USAHA_RAW
```

Optional output path:

```bash
uv run python merge_csv_to_excel.py output/KBLI/06072026/KBLI_LEVEL_5/pages --output output/KBLI/06072026/KBLI_LEVEL_5.xlsx
```

## Batch Queries

Run every `.sql` file in a directory with one Chrome login:

```bash
./run_sqllab_cdp_batch.sh path/to/sql-queries
```

The batch runner processes files in filename order and writes one final CSV
per query:

```text
output/15082026/query_name_15082026.csv
```

Page CSVs and checkpoints remain under the same date directory so an
interrupted query can resume. Completed final CSVs are skipped on rerun.
Use `FORCE=1` to restart completed queries from page 0; stale page files for
that query are cleared first:

```bash
OUTPUT_ROOT=output/exports RUN_DATE=15082026 FORCE=1 \
./run_sqllab_cdp_batch.sh path/to/sql-queries
```
