# Pre-build decisions — elaborated + owners

**Updated:** 2026-08-12  

| Owner | Meaning |
|---|---|
| **You (lead)** | Technical / implementation choice. You decide (junior may input on Expo ergonomics). |
| **PM** | Business / client / product rule. You can recommend; they confirm. |
| **Both** | You propose options; PM picks among business impacts. |
| **Client ops** | Account ownership, credentials, contracts — PM usually drives; you may execute. |

---

## Already decided (skip in the meeting)

Stack, direct-to-Supabase, points ledger, Lightspeed X webhooks, phone-only signup, US West, PITR after pilot, Pro backups + off-vendor dump.

**RLS matrix locked:** see [`rls-matrix.md`](./rls-matrix.md) — device tablet session + staff elevate for redeem **and corrections**; corrections = cashier + manager + owner; ledger writes RPC-only. **Next:** [`auth-wiring.md`](./auth-wiring.md).

**Hold:** no policy SQL and no junior Supabase writes until auth wiring is agreed.

---

# 1. Access control (RLS / permissions)

### What it is
Which **role** can **select / insert / update / delete** on each table. Enforced in Postgres as RLS policies. Without this, Expo and admin either can’t work or are dangerously open.

### Elaborate
Apps use the anon key + a logged-in session. Supabase will expose tables unless RLS says otherwise. You need:

1. A short list of roles  
2. A matrix (table × role × actions)  
3. Policies that implement the matrix  
4. A rule that money moves (`redeem`, `award`, `correct`) go through **RPCs**, not free-form inserts  

**Draft roles**

| Role | Who |
|---|---|
| `customer` | App user (shopper) |
| `partner` | Beautician using partner mode |
| `staff` | Counter tablet / cashier |
| `manager` | Store manager (admin) |
| `owner` | Client principals (admin) |
| `service` | Worker (service-role key; bypasses RLS) |

**Examples of decisions inside this**

- Can a cashier **correct** points, or only a manager?  
- Can a customer **read** their own sales history?  
- Can a partner see **only their** referrals, or all for their salon?  
- Can staff **create** customers (enrol) — yes, per product.  

### Owner

| Piece | Owner |
|---|---|
| Role list + RLS matrix + policy SQL + RPC boundaries | **You** |
| “Who is allowed to fix points / approve payouts?” (business authority) | **PM** (you encode it) |

**Meeting ask for PM:** “Can any cashier adjust points, or manager-only? Who approves beautician payouts?”

---

# 2. Auth & identity

### What it is
How each surface proves who they are, and how that maps to a `customers` / `staff` row.

### Elaborate

**Customers**  
Phone OTP via Supabase Auth. After OTP, you must link `auth.users.id` ↔ `customers.id` (column on `customers` or a profile table). Phone stored E.164.

**Partners**  
Same person may be a shopper *and* a beautician. Usual pattern: one Auth user; `referral_partners.customer_id` marks partner capability. Decide if partner mode is a flag you check in app + RLS, or a custom JWT claim.

**Admin**  
Email/password (or magic link). Rows in `staff` with `role = manager | owner`.

**Tablet** — biggest open technical choice  

| Option | Pros | Cons |
|---|---|---|
| A. Long-lived **device** session | Fast at counter | Device theft / shared iPad risk; need PIN for sensitive actions |
| B. Staff login every shift | Clear who acted | Slower; forgotten passwords at counter |
| C. Device session + **PIN** for redeem/correct | Balance of speed + audit | Slightly more UX work |

Also: empty phones in export (58), phone merge when two accounts are one person, Twilio/A2P for OTP (account ownership).

### Owner

| Piece | Owner |
|---|---|
| OTP + Auth↔customer link + E.164 + merge procedure design | **You** |
| Tablet auth pattern (A/B/C) | **Both** — you recommend C; PM confirms counter UX tolerance |
| Twilio / Apple / Google accounts in client’s name | **Client ops / PM** |
| Who may correct points | **PM** — decided 2026-08-17: cashier, manager, owner |

---

# 3. Money — earn / redeem / returns

### What it is
The business rules that turn a Lightspeed sale into ledger rows, and what happens when money comes back.

### Elaborate

**Earn — for Lightspeed integration later (not a kickoff topic)**  
- **1 point per $1 of purchase** (`floor(cents / 100)` — leftover cents do not earn)  
- No expiry unless PM later says otherwise  
- First implementation earns on **closed** sales with `eligible_cents = sale total`
- Tax / gift-card / sale-item exclusions remain open for a later refinement

