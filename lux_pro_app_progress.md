# Lux Pro — ship progress

**Updated:** 2026-10-02

**Ship** means the Decatur closed-beta sidecar: list QR → 5% at Lightspeed → beautician store credit. Not TapMango replacement, not live earn, not tablets.

OTP stays **phone + `000000`** until the client has a paid SMS account (Twilio or similar). There is no free US text-OTP. Do not use Twilio Verify.

---

## Already done

- Product rules locked (5%, $20 min, 3-day window, Decatur, shareable codes, self-referral blocked)
- Admin + schema + TapMango import + Decatur sale **headers** on staging
- Expo demo loop on this laptop (phone, `000000`, catalog, list, QR, claim). **Not committed.** Earn stays off.

---

## A. Client can see it

- [x] Commit and push the demo (otherwise a clone is the old scaffold only)
- [ ] EAS **preview** on 1–2 phones (not Expo Go). Android first; iOS needs Apple account + UDID
- [ ] PM runs the 5-minute script (`docs/demo-for-pm.md`) and gets a yes/no on the loop
- [ ] Confirm: cashier types a code vs keys 5%; who the first 3–5 beauticians are

---

## B. Live at Decatur

### Identity

- [ ] Wire phone OTP to Supabase Auth (keep `000000` until they have Twilio)
- [ ] Link Auth user ↔ `customers` by phone. Session must survive reload
- [ ] Admin: owner sets password, adds beautician phones by hand. Tools only if `referral_partners` has that phone

### Catalog + claim

- [ ] Postgres catalog copy (worker refresh). App never talks to Lightspeed
- [ ] Shareable cart token (SKU set, no minutes TTL) + claim RPC (3 days, Decatur, many shoppers, block self-referral)
- [ ] Home deal + promo code come from the claim, not the sample

### Register / money

- [ ] Persist sale **line items** (ingest still strips them; no lines = no match)
- [ ] Worker: closed sale → listed SKUs bought → 5% off those lines + beautician **dollar** credit
- [ ] Return/void claws both sides
- [ ] Reusable Lightspeed promo **or** cashier keys 5% on listed lines (phone never writes the cart)
- [ ] How cashiers apply beautician credit at checkout (manual is enough for v1)

### Ops

- [ ] Deploy worker on Fly (client org, `sjc`, always-on). Do not ship money-path matching on a laptop cron
- [ ] Store Apple / Play / privacy policy in **their** name
- [ ] Twilio + A2P only when leaving fake OTP

---

## Not this ship

Live earn, TapMango cutover, other stores, dashboard rebuild, counter tablets. Do not start those to “finish” the app.
