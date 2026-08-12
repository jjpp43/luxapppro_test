# Auth wiring

**Status:** Next up (RLS matrix locked — see [rls-matrix.md](./rls-matrix.md))  
**Updated:** 2026-08-12

**Hold until this doc is agreed**

- No RLS policy SQL  
- No junior Supabase **writes** from Expo (mocks/fixtures OK)

This doc scopes the auth discussion that follows RLS. Do not implement until the wiring design here is agreed.

---

## Goal

Make every RLS helper in `rls-matrix.md` return correct values for real sessions:

| Helper | Auth wiring must provide |
|---|---|
| `current_customer_id()` | Link `auth.uid()` → `customers.id` |
| `current_staff_id()` / `current_staff_role()` / `current_staff_store_id()` | Link `auth.uid()` → `staff` |
| `is_device()` / `device_store_id()` | Device-provisioned session → store |
| `is_partner()` / `current_partner_id()` | Customer with active `referral_partners` row |
| `is_manager_or_owner()` | Derived from staff role |

---

## Surfaces to design

### 1. Customer (Expo app)

- Phone OTP via Supabase Auth  
- On first login / enrol: ensure `customers` row exists and is linked to `auth.users`  
- Decide link shape: `customers.auth_user_id` (unique) vs separate profile table  

### 2. Partner mode

- Same Auth user as customer  
- Capability = active `referral_partners.customer_id`  
- App switches UI; RLS uses `is_partner()` — no second login  

### 3. Admin (Next.js)

- Email/password (or magic link) for `staff`  
- `staff.auth_user_id` + `role` (`cashier` \| `manager` \| `owner`)  
- Owner invites staff; staff cannot self-escalate role  

### 4. Tablet (Expo Android)

Per locked RLS forks:

| Mode | Session | Allowed |
|---|---|---|
| Baseline | **Device** session | Lookup, enrol, start-earn |
| Elevated | **Staff** (PIN unlock or staff login) | `redeem`; managers/owners also `correct_balance` |

Still to decide in this session:

- How devices are provisioned (one-time admin code? device table?)  
- PIN vs full staff password on tablet  
- Whether device is a custom Auth user, a signed JWT, or a `devices` table + restricted role  

### 5. Worker

- Service-role key only in worker env  
- No end-user Auth  

---

## Schema additions likely needed

(Exact columns agreed during auth wiring — not locked yet.)

- `customers.auth_user_id` → `auth.users`  
- `staff.auth_user_id` → `auth.users`  
- `devices` (or equivalent): store_id, label, active, credential metadata  
- Optional: JWT custom claims (`app_role`, `staff_id`, `store_id`) via Auth hook for fewer DB lookups in policies  

---

## Out of scope for auth wiring discussion

- Writing final policy SQL (follows after helpers work)  
- Earn/referral economics (PM)  
- Twilio account ownership (client ops) — note dependency only  

---

## Success criteria

1. Documented flow per surface (customer, partner, admin, tablet device, tablet elevate)  
2. Chosen link tables/columns  
3. Clear mapping to every RLS helper  
4. Ready to implement Auth + helpers before policy migrations  
