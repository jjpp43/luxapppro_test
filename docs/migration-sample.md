# Sample migration (100 rows)

**Updated:** 2026-08-12  
**Sample file:** `data/tapmango/customer_sample.csv` (gitignored; sourced from `~/Downloads/customer_sample.csv`)

## Hold

Per project gate: **no Supabase writes** (and no junior writes) until [auth-wiring.md](./auth-wiring.md) is agreed. This sample phase is for **validate + map** first; load into staging only when you open that gate.

## Sample stats

| Check | Result |
|---|---|
| Rows | 100 |
| Columns | 19 — same as full TapMango export |
| Empty phones | 0 |
| Duplicate phones | 0 |
| Points sum | 9,547 |
| Locations | Hollywood Beauty (97), Lux West Sahara (2), Hairway 2 Heaven (1) |

## What “small portion” means here

1. **Prove the pipeline** on 100 rows before touching ~197k  
2. Same column map as production ([schema.md](./schema.md) export map)  
3. Reconcile: imported opening balances sum = sample Points sum (9,547)  
4. Only then scale to full CSV  

## Target load (when gate opens)

Per row in sample:

| CSV | Destination |
|---|---|
| `CustomerId` | `customers.legacy_tapmango_id` |
| `Phone` | `customers.phone` (normalize E.164) |
| `Name` | `customers.name` (optional) |
| `Email` | `customers.email` |
| `Points` | one `points_ledger` row, `reason = migration_opening`, `delta = Points` |
| `Lifetime Points` | `customers.lifetime_points_at_migration` |
| `Location` | map name → `stores.id` → `home_store_id` |
| `Registration Date/Time` | `registered_at` |
| `Last Checkin Date/Time` | `last_seen_at` |
| SMS/Email flags | consent columns |
| App/Device/Push/DOB/Notes | staging only or skip |

Also seed `stores` for every distinct Location string in the sample (3 names).

## Suggested order

| Step | Do now? | Notes |
|---|---|---|
| Keep sample in `data/tapmango/` (gitignored) | Yes | Done |
| Auth wiring | Yes — next design | Blocks real DB load |
| Validation script (read CSV, print map/stats, no DB) | Optional now | Safe under hold |
| Staging Supabase + import 100 rows | After auth wiring | First real write |
| Reconcile 9,547 points | With staging import | Gate before full file |
| Full ~197k import on staging | After sample OK | Then prod cutover plan |

## Location note

Sample is skewed to **Hollywood Beauty**. Fine for pipeline testing; full export has all Lux stores. Confirm with PM which non-Lux locations are in-program before production import.
