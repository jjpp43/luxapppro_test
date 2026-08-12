-- Lux Pro loyalty — StackRender / Postgres DDL
-- Core v1 schema: PKs, FKs, enums, uniques.
--
-- Table groups:
--   1. Organization  — stores, staff
--   2. Customers     — customers
--   3. Commerce      — sales (Lightspeed ingest)
--   4. Loyalty       — rewards, points_ledger, redemptions
--   5. Referrals     — referral_partners, referrals, referral_tokens
--
-- Open product rules (earn rate, returns, referral anti-abuse) may add columns later.
-- For Supabase production, prefer UUID PKs; SERIAL kept here to match StackRender-style DDL.

BEGIN;

-- =============================================================================
-- Enums
-- =============================================================================

CREATE TYPE "customer_source_enum" AS ENUM(
  'migration',
  'tablet',
  'app',
  'referral',
  'admin'
);

CREATE TYPE "staff_role_enum" AS ENUM(
  'cashier',
  'manager',
  'owner'
);

CREATE TYPE "ledger_reason_enum" AS ENUM(
  'earn',
  'redemption',
  'migration_opening',
  'correction',
  'referral_bonus',
  'expiry',
  'return_clawback'
);

CREATE TYPE "ledger_ref_type_enum" AS ENUM(
  'sale',
  'redemption',
  'import',
  'manual',
  'referral'
);

CREATE TYPE "reward_kind_enum" AS ENUM(
  'fixed_discount',
  'percent',
  'free_item'
);

CREATE TYPE "referral_status_enum" AS ENUM(
  'pending',
  'qualified',
  'approved',
  'paid',
  'expired',
  'rejected'
);

CREATE TYPE "referral_capture_method_enum" AS ENUM(
  'qr_scan',
  'manual_phone'
);

-- =============================================================================
-- 1. Organization — places and people who operate the system
-- =============================================================================

