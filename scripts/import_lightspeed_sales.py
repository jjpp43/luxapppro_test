#!/usr/bin/env python3
"""Read-only Lightspeed X-Series sales → Supabase `sales` upsert.

Loads env from apps/admin/.env.local (or process env):
  LIGHTSPEED_DOMAIN
  LIGHTSPEED_PERSONAL_TOKEN
  NEXT_PUBLIC_SUPABASE_URL
  NEXT_PUBLIC_SUPABASE_ANON_KEY  (or SUPABASE_SERVICE_ROLE_KEY)

Usage:
  python3 scripts/import_lightspeed_sales.py --max-pages 50
  python3 scripts/import_lightspeed_sales.py --max-pages 5 --dry-run
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

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
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            env.setdefault(key, value)
    return env


def lightspeed_base(domain: str) -> str:
    if domain.startswith("http"):
        host = urlparse(domain).hostname
        if not host:
            raise SystemExit(f"Invalid LIGHTSPEED_DOMAIN: {domain}")
        return f"https://{host}"
    return f"https://{domain}.retail.lightspeed.app"


def http_json(url: str, headers: dict[str, str]) -> Any:
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as exc:
        body = exc.read().decode(errors="replace")[:500]
        raise SystemExit(f"HTTP {exc.code} for {url}\n{body}") from exc


def to_cents(amount: Any) -> int:
    if amount is None:
        return 0
    return int(round(float(amount) * 100))


def map_sale(
    sale: dict[str, Any],
    outlet_to_store: dict[str, str] | None = None,
) -> dict[str, Any] | None:
    sale_id = sale.get("id")
    if not sale_id:
        return None

    totals = sale.get("totals") or {}
    # Prefer tax-inclusive for "spend"; fall back to exclusive.
    total = totals.get("price_incl_tax")
    if total is None:
        total = totals.get("price")
    total_cents = to_cents(total)
    # Until earn rules exist, eligible = total (closed sales only later filtered)
    eligible_cents = total_cents

    occurred = sale.get("date") or sale.get("created_at")
    if not occurred:
        return None

    source = sale.get("source") or {}
    outlet_id = source.get("outlet_id") or sale.get("outlet_id")
    store_id = None
    if outlet_id and outlet_to_store:
        store_id = outlet_to_store.get(outlet_id)

    row: dict[str, Any] = {
        "lightspeed_sale_id": sale_id,
        "lightspeed_outlet_id": outlet_id,
        "lightspeed_customer_id": sale.get("customer_id"),
        "state": sale.get("state"),
        "total_cents": total_cents,
        "eligible_cents": eligible_cents,
        "occurred_at": occurred,
        "raw": sale,
        "updated_at": "now()",
    }
    if store_id:
        row["store_id"] = store_id
    return row


def supabase_upsert(
    supabase_url: str,
    supabase_key: str,
    rows: list[dict[str, Any]],
    dry_run: bool,
) -> None:
    if not rows:
        return
    if dry_run:
        print(f"dry-run: would upsert {len(rows)} sales")
        return

    # Strip sentinel updated_at; let DB default / trigger handle if present
    payload = []
    for row in rows:
        item = dict(row)
        item.pop("updated_at", None)
        payload.append(item)

    url = (
        f"{supabase_url.rstrip('/')}/rest/v1/sales"
        "?on_conflict=lightspeed_sale_id"
    )
    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        url,
        data=data,
        method="POST",
        headers={
            "apikey": supabase_key,
            "Authorization": f"Bearer {supabase_key}",
            "Content-Type": "application/json",
            "Prefer": "resolution=merge-duplicates,return=minimal",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            resp.read()
            print(f"upserted {len(rows)} (HTTP {resp.status})")
    except urllib.error.HTTPError as exc:
        body = exc.read().decode(errors="replace")[:800]
        raise SystemExit(f"Supabase upsert failed HTTP {exc.code}\n{body}") from exc


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--max-pages", type=int, default=50)
    parser.add_argument("--page-size", type=int, default=200)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument(
        "--states",
        default="closed",
        help="Comma-separated sale states to keep (default: closed)",
    )
    args = parser.parse_args()
    keep_states = {s.strip() for s in args.states.split(",") if s.strip()}

    env = load_env()
    domain = env.get("LIGHTSPEED_DOMAIN")
    token = env.get("LIGHTSPEED_PERSONAL_TOKEN")
    supabase_url = env.get("NEXT_PUBLIC_SUPABASE_URL") or env.get("SUPABASE_URL")
    supabase_key = (
        env.get("SUPABASE_SERVICE_ROLE_KEY")
        or env.get("NEXT_PUBLIC_SUPABASE_ANON_KEY")
        or env.get("SUPABASE_ANON_KEY")
    )

    if not domain or not token:
        raise SystemExit("Missing LIGHTSPEED_DOMAIN or LIGHTSPEED_PERSONAL_TOKEN")
    if not supabase_url or not supabase_key:
        raise SystemExit("Missing Supabase URL or key")

    base = lightspeed_base(domain)
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json",
        "User-Agent": "lux-pro-ingest/0.1",
    }

    outlets = http_json(f"{base}/api/2026-04/outlets", headers).get("data") or []
    print(f"Lightspeed outlets: {len(outlets)}")
    for outlet in outlets:
        print(f"  - {outlet.get('id')}  {outlet.get('name')}")

    # Map LS outlet → Lux store when stores.lightspeed_outlet_id is set
    outlet_to_store: dict[str, str] = {}
    stores = (
        http_json(
            f"{supabase_url.rstrip('/')}/rest/v1/stores"
            "?select=id,name,lightspeed_outlet_id&lightspeed_outlet_id=not.is.null",
            {
                "apikey": supabase_key,
                "Authorization": f"Bearer {supabase_key}",
                "Accept": "application/json",
            },
        )
        or []
    )
    for store in stores:
        oid = store.get("lightspeed_outlet_id")
        if oid:
            outlet_to_store[oid] = store["id"]
            print(f"  store map: {oid} → {store.get('name')}")

    after: int | None = None
    total_seen = 0
    total_kept = 0
    for page in range(1, args.max_pages + 1):
        path = f"/api/2026-04/sales?page_size={args.page_size}"
        if after is not None:
            path += f"&after={after}"
        payload = http_json(f"{base}{path}", headers)
        sales = payload.get("data") or []
        version = payload.get("version") or {}
        vmax = version.get("max")
        total_seen += len(sales)

        mapped: list[dict[str, Any]] = []
        for sale in sales:
            if keep_states and sale.get("state") not in keep_states:
                continue
            row = map_sale(sale, outlet_to_store)
            if row:
                mapped.append(row)

        total_kept += len(mapped)
        print(
            f"page {page}: fetched={len(sales)} kept={len(mapped)} "
            f"version.max={vmax}"
        )
        supabase_upsert(supabase_url, supabase_key, mapped, args.dry_run)

        if not sales or vmax is None:
            print("done: no more pages")
            break
        after = vmax
    else:
        print(f"stopped at --max-pages {args.max_pages}")

    print(f"summary: seen={total_seen} kept={total_kept}")


if __name__ == "__main__":
    main()
