# Staging sample load

**Project:** `luxproapp_test` (`lgesaomtqisfvzcllusy`, us-west-2)  
**Status:** Sample schema + 100-row TapMango import loaded. Admin can read via temporary anon SELECT policies.

## Verified counts

| Metric | Value |
|---|---|
| Customers | 100 |
| Stores | 3 |
| Ledger rows | 88 (12 zero-point customers have no opening row) |
| Points sum | 9,547 |

## Admin

`apps/admin` — Overview + Customers list/detail against Supabase anon key.

## Security hold

`staging_anon_select_*` policies are **temporary**. Remove before any non-staging use. Real RLS follows `docs/rls-matrix.md` after auth wiring (`docs/auth-wiring.md`).
