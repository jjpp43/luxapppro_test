#!/usr/bin/env python3
"""Load TapMango customer CSV into staging Supabase via staging_import_tapmango_batch."""

from __future__ import annotations

import csv
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CSV_CANDIDATES = [
    ROOT / "data/tapmango/tapmango_customer_list_report.csv",
    Path.home() / "Downloads/tapmango_customer_list_report.csv",
]
ENV_FILE = ROOT / "apps/admin/.env.local"
BATCH_SIZE = 150

PHONE_RE = re.compile(r"\D")


def load_env() -> dict[str, str]:
    out: dict[str, str] = {}
    for line in ENV_FILE.read_text().splitlines():
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        out[k.strip()] = v.strip().strip('"').strip("'")
    return out


def parse_dt(raw: str | None) -> str | None:
    s = (raw or "").strip()
    if not s:
        return None
    for fmt in ("%m/%d/%y %H:%M", "%m/%d/%Y %H:%M", "%m/%d/%y", "%Y-%m-%d %H:%M:%S", "%Y-%m-%d"):
        try:
            return datetime.strptime(s, fmt).isoformat()
        except ValueError:
            continue
    return None


def parse_bool(raw: str | None) -> bool:
    return (raw or "").strip() in {"1", "true", "True", "yes", "Yes"}


def parse_int(raw: str | None) -> int:
    s = (raw or "").strip()
    if not s:
        return 0
    try:
        return int(float(s))
    except ValueError:
        return 0


def normalize_phone(raw: str | None) -> tuple[str | None, str | None]:
    digits = PHONE_RE.sub("", raw or "")
    if len(digits) == 11 and digits.startswith("1"):
        digits = digits[1:]
    if len(digits) == 10 and digits != "0000000000":
        return f"+1{digits}", None
    if not digits:
        return None, "empty_phone"
    return None, f"malformed_phone:{len(digits)}"


def find_csv() -> Path:
    for p in CSV_CANDIDATES:
        if p.exists():
            return p
    raise SystemExit("CSV not found. Put tapmango_customer_list_report.csv in data/tapmango/ or ~/Downloads/")


def post_rpc(url: str, key: str, payload: list[dict], retries: int = 5) -> dict:
    body = json.dumps({"p_rows": payload}).encode()
    req = urllib.request.Request(
        f"{url}/rest/v1/rpc/staging_import_tapmango_batch",
        data=body,
        method="POST",
        headers={
            "apikey": key,
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
            "Prefer": "return=representation",
        },
    )
    last_err: Exception | None = None
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                raw = resp.read().decode()
                return json.loads(raw) if raw else {}
        except urllib.error.HTTPError as e:
            last_err = e
            detail = e.read().decode()[:500]
            if e.code in {429, 500, 502, 503, 504, 520, 546} or e.code >= 500:
                time.sleep(min(2**attempt, 20))
                continue
            raise SystemExit(f"HTTP {e.code}: {detail}") from e
        except (urllib.error.URLError, TimeoutError) as e:
            last_err = e
            time.sleep(min(2**attempt, 20))
    raise SystemExit(f"RPC failed after retries: {last_err}")


def main() -> None:
    env = load_env()
    url = env["NEXT_PUBLIC_SUPABASE_URL"].rstrip("/")
    key = env["NEXT_PUBLIC_SUPABASE_ANON_KEY"]
    csv_path = find_csv()
    dest = ROOT / "data/tapmango/tapmango_customer_list_report.csv"
    if csv_path.resolve() != dest.resolve():
        dest.write_bytes(csv_path.read_bytes())
        csv_path = dest

    batch: list[dict] = []
    quarantine: list[dict] = []
    seen = 0
    imported = 0
    ledger = 0

    with csv_path.open(newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            seen += 1
            tid = (row.get("CustomerId") or "").strip()
            phone, reason = normalize_phone(row.get("Phone"))
            if not phone:
                quarantine.append(
                    {
                        "legacy_tapmango_id": tid,
                        "raw_phone": (row.get("Phone") or "").strip(),
                        "name": (row.get("Name") or "").strip(),
                        "points": parse_int(row.get("Points")),
                        "location": (row.get("Location") or "").strip(),
                        "reason": reason or "invalid_phone",
                    }
                )
                continue
            batch.append(
                {
                    "tid": tid,
                    "phone": phone,
                    "name": (row.get("Name") or "").strip(),
                    "email": (row.get("Email") or "").strip(),
                    "points": parse_int(row.get("Points")),
                    "life": parse_int(row.get("Lifetime Points")),
                    "store": (row.get("Location") or "").strip(),
                    "sms": parse_bool(row.get("Subscribed To SMS")),
                    "sms_out": parse_dt(row.get("SMS Opt Out Date")),
                    "em": parse_bool(row.get("Subscribed To Emails")),
                    "em_out": parse_dt(row.get("Email Opt Out Date")),
                    "reg": parse_dt(row.get("Registration Date/Time")),
                    "seen": parse_dt(row.get("Last Checkin Date/Time")),
                }
            )
            if len(batch) >= BATCH_SIZE:
                result = post_rpc(url, key, batch)
                imported += int(result.get("customers") or 0)
                ledger += int(result.get("ledger") or 0)
                print(f"imported {imported}/{seen}  ledger {ledger}  quarantine {len(quarantine)}", flush=True)
                batch = []

    if batch:
        result = post_rpc(url, key, batch)
        imported += int(result.get("customers") or 0)
        ledger += int(result.get("ledger") or 0)

    qpath = ROOT / "data/tapmango/quarantine.json"
    qpath.write_text(json.dumps(quarantine, indent=2))
    print(
        json.dumps(
            {
                "csv_rows": seen,
                "imported": imported,
                "ledger_inserted": ledger,
                "quarantine": len(quarantine),
                "quarantine_file": str(qpath),
            },
            indent=2,
        )
    )


if __name__ == "__main__":
    os.chdir(ROOT)
    main()
