# Schema explained

Companion to `schema-stackrender.sql`. How the tables fit together and why they look this way.

---

## Table groups

| Group | Tables | Purpose |
|---|---|---|
| **1. Organization** | `stores`, `staff` | Outlets and people who run admin/tablet |
| **2. Customers** | `customers` | Loyalty members (phone = identity) |
| **3. Commerce** | `sales` | Lightspeed X sales mirrored in |
| **4. Loyalty** | `rewards`, `points_ledger`, `redemptions` | Catalog, point history, spends |
| **5. Referrals** | `referral_partners`, `referrals`, `referral_tokens` | Beautician program |

```
1. Organization          2. Customers           3. Commerce
   stores                   customers              sales
   staff                       │                     │
       │                       │                     │
       └───────────────────────┴─────────────────────┘
                               │
                    4. Loyalty │ 5. Referrals
              rewards          │   referral_partners
              points_ledger ←──┤   referrals
              redemptions      │   referral_tokens
```

**Money/sales** stay in Lightspeed. **This database** owns customers, points history, rewards, and referrals.

There is **no `balance` column** on `customers`. Balance = `SUM(points_ledger.delta)` for that customer.

---

## Enums (allowed values)

Postgres enums stop bad strings from landing in the DB.

| Enum | Used on | Meaning |
|---|---|---|
| `customer_source_enum` | `customers.source` | How the account was created (TapMango migration, tablet signup, app, etc.) |
| `staff_role_enum` | `staff.role` | cashier / manager / owner — drives admin permissions later |
| `ledger_reason_enum` | `points_ledger.reason` | Why points moved (earn, redeem, migration opening, correction, …) |
| `ledger_ref_type_enum` | `points_ledger.ref_type` | What kind of object `ref_id` points at |
| `reward_kind_enum` | `rewards.kind` | Shape of the reward (fixed $, %, free item) |
| `referral_status_enum` | `referrals.status` | Lifecycle: pending → qualified → approved → paid (or expired/rejected) |
| `referral_capture_method_enum` | `referrals.capture_method` | QR scan vs beautician typed phone |

---

## 1. Organization

### `stores`

Physical outlets (Lux Decatur, West Sahara, etc.).

| Column | Role |
|---|---|
| `id` | Primary key |
| `name` | Display name |
| `lightspeed_outlet_id` | Unique link to Lightspeed X outlet (nullable until mapped) |
| `active` | Soft-disable a location |

Almost everything that “happens in a shop” can point here.

### `staff`

People who use the **admin dashboard** or take sensitive tablet actions.

| Column | Role |
|---|---|
| `store_id` | Optional home store (FK → `stores`) |
| `email` | Unique login identity for admin |
| `role` | cashier / manager / owner |
| `created_by` on ledger | Points at `staff.id` when a human corrects a balance |

Without this table, you cannot answer “who fixed this customer’s points?”

---

## 2. Customers

### `customers`

Loyalty members. ~200k imported from TapMango + new signups.

| Column | Role |
|---|---|
| `phone` | **Identity key** — unique, E.164 (e.g. `+17025551234`). Signup is phone-only; `name` can be null |
| `home_store_id` | FK → `stores` from TapMango `Location` |
| `legacy_tapmango_id` | TapMango `CustomerId` — unique, for migration/traceability |
| `lifetime_points_at_migration` | Frozen TapMango figure for reconcile checks |
| `source` | migration / tablet / app / … |
| SMS/email flags | Consent-ish fields from export; marketing SMS not in v1 but data kept |

**FK:** `home_store_id` → `stores` (`ON DELETE SET NULL` — store can go away without deleting people).

---

## 3. Commerce

### `sales`

Copies of Lightspeed X sales we care about for loyalty (from `sale.update` webhook).

| Column | Role |
|---|---|
| `lightspeed_sale_id` | **Unique** — webhook replay / double-delivery safe |
| `store_id` | Which outlet |
| `customer_id` | Nullable if sale had no matched loyalty member |
| `total_cents` | Full sale amount |
| `eligible_cents` | Amount that should earn points (exclusions TBD: tax, gift cards, …) |
| `occurred_at` | When the sale happened |

A successful earn usually creates: one `sales` row + one `points_ledger` row (`reason = earn`, `ref_type = sale`).

---

## 4. Loyalty

### `rewards`

Catalog of what points can buy. Configured in admin. v1 seed:

| Name | `cost_points` | `kind` | Value |
|---|---|---|---|
| $10 off | 250 | `fixed_discount` | 1000 cents |
| $25 off | 500 | `fixed_discount` | 2500 cents |

