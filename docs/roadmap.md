# Roadmap and working notes

**Updated:** 2026-08-20  
**Purpose:** Snapshot of progress, decisions from build conversations, and the remaining work. Complements [`pre-build-decisions.md`](./pre-build-decisions.md), [`auth-wiring.md`](./auth-wiring.md), and [`rls-matrix.md`](./rls-matrix.md).

---

## Where we are

Staging project `luxproapp_test` (`lgesaomtqisfvzcllusy`, us-west-2). Admin: `apps/admin` on Vercel.

| Area | Status |
|---|---|
| Architecture / schema / RLS matrix docs | Done (RLS SQL not written — hold until auth wiring agreed) |
| TapMango import | Done — 196,493 customers, 180,453 opening ledger rows, 97 quarantined |
| Admin shell (TapMango IA) | Done — many nav items still stubs |
| Dashboard health snapshot | Live from `registered_at` / TapMango `last_seen_at` |
| Business Pulse | Four-card TapMango layout; **Total Customers** live; Engaged / spend / visit rate waiting |
| Location Performance | Counts live; Decatur spend/frequency when sales exist; other stores — |
| Lightspeed Decatur | Mapped: `luxbeauty4` → outlet Main Outlet → **Lux Beauty Supply - Decatur** |
| Decatur sales | Closed sales **2026-05-22 → 2026-08-19** (~15,890 in that window). Older Mar–Jun 2025 slice also in `sales` |
| Customer match | Partial — phone match LS → Lux; most tickets still WALKIN |
| Earn / redeem / worker / Auth / RLS / Expo | Not started |

Scripts: `scripts/import_lightspeed_sales.py`, `scripts/match_lightspeed_customers.py`.

---

## Locked (do not re-open unless PM changes it)

- Stack: Supabase + Next admin + Expo + worker; apps talk to Supabase; worker for Lightspeed webhooks
- Points ledger; balance = sum(delta); ledger writes RPC-only
- Earn: 1 pt per $1 (`floor`); no expiry unless PM later
- Rewards: 250 pts = $10 off; 500 pts = $25 off
- Phone = identity (E.164); signup is phone-only
- RLS matrix locked; tablet = device session + staff PIN for redeem/correct
- Corrections: cashier + manager + owner (staff identity, not bare device)
- PITR after pilot
- Personal token for Decatur (read-only GET by convention)

### TapMango pulse math (for when visit cards go live)

- **Engaged** = unique customers who visited in the window (loyalty-identified, not anonymous WALKIN)
- **Avg spend** = total $ ÷ all those visits
- **Monthly visit rate** = visits ÷ **engaged** ÷ months (not visits ÷ all enrolled)

### Business Pulse (2026-08-20)

- Visual matches TapMango (four colored cards, 90 days vs prior 90, sparklines)
- **Total Customers** is chain-wide from the TapMango import (no other POS needed)
- Engaged / Avg spend / Visit rate stay empty until **other stores’ Lightspeed** is connected (chain-wide numbers). Do not mix 196k enrolled with Decatur-only tickets

### Other stores’ POS — what it is and isn’t for

**Not required for:** Total Customers; health segments (New / Active / Lapsing / At-Risk / Inactive) using TapMango `last_seen_at`; custom groups feature; auth/RLS; rewards/redeem; Decatur earn; tablet/customer apps.

**Required for:** Chain-wide Engaged / spend / visit rate; Location Performance spend/frequency for Craig, East Twain, West Sahara (and Hairway / Hollywood if in program); POS-based `last_seen_at` for shoppers who never visit Decatur.

Health “last visit” stays on TapMango check-in until we backfill `last_seen_at` from Lightspeed.

---

## Discussed, not locked

**Phone OTP / Twilio**  
Skip SMS at the **counter** (wrong number = customer/staff fault). **Customer app login** without OTP means anyone who types a phone can open that account. Options: OTP on the app only; PIN/password at enrol; or no app login until later. Not decided.

