#!/usr/bin/env python3
"""Read-only Lightspeed X-Series sales → Supabase `sales` upsert.

Loads env from apps/admin/.env.local (or process env):
  LIGHTSPEED_DOMAIN
  LIGHTSPEED_PERSONAL_TOKEN
  NEXT_PUBLIC_SUPABASE_URL
  NEXT_PUBLIC_SUPABASE_ANON_KEY  (or SUPABASE_SERVICE_ROLE_KEY)

Usage:
  # Version cursor (oldest → newest), stop after N pages
  python3 scripts/import_lightspeed_sales.py --max-pages 50

  # Calendar window ending yesterday (covers 30d + 90d dashboards)
  python3 scripts/import_lightspeed_sales.py --days-before-yesterday 90

  python3 scripts/import_lightspeed_sales.py --date-from 2026-05-18 --date-to 2026-08-16
  python3 scripts/import_lightspeed_sales.py --days-before-yesterday 90 --dry-run
"""

from __future__ import annotations

import argparse
import json
import os
import urllib.error
import urllib.parse
import urllib.request
from datetime import date, datetime, timedelta, timezone
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
        with urllib.request.urlopen(req, timeout=120) as resp:
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
    # List API uses nested totals; search API flattens price fields.
    total = totals.get("price_incl_tax")
    if total is None:
        total = sale.get("total_price_incl")
    if total is None:
        total = totals.get("price")
    if total is None:
        total = sale.get("total_price")
    total_cents = to_cents(total)
    eligible_cents = total_cents

    occurred = (
        sale.get("sale_date")
        or sale.get("date")
        or sale.get("created_at")
    )
    if not occurred:
        return None

    source = sale.get("source")
    outlet_id = sale.get("outlet_id")
    if isinstance(source, dict):
        outlet_id = source.get("outlet_id") or outlet_id
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
    }
    if store_id:
        row["store_id"] = store_id
    return row


def supabase_upsert(
    supabase_url: str,
    supabase_key: str,
    rows: list[dict[str, Any]],
    dry_run: bool,
    chunk_size: int = 100,
) -> None:
    if not rows:
        return
    if dry_run:
        print(f"dry-run: would upsert {len(rows)} sales")
        return

    url = (
        f"{supabase_url.rstrip('/')}/rest/v1/sales"
        "?on_conflict=lightspeed_sale_id"
    )
    for i in range(0, len(rows), chunk_size):
        chunk = rows[i : i + chunk_size]
        # Keep raw slim enough for staging upserts (line_items blow up timeouts).
        payload = []
        for row in chunk:
            item = dict(row)
            raw = item.get("raw")
            if isinstance(raw, dict):
                item["raw"] = {
                    k: raw.get(k)
                    for k in (
                        "id",
                        "state",
                        "sale_date",
                        "created_at",
                        "updated_at",
                        "outlet_id",
                        "customer_id",
                        "register_id",
                        "receipt_number",
                        "invoice_number",
                        "total_price",
                        "total_price_incl",
                        "total_tax",
                        "note",
                    )
                    if k in raw
                }
            payload.append(item)

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
            with urllib.request.urlopen(req, timeout=180) as resp:
                resp.read()
                print(f"  upserted {len(chunk)} (HTTP {resp.status})")
        except urllib.error.HTTPError as exc:
            body = exc.read().decode(errors="replace")[:800]
            raise SystemExit(f"Supabase upsert failed HTTP {exc.code}\n{body}") from exc


def parse_ymd(value: str) -> date:
    return date.fromisoformat(value)


def resolve_date_window(args: argparse.Namespace) -> tuple[str, str] | None:
    """Return (date_from_iso_z, date_to_exclusive_iso_z) or None for version mode."""
    if args.days_before_yesterday is not None:
        yesterday = date.today() - timedelta(days=1)
        start = yesterday - timedelta(days=args.days_before_yesterday)
        end_exclusive = yesterday + timedelta(days=1)
        return (
            f"{start.isoformat()}T00:00:00Z",
            f"{end_exclusive.isoformat()}T00:00:00Z",
        )

    if args.date_from or args.date_to:
        if not args.date_from or not args.date_to:
            raise SystemExit("Provide both --date-from and --date-to (YYYY-MM-DD)")
        start = parse_ymd(args.date_from)
        end = parse_ymd(args.date_to)
        # Inclusive end date → exclusive next-day bound for the API
        end_exclusive = end + timedelta(days=1)
        return (
            f"{start.isoformat()}T00:00:00Z",
            f"{end_exclusive.isoformat()}T00:00:00Z",
        )

    return None


