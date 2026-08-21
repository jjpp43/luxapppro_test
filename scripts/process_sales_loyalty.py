#!/usr/bin/env python3
"""Call process_sale_loyalty for identified sales. Earn still requires the store flag.

Usage:
  python3 scripts/process_sales_loyalty.py --dry-run
  python3 scripts/process_sales_loyalty.py --enable-earn
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
    headers = {"apikey": key, **(extra or {})}
    if not key.startswith("sb_secret_"):
        headers["Authorization"] = f"Bearer {key}"
    return headers


def http_json(url: str, headers: dict[str, str], body: bytes | None = None) -> Any:
    req = urllib.request.Request(url, data=body, method="POST" if body else "GET", headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=180) as resp:
            raw = resp.read()
            return json.loads(raw.decode()) if raw else None
    except urllib.error.HTTPError as exc:
        err = exc.read().decode(errors="replace")[:500]
        raise SystemExit(f"HTTP {exc.code} for {url}\n{err}") from exc


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument(
        "--enable-earn",
        action="store_true",
        help="Required to call process_sale_loyalty. Store flags still default off.",
    )
    parser.add_argument("--page-size", type=int, default=200)
    args = parser.parse_args()

    env = load_env()
    if env.get("LOYALTY_EARN_GLOBAL", "false").lower() not in {"1", "true", "yes"}:
        # Belt: scripts still require --enable-earn. Global env does not turn earn on.
        pass

    supabase_url = (env.get("NEXT_PUBLIC_SUPABASE_URL") or env.get("SUPABASE_URL") or "").rstrip("/")
    supabase_key = env.get("SUPABASE_SECRET_KEY") or env.get("SUPABASE_SERVICE_ROLE_KEY")
    if not supabase_url or not supabase_key:
        raise SystemExit("Missing Supabase URL or SUPABASE_SECRET_KEY/SUPABASE_SERVICE_ROLE_KEY")

    if not args.enable_earn and not args.dry_run:
        raise SystemExit("Refusing to run without --enable-earn (or --dry-run). Store flags remain off.")

    offset = 0
    total = 0
    while True:
        qs = urllib.parse.urlencode(
            {
                "select": "lightspeed_sale_id",
                "customer_id": "not.is.null",
                "order": "occurred_at.asc",
                "offset": offset,
                "limit": args.page_size,
            }
        )
        rows = (
            http_json(
                f"{supabase_url}/rest/v1/sales?{qs}",
                supabase_headers(supabase_key, {"Accept": "application/json"}),
            )
            or []
        )
        ids = [r["lightspeed_sale_id"] for r in rows if r.get("lightspeed_sale_id")]
        total += len(ids)
        print(f"page offset={offset} identified_sales={len(ids)}")

        if args.dry_run:
            if not rows:
                break
            offset += len(rows)
            continue

        if ids:
            http_json(
                f"{supabase_url}/rest/v1/rpc/process_sales_loyalty",
                supabase_headers(supabase_key, {"Content-Type": "application/json"}),
                json.dumps({"p_lightspeed_sale_ids": ids}).encode(),
            )

        if len(rows) < args.page_size:
            break
        offset += len(rows)

    print(f"summary: identified_sales={total} dry_run={args.dry_run}")


if __name__ == "__main__":
    main()