**Redeem — for Lightspeed integration later**  
Catalog is two active rewards (not a formula — $10 and $25 are different rates):

| Reward | Cost | Kind |
|---|---|---|
| $10 off | 250 points | `fixed_discount` |
| $25 off | 500 points | `fixed_discount` |

Still open when we build redeem: can both stack on one purchase? Counter-only vs in-app?

**Manual point updates — for tablet/admin later**  
Cashier, manager, and owner may adjust a balance. UI looks like an edit; database inserts a `correction` ledger row with `created_by` + reason. Bare tablet device session is **not** enough — staff identity (PIN / login) required, same as redeem.

**Returns / voids / layby**  
- Insert a `return_clawback` for points earned by the returned/voided sale.
- Cap the clawback at the customer’s current balance; never take them below zero.

**Sale ↔ customer match**  
- Counter phone capture matches the nearest unmatched sale at that store within
  **±15 minutes**, with one sale consumed by at most one capture.
- Prefer an existing Lightspeed customer link when the sale already has one.
- Or cashier-entered amount as fallback when webhook/match fails?

### Owner

| Piece | Owner |
|---|---|
| All earn / exclude / expiry / stack / clawback rules | **PM** |
| Match-window engineering + fallback UX | **You** (PM confirms “good enough” behavior) |
| Exact RPC implementation | **You** |

**When we wire Lightspeed:** apply 1 pt / $1 on `eligible_cents`; seed the two discount rewards; `correct_balance` executable by cashier/manager/owner. Ask then about tax/gift cards, returns clawback, and stacking.

---

# 4. Referrals

### What it is
How beauticians get credit, customers get a discount, and you limit abuse.

### Elaborate

**Economics — deferred, cannot decide yet**  
Park until a later product conversation. Schema already has the columns (`status`, `hold_until`, `attributed_amount_cents`); amounts and rules are configuration, not a redesign.

| Question | Status |
|---|---|
| What the beautician earns | **Later** |
| What the customer gets | **Later** |
| Minimum basket to qualify | **Later** |
| How long a pending referral lasts | **Later** (technical default on the table: 30 days — not a product sign-off) |
| Return hold before payout | **Later** |
| Cooling-off (same beautician + same customer) | **Later** |
| Last-touch if two beauticians referred them | **Later** |

Do not block partner/QR build on these. Use placeholders in admin until PM decides.

**Currency**

**Currency**  
- Beautician “points” on the **same** `points_ledger` as shoppers?  
- Or **no points** — only a payout report from `attributed_amount_cents`?  
This changes schema/RLS and the app’s “earnings” screen.

**Cross-check / anti-abuse — deferred with economics**  
Cooling-off and last-touch sit with the list above. Cheap flags (cap manual entries, odd QR:manual ratio) can wait for the same conversation.

**Tokens**  

**Tokens**  
60s TTL + single-use is a technical default; PM rarely cares unless UX complains.

**Customer discount delivery**  
Is the discount applied in **Lightspeed** (coupon), as a **loyalty reward**, or manually by cashier? That decides whether you need a Lightspeed write path (you currently don’t write to Lightspeed).

### Owner

| Piece | Owner |
|---|---|
| Economics, hold, min basket, customer reward, cooling-off, last-touch | **PM — later.** Not this meeting. |
| Same ledger vs payout-only for beauticians | **Both** — you explain tradeoffs; PM picks |
| Anti-abuse rules for v1 | **Later** (same conversation as economics) |
| Token TTL, QR UX, schema for statuses | **You** |
| How discount is applied at POS | **PM** (+ you say if it forces Lightspeed write) |

---

# 5. Lightspeed integration

### What it is
How the worker receives sales and maps them into `sales` + ledger.

### Elaborate

- Auth to their retailer API (OAuth app vs personal token)  
- Public HTTPS webhook URL on the worker  
- Verify signatures if provided  
- Only **closed** sales earn.
- Returns/voids claw back points up to the current balance (never negative).
- Map each X-Series **outlet** → `stores.id`  
- CSV has extra locations (Hairway 2 Heaven, Hollywood Beauty) — real stores in program or ignore?  
- Persist raw webhook payload, then process (resilience)  
- Keep cashier-entered totals as degraded mode?

### Owner

| Piece | Owner |
|---|---|
| API credentials / webhook enablement access | **Client ops / PM** |
| Outlet mapping; which locations are in scope | **PM** |
| Status/refund handling implementation | **You** (from PM rules) |
| Persist-raw + idempotency + host choice details | **You** |

