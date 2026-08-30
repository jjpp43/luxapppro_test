# Referral sidecar + customer app

**Updated:** 2026-08-30  
**Status:** Product locked for closed beta. App scaffold started (`apps/customer`). Not wired to Supabase. Live loyalty earn stays **off**.

This is the write-up of the Aug 2026 pivot. Do not treat TapMango cutover, tablet, or dashboard as the current build target unless PM reopens them.

Elevator: **Beauticians send clients a shopping list by QR. The client gets 5% off those products at Lightspeed. The beautician gets 5% store credit. TapMango and the register stay as they are.**

---

## What this is (and is not)

**Is:** a closed-beta **sidecar** next to TapMango (old points) and Lightspeed (register). One Expo app. Owner adds a few beauticians by hand. Decatur only.

**Is not:** replacing TapMango, turning on live earn, a second loyalty wallet as the customer reward, a whole-basket discount, cash payouts to beauticians, or a throwaway “referrals-only” app.

Dashboard and counter tablet stay paused. Loyalty earn flags stay false. Do not write Lightspeed **sales**. Fly worker stays undeployed until the client has a Fly org.

---

## Locked product rules

| Piece | Rule |
|---|---|
| Customer reward | **5% off listed products** at Lightspeed (not TapMango points). Number can change later. |
| Beautician reward | **5% of what was actually bought from the list**, as **store credit** (dollars), spent when they shop at Lux. Not the 1-pt-per-$1 shopper pile. Not % of the whole basket. |
| Min purchase | Whole ticket **≥ $20**, and they must buy at least one listed product. 5% is only on listed SKUs. |
| List / QR | Beautician builds a **cart of items**, then **one QR for the whole list**. Not one QR per product. |
| Partial buy | Buying 1 of 3 listed items is fine. 5% (and commission) only on what they bought from the list. |
| Quantity | If a SKU is on the list, **every unit** of that SKU on the ticket gets 5%. List qty is a suggestion, not a cap. |
| Extra items | Not on the list → full price. |
| Buy window | **3 days** after the customer **claims** the list. |
| QR lifetime | Scan token should expire in **minutes** so a screenshot cannot live forever. 3 days is the buy window, not the QR TTL. |
| Store | **Decatur only** for catalog and live path. |
| Partners | Owner adds phones in **admin**. No self-serve “I am a beautician.” |
| Login | Phone OTP. Closed beta: **fake code `000000`**. No Twilio until the client has an account. |
| Role after OTP | Always **customer**. If `referral_partners` has that phone, Account can show **Beautician tools** on/off. Do not ask at OTP. |
| Returns / voids | **No merit for anyone.** Claw back customer discount benefit and beautician credit. |
| Register | Cashier applies a **Lightspeed promo code** (type or scan from the app). The phone cannot reach into the open cart. |
| Promo automation | Create a one-use Lightspeed promotion/code via **Promotions API** when they claim. `POST /discount` is a calculator only — it does not change a live sale. Confirm the store plan includes promo codes (usually Pro / Advanced). Fallback: cashier keys 5% on those lines. |
| Repeat | One QR = one cart = one 3-day claim. A **new list later is a new QR**. Overlap with a previous list after the window ends is **not fully locked** — tighten if people game it. |
| Self-referral | Blocked (partner `customer_id` unique / same phone). |

**Beautician credit scale:** 5% of a $40 SKU is **$2** store credit, not 2 loyalty points.

---

## How a referral runs

1. Owner adds the beautician (phone) in admin.  
2. Beautician signs in (same app), turns on Beautician tools, sees **Decatur catalog**, builds a list, shows **one QR**.  
3. Customer installs if needed, **fake OTP**, scans, **claims** the list.  
4. App shows eligible products, 5% / $20 min / time left, **promo code or barcode**.  
5. At Lightspeed they buy whatever they want. Listed SKUs get 5%. Ticket must be ≥ $20.  
6. Worker matches **line items** on the closed sale to the list. Beautician credit = 5% of those lines.  
7. Return/void → claw both sides.

---

## App (Expo)