These are two catalog rows, not a formula — the dollar value per point is not the same.

| Column | Role |
|---|---|
| `cost_points` | How many points to spend |
| `kind` | fixed_discount / percent / free_item |
| `active` | Soft on/off without deleting history |

### `points_ledger` (the important one)

Append-only **history of every point movement**. This is the accounting book.

| Column | Role |
|---|---|
| `customer_id` | Whose balance (FK → `customers`, **RESTRICT** — don’t delete people with history) |
| `store_id` | Where it happened (nullable for system/migration rows) |
| `delta` | Signed integer: `+50` earn, `-100` redeem. Never zero |
| `reason` | Why (earn, redemption, migration_opening, correction, …) |
| `ref_type` + `ref_id` | Soft link to the cause (sale #, redemption #, …) — not always a formal FK so one column can point at different tables |
| `idempotency_key` | **Unique** — same webhook/retry cannot insert twice |
| `created_by` | Staff who made a manual correction |

**How TapMango import works:** one row per customer with `reason = migration_opening` and `delta =` their exported Points.

**How fixes work:** never update an old row; insert a new `correction` row.

**FKs:** customer RESTRICT, store SET NULL, staff SET NULL.

### `redemptions`

A customer **spent** points on a reward at a store.

| Column | Role |
|---|---|
| `customer_id`, `reward_id`, `store_id` | Who / what / where |
| `ledger_id` | **Unique** FK → the negative `points_ledger` row for this spend |

One redemption ↔ exactly one ledger debit. That keeps “I redeemed X” and “my balance dropped by Y” tied together.

All FKs use **RESTRICT** so you don’t orphan financial history.

---

## 5. Referrals

### `referral_partners`

Beauticians (or salons) in the referral program.

| Column | Role |
|---|---|
| `customer_id` | **Unique** FK → their own `customers` row — blocks self-referral (same phone) |
| `name` | Beautician name |
| `salon_name` | Optional shop grouping |
| `payout_terms` | Free-text for now (cash / product / credit TBD) |

They are customers too (app login), plus partner privileges.

### `referrals`

One **visit-level** referral event — not a permanent flag on the customer.

Flow:

1. Beautician shows QR or types phone → `referrals` row `status = pending`
2. Customer shops → linked `sale_id`, maybe `qualified`
3. After return window (`hold_until`) → `approved` → shows on payout report → `paid`

| Column | Role |
|---|---|
| `partner_id` | Who gets credit |
| `customer_id` | Who was referred |
| `sale_id` | Qualifying purchase (nullable while pending) |
| `capture_method` | qr_scan / manual_phone |
| `status` | pending → … → paid |
| `attributed_amount_cents` | Basket (or commission base) for payout math |
| `hold_until` | Don’t pay until returns window closes |

Same customer can be referred many times over years (different visits / partners).

### `referral_tokens`

Short-lived codes behind the rotating QR.

| Column | Role |
|---|---|
| `partner_id` | Whose code |
| `token` | Opaque random string (unique) |
| `expires_at` | Server-side expiry (e.g. ~60s) |
| `consumed_at` | Set on first successful use — single-use |

`ON DELETE CASCADE` from partner: if you remove a partner, their unused tokens go away.

---

## Foreign key delete behavior (why it differs)

| Behavior | Used when |
|---|---|
| **RESTRICT** | Money/history — refuse deleting a customer/store if ledger/sales/redemptions exist |
| **SET NULL** | Optional links — e.g. clear `home_store_id` if a store row is removed |
| **CASCADE** | Dependent junk — referral tokens die with the partner |

---

## Example: one happy path

1. Customer gives phone at tablet → find/create `customers`
2. Cashier rings sale in Lightspeed
3. Worker gets `sale.update` → insert `sales` (unique on `lightspeed_sale_id`)
4. Insert `points_ledger` `+N`, `reason = earn`, `idempotency_key = sale:…`
5. Later, redeem reward → insert `points_ledger` `-cost` + `redemptions` row pointing at that ledger id
6. Balance shown in app = sum of all ledger deltas for that customer

---

## What this schema does *not* freeze yet

Still product decisions (columns may grow):

- Tax / gift-card / other exclusions on `eligible_cents` (earn rate itself is frozen: 1 point per $1)
- Whether returns always write `return_clawback` ledger rows
- Referral economics — beautician payout, customer reward, min basket, pending TTL, return hold, cooling-off, last-touch (**deferred; discuss later**)
- Beautician payout = same points currency vs separate wallet (today: referral $ on `referrals`, customer points on ledger)
- Device/tablet registry

Those don’t remove the need for these core tables; they add detail on top.
