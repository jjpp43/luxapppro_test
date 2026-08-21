-- Roadmap 2.7-2.8: Auth-backed RLS helpers and locked matrix policies.
-- Device sessions remain deny-by-default until roadmap 2.5 adds credential wiring.

BEGIN;

CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC, anon, authenticated;
GRANT USAGE ON SCHEMA private TO authenticated;

CREATE OR REPLACE FUNCTION private.current_customer_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT id
  FROM public.customers
  WHERE auth_user_id = (SELECT auth.uid())
  LIMIT 1
$$;

CREATE OR REPLACE FUNCTION private.current_staff_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT id
  FROM public.staff
  WHERE auth_user_id = (SELECT auth.uid())
    AND active
  LIMIT 1
$$;

CREATE OR REPLACE FUNCTION private.current_staff_role()
RETURNS public.staff_role_enum
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT role
  FROM public.staff
  WHERE auth_user_id = (SELECT auth.uid())
    AND active
  LIMIT 1
$$;

CREATE OR REPLACE FUNCTION private.current_staff_store_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT store_id
  FROM public.staff
  WHERE auth_user_id = (SELECT auth.uid())
    AND active
  LIMIT 1
$$;

CREATE OR REPLACE FUNCTION private.is_staff()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT private.current_staff_id() IS NOT NULL
$$;

CREATE OR REPLACE FUNCTION private.is_manager_or_owner()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT private.current_staff_role() IN ('manager', 'owner')
$$;

CREATE OR REPLACE FUNCTION private.current_partner_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT id
  FROM public.referral_partners
  WHERE customer_id = private.current_customer_id()
    AND active
  LIMIT 1
$$;

CREATE OR REPLACE FUNCTION private.is_partner()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT private.current_partner_id() IS NOT NULL
$$;

-- Replaced by the device provisioning migration. Until then, no Auth session
-- can acquire device capabilities.
CREATE OR REPLACE FUNCTION private.is_device()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT false
$$;

CREATE OR REPLACE FUNCTION private.device_store_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT NULL::uuid
$$;

REVOKE ALL ON FUNCTION private.current_customer_id() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.current_staff_id() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.current_staff_role() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.current_staff_store_id() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.is_staff() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.is_manager_or_owner() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.current_partner_id() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.is_partner() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.is_device() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.device_store_id() FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION private.current_customer_id() TO authenticated;
GRANT EXECUTE ON FUNCTION private.current_staff_id() TO authenticated;
GRANT EXECUTE ON FUNCTION private.current_staff_role() TO authenticated;
GRANT EXECUTE ON FUNCTION private.current_staff_store_id() TO authenticated;
GRANT EXECUTE ON FUNCTION private.is_staff() TO authenticated;
GRANT EXECUTE ON FUNCTION private.is_manager_or_owner() TO authenticated;
GRANT EXECUTE ON FUNCTION private.current_partner_id() TO authenticated;
GRANT EXECUTE ON FUNCTION private.is_partner() TO authenticated;
GRANT EXECUTE ON FUNCTION private.is_device() TO authenticated;
GRANT EXECUTE ON FUNCTION private.device_store_id() TO authenticated;

COMMENT ON FUNCTION private.is_device() IS
  'Deny-by-default placeholder until roadmap 2.5 links provisioned device Auth sessions.';
COMMENT ON FUNCTION private.device_store_id() IS
  'Deny-by-default placeholder until roadmap 2.5 links provisioned device Auth sessions.';

-- Prevent self-service customer updates from changing identity, loyalty, or
-- import fields. Managers/owners and trusted service connections may update
-- those fields through their approved paths.
CREATE OR REPLACE FUNCTION private.enforce_customer_update()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  IF current_user IN ('postgres', 'service_role', 'supabase_admin')
    OR private.is_manager_or_owner()
  THEN
    RETURN NEW;
  END IF;

  IF private.current_customer_id() = OLD.id
    AND NEW.id IS NOT DISTINCT FROM OLD.id
    AND NEW.phone IS NOT DISTINCT FROM OLD.phone
    AND NEW.home_store_id IS NOT DISTINCT FROM OLD.home_store_id
    AND NEW.legacy_tapmango_id IS NOT DISTINCT FROM OLD.legacy_tapmango_id
    AND NEW.lifetime_points_at_migration IS NOT DISTINCT FROM OLD.lifetime_points_at_migration
    AND NEW.source IS NOT DISTINCT FROM OLD.source
    AND NEW.registered_at IS NOT DISTINCT FROM OLD.registered_at
    AND NEW.last_seen_at IS NOT DISTINCT FROM OLD.last_seen_at
    AND NEW.created_at IS NOT DISTINCT FROM OLD.created_at
    AND NEW.auth_user_id IS NOT DISTINCT FROM OLD.auth_user_id
  THEN
    RETURN NEW;
  END IF;

  RAISE EXCEPTION 'Customer identity and loyalty fields require a trusted workflow'
    USING ERRCODE = '42501';