def load_outlet_map(supabase_url: str, supabase_key: str) -> dict[str, str]:
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
    outlet_to_store: dict[str, str] = {}
    for store in stores:
        oid = store.get("lightspeed_outlet_id")
        if oid:
            outlet_to_store[oid] = store["id"]
            print(f"  store map: {oid} → {store.get('name')}")
    return outlet_to_store


def import_by_search(
    *,
    base: str,
    headers: dict[str, str],
    supabase_url: str,
    supabase_key: str,
    date_from: str,
    date_to: str,
    keep_states: set[str],
    outlet_to_store: dict[str, str],
    page_size: int,
    dry_run: bool,
) -> None:
    print(f"search window: {date_from} → {date_to} (end exclusive)")
    offset = 0
    total_seen = 0
    total_kept = 0
    page = 0
    while True:
        page += 1
        qs = urllib.parse.urlencode(
            {
                "type": "sales",
                "date_from": date_from,
                "date_to": date_to,
                "page_size": page_size,
                "offset": offset,
                **({"status": ",".join(sorted(keep_states))} if keep_states else {}),
            }
        )
        payload = http_json(f"{base}/api/2026-04/search?{qs}", headers)
        sales = payload.get("data") or []
        total_count = payload.get("total_count")
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
            f"page {page}: offset={offset} fetched={len(sales)} kept={len(mapped)} "
            f"total_count={total_count}"
        )
        supabase_upsert(supabase_url, supabase_key, mapped, dry_run)

        if not sales:
            break
        offset += len(sales)
        page_info = payload.get("page_info") or {}
        if total_count is not None and offset >= int(total_count):
            break
        if page_info.get("has_next_page") is False:
            break

    print(f"summary: seen={total_seen} kept={total_kept}")


def import_by_version(
    *,
    base: str,
    headers: dict[str, str],
    supabase_url: str,
    supabase_key: str,
    keep_states: set[str],
    outlet_to_store: dict[str, str],
    page_size: int,
    max_pages: int,
    dry_run: bool,
) -> None:
    after: int | None = None
    total_seen = 0
    total_kept = 0
    for page in range(1, max_pages + 1):
        path = f"/api/2026-04/sales?page_size={page_size}"
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
        supabase_upsert(supabase_url, supabase_key, mapped, dry_run)

        if not sales or vmax is None:
            print("done: no more pages")
            break
        after = vmax
    else:
        print(f"stopped at --max-pages {max_pages}")

    print(f"summary: seen={total_seen} kept={total_kept}")


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
    parser.add_argument(
        "--days-before-yesterday",
        type=int,
        default=None,
        help="Import closed sales from (yesterday - N) through yesterday inclusive",
    )
    parser.add_argument("--date-from", help="Inclusive start YYYY-MM-DD (UTC midnight)")
    parser.add_argument("--date-to", help="Inclusive end YYYY-MM-DD")
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

    outlet_to_store = load_outlet_map(supabase_url, supabase_key)
    window = resolve_date_window(args)

    if window:
        date_from, date_to = window
        # Search allows larger pages; default bump when using calendar mode
        page_size = args.page_size if args.page_size != 200 else 1000
        import_by_search(
            base=base,
            headers=headers,
            supabase_url=supabase_url,
            supabase_key=supabase_key,
            date_from=date_from,
            date_to=date_to,
            keep_states=keep_states,
            outlet_to_store=outlet_to_store,
            page_size=min(page_size, 1000),
            dry_run=args.dry_run,
        )
    else:
        import_by_version(
            base=base,
            headers=headers,
            supabase_url=supabase_url,
            supabase_key=supabase_key,
            keep_states=keep_states,
            outlet_to_store=outlet_to_store,
            page_size=args.page_size,
            max_pages=args.max_pages,
            dry_run=args.dry_run,
        )


if __name__ == "__main__":
    main()
