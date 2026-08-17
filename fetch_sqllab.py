#!/usr/bin/env python3
import argparse
import csv
import json
import os
import random
import re
import sys
import tempfile
import time
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any


BASE_URL = "https://fasih-dashboard.bps.go.id"
SQLLAB_URL = BASE_URL + "/superset/sqllab/"
RESULTS_URL_FRAGMENT = "/api/v1/sqllab/results/"
SQLLAB_API_FRAGMENT = "/api/v1/sqllab/"
NO_STORED_RESULT = "no stored result found"
OFFSET_RE = re.compile(
    r"OFFSET\s+(?:\d+\s*\*\s*\d+|\d+)\s+ROWS\s+FETCH\s+NEXT\s+\d+\s+ROWS\s+ONLY",
    re.IGNORECASE,
)
LIMIT_RE = re.compile(
    r"LIMIT\s+(?:\d+\s*\*\s*\d+|\d+)\s*,\s*\d+",
    re.IGNORECASE,
)
LIMIT_OFFSET_RE = re.compile(
    r"LIMIT\s+\d+\s+OFFSET\s+(?:\d+\s*\*\s*\d+|\d+)",
    re.IGNORECASE,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--sql")
    parser.add_argument("--env", default=".env")
    parser.add_argument("--output-dir", default="output")
    parser.add_argument("--page-size", type=int, default=9000)
    parser.add_argument("--pagination", choices=("auto", "offset", "limit"), default="auto")
    parser.add_argument("--timeout", type=int, default=300)
    parser.add_argument("--reload-after", type=int, default=120)
    parser.add_argument("--reload-wait-min", type=float, default=3)
    parser.add_argument("--reload-wait-max", type=float, default=15)
    parser.add_argument("--delay", type=float, default=3)
    parser.add_argument("--max-retries", type=int, default=3)
    parser.add_argument("--max-pages", type=int)
    parser.add_argument("--batch-pages", type=int)
    parser.add_argument("--save-json", action="store_true")
    parser.add_argument("--merged-csv")
    parser.add_argument("--manual-start", action="store_true")
    parser.add_argument("--resume", action=argparse.BooleanOptionalAction, default=True)
    parser.add_argument("--show-browser", action=argparse.BooleanOptionalAction, default=True)
    parser.add_argument("--chrome-profile")
    parser.add_argument("--chrome-profile-directory")
    parser.add_argument("--cdp-url")
    parser.add_argument("--no-sandbox", action="store_true")
    parser.add_argument("--self-check", action="store_true")
    return parser.parse_args()


def load_env(path: str) -> dict[str, str]:
    env = dict(os.environ)
    env_path = Path(path)
    if not env_path.exists():
        return env
    for raw_line in env_path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        env[key.strip()] = value.strip().strip('"').strip("'")
    return env


def read_sql(path: str) -> str:
    return Path(path).read_text().strip()


def log(message: str) -> None:
    print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {message}", flush=True)


def set_offset_sql(sql: str, page_index: int, page_size: int) -> str:
    matches = list(OFFSET_RE.finditer(sql))
    if len(matches) != 1:
        raise ValueError(f"Expected exactly one OFFSET/FETCH clause, found {len(matches)}")
    clause = f"OFFSET {page_size}*{page_index} ROWS FETCH NEXT {page_size} ROWS ONLY"
    return OFFSET_RE.sub(clause, sql, count=1)


def set_limit_sql(sql: str, page_index: int, page_size: int) -> str:
    comma_matches = list(LIMIT_RE.finditer(sql))
    offset_matches = list(LIMIT_OFFSET_RE.finditer(sql))
    if len(comma_matches) + len(offset_matches) != 1:
        raise ValueError("Expected exactly one LIMIT clause")
    if comma_matches:
        return LIMIT_RE.sub(f"LIMIT {page_index * page_size}, {page_size}", sql, count=1)
    return LIMIT_OFFSET_RE.sub(f"LIMIT {page_size} OFFSET {page_index * page_size}", sql, count=1)


def set_page_sql(sql: str, page_index: int, page_size: int, pagination: str) -> str:
    if pagination == "limit":
        return set_limit_sql(sql, page_index, page_size)
    return set_offset_sql(sql, page_index, page_size)


def resolve_pagination(sql: str, pagination: str) -> str:
    if pagination != "auto":
        return pagination
    has_limit = bool(LIMIT_RE.search(sql) or LIMIT_OFFSET_RE.search(sql))
    has_offset = bool(OFFSET_RE.search(sql))
    if has_limit == has_offset:
        raise ValueError("Expected exactly one LIMIT or OFFSET/FETCH clause")
    return "limit" if has_limit else "offset"


def output_paths(output_dir: str, sql_path: str) -> tuple[Path, Path, Path]:
    run_dir = Path(output_dir) / Path(sql_path).stem
    pages_dir = run_dir / "pages"
    checkpoint = run_dir / "checkpoint.json"
    pages_dir.mkdir(parents=True, exist_ok=True)
    return run_dir, pages_dir, checkpoint


def load_checkpoint(path: Path, resume: bool, page_size: int, pagination: str) -> dict[str, Any]:
    if resume and path.exists():
        checkpoint = json.loads(path.read_text())
        if checkpoint.get("page_size") != page_size or checkpoint.get("pagination") != pagination:
            raise RuntimeError(
                f"Checkpoint uses page_size={checkpoint.get('page_size')} "
                f"and pagination={checkpoint.get('pagination')}; "
                "use --no-resume to start a new run."
            )
        return checkpoint
    return {"next_page_index": 0, "total_rows": 0, "page_size": page_size, "pagination": pagination}


def save_checkpoint(path: Path, checkpoint: dict[str, Any]) -> None:
    path.write_text(json.dumps(checkpoint, indent=2))


def stop_reason(page_index: int, max_pages: int | None, batch_pages: int | None, start_page: int) -> str | None:
    if max_pages is not None and page_index >= max_pages:
        return f"Reached max-pages={max_pages}."
    if batch_pages is not None and page_index >= start_page + batch_pages:
        return f"Reached batch-pages={batch_pages}."
    return None


def rows_from_response(response: dict[str, Any]) -> list[dict[str, Any]]:
    if response.get("errors"):
        first = response["errors"][0] if response["errors"] else {}
        message = first.get("message", "SQL Lab API error") if isinstance(first, dict) else str(first)
        raise RuntimeError(message)
    rows = response.get("data")
    if not isinstance(rows, list):
        raise RuntimeError("Results JSON does not contain a data array")
    return rows


def write_csv(path: Path, rows: list[dict[str, Any]]) -> None:
    columns: list[str] = []
    seen: set[str] = set()
    for row in rows:
        for key in row:
            if key not in seen:
                seen.add(key)
                columns.append(key)
    with path.open("w", newline="", encoding="utf-8-sig") as handle:
        writer = csv.DictWriter(handle, fieldnames=columns, extrasaction="ignore")
        writer.writeheader()
        for row in rows:
            writer.writerow({key: normalize_cell(row.get(key)) for key in columns})


def merge_page_csvs(pages_dir: Path, output_path: Path) -> None:
    files = sorted(pages_dir.glob("page-*.csv"))
    if not files:
        raise RuntimeError(f"No page CSV files found in {pages_dir}")

    columns: list[str] = []
    seen: set[str] = set()
    for path in files:
        with path.open(newline="", encoding="utf-8-sig") as handle:
            for column in next(csv.reader(handle), []):
                if column not in seen:
                    seen.add(column)
                    columns.append(column)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    temporary_path = output_path.with_suffix(output_path.suffix + ".tmp")
    try:
        with temporary_path.open("w", newline="", encoding="utf-8-sig") as handle:
            writer = csv.DictWriter(handle, fieldnames=columns, extrasaction="ignore")
            if columns:
                writer.writeheader()
            for path in files:
                with path.open(newline="", encoding="utf-8-sig") as page_handle:
                    for row in csv.DictReader(page_handle):
                        writer.writerow({column: row.get(column, "") or "" for column in columns})
        temporary_path.replace(output_path)
    except Exception:
        temporary_path.unlink(missing_ok=True)
        raise


def normalize_cell(value: Any) -> Any:
    if value is None:
        return ""
    if isinstance(value, (dict, list)):
        return json.dumps(value, ensure_ascii=False)
    return value


def needs_result_rerun(response: dict[str, Any]) -> bool:
    return NO_STORED_RESULT in json.dumps(response, ensure_ascii=False).lower()


def response_row_count(response: dict[str, Any]) -> int | None:
    rows = response.get("data")
    return len(rows) if isinstance(rows, list) else None


def is_sql_lab_api_response(response: Any) -> bool:
    return (
        response.request.method.upper() in {"GET", "POST"}
        and SQLLAB_API_FRAGMENT in response.url
    )


def set_editor_sql(page: Any, sql: str) -> None:
    ok = page.evaluate(
        """(sql) => {
            const aceEl = document.querySelector(".ace_editor");
            if (aceEl && aceEl.env && aceEl.env.editor) {
                aceEl.env.editor.setValue(sql, -1);
                aceEl.env.editor.focus();
                return true;
            }

            const cmEl = document.querySelector(".CodeMirror");
            if (cmEl && cmEl.CodeMirror) {
                cmEl.CodeMirror.setValue(sql);
                cmEl.CodeMirror.focus();
                return true;
            }

            const textarea = Array.from(document.querySelectorAll("textarea"))
                .find((item) => item.offsetWidth > 0 && item.offsetHeight > 0);
            if (textarea) {
                textarea.focus();
                textarea.value = sql;
                textarea.dispatchEvent(new Event("input", { bubbles: true }));
                textarea.dispatchEvent(new Event("change", { bubbles: true }));
                return true;
            }

            return false;
        }""",
        sql,
    )
    if ok:
        return

    editor = page.locator(".ace_text-input, .CodeMirror textarea, textarea").first
    editor.click(timeout=20_000, force=True)
    page.keyboard.press("Control+A")
    page.keyboard.insert_text(sql)


def click_run_and_wait_results(page: Any, timeout_ms: int, rerun_delay: float = 5) -> dict[str, Any]:
    for attempt in range(2):
        log(f"Run click attempt={attempt + 1}/2")
        run_button = page.locator("button.ant-btn.superset-button.cta:has(span:has-text('Run'))").first
        run_button.wait_for(state="visible", timeout=45_000)
        run_button.scroll_into_view_if_needed(timeout=10_000)

        deadline = time.monotonic() + timeout_ms / 1000
        request_started = False
        while True:
            remaining_ms = max(1_000, int((deadline - time.monotonic()) * 1000))
            with page.expect_response(is_sql_lab_api_response, timeout=remaining_ms) as response_info:
                if not request_started:
                    run_button.click(timeout=20_000, force=True)
                    request_started = True
            response = response_info.value
            is_result = RESULTS_URL_FRAGMENT in response.url
            try:
                payload = response.json()
            except Exception:
                if is_result:
                    raise RuntimeError(f"Results returned non-JSON HTTP {response.status}")
                log(f"Ignored non-JSON SQL Lab response status={response.status} url={response.url}")
                continue

            warning = needs_result_rerun(payload)
            rows = response_row_count(payload)
            log(f"SQL Lab response status={response.status} rows={rows} warning={warning} url={response.url}")
            if warning:
                break
            if rows is not None:
                return payload
            if time.monotonic() >= deadline:
                raise TimeoutError(f"SQL Lab returned no row payload within {timeout_ms}ms")

        if attempt:
            return payload
        print("SQL Lab returned 'no stored result found'; rerunning in 5s...", file=sys.stderr)
        time.sleep(rerun_delay)
    raise RuntimeError("SQL Lab result rerun failed")


def fetch_page(page: Any, sql: str, page_index: int, page_size: int, timeout: int, reload_after: int, pagination: str) -> dict[str, Any]:
    page_sql = set_page_sql(sql, page_index, page_size, pagination)
    clause = (LIMIT_RE.search(page_sql) or LIMIT_OFFSET_RE.search(page_sql)) if pagination == "limit" else OFFSET_RE.search(page_sql)
    log(f"Preparing page={page_index} offset={page_index * page_size} clause={clause.group(0) if clause else 'MISSING'}")
    set_editor_sql(page, page_sql)
    log(f"Editor updated page={page_index}; waiting before Run")
    time.sleep(0.5)
    return click_run_and_wait_results(page, min(timeout, reload_after) * 1000)


def open_sqllab(page: Any, timeout_error: Any) -> None:
    try:
        page.wait_for_load_state("domcontentloaded", timeout=10_000)
    except timeout_error:
        pass
    try:
        page.goto(SQLLAB_URL, wait_until="domcontentloaded", timeout=120_000)
    except Exception as exc:
        if "interrupted by another navigation" not in str(exc).lower():
            raise
        log("SQL Lab navigation is still active; waiting for it to settle")
        page.wait_for_load_state("domcontentloaded", timeout=120_000)
    try:
        page.wait_for_load_state("networkidle", timeout=120_000)
    except timeout_error:
        pass


def first_page(context: Any) -> Any:
    for page in context.pages:
        if BASE_URL in page.url:
            return page
    return context.new_page()


def check_cdp(cdp_url: str) -> None:
    url = cdp_url.rstrip("/") + "/json/version"
    try:
        with urllib.request.urlopen(url, timeout=3) as response:
            json.loads(response.read().decode("utf-8"))
    except (OSError, urllib.error.URLError, json.JSONDecodeError) as exc:
        raise RuntimeError(
            f"Cannot reach Chrome DevTools at {url}. Close Chrome, start it with "
            "`google-chrome --remote-debugging-port=9222 --user-data-dir=$HOME/.config/google-chrome`, "
            "then verify `curl http://127.0.0.1:9222/json/version` works."
        ) from exc


def cdp_context(browser: Any) -> Any:
    if not browser.contexts:
        raise RuntimeError("CDP connected, but Chrome exposed no browser context. Restart Chrome with a real user-data-dir.")
    return browser.contexts[0]


def run(args: argparse.Namespace) -> int:
    try:
        from playwright.sync_api import TimeoutError as PlaywrightTimeoutError
        from playwright.sync_api import sync_playwright
    except ImportError as exc:
        raise RuntimeError("Playwright is not installed. Run `uv sync` first.") from exc

    if not args.sql:
        raise RuntimeError("--sql is required")

    env = load_env(args.env)
    cdp_url = args.cdp_url or env.get("SQLLAB_CDP_URL")
    profile = args.chrome_profile or env.get("SQLLAB_CHROME_PROFILE") or ".chrome-sqllab-profile"
    profile_directory = args.chrome_profile_directory or env.get("SQLLAB_CHROME_PROFILE_DIRECTORY")
    sql = read_sql(args.sql)
    pagination = resolve_pagination(sql, args.pagination)
    run_dir, pages_dir, checkpoint_path = output_paths(args.output_dir, args.sql)
    checkpoint = load_checkpoint(checkpoint_path, args.resume, args.page_size, pagination)
    start_page = int(checkpoint["next_page_index"])
    log(f"sql={args.sql}")
    log(f"output={run_dir}")
    log(f"pages={pages_dir}")
    log(f"checkpoint={checkpoint_path}")
    log(f"start_page={start_page} page_size={args.page_size} pagination={pagination}")
    if cdp_url:
        log(f"cdp_url={cdp_url}")

    with sync_playwright() as playwright:
        browser = None
        if cdp_url:
            check_cdp(cdp_url)
            browser = playwright.chromium.connect_over_cdp(cdp_url)
            context = cdp_context(browser)
        else:
            chrome_args = ["--no-sandbox"] if args.no_sandbox else []
            if profile_directory:
                chrome_args.append(f"--profile-directory={profile_directory}")
            context = playwright.chromium.launch_persistent_context(
                user_data_dir=profile,
                channel="chrome",
                headless=not args.show_browser,
                args=chrome_args,
            )
        try:
            page = first_page(context)
            open_sqllab(page, PlaywrightTimeoutError)
            if args.manual_start:
                input("Log in/check SQL Lab, then press Enter to start...")

            while True:
                page_index = int(checkpoint["next_page_index"])
                log(f"Starting page={page_index} offset={page_index * args.page_size}")
                reason = stop_reason(page_index, args.max_pages, args.batch_pages, start_page)
                if reason:
                    log(reason)
                    return 0

                response = retry_page(
                    args,
                    lambda: fetch_page(page, sql, page_index, args.page_size, args.timeout, args.reload_after, pagination),
                    page_index,
                    lambda: open_sqllab(page, PlaywrightTimeoutError),
                )
                rows = rows_from_response(response)
                log(f"Page={page_index} received rows={len(rows)}")
                page_base = pages_dir / f"page-{page_index:04d}"
                write_csv(page_base.with_suffix(".csv"), rows)
                log(f"Page={page_index} CSV saved path={page_base.with_suffix('.csv')}")
                if args.save_json:
                    page_base.with_suffix(".json").write_text(json.dumps(response, ensure_ascii=False, indent=2))

                checkpoint = {
                    "next_page_index": page_index + 1,
                    "last_completed_page_index": page_index,
                    "last_completed_offset": page_index * args.page_size,
                    "last_page_rows": len(rows),
                    "total_rows": int(checkpoint["total_rows"]) + len(rows),
                    "page_size": args.page_size,
                    "pagination": pagination,
                }
                save_checkpoint(checkpoint_path, checkpoint)
                log(
                    f"Checkpoint saved page={page_index} next_page={checkpoint['next_page_index']} "
                    f"offset={page_index * args.page_size} rows={len(rows)} total={checkpoint['total_rows']}"
                )
                time.sleep(args.delay)

                if len(rows) < args.page_size:
                    if args.merged_csv:
                        merged_csv = Path(args.merged_csv)
                        merge_page_csvs(pages_dir, merged_csv)
                        log(f"Merged CSV saved path={merged_csv}")
                    log("Last page reached.")
                    return 0
                log(f"Page={page_index} complete; advancing to page={page_index + 1}")
        finally:
            if not cdp_url:
                context.close()


def retry_page(args: argparse.Namespace, task: Any, page_index: int, on_retry: Any = None) -> dict[str, Any]:
    for attempt in range(1, args.max_retries + 1):
        try:
            return task()
        except Exception as exc:
            error_text = str(exc).lower()
            non_retry = "create failed" in error_text or "syntax" in error_text
            if non_retry or attempt >= args.max_retries:
                print(f"Page {page_index} failed: {exc}", file=sys.stderr, flush=True)
                raise
            sleep_seconds = random.uniform(args.reload_wait_min, args.reload_wait_max) if "timeout" in error_text else min(30, attempt * 3)
            print(f"Page {page_index} attempt {attempt} failed: {exc}. Retrying in {sleep_seconds:.1f}s...", file=sys.stderr, flush=True)
            if on_retry:
                on_retry()
            time.sleep(sleep_seconds)
    raise RuntimeError("Retry loop exhausted")


def self_check() -> int:
    sql = "select * from t OFFSET 1000*0 ROWS FETCH NEXT 1000 ROWS ONLY"
    assert set_offset_sql(sql, 0, 1000).endswith("OFFSET 1000*0 ROWS FETCH NEXT 1000 ROWS ONLY")
    assert set_offset_sql(sql, 9, 1000).endswith("OFFSET 1000*9 ROWS FETCH NEXT 1000 ROWS ONLY")
    limit_sql = "select * from t LIMIT 1000*0, 1000"
    assert set_limit_sql(limit_sql, 0, 1000).endswith("LIMIT 0, 1000")
    assert set_limit_sql(limit_sql, 9, 1000).endswith("LIMIT 9000, 1000")
    limit_offset_sql = "select * from t LIMIT 9000 OFFSET 0"
    assert set_limit_sql(limit_offset_sql, 0, 9000).endswith("LIMIT 9000 OFFSET 0")
    assert set_limit_sql(limit_offset_sql, 1, 9000).endswith("LIMIT 9000 OFFSET 9000")
    assert set_limit_sql(limit_offset_sql, 2, 9000).endswith("LIMIT 9000 OFFSET 18000")
    limit_9000 = "select * from t LIMIT 0, 1000"
    assert set_limit_sql(limit_9000, 0, 9000).endswith("LIMIT 0, 9000")
    assert set_limit_sql(limit_9000, 1, 9000).endswith("LIMIT 9000, 9000")
    assert set_limit_sql(limit_9000, 2, 9000).endswith("LIMIT 18000, 9000")
    assert resolve_pagination(limit_sql, "auto") == "limit"
    assert resolve_pagination(limit_offset_sql, "auto") == "limit"
    assert resolve_pagination(sql, "auto") == "offset"
    try:
        resolve_pagination("select 1", "auto")
    except ValueError:
        pass
    else:
        raise AssertionError("missing pagination should fail")
    assert stop_reason(5, 5, None, 0) == "Reached max-pages=5."
    assert stop_reason(12, None, 2, 10) == "Reached batch-pages=2."
    assert stop_reason(11, None, 2, 10) is None
    try:
        set_offset_sql(sql + " " + sql, 0, 1000)
    except ValueError:
        pass
    else:
        raise AssertionError("duplicate offsets should fail")
    try:
        rows_from_response({"errors": [{"message": "Create failed"}]})
    except RuntimeError as exc:
        assert "Create failed" in str(exc)
    else:
        raise AssertionError("api errors should fail")
    assert needs_result_rerun({"errors": [{"message": "No stored result found"}]})
    assert not needs_result_rerun({"data": [{"id": 1}]})
    with tempfile.TemporaryDirectory() as tmp:
        pages = Path(tmp) / "pages"
        pages.mkdir()
        write_csv(pages / "page-0000.csv", [{"id": "001", "name": "a"}])
        write_csv(pages / "page-0001.csv", [{"id": "002", "extra": "b"}])
        merged = Path(tmp) / "merged.csv"
        merge_page_csvs(pages, merged)
        with merged.open(newline="", encoding="utf-8-sig") as handle:
            merged_rows = list(csv.DictReader(handle))
        assert merged_rows == [
            {"id": "001", "name": "a", "extra": ""},
            {"id": "002", "name": "", "extra": "b"},
        ]
    print("self-check passed")
    return 0


if __name__ == "__main__":
    parsed_args = parse_args()
    try:
        raise SystemExit(self_check() if parsed_args.self_check else run(parsed_args))
    except KeyboardInterrupt:
        raise SystemExit(130)
