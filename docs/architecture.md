# Architecture — draft notes

**Updated:** 2026-08-21  
**Status:** Direction agreed; living task list is [`roadmap.md`](./roadmap.md)

## Proposed stack

| Piece | Choice | Notes |
|---|---|---|
| Database / auth | **Supabase** (Postgres) | Migrate ~200k TapMango customers here. Phone OTP, RLS, realtime |
| Admin dashboard | **Next.js** | TapMango-style owner/manager UI |
| Customer app + tablet | **Expo** (React Native) | iOS + Android customer app; Android tablet(s) at the counter |
| Transaction ingestion | **Worker on Fly.io** (San Jose) | Lightspeed poll now; `sale.update` webhooks later → Supabase |

**Volume assumption:** &lt; ~10k transactions / day across ~4 stores.

---

## Assessment

### Supabase — yes

Right fit for this project:

- Plain Postgres, so the TapMango CSV import is a normal data load, not a proprietary migration
- Phone OTP is built in (identity key for signup and counter lookup)
- Row-level security keeps customer app reads scoped without a custom API layer for CRUD
- Realtime can push balance updates to tablets after a sale lands

Watch-outs (not blockers):

- Put the project in a **US West** region (stores are Las Vegas)
- Own a nightly `pg_dump` into storage the client controls — vendor backups do not survive account loss
- All Supabase / infra accounts billed to and owned by the client

### Next.js admin — yes

Standard choice. Deploy on Vercel (or similar) and pin server work to the **same region as Supabase** so admin pages are not cross-country round-tripping to the DB.

### Expo for customer + tablet — yes

One TypeScript codebase for:

- Customer app (iOS + Android)
- Tablet app (Android) — cashier and/or customer-facing counter tablets

That is a real advantage with one small team. Tablet will need kiosk / MDM thinking later (TapMango owns the current hardware); Expo does not remove that, but it does not fight it either.

### Worker on Fly.io — yes, at this volume

Lightspeed should stay the system of record for **sales**. Lux Pro should **ingest** completed sales (webhooks or polling) and turn them into points / referral qualification. That inbound path does not belong in the Next.js app or on a phone.

&lt;10k transactions/day is small (~7/min average; short peaks still trivial). A **single small always-on container** is enough.

Why not only Supabase Edge Functions?

- Fine for a thin webhook receiver
- Weaker for longer nightly jobs (reconciliation, gap detection) as data grows — containers have no awkward execution-time ceiling for the same few dollars

**Picked Fly.io** (not Railway). We are not chasing extra knobs for their own sake. We need four settings Railway would hide or default badly:

1. **Does not sleep on idle** — `auto_stop_machines = "off"` and `min_machines_running = 1`. A sleeping worker drops Lightspeed webhooks; dropped webhook = sale with no points
2. **Pin US West** — `primary_region = "sjc"` (San Jose), next to Supabase `us-west-2`
3. Hold the **service-role key** only in Fly secrets — never in Expo or the browser
4. One small always-on VM (~$3–6/month), not a serverless function

Admin stays on **Vercel**. Postgres stays on **Supabase**. Do not move either onto Fly.

---

## Suggested shape (C4-ish)

```
Customer app (Expo) ─┐
Tablet app (Expo)   ─┼─→ Supabase (Postgres, Auth, RLS, Realtime)
Admin (Next.js)     ─┘         ↑
                               │ service role
Lightspeed ──webhook──→ Worker (Fly.io, sjc)
TapMango CSV ──one-time import (local script)──→ Supabase
```

**Boundary:** Lightspeed owns money/sales. Supabase owns customers, points, referrals. Neither writes into the other’s domain of truth.

---

## What counts as “the server”?

There is **no custom monolith API** in front of the database for normal app traffic.

| Role | What it is | Who talks to it |
|---|---|---|
| **Primary backend** | **Supabase** — Postgres + Auth + RLS (+ Realtime, Postgres functions/RPCs) | Admin, customer app, tablet |
| **Secondary server** | **Worker** (Fly.io, sjc) — small, always-on | Lightspeed (and cron). Not called by the apps for everyday reads/writes |
| **Admin host** | **Next.js on Vercel** | Browsers. Mostly a UI; may use server components/actions, but it is not the loyalty API of record |

