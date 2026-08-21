-- Follow-up security fixes from the first authenticated RLS review.

BEGIN;

-- Managers and owners may edit customer profile/preferences, but identity,
-- import, and loyalty fields remain RPC/service-only.
CREATE OR REPLACE FUNCTION private.enforce_customer_update()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  IF current_user IN ('postgres', 'service_role', 'supabase_admin') THEN
    RETURN NEW;
  END IF;

  IF (
      private.current_customer_id() = OLD.id
      OR private.current_staff_role() IN ('manager', 'owner')
    )
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
    AND NEW.lightspeed_customer_id IS NOT DISTINCT FROM OLD.lightspeed_customer_id
  THEN
    RETURN NEW;
  END IF;

  RAISE EXCEPTION 'Customer identity and loyalty fields require a trusted workflow'
    USING ERRCODE = '42501';
END;
$$;

-- Raw INSERT cannot enforce E.164 enrolment and field restrictions. Keep it
-- closed until enrol_customer is added in roadmap 2.9.
DROP POLICY IF EXISTS customers_counter_insert ON public.customers;
REVOKE INSERT ON public.customers FROM authenticated;

-- Staff edits use one locked transaction so concurrent requests cannot remove
-- the final active owner.
CREATE OR REPLACE FUNCTION public.update_admin_staff(
  p_actor_id uuid,
  p_staff_id uuid,
  p_name text,
  p_role public.staff_role_enum,
  p_store_id uuid,
  p_active boolean
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  target_role public.staff_role_enum;
  target_active boolean;
  active_owner_count integer;
BEGIN
  LOCK TABLE public.staff IN SHARE ROW EXCLUSIVE MODE;

  IF NOT EXISTS (
    SELECT 1
    FROM public.staff
    WHERE id = p_actor_id
      AND role = 'owner'
      AND active
  ) THEN
    RAISE EXCEPTION 'Owner authorization required'
      USING ERRCODE = '42501';
  END IF;

  IF NULLIF(btrim(p_name), '') IS NULL THEN
    RAISE EXCEPTION 'Name is required'
      USING ERRCODE = '22023';
  END IF;

  IF p_role NOT IN ('manager', 'owner') THEN
    RAISE EXCEPTION 'Role must be manager or owner'
      USING ERRCODE = '22023';
  END IF;

  IF p_role = 'manager' AND p_store_id IS NULL THEN
    RAISE EXCEPTION 'Managers must be assigned to a store'
      USING ERRCODE = '22023';
  END IF;

  SELECT role, active
  INTO target_role, target_active
  FROM public.staff
  WHERE id = p_staff_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Staff record not found'
      USING ERRCODE = 'P0002';
  END IF;

  IF p_staff_id = p_actor_id AND (p_role <> 'owner' OR NOT p_active) THEN
    RAISE EXCEPTION 'You cannot demote or deactivate your own account'
      USING ERRCODE = '42501';
  END IF;

  IF target_role = 'owner'
    AND target_active
    AND (p_role <> 'owner' OR NOT p_active)
  THEN
    SELECT count(*)
    INTO active_owner_count
    FROM public.staff
    WHERE role = 'owner'
      AND active;

    IF active_owner_count <= 1 THEN
      RAISE EXCEPTION 'At least one active owner is required'
        USING ERRCODE = '23514';
    END IF;
  END IF;

  UPDATE public.staff
  SET
    name = btrim(p_name),
    role = p_role,
    store_id = p_store_id,
    active = p_active
  WHERE id = p_staff_id;
END;
$$;

REVOKE ALL ON FUNCTION public.update_admin_staff(
  uuid,
  uuid,
  text,
  public.staff_role_enum,
  uuid,
  boolean
) FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.update_admin_staff(
  uuid,
  uuid,
  text,
  public.staff_role_enum,
  uuid,
  boolean
) TO service_role;

COMMIT;
