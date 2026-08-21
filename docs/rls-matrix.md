# RLS matrix and policies

**Status:** Locked and implemented on staging  
**Updated:** 2026-08-20  
**Next:** Customer/device allow-case tests when those auth flows are implemented

Auth wiring and the first policy migration are complete. Device policies remain
deny-by-default until the roadmap 2.5 provisioning flow replaces the placeholder
device helpers.

This document is the source of truth for Supabase Row Level Security before policy SQL is written. Auth wiring (how sessions map to these roles) comes next; it must satisfy the helpers and roles below.

---

## Locked forks

| Decision | Choice |
|---|---|
| **Tablet auth** | Shared **device session** for lookup / enrol / start-earn; **staff identity required** for redeem and balance corrections (PIN unlock or staff login for those actions) |
| **Corrections** | **Cashier + manager + owner** (staff identity required — not a bare device session) |
| **Ledger writes** | **RPC-only** — clients never `INSERT`/`UPDATE`/`DELETE` `points_ledger` |
| **Partner** | Same Auth user as a customer who has an active `referral_partners` row |
| **Service role** | Worker only; bypasses RLS; never in Expo or browser bundles |

---

## Roles

| Role | Surfaces | Recognition (auth wiring will define exact mechanism) |
|---|---|---|
| `customer` | Customer app | OTP user linked to `customers` |
| `partner` | Customer app (partner mode) | `customer` who owns an active `referral_partners` row |
| `cashier` | Tablet (elevated) | `staff.role = cashier` |
| `manager` | Admin (+ tablet elevate) | `staff.role = manager` |
| `owner` | Admin | `staff.role = owner` |
| `device` | Tablet kiosk baseline | Device-provisioned session (not a person) |
| `service` | Worker only | Service-role key |

---

## Helper functions (required by policies)

Implement as stable `SECURITY DEFINER` SQL helpers (or equivalent) used by every policy. Auth wiring must populate whatever these read (`auth.uid()`, claims, link tables).

| Helper | Returns | Purpose |
|---|---|---|
| `current_customer_id()` | `uuid` / int PK or null | Auth user → `customers.id` |
| `current_staff_id()` | staff PK or null | Auth user → `staff.id` |
| `current_staff_role()` | `cashier` \| `manager` \| `owner` \| null | From `staff.role` |
| `current_staff_store_id()` | store PK or null | From `staff.store_id` |
| `is_manager_or_owner()` | boolean | `current_staff_role()` in (`manager`, `owner`) |
| `is_staff()` | boolean | Any active staff row for this auth user |
| `is_device()` | boolean | Session is a provisioned tablet device |
| `is_partner()` | boolean | Active `referral_partners` for `current_customer_id()` |
| `current_partner_id()` | partner PK or null | That partner’s id |
| `device_store_id()` | store PK or null | Store bound to this tablet device |

---

## Matrix

### How to read a cell

Every cell is built from the same pieces:

```
[actions] [scope?]
```

Examples: `R` · `R own` · `R+C` · `R+U own` · `R+C+U` · `-`

### Terms (complete list)

| Term | Meaning |
|---|---|
| **R** | **Read** — can see rows |
| **C** | **Create** — can add rows |
| **U** | **Update** — can change rows |
| **+** | Combine actions (e.g. **R+C** = read and create) |
| **-** | **No access** |
| **own** | Only **your** rows (for this role — see table below) |
| **active** | Only rows with `active = true` |
| **store** | Only rows for **your store** (this tablet’s or this staff member’s store) |

No other matrix abbreviations. (We do **not** use “full”, “self”, “actor”, or “/”.)

**Your rows (`own`) by table**

| Table | “Your rows” means |
|---|---|
| `customers` | Your customer profile |
| `staff` | Your staff profile |
| `points_ledger`, `sales`, `redemptions` | Rows for your `customer_id` |
| `referral_partners` | Your partner profile |
| `referrals` | Customer: you were referred. Partner: you referred them |
| `referral_tokens` | Tokens for your partner id |

### Every cell value explained

These are **all** the labels that appear in the matrix. Each one is only a combo of the terms above.

---

#### `-`
**No access.** This role cannot read, create, or update any row in that table.

*Example:* partner → `points_ledger` = `-` — beauticians cannot browse customer point histories.

---

#### `R`
**Read** rows in this table, **not** limited to “only mine” / “only active” / “only my store” by the cell itself.

