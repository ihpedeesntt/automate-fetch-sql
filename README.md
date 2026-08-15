# SQL Lab Pager

Automates authenticated Superset SQL Lab queries through Chrome/CDP, paginates
results, saves page CSVs, and creates one merged CSV per query.

## Layout

```text
queries/                  SQL inputs
fetch_sqllab.py           Single-query fetcher
run_sqllab_cdp.sh         Single-query launcher
run_sqllab_cdp_batch.sh   Directory batch launcher
merge_csv_to_excel.py     Optional Excel conversion
archive/legacy-scripts/   Older launcher variants
output/                   Generated pages, checkpoints, and CSVs
```

Generated output, Excel files, browser profiles, `.env`, and the virtual
environment are local and ignored by Git.

## Setup

```bash
uv sync
uv run playwright install chrome
```

Start the supported single-query launcher with a query file:

```bash
./run_sqllab_cdp.sh queries/Keluarga_Ditemukan_Baru.sql
```

The launcher starts a dedicated Chrome CDP profile. Log in to SQL Lab once,
then press Enter in the terminal.

Run every SQL file in the query directory with one login:

```bash
./run_sqllab_cdp_batch.sh queries
```

Files run in filename order. A failed query stops the batch so it can be
resumed without silently skipping data.

## Pagination

The fetcher automatically detects one pagination clause in each SQL file.

LIMIT queries use comma syntax:

```sql
LIMIT 0, 9000
```

Pages become `LIMIT 0, 9000`, `LIMIT 9000, 9000`, and so on. OFFSET queries
can use:

```sql
OFFSET 9000*0 ROWS FETCH NEXT 9000 ROWS ONLY
```

The fetcher continues when exactly 9,000 rows are returned and stops when a
page contains fewer rows. Every query should have a stable deterministic
`ORDER BY` so rows do not move between pages during a run.

For direct Python usage:

```bash
uv run python fetch_sqllab.py \
  --sql queries/Keluarga_Ditemukan_Baru.sql \
  --output-dir output/15082026 \
  --pagination auto \
  --page-size 9000 \
  --cdp-url http://127.0.0.1:9222
```

## Output and Resume

For query `Keluarga_Ditemukan_Baru.sql` on `15082026`:

```text
output/15082026/Keluarga_Ditemukan_Baru_15082026.csv
output/15082026/Keluarga_Ditemukan_Baru/pages/page-0000.csv
output/15082026/Keluarga_Ditemukan_Baru/checkpoint.json
```

The batch launcher skips a query when its final CSV already exists. Restart
completed queries from page 0 with:

```bash
FORCE=1 RUN_DATE=15082026 ./run_sqllab_cdp_batch.sh queries
```

Useful overrides:

```bash
OUTPUT_ROOT=output/exports
RUN_DATE=15082026
PAGE_SIZE=9000
TIMEOUT=900
DELAY=15
MAX_RETRIES=20
```

The batch launcher also accepts `CDP_URL`, `CHROME_USER_DATA_DIR`,
`CHROME_LOG`, and `CDP_WAIT_SECONDS`.

## Excel Conversion

Convert one query's page CSVs to an Excel workbook with all values stored as
text:

```bash
uv run python merge_csv_to_excel.py \
  output/15082026/Keluarga_Ditemukan_Baru
```

Use `--output` to choose the workbook path.

## Windows

The Python fetcher works on Windows. The `.sh` launchers require Bash, so use
WSL or Git Bash. Start Chrome with CDP manually and run the Python command if
using PowerShell.

## Legacy Scripts

`archive/legacy-scripts/` contains the older LIMIT-only and existing-profile
launchers. Use the generic CDP launcher or the batch launcher instead.
