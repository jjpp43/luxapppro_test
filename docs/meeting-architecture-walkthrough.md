# Kickoff meeting — architecture & schema walkthrough

**Audience:** Client PM, lead (you), junior (Expo)  
**Goal:** Align on *why* this stack and schema before build starts  
**Length:** ~30–40 min talk track

---

## Suggested agenda

| Time | Topic | Who cares most |
|---|---|---|
| 5 min | Problem we’re solving | PM |
| 10 min | Architecture — what talks to what, and why | PM + junior |
| 10 min | Schema — five groups, ledger, referrals | PM + junior |
| 5 min | Who builds what | Junior + you |
| 5–10 min | Open decisions we still need from the business | PM |

---

## 1. Open with the problem (PM language)

We’re replacing **TapMango** with a system the client **owns**:

- ~**200k** customers migrate with their points  
- **~4** Las Vegas stores  
- Keep **Lightspeed** as the cash register  
- Add a **beautician referral** channel TapMango doesn’t do well  
- Three surfaces: **admin**, **customer/partner app**, **counter tablets**

**Success frame:** store keeps selling even if loyalty wobbles; nobody loses points on cutover; staff can explain a balance dispute.

---

## 2. Architecture — why this shape

### Picture to draw on the whiteboard

```
Admin (Next.js)  ─┐
Customer app     ─┼─→  Supabase (Postgres + Auth + RLS)
Tablet (Expo)    ─┘         ↑
                            │
Lightspeed X ──webhook──→ Worker (Fly/Railway)
TapMango CSV ──import──→ Supabase (one-time)
```

### Talking points (say these out loud)

**1. Supabase is the main backend — on purpose**  
We are a small team. We do not want to build and maintain a custom API for login, CRUD, and permissions. Supabase gives us Postgres, phone OTP (identity is phone), and row-level security so the apps talk to the DB safely.

**2. Apps talk directly to Supabase**  
Admin, customer app, and tablet use the Supabase client + session. Authorization lives in the database (RLS), not in a big Node API. Sensitive actions (redeem, award) go through database functions, not “trust the phone.”

**3. The worker is small and specific**  
Lightspeed sends `sale.update` webhooks. Phones and Next.js should not receive those. A tiny always-on worker on Fly/Railway ingests sales and writes points. Also good for nightly reconcile. At &lt;10k tx/day this is cheap (~$5–10/mo).

**4. Lightspeed stays system of record for money**  
We never write sales into Lightspeed. We mirror sales we need for loyalty. If Lux Pro is down, **the register still works** — worst case points catch up later.

**5. Expo for all mobile**  
One TypeScript/React Native stack for iOS customer app, Android customer app, and Android tablets. Junior owns this surface; shared types/API patterns with the rest of the monorepo.

**6. Next.js for admin**  
Familiar web dashboard for owners/managers — TapMango-shaped, not a second mobile app.

**7. Resilience without over-engineering**  
Supabase Pro daily backups + our own nightly dump off-vendor. PITR waits until after pilot. We are not building multi-region failover for four stores.

### If PM asks “why not a normal backend?”

Because most of a normal backend would reimplement what Supabase already does (auth, CRUD, permissions). We only custom-build the part vendors don’t cover well: **Lightspeed ingest + scheduled reconcile**. Less code → fewer bugs → faster with one lead + one junior.

### If junior asks “do I call the worker from the app?”

**No.** Expo apps → Supabase only. Worker is inbound from Lightspeed (and cron).

---

## 3. Schema — why it looks like this

### Five groups (easy to remember)

| Group | Tables | One-liner for the room |
|---|---|---|
| **Organization** | stores, staff | Where it happens; who can fix points |
| **Customers** | customers | Phone = identity; names optional |
| **Commerce** | sales | Lightspeed sales we ingested |
| **Loyalty** | rewards, points_ledger, redemptions | What points mean and how they move |
| **Referrals** | partners, referrals, tokens | Beautician program |

### The three ideas to defend

**A. Phone is the primary identity**  
Matches TapMango, counter signup (phone only), and Lightspeed matching. `name` is optional on purpose.

**B. Points live in a ledger, not a single balance field**  
`points_ledger` is append-only history (`+50` earn, `-100` redeem, corrections). Balance = sum of rows.  
**Why PM cares:** disputes and “who changed this?” are answerable; mistakes are fixed by adding a correction, not silently editing the past. Points are money the business owes customers.

**C. Referrals are events on visits, not a one-time flag on the customer**  
Beauticians influence repeat purchases. Same customer can be referred many times. QR tokens are short-lived and single-use to reduce screenshot abuse. Cross-check/anti-abuse design is still open — say that honestly.

### Import story (one sentence)

TapMango CSV → each customer gets a row + one ledger row (`migration_opening`) with their current points. History before cutover does not exist in the export.

---

## 4. Who builds what

| Area | Owner |
|---|---|
| Expo customer app + tablet UX | **Junior** |
| Supabase schema, RLS, RPCs, migrations | **Lead** |
| Next.js admin | **Lead** |
| Lightspeed worker + reconcile | **Lead** |
| TapMango import / cutover | **Lead** (junior can help with tooling/QA) |
| Shared types / API client conventions | **Lead** sets; junior consumes |

**Junior takeaway:** you build against Supabase like a backend that already exists; you don’t invent a second API. Ask before writing anything that changes balances on the client.

---

## 5. Ask the PM (do not leave without owners)

High priority:

1. Earn rules — points per $, exclusions, expiry  
2. Returns/voids — claw back points?  
3. How tablet phone ties to a Lightspeed sale  
4. Referral economics + what “cross-check” must mean for v1  
5. Beautician credit = same points currency or separate payout?

Medium:

6. Extra CSV locations (Hairway / Hollywood) — in program?  
7. Dual tablet = one Expo app two modes vs two apps  
8. Admin “basic TapMango” — which screens are must-have for pilot?

Already decided (confirm verbally):

- Stack: Supabase + Next + Expo + worker  
- Lightspeed X webhooks for auto-earn  
- Ledger for points  
- PITR after pilot  

---

## One-liner closers

**Architecture:** Small team, owned data, register never blocked — Supabase for apps, tiny worker for Lightspeed.  
**Schema:** Phone identity, append-only points history, referrals as visit events — easy to explain and easy to fix.