### Do the dashboard and apps talk directly to Supabase?

**Yes.** That is the intended design.

```
Admin (browser / Next)  ──Supabase JS client──→  Supabase
Customer app (Expo)     ──Supabase JS client──→  Supabase
Tablet (Expo)           ──Supabase JS client──→  Supabase

Lightspeed ──HTTPS webhook──→ Worker ──service role──→ Supabase
```

- Clients use the **anon/publishable key** + a **user/device session**
- **Row Level Security (RLS)** in Postgres is the authorization layer (customer sees only their rows; staff scoped by role/store)
- Sensitive money-like operations (e.g. redeem, award) should be **Postgres functions / RPCs** (or carefully gated server paths), not “trust the client’s math”
- The **service-role key** (bypasses RLS) lives **only** in the worker — never in Expo, never in browser bundles

### Why this shape

- Less code to own: Auth, CRUD, and realtime stay on Supabase
- Fits &lt;10k tx/day and a small team
- Worker exists only for what Supabase is awkward at: **inbound webhooks** and **scheduled jobs**

### What Next.js is *not*

The admin dashboard should not become a second backend that proxies every query “for safety” unless we later decide RLS is not enough. If we add Next.js Route Handlers / Server Actions, use them sparingly (e.g. secrets, admin-only reports), not as a duplicate API for the mobile apps.

### Practical rule

**Apps → Supabase directly. Lightspeed → Worker → Supabase. Nobody else is the server for loyalty data.**

**Short answer:** Resilient enough for a 4-store loyalty system *if* we treat “store keeps selling” as the hard requirement and “points arrive eventually” as recoverable. It is **not** highly available in the multi-region sense — and it does not need to be at this volume. There **are** single points of failure; most of them degrade points/app, not the cash register.

### What must never stop the business

Lightspeed is a **separate system**. If Lux Pro (Supabase, worker, tablets, admin) is down, cashiers can still ring sales. Worst case: missing or delayed points, fixed later by manual award or reconciliation — not lost trade.

That boundary is the main resilience property of this design.

### Single points of failure

| Component | SPOF? | If it dies | Blast radius | Severity |
|---|---|---|---|---|
| **Supabase (DB/Auth)** | Yes — one project/region | All apps lose live data; OTP login fails | Whole loyalty platform | High for points/app; register still sells |
| **Worker (one instance)** | Yes, as drawn | Automatic earn from Lightspeed stops | Points lag until catch-up | Medium — fix with idle-proof host + optional 2nd instance |
| **Lightspeed** | External SPOF we do not own | No sale webhooks / no POS | Store operations (out of our scope) | Critical for store; not ours to HA |
| **Store internet** | Per store | Tablet cannot reach Supabase | That store’s points UX | Medium — cellular backup is cheaper than offline write queues |
| **Twilio / phone OTP** | Yes for app login | Customer app cannot sign in | App only; counter phone entry still works | Low–medium |
| **Vercel (admin)** | Yes for dashboard | Managers cannot configure/report | Admin only; counter unaffected | Low |
| **Expo tablets** | Per device | That counter cannot look up / enrol | One station | Low if spare tablet exists |
| **Domain / billing card** | Yes if accounts lapse | Total outage | Everything | High — prevent with auto-renew + client-owned billing |

### What is *not* a SPOF for revenue

- Admin dashboard down → annoying, stores still sell
- Customer app down → referrals/push suffer; counter path can continue
- Worker down → sales still happen; points need replay/reconcile/manual award
- One tablet dies → other station / spare device

### Honest limits of this stack

1. **Supabase is the real SPOF.** One managed Postgres project in one region. Outages are usually short; **account suspension or data deletion is the catastrophe**. Mitigate with: PITR on Supabase, plus **nightly `pg_dump` to client-controlled storage**, plus client owns the billing account.
2. **A single worker is a SPOF for automatic points.** Cheap to soften: two small instances behind a load balancer (~+$5–10/mo), persist raw webhooks before processing, nightly reconcile against Lightspeed for gaps. Idempotent writes so double-delivery is safe.
3. **We are not designing multi-region failover.** Active-active across coasts would dominate cost and complexity for &lt;10k tx/day and four stores. Accept regional risk; optimize recovery (backups, manual award, clear offline messaging on tablets).
4. **“Eventually consistent points” is the model under failure.** Tablets should show stale balance as stale, refuse silent offline writes, and make recovery obvious — not pretend the system is partition-tolerant for earning/redeeming.

