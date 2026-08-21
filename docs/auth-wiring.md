# Auth wiring

**Status:** Locked — manager/owner login, invitations, and RLS implemented
**Updated:** 2026-08-20

The auth agreement is complete. Authenticated RLS is live on staging; Expo
writes remain blocked until the corresponding customer/device flows exist.

This document is the source of truth for how Supabase Auth identities map to
Lux Pro customers, staff, partners, tablets, and trusted services.

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

- Customer-app login and account claiming are **deferred**.
- Counter enrolment remains phone-only and does not create an Auth user.
- Imported and counter-created customers keep `auth_user_id = null`.
- When customer login is added, account claiming must verify phone ownership
  before setting `customers.auth_user_id`; typing a known phone is not enough.

### 2. Partner mode

- Same Auth user as customer
- Capability = active `referral_partners.customer_id`
- App switches UI; RLS uses `is_partner()` — no second login

### 3. Admin (Next.js)

- Active `manager` and `owner` rows may access the admin dashboard.
- Staff are invited by an owner, set a password from the invite, and then use
  email/password login.
- The Supabase SSR session is stored in secure cookies.
- Every protected request resolves `auth.uid()` through
  `staff.auth_user_id`; unlinked, inactive, and cashier rows are denied.
- Invitation and Auth admin calls run in server-only Next.js code. The
  service-role key is allowed in trusted server environments but never in a
  browser or Expo bundle.
- Staff cannot change their own role. Owner-only server actions manage roles
  and invitations.

### 4. Tablet (Expo Android)

Per locked RLS forks:

| Mode | Session | Allowed |
|---|---|---|
| Baseline | **Device** session | Lookup, enrol, start-earn |
| Elevated | **Staff PIN** | `redeem` and `correct_balance` for allowed staff roles |

- An owner generates a short-lived, single-use setup code in admin.
- The tablet exchanges that code for a persistent device session stored in
  platform secure storage.
- Device credential columns and the setup-code exchange are implemented in
  roadmap 2.5; they are not part of admin staff login.
- Staff PIN elevation is implemented with the tablet work, not the web login.

### 5. Worker

- No end-user Auth.
- Uses the service role only from its trusted server environment.

---

## Schema foundation now present

- `customers.auth_user_id` → `auth.users` (nullable, unique, `ON DELETE SET NULL`)
- `staff.auth_user_id` → `auth.users` (nullable, unique, `ON DELETE SET NULL`)
- `devices`: store-bound registry with label, active state, and timestamps

Implementation notes:

- Customer links remain null until customer auth is designed.
- Staff links are populated by the owner invitation flow.
- Device credentials are provisioned by the one-time setup-code flow.
- RLS helpers initially use indexed table lookups rather than custom JWT
  claims. Claims can be added later only if policy profiling proves necessary.

---

## Out of scope for the staff-login slice

- Earn/referral economics (PM)
- Customer login and SMS ownership
- Device credential exchange and staff PIN verification

The device RLS helpers currently return false/null so no ordinary Auth session
can acquire tablet capabilities before the provisioning flow is implemented.

---

## Success criteria

1. Documented flow per surface (customer, partner, admin, tablet device, tablet elevate)
2. Chosen link columns and provisioning paths
3. Clear mapping to every RLS helper
4. Staff Auth, helper functions, and policy migrations implemented