*Example:* cashier → `points_ledger` = `R` — look up whatever customer is at the counter.

*Note:* Point **writes** still go through RPCs, not raw inserts, even when `R` is allowed.

---

#### `R active`
**Read** only rows where **`active = true`**.

Used so shoppers (and similar) see live catalog/locations, not retired ones.

*Example:* customer → `rewards` = `R active` — see current rewards only.  
*Example:* customer → `stores` = `R active` — see open stores only.

Managers/owners use `R+C+U` on those tables so they can still see and edit inactive rows.

---

#### `R own`
**Read** only **your** rows (see “Your rows by table”).

*Example:* customer → `points_ledger` = `R own` — only your point history.  
*Example:* cashier → `staff` = `R own` — only your staff profile, not every employee.  
*Example:* customer → `referrals` = `R own` — referral rows where **you** were referred.

---

#### `R store`
**Read** only rows for **your store** (tablet’s store or staff member’s store).

*Example:* cashier → `sales` = `R store` — sales at this location, not every Lux store.  
*Example:* manager → `staff` = `R store` — colleagues at your store.

---

#### `R+C`
**Read and create.** No `own`/`store`/`active` limit in the label.

*Example:* device/cashier → `customers` = `R+C` — look up by phone (**R**) and enrol a new phone (**C**). Create here means enrol only, not arbitrary profile inventing.

---

#### `R+U`
**Read and update** across customers you’re allowed to manage (not limited to “own”).

*Example:* manager → `customers` = `R+U` — search customers and edit their records (phone change still via merge RPC later).

---

#### `R+U own`
**Read and update** only **your** rows.

*Example:* customer → `customers` = `R+U own` — see/edit your profile (safe fields like email; not phone without merge).  
*Example:* partner → `referral_partners` = `R+U own` — edit your own partner profile only.

---

#### `R+C own`
**Read and create** only **your** rows.

*Example:* partner → `referrals` = `R+C own` — see your referrals and create new ones for you.  
*Example:* partner → `referral_tokens` = `R+C own` — your QR tokens (create still via RPC for expiry/rate limits).

---

#### `R+C+U`
**Read, create, and update** on that table (admin/service-level). Still **no deleting** money history from the apps.

*Example:* owner → `rewards` = `R+C+U` — full catalog management, including inactive rewards.  
*Example:* service → most tables = `R+C+U` — worker can ingest sales and write ledger (also bypasses RLS with service role).

---

### Quick compare

| Label | Read? | Create? | Update? | Which rows? |
|---|---|---|---|---|
| `-` | no | no | no | none |
| `R` | yes | no | no | not scoped to mine/active/store in the label |
| `R active` | yes | no | no | `active = true` only |
| `R own` | yes | no | no | yours only |
| `R store` | yes | no | no | your store only |
| `R+C` | yes | yes | no | not “own”-scoped |
| `R+U` | yes | no | yes | not “own”-scoped |
| `R+U own` | yes | no | yes | yours only |
| `R+C own` | yes | yes | no | yours only |
| `R+C+U` | yes | yes | yes | broadly that table (admin/service) |

---

| Table | customer | partner | device | cashier | manager | owner | service |
|---|---|---|---|---|---|---|---|
| `stores` | R active | R active | R | R | R | R+C+U | R+C+U |
| `staff` | - | - | - | R own | R store | R+C+U | R+C+U |
| `customers` | R+U own | R own | R+C | R+C | R+U | R+C+U | R+C+U |
| `points_ledger` | R own | - | R | R | R | R | R+C+U |
| `sales` | R own | - | R store | R store | R store | R+C+U | R+C+U |
| `rewards` | R active | R active | R active | R active | R+C+U | R+C+U | R+C+U |
| `redemptions` | R own | - | - | R store | R | R | R+C+U |
| `referral_partners` | - | R+U own | - | - | R | R+C+U | R+C+U |
| `referrals` | R own | R+C own | - | - | R | R+C+U | R+C+U |
| `referral_tokens` | - | R+C own* | - | - | - | - | R+C+U |

\*Token **create** still goes through RPC (expiry + rate limit).

### Notes (limits the short cell doesn’t show)

