#!/usr/bin/env python3
"""Match Lightspeed customers → Lux `customers` by phone; backfill `sales.customer_id`.

Phase 1 (default): only distinct `lightspeed_customer_id` values already on `sales`.

Rules:
  - Skip WALKIN and customers with no usable phone/mobile
  - Normalize to E.164 (+1 for 10-digit US)
  - Prefer mobile, then phone; if both normalize to different numbers, try each
    and require exactly one Lux hit across candidates
  - Set customers.lightspeed_customer_id and sales.customer_id
  - Does not create customers or write points

Env (apps/admin/.env.local):
  LIGHTSPEED_DOMAIN, LIGHTSPEED_PERSONAL_TOKEN
  NEXT_PUBLIC_SUPABASE_URL
  SUPABASE_SECRET_KEY (or legacy SUPABASE_SERVICE_ROLE_KEY)

Usage:
  python3 scripts/match_lightspeed_customers.py --dry-run
  python3 scripts/match_lightspeed_customers.py
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from collections import Counter
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
ENV_CANDIDATES = [
    ROOT / "apps" / "admin" / ".env.local",
    ROOT / ".env.local",
]

# Default WALKIN on luxbeauty4 (Decatur). Override with --walkin-id if needed.
DEFAULT_WALKIN_ID = "06f24f8b-21fd-11ef-f4ca-f3afc6463c48"


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
    headers = {"apikey": key}
    if not key.startswith("sb_secret_"):
        headers["Authorization"] = f"Bearer {key}"
    return headers


def lightspeed_base(domain: str) -> str:
    if domain.startswith("http"):
        host = urlparse(domain).hostname
        if not host:
            raise SystemExit(f"Invalid LIGHTSPEED_DOMAIN: {domain}")
        return f"https://{host}"
    return f"https://{domain}.retail.lightspeed.app"


def http_json(
    url: str,
    headers: dict[str, str],
    method: str = "GET",
    body: bytes | None = None,
    timeout: int = 60,
    retries: int = 4,
) -> Any:
    last_error: Exception | None = None
    for attempt in range(retries):
        req = urllib.request.Request(url, data=body, method=method, headers=headers)
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                raw = resp.read()
                if not raw:
                    return None
                return json.loads(raw.decode())
        except urllib.error.HTTPError as exc:
            err = exc.read().decode(errors="replace")[:500]
            raise SystemExit(f"HTTP {exc.code} for {url}\n{err}") from exc
        except (TimeoutError, urllib.error.URLError, ConnectionResetError) as exc:
            last_error = exc
            wait = min(30, 2 ** attempt)
            print(f"retry {attempt + 1}/{retries} after {wait}s: {exc}")
            time.sleep(wait)
    raise SystemExit(f"Gave up on {url}: {last_error}") from last_error


def to_e164(raw: str | None) -> str | None:
    if not raw:
        return None
    digits = re.sub(r"\D", "", raw)
    if len(digits) == 10:
        return f"+1{digits}"
    if len(digits) == 11 and digits.startswith("1"):
        return f"+{digits}"
    if raw.startswith("+") and len(digits) >= 10:
        return f"+{digits}"
    return None


def candidate_phones(ls_customer: dict[str, Any]) -> list[str]:
    """mobile first, then phone; unique E.164 values preserving order."""
    out: list[str] = []
    for key in ("mobile", "phone"):
        e164 = to_e164(ls_customer.get(key))
        if e164 and e164 not in out:
            out.append(e164)
    return out


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--walkin-id", default=DEFAULT_WALKIN_ID)
    parser.add_argument(
        "--limit",
        type=int,
        default=0,
        help="Max distinct LS customer ids to process (0 = all)",
    )
    args = parser.parse_args()

    env = load_env()
    domain = env.get("LIGHTSPEED_DOMAIN")
    token = env.get("LIGHTSPEED_PERSONAL_TOKEN")
    supabase_url = (env.get("NEXT_PUBLIC_SUPABASE_URL") or env.get("SUPABASE_URL") or "").rstrip("/")
    supabase_key = (
        env.get("SUPABASE_SECRET_KEY")
        or env.get("SUPABASE_SERVICE_ROLE_KEY")
    )
    if not domain or not token:
        raise SystemExit("Missing LIGHTSPEED_DOMAIN or LIGHTSPEED_PERSONAL_TOKEN")
    if not supabase_url or not supabase_key:
        raise SystemExit(
            "Missing Supabase URL or SUPABASE_SECRET_KEY/SUPABASE_SERVICE_ROLE_KEY"
        )

    ls_headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json",
        "User-Agent": "lux-pro-match/0.1",
    }
    sb_headers = {
        **supabase_headers(supabase_key),
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
    }
    base = lightspeed_base(domain)

    # Distinct LS customer ids on sales that are not yet matched
    ls_ids: list[str] = []
    seen: set[str] = set()
    offset = 0
    while True:
        path = (
            f"/rest/v1/sales?select=lightspeed_customer_id"
            f"&lightspeed_customer_id=not.is.null"
            f"&customer_id=is.null"
            f"&offset={offset}&limit=1000"
        )
        rows = http_json(f"{supabase_url}{path}", sb_headers) or []
        for row in rows:
            cid = row.get("lightspeed_customer_id")
            if cid and cid not in seen:
                seen.add(cid)
                ls_ids.append(cid)
        if len(rows) < 1000:
            break
        offset += 1000

    walkin = args.walkin_id
    ls_ids = [c for c in ls_ids if c != walkin]
    if args.limit:
        ls_ids = ls_ids[: args.limit]

    print(f"distinct unmatched non-WALKIN LS customers: {len(ls_ids)}")
    print(f"walkin skipped id: {walkin}")

    def apply_link(ls_id: str, lux_id: str) -> None:
        patch = json.dumps({"lightspeed_customer_id": ls_id}).encode()
        try:
            http_json(
                f"{supabase_url}/rest/v1/customers?id=eq.{lux_id}&lightspeed_customer_id=is.null",
                sb_headers,
                method="PATCH",
                body=patch,
                timeout=60,
            )
        except SystemExit as exc:
            print(f"customer patch failed lux={lux_id} ls={ls_id}: {exc}")
            stats["apply_customer_fail"] += 1
            return

        sales_url = (
            f"{supabase_url}/rest/v1/sales?lightspeed_customer_id=eq.{ls_id}&customer_id=is.null"
        )
        patch_sales = json.dumps({"customer_id": lux_id}).encode()
        try:
            http_json(
                sales_url,
                sb_headers,
                method="PATCH",
                body=patch_sales,
                timeout=180,
            )
            stats["sales_groups_patched"] += 1
        except SystemExit as exc:
            print(f"sales patch failed ls={ls_id}: {exc}")
            stats["apply_sales_fail"] += 1

    stats: Counter[str] = Counter()

    for i, ls_id in enumerate(ls_ids, 1):
        payload = http_json(f"{base}/api/2026-04/customers/{ls_id}", ls_headers)
        cust = (payload or {}).get("data") or payload or {}
        phones = candidate_phones(cust)
        if not phones:
            stats["skip_no_phone"] += 1
            continue

        lux_hits: list[dict[str, Any]] = []
        for phone in phones:
            q = urllib.parse.quote(phone)
            found = (
                http_json(
                    f"{supabase_url}/rest/v1/customers?phone=eq.{q}&select=id,phone,name,lightspeed_customer_id&limit=2",
                    sb_headers,
                )
                or []
            )
            for hit in found:
                if hit["id"] not in {h["id"] for h in lux_hits}:
                    lux_hits.append(hit)

        if len(lux_hits) == 0:
            stats["skip_unmatched_phone"] += 1
            continue
        if len(lux_hits) > 1:
            stats["skip_ambiguous"] += 1
            print(f"ambiguous {ls_id} phones={phones} hits={[h['phone'] for h in lux_hits]}")
            continue

        lux = lux_hits[0]
        existing = lux.get("lightspeed_customer_id")
        if existing and existing != ls_id:
            stats["skip_conflict"] += 1
            print(
                f"conflict lux={lux['id']} already linked to {existing}, sale has {ls_id}"
            )
            continue

        stats["matched"] += 1
        if args.dry_run:
            if stats["matched"] <= 10:
                print(f"  would link ls={ls_id} → lux={lux['id']} ({lux['phone']})")
        else:
            apply_link(ls_id, lux["id"])
        if i % 40 == 0:
            print(
                f"progress {i}/{len(ls_ids)} matched={stats['matched']} "
                f"patched={stats['sales_groups_patched']}"
            )

    print("final stats:", dict(stats))

    if args.dry_run:
        return

    try:
        updated = http_json(
            f"{supabase_url.rstrip('/')}/rest/v1/rpc/backfill_last_seen_from_sales",
            {**sb_headers, "Content-Type": "application/json"},
            method="POST",
            body=b"{}",
            timeout=180,
        )
        print(f"last_seen backfill updated={updated or 0}")
    except SystemExit as exc:
        print(f"last_seen backfill skipped: {exc}")


if __name__ == "__main__":
    main()