Path: `apps/customer`. EAS project `b7dad647-e507-4987-a4b0-05104c8dc1ed`, owner `jpark_dev`. One repo (`luxapppro_test`). One design for iOS and Android.

**Stay on Expo** (not Flutter/Swift). iPhone pain was **Expo Go** (App Store stuck on SDK 54; this app is SDK 57). Develop in the **simulator** or a **development build**. Do not switch stacks for Expo Go.

**Local:** `cd apps/customer && npx expo start`. EAS is for installable binaries / TestFlight later, not day-to-day JS. GitHub connected to Expo ≠ a development build exists.

**Forced light mode.** Outer padding uses device safe area (island / no island / Android nav) plus a 12pt rest and 20pt sides. Tab screens do not double-count the home indicator (tab bar owns bottom inset).

### Screens (closed beta)

| Screen | Job |
|---|---|
| Phone | 10-digit US number |
| OTP | Fake `000000` |
| Home | Point balance (stub `0` until Supabase), **Scan QR**, empty state or **active deal** (code, 5%, $20, days left, product list) |
| Scan | Camera on device; **Load a sample referral** until real tokens exist |
| Account | Phone, sign out. Beautician toggle later, only if partner |

No $10/$25 catalog in this app yet (stays TapMango). No partner catalog UI yet.

**Points on Home:** Lux ledger, not TapMango. Earn is off. Referral does **not** add shopper points. Caption must say that. Redeem still TapMango until we build it here.

Session today is **in memory** (reload signs out).

---

## Architecture

```
Expo app  →  Supabase (Auth, RLS, catalog copy, referrals, credits)
Admin     →  Supabase
Worker    →  Lightspeed (sales poll, later product/stock sync, later promo create)
          →  Supabase service role
```

**Never put the Lightspeed token in the app.** Inventory is a **copy** in Postgres. Do not hit Lightspeed on every catalog open.

**Catalog refresh (worker, not a new server):**

| What | How often |
|---|---|
| Names, prices, barcodes, photos | Every 1–6 hours (or overnight + midday) |
| On-hand stock | Every **15 minutes** while open (drop to 5 if they complain) |
| Closed / overnight | Hourly or pause |

Start stock at **15 minutes** (same idea as the sales poller). Full catalog every minute is waste.

**Need in DB (not built):** product catalog; **line items** on sales (today we slim `raw` and skip lines because they blew upsert timeouts); cart-level referral token (SKU set, not one product); beautician **credit** ledger; claim/consume RPCs.

**Lightspeed Promotions API** can target `product_id`, attach one-use codes, set an end time. One sale can take **one** promo code (Lightspeed limit). Writing **promotions** is a narrow exception; we still do not write tickets.

---

## OTP cost (US SMS, planning)

Send SMS ourselves (Twilio Programmable Messaging or similar). **Do not use Twilio Verify** (~5¢/check).

Budget **~1–2¢ per text** including carrier fees.

| Volume (one-time codes) | SMS (plan) | Twilio Verify (avoid) |
|---|---|---|
| 10,000 | **~$150** ($100–$200) | ~$500 |
| 50,000 | **~$750** ($500–$1,000) | ~$2,500 |

Plus A2P 10DLC: tens of dollars up front, ~$10/month. Closed beta SMS cost is negligible. Keep sessions so people are not OTPing every visit. Client Twilio + A2P when going live.

---

## Still open / later

- Same customer, **new list** that overlaps SKUs after the first 3-day window  
- Confirm Lightspeed **promo codes** on their plan  
- Twilio account, Apple/Play, Fly org (client)  
- Wire Home points to the real ledger  
- Partner catalog + real QR tokens  
- Beautician redeem-credit at checkout  
- Store earn flags / Fly deploy / TapMango cutover — **not this slice**

---

## Related

- Loyalty earn / WALKIN / QA Lab: [`roadmap.md`](./roadmap.md), [`qa-lab.md`](./qa-lab.md)  
- Stack / RLS: [`architecture.md`](./architecture.md), [`rls-matrix.md`](./rls-matrix.md), [`auth-wiring.md`](./auth-wiring.md)  
- Older PM packet (partially superseded on referrals): [`pre-build-decisions.md`](./pre-build-decisions.md) § referrals still said “later”