**WALKIN (~most Decatur tickets)**  
Need tablet phone + time window / cashier attach. Behavior = “good enough” with PM.

**Hairway 2 Heaven / Hollywood Beauty**  
In the loyalty program or ignore? PM.

---

## Suggested build order

1. PM packet: exclusions, returns, locations in scope, other store logins, tablet PIN, match window, pilot store  
2. Auth wiring agreed → leftover tables + RLS helpers (no junior writes until then)  
3. Groups screen + customers `?health=` filter (no other POS)  
4. WALKIN match + `last_seen_at` from Decatur sales + earn worker on matched Decatur sales  
5. Redeem + two rewards + staff/tablet  
6. Cutover: TapMango delta, per-store reconcile, ~5-day single-store pilot  
7. Other stores’ Lightspeed → chain pulse + remaining location rows  
8. Referral economics, campaigns/SMS, PITR — after the above

**Unblocked without other stores:** schema leftovers, auth/RLS, Decatur match/earn/webhook, rewards/redeem, admin Groups/Users/ledger/POS list, Expo apps, ops (backups, Sentry, runbooks).

---

## Full task list

**Owner key:** You = developer · PM / client = they decide or do · Both = you propose, they pick

| ID | Area | Task | Status | Owner |
|---|---|---|---|---|
| D.1 | Decided | Stack: Supabase + Next admin + Expo + worker | Done | — |
| D.2 | Decided | Points ledger; balance = sum(delta) | Done | — |
| D.3 | Decided | Earn: 1 pt per $1 (floor); no expiry unless PM later | Done | — |
| D.4 | Decided | Rewards: 250 pts = $10 off; 500 pts = $25 off | Done | — |
| D.5 | Decided | Phone-only signup; phone = E.164 identity | Done | — |
| D.6 | Decided | RLS matrix locked; ledger RPC-only | Done | — |
| D.7 | Decided | Corrections: cashier + manager + owner (staff identity) | Done | — |
| D.8 | Decided | Tablet: device session + staff PIN for redeem/correct | Done | — |
| D.9 | Decided | PITR after pilot | Done | — |
| 0.1 | Foundation | Architecture, schema, RLS, auth-wiring docs | Done | You |
| 0.2 | Foundation | Staging Supabase (luxproapp_test) | Done | You |
| 0.3 | Foundation | Core tables: stores, customers, points_ledger, sales | Done | You |
| 0.4 | Foundation | TapMango import (~196k customers, ~180k opening ledger, 97 quarantined) | Done | You |
| 0.5 | Foundation | Admin shell + customers list/detail + dashboard (partial live data) | Done | You |
| 0.6 | Foundation | Remaining v1 tables: staff, devices, rewards, redemptions, referral_partners, referrals | Not started | You |
| 0.7 | Foundation | customer_balance view; ledger append-only trigger; earn idempotency_key | Not started | You |
| 0.8 | Foundation | customers.auth_user_id; staff.auth_user_id | Not started | You |
| 0.9 | Foundation | Remove staging anon SELECT/UPDATE policies before real users | Not started (blocked by 2.x) | You |
| 1.1 | PM rules | Earn exclusions: tax, gift cards, other line types — or “same as TapMango” | Open | PM |
| 1.2 | PM rules | Returns/voids/layby: claw back points? What if already redeemed? | Open | PM |
| 1.3 | PM rules | Reward stacking; redeem counter-only vs in-app | Open | PM |
| 1.4 | PM rules | How $10/$25 off is applied at register (Lightspeed write vs cashier vs loyalty-only) | Open | PM (You flag write-path cost) |
| 1.5 | PM rules | Hairway 2 Heaven + Hollywood Beauty in program or ignore? | Open | PM |
| 1.6 | PM rules | Pilot store + go/no-go + ~5-day window | Open | PM |
| 1.7 | PM rules | TapMango delta export near switch weekend | Open | PM / client |
| 1.8 | PM rules | Sign off per-store reconcile before cutover | Open | PM / client |
| 1.9 | PM rules | Referral economics (beautician $, customer discount, min basket, hold, cooling-off, last-touch) | Deferred | PM |
| 1.10 | PM rules | Beautician: same points wallet vs payout report only | Deferred | Both |
| 1.11 | PM rules | Referral anti-abuse for v1 | Deferred | Both |
| 1.12 | PM rules | Confirm tablet device + PIN at the counter | Open | Both |
| 1.13 | PM rules | Dual tablet: one app / two modes vs two apps | Open | Both |
| 1.14 | PM rules | “Good enough” WALKIN / phone-to-sale match | Open | Both |
| 1.15 | PM rules | Customer app: OTP vs PIN vs no app login (see Discussed) | Open | Both |
| 2.1 | Auth | Agree auth-wiring.md | Not started | Both |
| 2.2 | Auth | Customer phone OTP ↔ customers (if 1.15 says OTP) | Not started | You |
| 2.3 | Auth | Admin email/password ↔ staff; owner invites; no self-escalate | Not started | You |
| 2.4 | Auth | Partner mode: same Auth user + referral_partners | Not started | You |
| 2.5 | Auth | Device provisioning | Not started | You (PM confirms ops) |
| 2.6 | Auth | Tablet elevate: PIN / staff login for redeem + correct | Not started | You |
| 2.7 | Auth | RLS helpers | Not started | You |
| 2.8 | Auth | Real RLS + revoke ledger writes from clients | Not started | You |
| 2.9 | Auth | RPCs: enrol, redeem, correct_balance, award | Not started | You |
| 2.10 | Auth | Policy tests (allow + deny) | Not started | You |
| 2.11 | Auth | Twilio A2P in client’s name (only if app OTP) | Open | PM / client |
| 2.12 | Auth | Apple + Play + privacy policy in client’s name | Not started | PM / client |
| 2.13 | Auth | Phone merge procedure | Not started | You |
| 2.14 | Auth | Never ship service_role to admin or Expo | Ongoing | You |
| 2.15 | Auth | Hold: no junior Supabase writes / no prod RLS SQL until 2.1 | Ongoing | You |
| 3.1 | Lightspeed | Decatur mapped (luxbeauty4 → Main Outlet) | Done | You + client |
| 3.2 | Lightspeed | Sales import script (date search + upsert) | Done | You |
| 3.3 | Lightspeed | Decatur last 30 days (through 2026-08-16) | Done | You |
| 3.4 | Lightspeed | Decatur 90 days (2026-05-22 → 2026-08-19) | Done | You |
| 3.5 | Lightspeed | Phone match LS customer → Lux | Partial | You |
| 3.6 | Lightspeed | Keep 30/90-day import current (cron or webhooks) | Not started | You |
| 3.7 | Lightspeed | Tokens for Craig, East Twain, West Sahara | Not started | PM / client; You map |
| 3.8 | Lightspeed | Hairway / Hollywood if 1.5 says in | Blocked on 1.5 | You after PM |
| 3.9 | Lightspeed | Personal token vs OAuth app for production | Open | You recommend; client credentials |
| 3.10 | Lightspeed | Worker: HTTPS, sale.update, signature, persist raw, upsert sale id | Not started | You |
| 3.11 | Lightspeed | Host worker (Fly vs Railway, US West) | Not started | You pick; PM account |
| 3.12 | Lightspeed | Which sale states earn | Not started | You (from 1.2) |
| 3.13 | Lightspeed | WALKIN attribution (tablet phone + window) | Not started | You (from 1.14) |
| 3.14 | Lightspeed | Cashier-entered total as degraded fallback | Not started | You |
| 3.15 | Lightspeed | Update last_seen_at from matched sales | Not started | You |
| 3.16 | Lightspeed | Enable webhooks on retailer | Not started | PM / client |
| 4.1 | Loyalty | eligible_cents from 1.1 (until then = sale total) | Not started | You |
| 4.2 | Loyalty | Earn ledger row, idempotent on sale | Not started | You |
| 4.3 | Loyalty | Seed two discount rewards | Not started | You |
| 4.4 | Loyalty | Redeem RPC + redemptions | Not started | You |
| 4.5 | Loyalty | correct_balance | Not started | You |
| 4.6 | Loyalty | Return clawback | Blocked on 1.2 | You |
| 4.7 | Loyalty | Admin rewards + ledger screens | Not started | You |
| 4.8 | Loyalty | Admin POS transactions from sales | Not started | You |
| 5.1 | Admin | Health snapshot + Decatur location spend/frequency | Partial | You |
| 5.2 | Admin | Business Pulse Total Customers | Done | You |
| 5.3 | Admin | Business Pulse Engaged / spend / visit rate (chain) | Waiting on 3.7 | You |
| 5.4 | Admin | Groups page: health segments + See Customers filter | Not started | You |
| 5.5 | Admin | Users UI wired to staff | Stub | You |
| 5.6 | Admin | Devices admin | Stub | You |
| 5.7 | Admin | Stores mapping UI | Read-only | You |
| 5.8 | Admin | Campaigns / SMS / memberships / branding / reports | Out of v1 unless PM wants | You if asked |
| 5.9 | Admin | Real admin login (after 2.3) | Not started | You |
| 6.1 | Apps | Monorepo: customer, tablet, worker, shared client, CI | Not started | You |
| 6.2 | Apps | Customer app | Not started | You (junior after 2.1) |
| 6.3 | Apps | Tablet: lookup, enrol, attach sale, redeem, correct | Not started | You |
| 6.4 | Apps | Dual-mode vs two tablet apps | Blocked on 1.13 | You |
| 6.5 | Apps | Store submit | Not started | PM accounts; You submit |
| 6.6 | Apps | MDM / kiosk after TapMango hardware | Later | Both |
| 7.1 | Referrals | Schema + QR / manual capture | Not started | You |
| 7.2 | Referrals | Token TTL / single-use | Not started | You |
| 7.3 | Referrals | Admin placeholders until 1.9–1.11 | Not started | You |
| 7.4 | Referrals | Payouts / discount delivery / anti-abuse | Deferred | PM then You |
| 8.1 | Ops | Vercel admin US West | Staging deployed | You; client billing later |
| 8.2 | Ops | Production Supabase + secrets | Not started | You; PM billing |
| 8.3 | Ops | Pro daily backups | Not started | You; PM budget |
| 8.4 | Ops | Nightly off-vendor pg_dump | Not started | You; PM owns bucket |
| 8.5 | Ops | Restore drill before go-live | Not started | You |
| 8.6 | Ops | Tablet degraded mode + manual award runbook | Not started | You write; PM trains |
| 8.7 | Ops | Sentry | Not started | You; PM account |
| 8.8 | Ops | Per-store reconcile | Not started | You report; PM signs |
| 8.9 | Ops | Pilot ~5 days; rollback = TapMango tablets | Not started | PM; You support |
| 8.10 | Ops | Remove staging shortcuts; LS ↔ sales ↔ ledger reconcile | Not started | You |
| 8.11 | Ops | PITR add-on | After pilot | PM; You enable |

---

## Related docs

- [`background.md`](./background.md) — client and product intent  
- [`pre-build-decisions.md`](./pre-build-decisions.md) — owners and open PM questions  
- [`rls-matrix.md`](./rls-matrix.md) — locked permissions  
- [`auth-wiring.md`](./auth-wiring.md) — next gate before policy SQL  
- [`staging-sample.md`](./staging-sample.md) — import counts  
- [`schema-explained.md`](./schema-explained.md) — tables  