### Resilience posture (recommended defaults)

| Practice | Why |
|---|---|
| Register never depends on Lux Pro | Commercial floor |
| Worker always-on (no sleep) | Avoid silent dropped webhooks |
| Persist webhook payload, then process | Processing crash ≠ lost sale |
| Nightly Lightspeed vs Lux reconcile | Catches gaps without babysitting |
| Manual award in admin | Human recovery path when automation fails |
| Nightly dump off-vendor | Survives Supabase account loss |
| Cellular failover at counter (optional) | Beats building full offline sync for 4 stores |
| Spare tablet per store (optional) | Hardware SPOF is boring and real |

**Verdict:** Architecture is **appropriately resilient** for this business: sales stay up when loyalty wobbles; loyalty has clear, mostly cheap mitigations. The one failure class that is unrecoverable without preparation is **losing the Supabase account/data** — treat backups + client-owned billing as part of the architecture, not ops trivia.

---

## Supabase down / backup plan

**Plan choice:** Supabase **Pro** (listed at **$25/mo** as of writing — not $20; confirm on supabase.com/pricing). Includes **daily backups, 7-day retention**, restoreable from the dashboard *while Supabase itself is healthy*.

Pro daily backups are necessary but **not** a plan for “Supabase is down.” They answer a different question.

### Two different failures

| Failure | What you need | What Pro daily backups do |
|---|---|---|
| **A. Bad write / accidental delete / “restore to yesterday”** | Snapshot or PITR inside Supabase | Yes — restore in-dashboard (last 7 days) |
| **B. Supabase outage / account locked / region broken** | Stay operable somehow + copy of data **outside** Supabase | **No** — you cannot restore from their backup UI if the platform is the thing that is down |

Design for **A** and **B** separately.

### Layer 1 — Vendor backups (already on Pro)

- Daily automatic backups, 7 days
- Good for operator error and short “we need yesterday’s DB”
- **Gap:** up to ~24h of writes since last backup; restore only works when Supabase can serve you
- Optional later: **PITR** add-on (~$100/mo for 7-day window) — **decided: wait until after pilot**

### Layer 2 — Off-vendor copy (recommended even with Pro)

Nightly logical backup the **client owns**:

```
pg_dump (custom or plain) → Cloudflare R2 / Backblaze B2 / S3
  (client’s cloud account, separate from Supabase billing)
```

| Detail | Suggestion |
|---|---|
| Cadence | Nightly (Pacific off-peak), plus one run after any big migration |
| What to dump | Database (customers, ledger, referrals). Auth users need a documented path too — `pg_dump` of the DB is not always enough for “full Auth replay”; test restore includes “can a customer log in again?” |
| Retention | e.g. 14–30 daily + 1 monthly, cheap at this data size |
| Alert | Job failure pages someone — a silent failed backup is no backup |
| Cost | A few dollars/month storage + a tiny scheduled runner (GitHub Actions, or the existing worker cron) |

This is what survives **account suspension, billing failure, or “we are leaving Supabase.”** Pro’s own backups do not.

### Layer 3 — When Supabase is down (operations, not a hot standby)

For a 4-store loyalty app, **do not** build active-active Postgres failover in v1. Cost and complexity dwarf the benefit. Instead: **degrade cleanly**, then **restore**.

**During the outage (minutes–hours):**

| Surface | Behavior |
|---|---|
| Lightspeed | Keep selling — unchanged |
| Tablet | Show last-known balance stamped “as of …”; **no earn/redeem/signup writes** (or queue only if we later choose to — deferred). Message staff: points added after systems return |
| Customer app | Unavailable or read-only error state |
| Worker | Buffer or retry Lightspeed webhooks; do not drop silently |
| Admin | Manual award after recovery for any sale that missed points |

**After Supabase returns:**

