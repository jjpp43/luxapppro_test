# Lux Pro — Background

**Updated:** 2026-08-10

## Client

Owner of a beauty supply retail business in Las Vegas. Roughly **four stores** in the city.

Today they run customer rewards on **TapMango**. Counter tablets are TapMango hardware. They want to leave TapMango and run an equivalent system they own — TapMango-shaped, built for their stores.

They have about **200,000 customers** on TapMango. Those accounts need to come with them.

## What we are building

Three surfaces:

| Surface | Platform | Role |
|---|---|---|
| **Admin dashboard** | Next.js (web) | Owner/manager ops — basic TapMango-style features |
| **Customer app** | iOS + Android | Customers and the beautician referral flow |
| **Tablet app** | Android | Counter: cashier tablet + customer-facing tablet |

### Counter setup

Two tablets at the cashier:

- **Customer tablet** — new customers sign up with **phone number only** (no name)
- **Cashier tablet** — staff side of the counter flow (details TBD with architecture)

### Beautician / salon referrals

Beauticians and hair salons have strong influence over what customers buy. The program should:

1. Credit the **beautician** with points when a referred customer visits the store
2. Give the **customer** a discount
3. Grow traffic for the stores

Win for customer, beautician, and store. A **cross-checking / anti-abuse system** for referrals is still an open design problem. Referral participation lives in the **customer app**.

## Open / next

- Living roadmap and task list: [`roadmap.md`](./roadmap.md)
- Architecture direction drafted in `architecture.md` (Supabase, Next.js, Expo, Fly/Railway worker)
- Auth wiring before RLS SQL (`auth-wiring.md`)
- Referral verification / cross-check design (economics deferred)
- Full TapMango feature parity vs “basic” admin scope
- Lightspeed accounts for stores other than Decatur
- Tablet hardware after leaving TapMango
