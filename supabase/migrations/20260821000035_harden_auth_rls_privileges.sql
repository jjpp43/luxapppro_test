-- Service-role requests bypass RLS but still need private-schema access when
-- update triggers call shared authorization helpers.

BEGIN;

GRANT USAGE ON SCHEMA private TO service_role;

GRANT EXECUTE ON FUNCTION private.current_customer_id() TO service_role;
GRANT EXECUTE ON FUNCTION private.current_staff_id() TO service_role;
GRANT EXECUTE ON FUNCTION private.current_staff_role() TO service_role;
GRANT EXECUTE ON FUNCTION private.current_staff_store_id() TO service_role;
GRANT EXECUTE ON FUNCTION private.is_staff() TO service_role;
GRANT EXECUTE ON FUNCTION private.is_manager_or_owner() TO service_role;
GRANT EXECUTE ON FUNCTION private.current_partner_id() TO service_role;
GRANT EXECUTE ON FUNCTION private.is_partner() TO service_role;
GRANT EXECUTE ON FUNCTION private.is_device() TO service_role;
GRANT EXECUTE ON FUNCTION private.device_store_id() TO service_role;

-- One permissive INSERT policy avoids evaluating two policies for every row.
DROP POLICY IF EXISTS referrals_partner_insert ON public.referrals;
DROP POLICY IF EXISTS referrals_owner_insert ON public.referrals;

CREATE POLICY referrals_insert
  ON public.referrals
  FOR INSERT
  TO authenticated
  WITH CHECK (
    (SELECT private.current_staff_role()) = 'owner'
    OR (
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
    )
  );

COMMIT;