| Where | Extra meaning |
|---|---|
| `customers` · customer **R+U own** | Update safe fields only (e.g. email) — not phone without merge RPC |
| `customers` · device/cashier **R+C** | Create = enrol by phone only |
| `points_ledger` · device/staff **R** | Lookup only — point writes are RPC-only |
| `referrals` · customer **R own** | Rows where you were the referred customer |
| `sales` · manager **R store** | This store only; owner **R+C+U** covers all stores |

---

## RPC execute grants

Clients do not raw-insert ledger rows. `authenticated` / `anon` have **INSERT/UPDATE/DELETE revoked** on `points_ledger`. Writes go through `SECURITY DEFINER` RPCs (with `SET search_path`, explicit role checks, idempotency keys) or `service_role`.

| RPC | Purpose | Who may execute |
|---|---|---|
| `enrol_customer` | Create customer by phone at counter | `device`, `cashier`, `manager`, `owner` |
| `earn` / `award` | Credit points for a sale (or cashier fallback total) | `service` (Lightspeed webhook); optional `cashier` / `manager` / `owner` for degraded manual earn |
| `redeem` | Debit points + insert `redemptions` in one transaction | `cashier`, `manager`, `owner` (requires staff elevate on tablet — not bare `device`) |
| `correct_balance` | Insert compensating ledger row (`reason = correction`) | `cashier`, `manager`, `owner` (requires staff elevate on tablet — not bare `device`) |
| `issue_referral_token` | Create short-lived single-use token | `partner` |
| `consume_referral_token` | Attach pending referral (QR path) | `customer` and/or `partner` (manual phone path may be separate RPC) |
| `merge_customers` | Phone identity merge (later) | `manager`, `owner` |

### RPC hardening checklist

- [ ] `SECURITY DEFINER` + `SET search_path = public, pg_temp`
- [ ] Assert caller role inside the function (do not trust client args alone)
- [ ] Redeem: lock customer row, compute balance, insert ledger + redemption, honor `idempotency_key`
- [ ] Correct: compute delta from target balance; require non-empty reason; set `created_by`
- [ ] Grant `EXECUTE` only to roles listed above; revoke from `anon` where not needed

---

## Policy intent by table

### `stores`
- Customers/partners: **R active** only.
- Staff/device: **R**.
- Owner: **R+C+U**.

### `staff`
- Cashier: **R own**.
- Manager: **R store**.
- Owner: **R+C+U**; nobody may escalate their own `role` via client update.

### `customers`
- Customer: **R+U own** (`id = current_customer_id()`).
- Device/cashier: phone lookup + enrol (prefer `enrol_customer` RPC).
- Manager: **R+U**; owner: **R+C+U**.

### `points_ledger`
- Customer: **R own**.
- Device/cashier/manager/owner: **R** (lookup).
- Partner: **-**.
- No client writes.

### `sales`
- Inserts: `service` only (worker).
- Customer: **R own**.
- Device/cashier/manager: **R store**.
- Owner: **R+C+U** (all stores).

### `rewards`
- Customer/partner/device/cashier: **R active**.
- Manager/owner: **R+C+U**.

### `redemptions`
- Created only inside `redeem` RPC.
- Customer: **R own**; cashier: **R store**; manager/owner: **R**.

### `referral_partners` / `referrals` / `referral_tokens`
- Partner: **own** only.
- Customer may **R own** referrals (as referred).
- Manager: **R**; owner: **R+C+U**.
- Token issue/consume via RPCs preferred.

---

## Global security rules

1. Enable RLS on every `public` table apps can touch; default deny.
2. Revoke `INSERT` / `UPDATE` / `DELETE` on `points_ledger` from `anon` and `authenticated`.
3. Append-only trigger on `points_ledger` remains (no update/delete even for privileged app roles).
4. Never ship `service_role` to Expo or the admin browser bundle.
5. Policy tests: at least one **allow** and one **deny** case per sensitive matrix cell (`customers`, `points_ledger`, `redeem`, `correct_balance`).

---

## Implementation order (when writing SQL)

1. Helpers (`current_customer_id`, staff/device/partner helpers)  
2. `ENABLE ROW LEVEL SECURITY` + revoke dangerous grants on ledger  
3. SELECT policies per table  
4. Narrow INSERT/UPDATE policies (enrol, rewards admin, etc.)  
5. RPCs + `EXECUTE` grants  
6. pgTAP or equivalent policy tests  

Auth wiring must land before helpers return real ids — see [auth-wiring.md](./auth-wiring.md).