END;
$$;

REVOKE ALL ON FUNCTION private.enforce_customer_update() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS customers_enforce_safe_update ON public.customers;
CREATE TRIGGER customers_enforce_safe_update
  BEFORE UPDATE ON public.customers
  FOR EACH ROW
  EXECUTE FUNCTION private.enforce_customer_update();

-- Partners may edit presentation fields, but cannot relink ownership, approve
-- themselves, or alter payout controls.
CREATE OR REPLACE FUNCTION private.enforce_partner_update()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  IF current_user IN ('postgres', 'service_role', 'supabase_admin')
    OR private.current_staff_role() = 'owner'
  THEN
    RETURN NEW;
  END IF;

  IF private.current_partner_id() = OLD.id
    AND NEW.id IS NOT DISTINCT FROM OLD.id
    AND NEW.customer_id IS NOT DISTINCT FROM OLD.customer_id
    AND NEW.payout_terms IS NOT DISTINCT FROM OLD.payout_terms
    AND NEW.active IS NOT DISTINCT FROM OLD.active
    AND NEW.created_at IS NOT DISTINCT FROM OLD.created_at
  THEN
    RETURN NEW;
  END IF;

  RAISE EXCEPTION 'Partner ownership and payout fields require an owner'
    USING ERRCODE = '42501';
END;
$$;

REVOKE ALL ON FUNCTION private.enforce_partner_update() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS referral_partners_enforce_safe_update
  ON public.referral_partners;
CREATE TRIGGER referral_partners_enforce_safe_update
  BEFORE UPDATE ON public.referral_partners
  FOR EACH ROW
  EXECUTE FUNCTION private.enforce_partner_update();

ALTER FUNCTION public.ledger_append_only() SET search_path = '';

DO $$
BEGIN
  IF to_regprocedure('public.rls_auto_enable()') IS NOT NULL THEN
    EXECUTE
      'REVOKE ALL ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated';
  END IF;
END;
$$;

CREATE INDEX IF NOT EXISTS customers_home_store_id_idx
  ON public.customers (home_store_id);
CREATE INDEX IF NOT EXISTS points_ledger_store_id_idx
  ON public.points_ledger (store_id);

ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.points_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.redemptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_tokens ENABLE ROW LEVEL SECURITY;

-- The quarantine table came from a staging-only import migration that is not
-- part of clean production replays.
DO $$
BEGIN
  IF to_regclass('public.staging_tapmango_quarantine') IS NOT NULL THEN
    EXECUTE
      'ALTER TABLE public.staging_tapmango_quarantine ENABLE ROW LEVEL SECURITY';
    EXECUTE
      'DROP POLICY IF EXISTS staging_anon_select_quarantine '
      'ON public.staging_tapmango_quarantine';
    EXECUTE
      'REVOKE ALL PRIVILEGES ON TABLE public.staging_tapmango_quarantine '
      'FROM anon, authenticated';
  END IF;
END;
$$;

DROP POLICY IF EXISTS staging_anon_select_stores ON public.stores;
DROP POLICY IF EXISTS staging_anon_select_staff ON public.staff;
DROP POLICY IF EXISTS staging_anon_select_customers ON public.customers;
DROP POLICY IF EXISTS staging_anon_update_customers ON public.customers;
DROP POLICY IF EXISTS staging_anon_select_points_ledger ON public.points_ledger;
DROP POLICY IF EXISTS staging_anon_select_sales ON public.sales;
DROP POLICY IF EXISTS staging_anon_write_sales ON public.sales;
DROP POLICY IF EXISTS staging_anon_select_devices ON public.devices;
DROP POLICY IF EXISTS staging_anon_select_rewards ON public.rewards;
DROP POLICY IF EXISTS staging_anon_select_redemptions ON public.redemptions;
DROP POLICY IF EXISTS staging_anon_select_referral_partners ON public.referral_partners;
DROP POLICY IF EXISTS staging_anon_select_referrals ON public.referrals;
DROP POLICY IF EXISTS staging_anon_select_referral_tokens ON public.referral_tokens;

