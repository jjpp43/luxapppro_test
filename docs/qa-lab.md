# QA Lab — testing environment

**Updated:** 2026-08-21  
**Audience:** anyone running loyalty tests before a store pilot  
**Project:** staging Supabase `luxproapp_test` (`lgesaomtqisfvzcllusy`, us-west-2)  
**Admin:** `apps/admin` on Vercel (same staging database)

This is the rehearsal counter. Real loyalty code (RPCs, ledger, admin) runs against **fake people and fake tickets**. Lightspeed and TapMango are never called and never written to.

---

## What this environment is

| Layer | What we use | What we do not use |
|---|---|---|
| Database | Staging Supabase (already a test account) | A second Supabase project is not required |
| Admin | Staging Vercel admin, logged in as owner/manager | Production admin (does not exist yet) |
| Tickets | Rows we insert with ids `test-qa-…` | Live register, Lightspeed API, worker poll |
| Customers | Phones `+1555100…` named `QA …` | The ~196k TapMango import |
| Earn | On **only** for the store named **QA Lab** | Decatur / Craig / East Twain / West Sahara / Hairway / Hollywood stay **off** |
| Worker / Fly | Not part of this lab | Do not point the poller at QA Lab (it has no outlet id anyway) |

Same Postgres as the import, on purpose: schema, RLS, and RPCs are the ones we will ship. Isolation is by **store flag, phone prefix, and sale id prefix**, not by a separate cloud.

---

## How it is set up

### 1. Sandbox store

Migration `supabase/migrations/20260821080000_add_qa_lab_sandbox.sql` adds:

- `stores.is_sandbox` (boolean, default false)
- A store named **QA Lab**
  - `sort_rank` 99
  - `is_sandbox` true
  - `loyalty_earn_enabled` **true** (this is the only store allowed to write earn/clawback)
  - `lightspeed_outlet_id` **null** — the ingest worker maps outlets to stores; with no outlet, Decatur tickets cannot land here

Live stores must keep `is_sandbox = false` and `loyalty_earn_enabled = false` until a real pilot is chosen.

### 2. What “reset” is allowed to delete

The ledger is append-only in normal use. QA reset is the exception: `qa_lab_reset()` (service role only) turns on a transaction-local switch and deletes **only**:

- customers whose phone starts with `+1555100` **or** whose home store is QA Lab
- their `points_ledger` and `redemptions` rows
- sales on QA Lab **or** whose `lightspeed_sale_id` starts with `test-qa-`

It does **not** delete TapMango customers, Decatur sales, or live-store ledger rows.

### 3. Seeded personas

`qa_lab_seed()` calls reset, then creates:

| Phone | Name | Starting points | Fake ticket |
|---|---|---|---|
| `+15551001001` | QA Maya Chen | 500 (correction row) | none — ready to redeem $10 or $25 when that RPC exists |
| `+15551001002` | QA Luis Ortega | 200 (correction row) | none — **not** enough for $10 (250 pts) |
| `+15551001003` | QA Priya Shah | 0 | `test-qa-priya-closed` — closed, $47.80, identified |
| — | anonymous WALKIN | — | `test-qa-walkin` — closed, $32.50, **no** customer |
| `+15551001004` | QA New Walkup | 0 | none — created by the runner via `enrol_customer`, not by seed |

Names are prefixed `QA` so they are obvious in customer search.

### 4. Dashboard isolation

So lab traffic does not look like chain performance:

- **Location Performance** ignores sandbox stores and does not use QA tickets as the “latest sale” anchor
- **POS Transactions** and **Points ledger** hide QA Lab when **All stores** is selected
- Click the **QA Lab** chip on those pages to inspect the fake tickets
- **Stores** shows QA Lab with a sandbox badge and “Sandbox — fake tickets only”

A few extra QA customers can appear in the global customer count (~196k + a handful). That does not change live-store spend.

### 5. Credentials the runner needs

`scripts/qa_lab.py` reads, in order:

1. `apps/admin/.env.local`
2. repo `.env.local`
3. `apps/worker/.env`

Required:

- `NEXT_PUBLIC_SUPABASE_URL` or `SUPABASE_URL`
- `SUPABASE_SECRET_KEY` or `SUPABASE_SERVICE_ROLE_KEY`

Service role only. The reset/seed RPCs refuse `anon` / `authenticated`. Do not put this key in Expo or the browser.

---

## How to conduct a test

Work from the repo root. You need Python 3 and the staging key above. You do **not** need Fly, Lightspeed tokens, or a tablet.

### A. Automated counter rehearsal (do this first)

```bash
python3 scripts/qa_lab.py
```

