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
```

The script detects `X-CSRFToken` from the Playwright Chrome session automatically.

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
--no-resume
--save-json
--page-size 1000
--no-sandbox
```

Each `.sql` file must contain exactly one clause like:

```sql
OFFSET 1000*0 ROWS FETCH NEXT 1000 ROWS ONLY
```
