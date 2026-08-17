# Staging load

**Project:** `luxproapp_test` (`lgesaomtqisfvzcllusy`, us-west-2)  
**Status:** Full TapMango customer export imported 2026-08-17. Admin can read via temporary anon SELECT policies.

## Verified counts

CSV rows: **196,590**. Imported customers: **196,493**. Quarantined (no usable phone): **97**.

| Metric | Value |
|---|---|
| Customers | 196,493 |
| Stores | 6 |
| Opening ledger rows | 180,453 (zero-point customers have no opening row) |
| Opening points sum | **20,100,952** — matches CSV Points for imported rows (`21,091,113` CSV total − `8,161` quarantined) |

### Per store

| Store | Customers | Opening points |
|---|---|---|
| Hairway 2 Heaven | 26,973 | 2,649,772 |
| Hollywood Beauty | 25,905 | 2,365,052 |
| Lux Beauty Supply - Craig | 37,928 | 4,151,371 |
| Lux Beauty Supply - Decatur | 40,845 | 3,989,013 |
| Lux Beauty Supply - East Twain | 26,255 | 2,622,678 |
| Lux Beauty Supply - West Sahara Avenue | 38,587 | 4,323,066 |

### Quarantine (`staging_tapmango_quarantine`)

97 rows not imported — we do not invent phones.

| Reason | Count |
|---|---|
| Empty phone | 58 |
| Malformed (not 10-digit US) | 39 |

Re-import script: `python3 scripts/import_tapmango.py` (needs the CSV locally; import RPC is **dropped** after load).

## Admin

`apps/admin` — Dashboard + Customers against Supabase anon key.

## Security hold

`staging_anon_select_*` policies are **temporary**. Remove before any non-staging use. Real RLS follows `docs/rls-matrix.md` after auth wiring (`docs/auth-wiring.md`).