This wipes previous QA rows, reseeds personas, then runs the scenarios below. Every line should print `PASS`. `SKIP` on redeem is expected until that RPC ships.

```bash
python3 scripts/qa_lab.py --reset-only
```

Removes QA rows and leaves the empty lab store. Use this if you want a clean slate without seeding.

**If any `FAIL`:** stop. Do not “fix” a live customer. Re-run the script (it resets the lab first). If it still fails, the RPC or seed changed — fix code, not imported data.

### B. What the runner proves today

Run in this order (the script does it for you):

| # | Scenario | Expected |
|---|---|---|
| 1 | Maya / Luis / Priya starting balances | 500 / 200 / 0 |
| 2 | Process `test-qa-walkin` | `unidentified_ignored` — no ledger earn |
| 3 | Process `test-qa-priya-closed` | earn **47** pts (`floor(4780/100)`), Priya balance 47 |
| 4 | Process the same Priya sale again | `in_sync`, still 47 — no double earn |
| 5 | Mark that sale `voided`, process again | clawback to net 0; Priya balance 0; never below zero |
| 6 | `enrol_customer` `+15551001004` | new customer on QA Lab |
| 7 | Redeem | **SKIP** until `redeem` exists — then Maya should succeed, Luis should be refused |

### C. Click-through in staging admin

After a successful `python3 scripts/qa_lab.py`:

1. Open the staging admin and sign in as owner (or manager).
2. **Customize → Stores** — confirm QA Lab is sandbox, earn On; Decatur earn **Off**.
3. **Customers** — search `1555100` or `QA Maya`. Open Maya; points should be 500. Open Priya; after the runner, points should be **0** (void already clawed back).
4. **Audience → POS Transactions** — click **QA Lab** (not All stores). You should see `test-qa-priya-closed` (voided) and `test-qa-walkin` (no customer). You should **not** see Decatur Lightspeed ids mixed in on All stores.
5. **Loyalty → Points ledger** — click **QA Lab**. You should see Maya/Luis corrections, Priya earn, Priya clawback. Live import opening balances stay under All stores / other chips.

To look at Priya **with 47 points** (before the void), you would need a seed that stops before step 5 — today the runner always finishes the void. For a visual mid-state, run seed via SQL/`qa_lab_seed` and process only the closed sale, then stop; or add a flag later. Do not process Decatur sales to “see earn.”

### D. When redeem exists

Still only QA phones:

1. `python3 scripts/qa_lab.py` (or seed, skip void if you need Priya mid-earn).
2. As staff (owner in admin first; tablet PIN later), redeem **$10 off** (250 pts) for Maya → balance 250, one `redemptions` row, one ledger `redemption` of −250.
3. Attempt **$10 off** for Luis → refused; balance stays 200.
4. Confirm Lightspeed still has no new discount — we do not write to the register. The “cashier keys $10 off” part is a later dry-run at a quiet counter, not this lab.

### E. What this lab does not prove

- A real Lightspeed checkout or webhook
- TapMango remaining in sync
- Worker polling / Fly always-on
- Tablet device session + PIN
- Chain Business Pulse (other stores’ POS)
- Production (there is no production project yet)

A quiet **in-store** trial is a later step: one test phone, earn still off on the live store, cashier applies discount by hand.

---

## Safety rules

1. Never set `loyalty_earn_enabled` on Decatur (or any non-sandbox store) to test earn. Use QA Lab.
2. Never run `scripts/qa_lab.py` against a production Supabase URL.
3. Never give a QA phone (`+1555100…`) to a real shopper.
4. Never map a real Lightspeed `outlet_id` onto QA Lab.
5. Do not delete or correct imported customers to make a test pass. Reset the lab instead.
6. `process_sales_loyalty.py --enable-earn` still respects **per-store** flags. It will no-op on Decatur and **will** earn on QA Lab tickets if those rows exist. Prefer `qa_lab.py` so you do not scan the whole sales table.

---

## Files

| File | Role |
|---|---|
| `supabase/migrations/20260821080000_add_qa_lab_sandbox.sql` | Store flag, QA Lab row, `qa_lab_reset` / `qa_lab_seed` |
| `scripts/qa_lab.py` | Seed + scenario runner |
| `apps/admin/src/lib/stores.ts` | Sandbox helpers for admin queries |
| Location Performance / POS / ledger / Stores pages | Hide or badge the lab |

RPCs: `qa_lab_reset()`, `qa_lab_seed()` — `service_role` only.

---

## After a test

If you are done for the day:

```bash
python3 scripts/qa_lab.py --reset-only
```

QA Lab store remains; fake people and tickets are gone. Live import data is unchanged.