CREATE TABLE "stores" (
  id SERIAL NOT NULL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  lightspeed_outlet_id VARCHAR(255) NULL UNIQUE,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "staff" (
  id SERIAL NOT NULL PRIMARY KEY,
  store_id INTEGER NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  role staff_role_enum NOT NULL DEFAULT 'cashier',
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- 2. Customers — loyalty members (phone = identity)
-- =============================================================================

CREATE TABLE "customers" (
  id SERIAL NOT NULL PRIMARY KEY,
  phone VARCHAR(32) NOT NULL UNIQUE,
  name VARCHAR(255) NULL,
  email VARCHAR(255) NULL,
  home_store_id INTEGER NULL,
  legacy_tapmango_id VARCHAR(64) NULL UNIQUE,
  lifetime_points_at_migration INTEGER NULL,
  source customer_source_enum NOT NULL DEFAULT 'tablet',
  sms_subscribed BOOLEAN NOT NULL DEFAULT FALSE,
  sms_opt_out_at TIMESTAMP NULL,
  email_subscribed BOOLEAN NOT NULL DEFAULT FALSE,
  email_opt_out_at TIMESTAMP NULL,
  registered_at TIMESTAMP NULL,
  last_seen_at TIMESTAMP NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- 3. Commerce — sales mirrored from Lightspeed X
-- =============================================================================

CREATE TABLE "sales" (
  id SERIAL NOT NULL PRIMARY KEY,
  store_id INTEGER NOT NULL,
  customer_id INTEGER NULL,
  lightspeed_sale_id VARCHAR(255) NOT NULL UNIQUE,
  total_cents INTEGER NOT NULL,
  eligible_cents INTEGER NOT NULL,
  occurred_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- 4. Loyalty — rewards catalog, point history, redemptions
-- =============================================================================

CREATE TABLE "rewards" (
  id SERIAL NOT NULL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  cost_points INTEGER NOT NULL,
  kind reward_kind_enum NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "points_ledger" (
  id SERIAL NOT NULL PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  store_id INTEGER NULL,
  delta INTEGER NOT NULL,
  reason ledger_reason_enum NOT NULL,
  ref_type ledger_ref_type_enum NULL,
  ref_id INTEGER NULL,
  idempotency_key VARCHAR(255) NOT NULL UNIQUE,
  created_by INTEGER NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "redemptions" (
  id SERIAL NOT NULL PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  reward_id INTEGER NOT NULL,
  store_id INTEGER NOT NULL,
  ledger_id INTEGER NOT NULL UNIQUE,
  redeemed_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- 5. Referrals — beautician partners, visit credits, QR tokens
-- =============================================================================

CREATE TABLE "referral_partners" (
  id SERIAL NOT NULL PRIMARY KEY,
  customer_id INTEGER NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  salon_name VARCHAR(255) NULL,
  payout_terms VARCHAR(255) NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "referrals" (
  id SERIAL NOT NULL PRIMARY KEY,
  partner_id INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  sale_id INTEGER NULL,
  capture_method referral_capture_method_enum NOT NULL,
  status referral_status_enum NOT NULL DEFAULT 'pending',
  attributed_amount_cents INTEGER NULL,
  referred_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  qualified_at TIMESTAMP NULL,
  hold_until TIMESTAMP NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "referral_tokens" (
  id SERIAL NOT NULL PRIMARY KEY,
  partner_id INTEGER NOT NULL,
  token VARCHAR(255) NOT NULL UNIQUE,
  expires_at TIMESTAMP NOT NULL,
  consumed_at TIMESTAMP NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- Foreign keys
-- =============================================================================

ALTER TABLE "staff"
ADD CONSTRAINT "fk_stores_staff" FOREIGN KEY (store_id) REFERENCES "stores" (id) ON DELETE SET NULL;

ALTER TABLE "customers"
ADD CONSTRAINT "fk_stores_customers" FOREIGN KEY (home_store_id) REFERENCES "stores" (id) ON DELETE SET NULL;

ALTER TABLE "sales"
ADD CONSTRAINT "fk_stores_sales" FOREIGN KEY (store_id) REFERENCES "stores" (id) ON DELETE RESTRICT;

ALTER TABLE "sales"
ADD CONSTRAINT "fk_customers_sales" FOREIGN KEY (customer_id) REFERENCES "customers" (id) ON DELETE SET NULL;

ALTER TABLE "points_ledger"
ADD CONSTRAINT "fk_customers_points_ledger" FOREIGN KEY (customer_id) REFERENCES "customers" (id) ON DELETE RESTRICT;

ALTER TABLE "points_ledger"
ADD CONSTRAINT "fk_stores_points_ledger" FOREIGN KEY (store_id) REFERENCES "stores" (id) ON DELETE SET NULL;

ALTER TABLE "points_ledger"
ADD CONSTRAINT "fk_staff_points_ledger" FOREIGN KEY (created_by) REFERENCES "staff" (id) ON DELETE SET NULL;

ALTER TABLE "redemptions"
ADD CONSTRAINT "fk_customers_redemptions" FOREIGN KEY (customer_id) REFERENCES "customers" (id) ON DELETE RESTRICT;

ALTER TABLE "redemptions"
ADD CONSTRAINT "fk_rewards_redemptions" FOREIGN KEY (reward_id) REFERENCES "rewards" (id) ON DELETE RESTRICT;

ALTER TABLE "redemptions"
ADD CONSTRAINT "fk_stores_redemptions" FOREIGN KEY (store_id) REFERENCES "stores" (id) ON DELETE RESTRICT;

ALTER TABLE "redemptions"
ADD CONSTRAINT "fk_points_ledger_redemptions" FOREIGN KEY (ledger_id) REFERENCES "points_ledger" (id) ON DELETE RESTRICT;

ALTER TABLE "referral_partners"
ADD CONSTRAINT "fk_customers_referral_partners" FOREIGN KEY (customer_id) REFERENCES "customers" (id) ON DELETE RESTRICT;

ALTER TABLE "referrals"
ADD CONSTRAINT "fk_referral_partners_referrals" FOREIGN KEY (partner_id) REFERENCES "referral_partners" (id) ON DELETE RESTRICT;

ALTER TABLE "referrals"
ADD CONSTRAINT "fk_customers_referrals" FOREIGN KEY (customer_id) REFERENCES "customers" (id) ON DELETE RESTRICT;

ALTER TABLE "referrals"
ADD CONSTRAINT "fk_sales_referrals" FOREIGN KEY (sale_id) REFERENCES "sales" (id) ON DELETE SET NULL;

ALTER TABLE "referral_tokens"
ADD CONSTRAINT "fk_referral_partners_referral_tokens" FOREIGN KEY (partner_id) REFERENCES "referral_partners" (id) ON DELETE CASCADE;

COMMIT;