---

# 6. Apps / monorepo

### What it is
How the codebase and Expo targets are structured so you and the junior don’t step on each other.

### Elaborate

**Repo**  
`apps/admin`, `apps/customer`, `apps/tablet` (or one `apps/mobile` with flavors), `apps/worker`, `packages/types`, `packages/api-client`.

**Dual tablet**  
- **One app, two modes** (customer-facing vs cashier) — one EAS project, config/role switch  
- **Two apps** — clearer UX separation, more store/submit overhead  

**Junior day-1 path if undecided:** build **customer app** first (balance, history, referral capture); tablet second.

**Shared client**  
All Expo/Next go through a thin API helper so RLS/RPC calls stay consistent.

**Stores**  
Apple Developer + Play consoles in **client** name; privacy policy needed for submit.

**MDM / kiosk**  
After TapMango hardware leaves — can wait until tablet build is real.

### Owner

| Piece | Owner |
|---|---|
| Monorepo layout, shared packages, CI | **You** |
| Dual-tablet one vs two apps | **Both** — you recommend one app/two modes; PM/client confirm if they care |
| Junior starts on customer app | **You** |
| App Store / Play accounts, privacy policy | **PM / client** |
| MDM vendor later | **Both** |

---

# 7. Ops / infra

### What it is
Where things run and who pays / owns accounts.

### Elaborate

- Fly vs Railway (always-on, US West, no sleep)  
- Vercel for admin (pin US West)  
- Off-vendor backup bucket (R2/B2/S3) on **client** cloud  
- Staging Supabase project for import dry-runs  
- Sentry (or similar)  
- Optional second worker instance after pilot  
- All billing in client’s name  

### Owner

| Piece | Owner |
|---|---|
| Fly vs Railway, staging topology, backup job design | **You** |
| Who creates/owns cloud accounts and cards | **PM / client** |
| Budget comfort for Pro + worker + Vercel + Twilio | **PM** |

---

# 8. Migration / cutover

### What it is
Moving ~197k TapMango rows safely and switching stores.

### Elaborate

- Load CSV to staging → normalize phones → opening ledger rows  
- Reconcile totals **per store** before cutover  
- Quarantine 58 empty-phone rows (don’t invent numbers)  
- Ask TapMango for a **delta** export near switch weekend  
- Pilot one store ~5 days; rollback = tablets back to TapMango  
- Privacy policy before app store submit  

### Owner

| Piece | Owner |
|---|---|
| Import scripts, reconcile reports, quarantine tech | **You** |
| Request delta export; sign off on reconcile numbers | **PM / client** |
| Pilot store choice + go/no-go | **PM / client** |
| Privacy policy text | **PM / client** (you can stub URL) |

---

# Cheat sheet — who answers what

## You decide (technical)

1. RLS matrix structure + policies + RPC list  
2. Auth wiring (OTP, Auth↔customer, admin auth implementation)  
3. Recommend tablet auth (device + PIN)  
4. Match-window / webhook persistence / idempotency  
5. Monorepo, shared client, UUID for prod, staging projects  
6. Fly vs Railway, backup automation design  
7. Import tooling and reconcile reports  
8. Token TTL / QR mechanics  
9. Propose referral anti-abuse defaults  

## PM / client answer (business)

1. Who may correct points / approve payouts  
2. Earn rate, exclusions, expiry, rounding  
3. Returns / voids → claw back points? already spent?  
4. Reward stacking; where redemption happens  
5. Referral $: beautician earn + customer discount + hold window + min basket  
6. Beautician: same points wallet vs payout report only  
7. How customer discount is applied at the register  
8. Which locations are in the program (extra CSV names)  
9. Pilot store; reconcile sign-off; TapMango delta export  
10. App store accounts + privacy policy  
11. Account ownership / billing  

## Decide together (you propose, PM picks)

1. Tablet auth UX (speed vs control)  
2. Dual-tablet: one app vs two  
3. Referral anti-abuse strictness for v1  
4. Beautician currency model (once you explain ledger vs payout)  
5. “Good enough” sale↔phone matching behavior  

---

## What to put on the next PM agenda (only their column)

1. Earn / return / exclusion rules (or “same as TapMango” + exceptions)  
2. Corrections & payout approvals — which role  
3. Referral economics + discount delivery at POS  
4. Beautician: points vs payout report  
5. Locations in scope  
6. Pilot store + data sign-off process  
7. Accounts: Twilio, Apple, Google, Supabase billing  

Everything else you can decide async and inform them.
