# SQL Lab Automate


## Layout

```text
queries/                  SQL inputs
fetch_sqllab.py           Single-query fetcher
run_sqllab_cdp.sh         Single-query launcher
run_sqllab_cdp_batch.sh   Directory batch launcher
run_sqllab_cdp_batch.ps1  Windows PowerShell batch launcher
merge_csv_to_excel.py     Optional Excel conversion
archive/legacy-scripts/   Older launcher variants
output/                   Generated pages, checkpoints, and CSVs
```


## Setup

```bash
uv sync
uv run playwright install chrome
```

## Run shell command 


```bash
./run_sqllab_cdp.sh queries/Keluarga_Ditemukan_Baru.sql
```
On Windows, use the native PowerShell launcher:

```powershell
.\run_sqllab_cdp_batch.ps1
```

It defaults to `queries\Usaha`. To choose another directory:

```powershell
.\run_sqllab_cdp_batch.ps1 .\queries\Sosek
```

If PowerShell blocks local scripts, run it once with:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

The Bash launchers still work through Git Bash or WSL. The Python fetcher is
cross-platform.


```bash
./run_sqllab_cdp_batch.sh queries
```

Jika mau run SQL secara batch, parameter argumen adalah direktori SQL 


```bash
./run_sqllab_cdp_batch.sh queries/Usaha
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

NOTE : Ketika membuka SQLLAB pastikan limit sudah diset menjadi 10000 dan sebaiknya gunakan tab kosong



