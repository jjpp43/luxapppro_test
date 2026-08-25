#!/usr/bin/env python3
"""Reset and run QA Lab counter scenarios. Never calls Lightspeed or TapMango.

Usage:
  python3 scripts/qa_lab.py
  python3 scripts/qa_lab.py --reset-only
"""

from __future__ import annotations

import argparse
import json
import os
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
ENV_CANDIDATES = [
    ROOT / "apps" / "admin" / ".env.local",
    ROOT / ".env.local",
    ROOT / "apps" / "worker" / ".env",
]


def load_env() -> dict[str, str]:
    env = dict(os.environ)
    for path in ENV_CANDIDATES:
        if not path.exists():
            continue
        for line in path.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            env.setdefault(key.strip(), value.strip().strip('"').strip("'"))
    return env


def supabase_headers(key: str, extra: dict[str, str] | None = None) -> dict[str, str]:
    headers = {"apikey": key, "Accept": "application/json", **(extra or {})}
    if not key.startswith("sb_secret_"):
        headers["Authorization"] = f"Bearer {key}"
    return headers


def http_json(
    url: str,
    headers: dict[str, str],
    body: bytes | None = None,
    method: str | None = None,
) -> Any:
    verb = method or ("POST" if body else "GET")
    req = urllib.request.Request(url, data=body, method=verb, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=180) as resp:
            raw = resp.read()
            return json.loads(raw.decode()) if raw else None
    except urllib.error.HTTPError as exc:
        err = exc.read().decode(errors="replace")[:800]
        raise SystemExit(f"HTTP {exc.code} for {url}\n{err}") from exc


def rpc(url: str, key: str, name: str, payload: dict[str, Any] | None = None) -> Any:
    return http_json(
        f"{url}/rest/v1/rpc/{name}",
        supabase_headers(key, {"Content-Type": "application/json"}),
        json.dumps(payload or {}).encode(),
    )


def get_rows(url: str, key: str, table: str, query: str) -> list[dict[str, Any]]:
    rows = http_json(f"{url}/rest/v1/{table}?{query}", supabase_headers(key))
    return rows or []


def balance(url: str, key: str, customer_id: str) -> int:
    rows = get_rows(
        url,
        key,
        "customer_balance",
        urllib.parse.urlencode({"customer_id": f"eq.{customer_id}", "select": "balance"}),
    )
    if not rows:
        return 0
    return int(rows[0].get("balance") or 0)


def check(ok: bool, label: str) -> bool:
    print(("PASS" if ok else "FAIL") + f"  {label}")
    return ok


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--reset-only", action="store_true")
    args = parser.parse_args()

    env = load_env()
    supabase_url = (env.get("NEXT_PUBLIC_SUPABASE_URL") or env.get("SUPABASE_URL") or "").rstrip("/")
    supabase_key = env.get("SUPABASE_SECRET_KEY") or env.get("SUPABASE_SERVICE_ROLE_KEY")
    if not supabase_url or not supabase_key:
        raise SystemExit("Missing Supabase URL or SUPABASE_SECRET_KEY")

    if args.reset_only:
        result = rpc(supabase_url, supabase_key, "qa_lab_reset")
        print(json.dumps(result, indent=2))
        return

    seed = rpc(supabase_url, supabase_key, "qa_lab_seed")
    maya = seed["maya_id"]
    luis = seed["luis_id"]
    priya = seed["priya_id"]
    priya_sale = seed["priya_sale"]
    walkin_sale = seed["walkin_sale"]
    store_id = seed["store_id"]

    print("QA Lab seeded. Fake phones only (+1555100…). Lightspeed was not called.")
    print(f"  Maya  +15551001001  {maya}")
    print(f"  Luis  +15551001002  {luis}")
    print(f"  Priya +15551001003  {priya}")

    failed = 0
    if not check(balance(supabase_url, supabase_key, maya) == 500, "Maya starts at 500 pts"):
        failed += 1
    if not check(balance(supabase_url, supabase_key, luis) == 200, "Luis starts at 200 pts (cannot afford $10)"):
        failed += 1
    if not check(balance(supabase_url, supabase_key, priya) == 0, "Priya starts at 0 pts"):
        failed += 1

    walkin = rpc(
        supabase_url,
        supabase_key,
        "process_sale_loyalty",
        {"p_lightspeed_sale_id": walkin_sale},
    )
    if not check(walkin.get("reason") == "unidentified_ignored", "WALKIN ticket does not earn"):
        failed += 1
        print(f"       got {walkin}")

    earned = rpc(
        supabase_url,
        supabase_key,
        "process_sale_loyalty",
        {"p_lightspeed_sale_id": priya_sale},
    )
    if not check(
        earned.get("reason") == "applied" and earned.get("net") == 47,
        "Identified $47.80 closed sale earns 47 pts",
    ):
        failed += 1
        print(f"       got {earned}")
    if not check(balance(supabase_url, supabase_key, priya) == 47, "Priya balance is 47 after earn"):
        failed += 1

    again = rpc(
        supabase_url,
        supabase_key,
        "process_sale_loyalty",
        {"p_lightspeed_sale_id": priya_sale},
    )
    if not check(again.get("reason") == "in_sync" and again.get("net") == 47, "Same sale is idempotent"):
        failed += 1
        print(f"       got {again}")

    http_json(
        f"{supabase_url}/rest/v1/sales?lightspeed_sale_id=eq.{urllib.parse.quote(priya_sale)}",
        supabase_headers(supabase_key, {"Content-Type": "application/json", "Prefer": "return=minimal"}),
        json.dumps({"state": "voided"}).encode(),
        method="PATCH",
    )
    clawed = rpc(
        supabase_url,
        supabase_key,
        "process_sale_loyalty",
        {"p_lightspeed_sale_id": priya_sale},
    )
    if not check(
        clawed.get("reason") == "applied" and clawed.get("net") == 0,
        "Void claws back earn, balance not below zero",
    ):
        failed += 1
        print(f"       got {clawed}")
    if not check(balance(supabase_url, supabase_key, priya) == 0, "Priya is back at 0 after void"):
        failed += 1

    enrolled = rpc(
        supabase_url,
        supabase_key,
        "enrol_customer",
        {
            "p_phone": "+15551001004",
            "p_store_id": store_id,
            "p_name": "QA New Walkup",
        },
    )
    if not check(isinstance(enrolled, str) and len(enrolled) > 0, "Enrol a new fake phone at the counter"):
        failed += 1
        print(f"       got {enrolled}")

    try:
        rpc(supabase_url, supabase_key, "redeem", {})
        print("SKIP  Redeem RPC exists but needs a real call — wire the staff flow next")
    except SystemExit as exc:
        if "redeem" in str(exc).lower() or "404" in str(exc) or "PGRST202" in str(exc):
            print("SKIP  Redeem RPC not built yet — Maya/Luis are ready for it")
        else:
            raise

    print()
    if failed:
        raise SystemExit(f"{failed} QA Lab check(s) failed")
    print("QA Lab scenarios passed. Open admin, filter POS/ledger to QA Lab to click through.")


if __name__ == "__main__":
    main()