REVOKE ALL PRIVILEGES ON TABLE
  public.stores,
  public.staff,
  public.customers,
  public.points_ledger,
  public.sales,
  public.devices,
  public.rewards,
  public.redemptions,
  public.referral_partners,
  public.referrals,
  public.referral_tokens,
  public.customer_balance
FROM anon, authenticated;

GRANT SELECT ON TABLE
  public.stores,
  public.staff,
  public.customers,
  public.points_ledger,
  public.sales,
  public.devices,
  public.rewards,
  public.redemptions,
  public.referral_partners,
  public.referrals,
  public.referral_tokens,
  public.customer_balance
TO authenticated;

GRANT INSERT, UPDATE ON TABLE
  public.stores,
  public.staff,
  public.customers,
  public.sales,
  public.devices,
  public.rewards,
  public.referral_partners,
  public.referrals
TO authenticated;

-- Ledger and redemption rows are append-only through trusted RPCs. Referral
-- tokens are also issued through a rate-limited RPC in roadmap 2.9.
REVOKE INSERT, UPDATE, DELETE, TRUNCATE
  ON public.points_ledger, public.redemptions, public.referral_tokens
  FROM anon, authenticated;

CREATE POLICY stores_read
  ON public.stores
  FOR SELECT
  TO authenticated
  USING (
    (
      (SELECT private.current_customer_id()) IS NOT NULL
      OR (SELECT private.is_staff())
      OR (SELECT private.is_device())
    )
    AND (
      active
      OR (SELECT private.is_staff())
      OR (SELECT private.is_device())
    )
  );

CREATE POLICY stores_owner_insert
  ON public.stores
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT private.current_staff_role()) = 'owner');

CREATE POLICY stores_owner_update
  ON public.stores
  FOR UPDATE
  TO authenticated
  USING ((SELECT private.current_staff_role()) = 'owner')
  WITH CHECK ((SELECT private.current_staff_role()) = 'owner');

CREATE POLICY staff_read
  ON public.staff
  FOR SELECT
  TO authenticated
  USING (
    id = (SELECT private.current_staff_id())
    OR (SELECT private.current_staff_role()) = 'owner'
    OR (
      (SELECT private.current_staff_role()) = 'manager'
      AND store_id = (SELECT private.current_staff_store_id())
    )
  );

CREATE POLICY staff_owner_insert
  ON public.staff
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT private.current_staff_role()) = 'owner');

CREATE POLICY staff_owner_update
  ON public.staff
  FOR UPDATE
  TO authenticated
  USING ((SELECT private.current_staff_role()) = 'owner')
  WITH CHECK ((SELECT private.current_staff_role()) = 'owner');

CREATE POLICY customers_read
  ON public.customers
  FOR SELECT
  TO authenticated
  USING (
    id = (SELECT private.current_customer_id())
    OR (SELECT private.is_staff())
    OR (SELECT private.is_device())
  );

CREATE POLICY customers_counter_insert
  ON public.customers
  FOR INSERT
  TO authenticated
  WITH CHECK (
    (
      (SELECT private.is_staff())
      OR (SELECT private.is_device())
    )
    AND auth_user_id IS NULL
  );

CREATE POLICY customers_update
  ON public.customers
  FOR UPDATE
  TO authenticated
  USING (
    id = (SELECT private.current_customer_id())
    OR (SELECT private.is_manager_or_owner())
  )
  WITH CHECK (
    id = (SELECT private.current_customer_id())
    OR (SELECT private.is_manager_or_owner())
  );

CREATE POLICY points_ledger_read
  ON public.points_ledger
  FOR SELECT
  TO authenticated
  USING (
    customer_id = (SELECT private.current_customer_id())
    OR (SELECT private.is_staff())
    OR (SELECT private.is_device())
  );

CREATE POLICY sales_read
  ON public.sales
  FOR SELECT
  TO authenticated
  USING (
    customer_id = (SELECT private.current_customer_id())
    OR (SELECT private.current_staff_role()) = 'owner'
    OR (
      (SELECT private.current_staff_role()) IN ('cashier', 'manager')
      AND store_id = (SELECT private.current_staff_store_id())
    )
    OR (
      (SELECT private.is_device())
      AND store_id = (SELECT private.device_store_id())
    )
  );

