-- Staging core loyalty sample schema (applied to luxproapp_test)
-- Mirrors remote migrations:
--   20260812220859_core_loyalty_sample
--   + customer_balance_fk_hint
-- Temporary staging_anon_select_* policies allow anon read for admin verification.
-- Replace with real RLS after auth wiring.

BEGIN;

CREATE TYPE customer_source_enum AS ENUM (
  'migration',
  'tablet',
  'app',
  'referral',
  'admin'
);

CREATE TYPE ledger_reason_enum AS ENUM (
  'earn',
  'redemption',
  'migration_opening',
  'correction',
  'referral_bonus',
  'expiry',
  'return_clawback'
);

CREATE TYPE ledger_ref_type_enum AS ENUM (
  'sale',
  'redemption',
  'import',
  'manual',
  'referral'
);

CREATE TABLE stores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  lightspeed_outlet_id text UNIQUE,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone text NOT NULL UNIQUE,
  name text,
  email text,
  home_store_id uuid REFERENCES stores (id),
  legacy_tapmango_id text UNIQUE,
  lifetime_points_at_migration integer,
  source customer_source_enum NOT NULL DEFAULT 'migration',
  sms_subscribed boolean NOT NULL DEFAULT false,
  sms_opt_out_at timestamptz,
  email_subscribed boolean NOT NULL DEFAULT false,
  email_opt_out_at timestamptz,
  registered_at timestamptz,
  last_seen_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE points_ledger (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL REFERENCES customers (id),
  store_id uuid REFERENCES stores (id),
  delta integer NOT NULL,
  reason ledger_reason_enum NOT NULL,
  ref_type ledger_ref_type_enum,
  ref_id uuid,
  idempotency_key text NOT NULL UNIQUE,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX points_ledger_customer_created_idx
  ON points_ledger (customer_id, created_at DESC);

CREATE OR REPLACE FUNCTION ledger_append_only()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION 'points_ledger is append-only';
END;
$$;

CREATE TRIGGER ledger_no_mutate
  BEFORE UPDATE OR DELETE ON points_ledger
  FOR EACH ROW
  EXECUTE FUNCTION ledger_append_only();

CREATE VIEW customer_balance
  WITH (security_invoker = true)
AS
SELECT
  customer_id,
  COALESCE(sum(delta), 0)::integer AS balance
FROM points_ledger
GROUP BY customer_id;

COMMENT ON VIEW customer_balance IS
  E'@foreignKey (customer_id) references customers(id)';

ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE points_ledger ENABLE ROW LEVEL SECURITY;

-- TEMP staging: open anon SELECT for admin verification only
CREATE POLICY staging_anon_select_stores
  ON stores FOR SELECT TO anon USING (true);

CREATE POLICY staging_anon_select_customers
  ON customers FOR SELECT TO anon USING (true);

CREATE POLICY staging_anon_select_points_ledger
  ON points_ledger FOR SELECT TO anon USING (true);

GRANT SELECT ON stores, customers, points_ledger, customer_balance TO anon;

COMMIT;
