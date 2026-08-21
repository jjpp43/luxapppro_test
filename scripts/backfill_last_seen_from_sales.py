#!/usr/bin/env python3
"""Advance customers.last_seen_at from matched closed sales. Does not award points.

Usage:
  python3 scripts/backfill_last_seen_from_sales.py --dry-run
  python3 scripts/backfill_last_seen_from_sales.py
"""

from __future__ import annotations

import argparse
import json
import os
import urllib.error
import urllib.request
from pathlib import Path

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


def supabase_headers(key: str) -> dict[str, str]:
    headers = {"apikey": key, "Content-Type": "application/json"}
    if not key.startswith("sb_secret_"):
        headers["Authorization"] = f"Bearer {key}"
    return headers


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    env = load_env()
    supabase_url = (env.get("NEXT_PUBLIC_SUPABASE_URL") or env.get("SUPABASE_URL") or "").rstrip("/")
    supabase_key = env.get("SUPABASE_SECRET_KEY") or env.get("SUPABASE_SERVICE_ROLE_KEY")
    if not supabase_url or not supabase_key:
        raise SystemExit("Missing Supabase URL or SUPABASE_SECRET_KEY/SUPABASE_SERVICE_ROLE_KEY")

    if args.dry_run:
        req = urllib.request.Request(
            f"{supabase_url}/rest/v1/sales?select=customer_id&customer_id=not.is.null&state=eq.closed",
            headers=supabase_headers(supabase_key) | {"Prefer": "count=exact", "Range": "0-0"},
            method="HEAD",
        )
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                count = resp.headers.get("content-range", "?")
        except urllib.error.HTTPError as exc:
            raise SystemExit(f"count failed HTTP {exc.code}") from exc
        print(f"dry-run: would backfill last_seen_at from identified closed sales ({count})")
        return

    body = json.dumps({}).encode()
    req = urllib.request.Request(
        f"{supabase_url}/rest/v1/rpc/backfill_last_seen_from_sales",
        data=body,
        method="POST",
        headers=supabase_headers(supabase_key),
    )
    try:
        with urllib.request.urlopen(req, timeout=180) as resp:
            raw = resp.read().decode()
    except urllib.error.HTTPError as exc:
        err = exc.read().decode(errors="replace")[:500]
        raise SystemExit(f"backfill RPC failed HTTP {exc.code}\n{err}") from exc

    print(f"updated customers: {raw or 0}")


if __name__ == "__main__":
    main()
