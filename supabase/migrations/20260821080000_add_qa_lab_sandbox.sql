-- Isolated counter lab inside staging. Does not talk to Lightspeed or TapMango.
-- Earn may be on for this store only. Real stores stay off.

BEGIN;

ALTER TABLE public.stores
  ADD COLUMN IF NOT EXISTS is_sandbox boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN public.stores.is_sandbox IS
  'QA Lab only. Hidden from chain dashboards. Never map a Lightspeed outlet here.';

INSERT INTO public.stores (
  name,
  lightspeed_outlet_id,
  active,
  sort_rank,
  loyalty_earn_enabled,
  is_sandbox
)
VALUES (
  'QA Lab',
  NULL,
  true,
  99,
  true,
  true
)
ON CONFLICT (name) DO UPDATE
SET
  lightspeed_outlet_id = NULL,
  active = true,
  sort_rank = 99,
  loyalty_earn_enabled = true,
  is_sandbox = true,
  updated_at = now();

CREATE OR REPLACE FUNCTION public.ledger_append_only()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'DELETE'
    AND current_setting('lux.allow_ledger_delete', true) = 'on'
  THEN
    RETURN OLD;
  END IF;
  RAISE EXCEPTION 'points_ledger is append-only';
END;
$$;

CREATE OR REPLACE FUNCTION public.qa_lab_reset()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  lab_id uuid;
  removed_customers integer := 0;
  removed_sales integer := 0;
  removed_ledger integer := 0;
  removed_redemptions integer := 0;
BEGIN
  IF current_user NOT IN ('postgres', 'service_role', 'supabase_admin') THEN
    RAISE EXCEPTION 'QA Lab reset requires service role'
      USING ERRCODE = '42501';
  END IF;

  SELECT id INTO lab_id
  FROM public.stores
  WHERE is_sandbox
  LIMIT 1;

  IF lab_id IS NULL THEN
    RAISE EXCEPTION 'QA Lab store is missing';
  END IF;

  PERFORM set_config('lux.allow_ledger_delete', 'on', true);

  DELETE FROM public.redemptions
  WHERE customer_id IN (
    SELECT id FROM public.customers
    WHERE home_store_id = lab_id
      OR phone LIKE '+1555100%'
  );
  GET DIAGNOSTICS removed_redemptions = ROW_COUNT;

  DELETE FROM public.points_ledger
  WHERE customer_id IN (
    SELECT id FROM public.customers
    WHERE home_store_id = lab_id
      OR phone LIKE '+1555100%'
  )
  OR store_id = lab_id;
  GET DIAGNOSTICS removed_ledger = ROW_COUNT;

  DELETE FROM public.sales
  WHERE store_id = lab_id
    OR lightspeed_sale_id LIKE 'test-qa-%';
  GET DIAGNOSTICS removed_sales = ROW_COUNT;

  DELETE FROM public.customers
  WHERE home_store_id = lab_id
    OR phone LIKE '+1555100%';
  GET DIAGNOSTICS removed_customers = ROW_COUNT;

  RETURN jsonb_build_object(
    'ok', true,
    'store_id', lab_id,
    'removed_customers', removed_customers,
    'removed_sales', removed_sales,
    'removed_ledger', removed_ledger,
    'removed_redemptions', removed_redemptions
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.qa_lab_seed()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  lab_id uuid;
  maya_id uuid;
  luis_id uuid;
  priya_id uuid;
  priya_sale text := 'test-qa-priya-closed';
  walkin_sale text := 'test-qa-walkin';
BEGIN
  IF current_user NOT IN ('postgres', 'service_role', 'supabase_admin') THEN
    RAISE EXCEPTION 'QA Lab seed requires service role'
      USING ERRCODE = '42501';
  END IF;

  PERFORM public.qa_lab_reset();

  SELECT id INTO lab_id
  FROM public.stores
  WHERE is_sandbox
  LIMIT 1;

  INSERT INTO public.customers (
    phone, name, home_store_id, source, registered_at
  )
  VALUES (
    '+15551001001',
    'QA Maya Chen',
    lab_id,
    'admin',
    now()
  )
  RETURNING id INTO maya_id;

  INSERT INTO public.customers (
    phone, name, home_store_id, source, registered_at
  )
  VALUES (
    '+15551001002',
    'QA Luis Ortega',
    lab_id,
    'admin',
    now()
  )
  RETURNING id INTO luis_id;

  INSERT INTO public.customers (
    phone, name, home_store_id, source, registered_at
  )
  VALUES (
    '+15551001003',
    'QA Priya Shah',
    lab_id,
    'admin',
    now()
  )
  RETURNING id INTO priya_id;

  INSERT INTO public.points_ledger (
    customer_id, store_id, delta, reason, ref_type, idempotency_key
  )
  VALUES
    (
      maya_id,
      lab_id,
      500,
      'correction',
      'manual',
      'qa:seed:maya:500'
    ),
    (
      luis_id,
      lab_id,
      200,
      'correction',
      'manual',
      'qa:seed:luis:200'
    );

  INSERT INTO public.sales (
    store_id,
    customer_id,
    lightspeed_sale_id,
    state,
    total_cents,
    eligible_cents,
    occurred_at,
    raw
  )
  VALUES
    (
      lab_id,
      priya_id,
      priya_sale,
      'closed',
      4780,
      4780,
      now(),
      jsonb_build_object('source', 'qa_lab', 'note', 'identified closed ticket')
    ),
    (
      lab_id,
      NULL,
      walkin_sale,
      'closed',
      3250,
      3250,
      now(),
      jsonb_build_object('source', 'qa_lab', 'note', 'anonymous WALKIN')
    );

  RETURN jsonb_build_object(
    'ok', true,
    'store_id', lab_id,
    'maya_id', maya_id,
    'luis_id', luis_id,
    'priya_id', priya_id,
    'priya_sale', priya_sale,
    'walkin_sale', walkin_sale,
    'personas', jsonb_build_array(
      jsonb_build_object(
        'name', 'QA Maya Chen',
        'phone', '+15551001001',
        'role', 'Has 500 pts — enough for $10 or $25'
      ),
      jsonb_build_object(
        'name', 'QA Luis Ortega',
        'phone', '+15551001002',
        'role', 'Has 200 pts — not enough for $10'
      ),
      jsonb_build_object(
        'name', 'QA Priya Shah',
        'phone', '+15551001003',
        'role', '0 pts + $47.80 identified sale (earn 47 when processed)'
      )
    )
  );
END;
$$;

REVOKE ALL ON FUNCTION public.qa_lab_reset() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.qa_lab_reset() TO service_role;

REVOKE ALL ON FUNCTION public.qa_lab_seed() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.qa_lab_seed() TO service_role;

COMMENT ON FUNCTION public.qa_lab_reset() IS
  'Deletes only QA Lab customers/sales/ledger. Never touches TapMango import or Lightspeed ids.';
COMMENT ON FUNCTION public.qa_lab_seed() IS
  'Rebuilds fake counter personas and tickets. Lightspeed is not called.';

COMMIT;