CREATE POLICY sales_owner_insert
  ON public.sales
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT private.current_staff_role()) = 'owner');

CREATE POLICY sales_owner_update
  ON public.sales
  FOR UPDATE
  TO authenticated
  USING ((SELECT private.current_staff_role()) = 'owner')
  WITH CHECK ((SELECT private.current_staff_role()) = 'owner');

CREATE POLICY devices_owner_read
  ON public.devices
  FOR SELECT
  TO authenticated
  USING ((SELECT private.current_staff_role()) = 'owner');

CREATE POLICY devices_owner_insert
  ON public.devices
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT private.current_staff_role()) = 'owner');

CREATE POLICY devices_owner_update
  ON public.devices
  FOR UPDATE
  TO authenticated
  USING ((SELECT private.current_staff_role()) = 'owner')
  WITH CHECK ((SELECT private.current_staff_role()) = 'owner');

CREATE POLICY rewards_read
  ON public.rewards
  FOR SELECT
  TO authenticated
  USING (
    (
      (SELECT private.current_customer_id()) IS NOT NULL
      OR (SELECT private.is_staff())
      OR (SELECT private.is_device())
    )
    AND (
      active
      OR (SELECT private.current_staff_role()) IN ('manager', 'owner')
    )
  );

CREATE POLICY rewards_manager_owner_insert
  ON public.rewards
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT private.is_manager_or_owner()));

CREATE POLICY rewards_manager_owner_update
  ON public.rewards
  FOR UPDATE
  TO authenticated
  USING ((SELECT private.is_manager_or_owner()))
  WITH CHECK ((SELECT private.is_manager_or_owner()));

CREATE POLICY redemptions_read
  ON public.redemptions
  FOR SELECT
  TO authenticated
  USING (
    customer_id = (SELECT private.current_customer_id())
    OR (SELECT private.current_staff_role()) IN ('manager', 'owner')
    OR (
      (SELECT private.current_staff_role()) = 'cashier'
      AND store_id = (SELECT private.current_staff_store_id())
    )
  );

CREATE POLICY referral_partners_read
  ON public.referral_partners
  FOR SELECT
  TO authenticated
  USING (
    id = (SELECT private.current_partner_id())
    OR (SELECT private.current_staff_role()) IN ('manager', 'owner')
  );

CREATE POLICY referral_partners_owner_insert
  ON public.referral_partners
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT private.current_staff_role()) = 'owner');

CREATE POLICY referral_partners_update
  ON public.referral_partners
  FOR UPDATE
  TO authenticated
  USING (
    id = (SELECT private.current_partner_id())
    OR (SELECT private.current_staff_role()) = 'owner'
  )
  WITH CHECK (
    id = (SELECT private.current_partner_id())
    OR (SELECT private.current_staff_role()) = 'owner'
  );

CREATE POLICY referrals_read
  ON public.referrals
  FOR SELECT
  TO authenticated
  USING (
    customer_id = (SELECT private.current_customer_id())
    OR partner_id = (SELECT private.current_partner_id())
    OR (SELECT private.current_staff_role()) IN ('manager', 'owner')
  );

CREATE POLICY referrals_partner_insert
  ON public.referrals
  FOR INSERT
  TO authenticated
  WITH CHECK (
    partner_id = (SELECT private.current_partner_id())
    AND customer_id <> (SELECT private.current_customer_id())
    AND sale_id IS NULL
    AND status = 'pending'
    AND attributed_amount_cents IS NULL
    AND qualified_at IS NULL
    AND hold_until IS NULL
    AND approved_at IS NULL
    AND paid_at IS NULL
    AND rejected_at IS NULL
  );

CREATE POLICY referrals_owner_insert
  ON public.referrals
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT private.current_staff_role()) = 'owner');

CREATE POLICY referrals_owner_update
  ON public.referrals
  FOR UPDATE
  TO authenticated
  USING ((SELECT private.current_staff_role()) = 'owner')
  WITH CHECK ((SELECT private.current_staff_role()) = 'owner');

CREATE POLICY referral_tokens_partner_read
  ON public.referral_tokens
  FOR SELECT
  TO authenticated
  USING (partner_id = (SELECT private.current_partner_id()));

COMMIT;