1. Confirm DB healthy
2. Replay / reconcile Lightspeed sales vs ledger (nightly job or ad-hoc)
3. Manual award gaps from the outage window
4. If data was corrupted, restore from Pro backup or Layer 2 dump *before* replaying

**If Supabase is down for days or the project is gone:**

1. Provision new Postgres (new Supabase project)
2. Restore latest Layer 2 `pg_dump`
3. Repoint apps (env URLs/keys) — this is why a thin API client / config layer matters
4. Re-verify Auth / OTP (Twilio wiring)
5. Reconcile sales during the gap

**RTO/RPO to agree with the client (draft):**

| Target | Draft for v1 |
|---|---|
| **RPO** (how much data we may lose) | ≤ 24h from Layer 2 nightly dump; tighter only if PITR purchased |
| **RTO** (how fast loyalty is back) | Hours for restore-to-new-project (runbook + practiced once); during outage, **sales RTO = 0** because POS is independent |

Practice a restore to a throwaway project once before launch (week of cutover). An untested dump is a hope, not a plan.

### What we are explicitly not doing in v1

- Multi-region active-active Supabase
- Streaming replica promoted on outage (Supabase does not make this a Pro self-serve button)
- Dual-writing every transaction to a second live DB

Revisit only if outage history or contract SLA demands it.

### Recommended v1 package

1. **Pro daily backups** — keep (baseline)
2. **Nightly off-vendor `pg_dump`** — must-have
3. **Tablet degraded mode + manual award runbook** — must-have for “Supabase is down”
4. **One restore drill** before go-live — must-have
5. **PITR (~$100/mo)** — **deferred until after pilot.** Pro daily backups + off-vendor dump + degraded counter mode are enough for launch. Revisit if outage/restore experience or earn volume makes “lose up to a day” unacceptable.

---

## Open follow-ups

### Lightspeed — X-Series (confirmed)

Client is on **Lightspeed Retail (X-Series)**. That unblocks automatic earn:

- API/webhooks docs: [x-series-api.lightspeedhq.com](https://x-series-api.lightspeedhq.com/docs/webhooks)
- Relevant event: **`sale.update`** — fires when a sale is created or modified (usually once at payment; layby/account may fire more than once)
- Worker receives the webhook, upserts by Lightspeed sale id (idempotent), matches customer/store, writes `sale` + ledger earn
- Cashier-entered totals remain as **degraded/fallback** mode, not the primary path

Still to nail in integration design (not blockers for “can we webhook?”):

- OAuth / personal token setup for their retailer
- Which sale statuses count as “award points” (ignore voided / incomplete)
- Returns / refunds → claw back points or not (product decision)
- Matching tablet phone entry to the sale (timing window) vs relying on Lightspeed customer on the sale
- Multi-outlet: map X-Series outlet/register → our `store` rows (export already has 4 Lux locations + 2 others)

### Deferred — come back later

- Dual-tablet split: what runs on customer tablet vs cashier tablet in Expo (one app, two modes? two apps?)
- **Supabase PITR** — after pilot (Pro daily backups + off-vendor `pg_dump` for launch)
- Lightspeed edge cases: returns, voids, layby, refund point clawback
- How tablet attribution ties to an X-Series `sale.update` (match window vs customer on sale)

### Still open

- Referral cross-check / anti-abuse design
- How hard to push worker redundancy + webhook persistence in v1 vs after pilot
- Choose off-vendor backup target (R2 / B2 / S3) and who owns that cloud account
- Confirm Supabase Pro billing (~$25/mo)

### Decided

- **Worker host** — Fly.io in `sjc`, always-on, autostop off. Admin stays on Vercel. Postgres stays on Supabase.
- **Points ledger** — append-only history in Supabase; balance = sum(delta)
- **Lightspeed X-Series** — primary earn via `sale.update` webhooks; cashier-entered fallback secondary
- **PITR** — after pilot
- **RLS matrix** — locked in `docs/rls-matrix.md` (device tablet + staff elevate for redeem **and corrections**; cashier + manager + owner may correct; ledger RPC-only)
- **Earn / rewards (later, Lightspeed worker)** — 1 point per $1; 250 pts = $10 off; 500 pts = $25 off (`docs/pre-build-decisions.md` §3). Not a kickoff talking point.
