-- Identified-sale loyalty pipeline. Earn stays off until a store flag is flipped.
-- Anonymous WALKIN tickets are ignored (no phone → no points).

BEGIN;

ALTER TABLE public.stores
  ADD COLUMN IF NOT EXISTS loyalty_earn_enabled boolean NOT NULL DEFAULT false;

ALTER TABLE public.sales
  ADD COLUMN IF NOT EXISTS points_earned integer;

ALTER TABLE public.sales
  DROP CONSTRAINT IF EXISTS sales_points_earned_nonnegative;

ALTER TABLE public.sales
  ADD CONSTRAINT sales_points_earned_nonnegative
  CHECK (points_earned IS NULL OR points_earned >= 0);

CREATE TABLE IF NOT EXISTS public.lightspeed_webhook_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lightspeed_sale_id text NOT NULL,
  event_type text NOT NULL,
  payload jsonb NOT NULL,
  payload_hash text GENERATED ALWAYS AS (md5(payload::text)) STORED,
  received_at timestamptz NOT NULL DEFAULT now(),
  processed_at timestamptz,
  process_error text,
  CONSTRAINT lightspeed_webhook_events_idempotent
    UNIQUE (lightspeed_sale_id, event_type, payload_hash)
);

CREATE INDEX IF NOT EXISTS lightspeed_webhook_events_received_idx
  ON public.lightspeed_webhook_events (received_at DESC);

ALTER TABLE public.lightspeed_webhook_events ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON public.lightspeed_webhook_events TO authenticated;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE
  ON public.lightspeed_webhook_events
  FROM anon, authenticated;

DROP POLICY IF EXISTS lightspeed_webhook_events_owner_read
  ON public.lightspeed_webhook_events;

CREATE POLICY lightspeed_webhook_events_owner_read
  ON public.lightspeed_webhook_events
  FOR SELECT
  TO authenticated
  USING ((SELECT private.current_staff_role()) = 'owner');

-- Phone identity for counter enrolment (staff now; device later).
CREATE OR REPLACE FUNCTION private.normalize_us_e164(p_phone text)
RETURNS text
LANGUAGE plpgsql
IMMUTABLE
SET search_path = ''
AS $$
DECLARE
  digits text;
BEGIN
  digits := regexp_replace(coalesce(p_phone, ''), '\D', '', 'g');
  IF length(digits) = 11 AND left(digits, 1) = '1' THEN
    digits := substr(digits, 2);
  END IF;
  IF length(digits) = 10 AND digits <> '0000000000' THEN
    RETURN '+1' || digits;
  END IF;
  RETURN NULL;
END;
$$;

REVOKE ALL ON FUNCTION private.normalize_us_e164(text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.normalize_us_e164(text) TO service_role;

CREATE OR REPLACE FUNCTION public.enrol_customer(
  p_phone text,
  p_store_id uuid DEFAULT NULL,
  p_name text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  phone_e164 text;
  existing_id uuid;
  new_id uuid;
  source public.customer_source_enum;
BEGIN
  IF current_user NOT IN ('postgres', 'service_role', 'supabase_admin')
    AND NOT private.is_staff()
    AND NOT private.is_device()
  THEN
    RAISE EXCEPTION 'Enrolment requires staff, device, or service access'
      USING ERRCODE = '42501';
  END IF;

  IF private.is_device()
    AND p_store_id IS NOT NULL
    AND p_store_id IS DISTINCT FROM private.device_store_id()
  THEN
    RAISE EXCEPTION 'Device can only enrol at its own store'
      USING ERRCODE = '42501';
  END IF;

  phone_e164 := private.normalize_us_e164(p_phone);
  IF phone_e164 IS NULL THEN
    RAISE EXCEPTION 'A valid US phone number is required'
      USING ERRCODE = '22023';
  END IF;

  IF p_store_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM public.stores WHERE id = p_store_id
  ) THEN
    RAISE EXCEPTION 'Store not found'
      USING ERRCODE = 'P0002';
  END IF;

  SELECT id INTO existing_id
  FROM public.customers
  WHERE phone = phone_e164;

  IF existing_id IS NOT NULL THEN
    RETURN existing_id;
  END IF;

  source := CASE WHEN private.is_device() THEN 'tablet' ELSE 'admin' END;

  INSERT INTO public.customers (
    phone,
    name,
    home_store_id,
    source,
    registered_at
  )
  VALUES (
    phone_e164,
    NULLIF(btrim(p_name), ''),
    p_store_id,
    source,
    now()
  )
  ON CONFLICT (phone) DO NOTHING
  RETURNING id INTO new_id;

  IF new_id IS NOT NULL THEN
    RETURN new_id;
  END IF;

  SELECT id INTO existing_id
  FROM public.customers
  WHERE phone = phone_e164;

  RETURN existing_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.touch_customer_last_seen(
  p_customer_id uuid,
  p_occurred_at timestamptz
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF p_customer_id IS NULL OR p_occurred_at IS NULL THEN
    RETURN;
  END IF;

  UPDATE public.customers
  SET
    last_seen_at = GREATEST(COALESCE(last_seen_at, p_occurred_at), p_occurred_at),
    updated_at = now()
  WHERE id = p_customer_id
    AND (last_seen_at IS NULL OR last_seen_at < p_occurred_at);
END;
$$;

CREATE OR REPLACE FUNCTION public.backfill_last_seen_from_sales()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  updated_count integer;
BEGIN
  UPDATE public.customers AS c
  SET
    last_seen_at = GREATEST(COALESCE(c.last_seen_at, s.max_at), s.max_at),
    updated_at = now()
  FROM (
    SELECT customer_id, max(occurred_at) AS max_at
    FROM public.sales
    WHERE customer_id IS NOT NULL
      AND lower(coalesce(state, '')) = 'closed'
    GROUP BY customer_id
  ) AS s
  WHERE c.id = s.customer_id
    AND (c.last_seen_at IS NULL OR c.last_seen_at < s.max_at);

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count;
END;
$$;

CREATE OR REPLACE FUNCTION private.sale_loyalty_net(p_sale_id uuid)
RETURNS integer
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
  SELECT COALESCE(sum(delta), 0)::integer
  FROM public.points_ledger
  WHERE ref_type = 'sale'
    AND ref_id = p_sale_id
    AND reason IN ('earn', 'return_clawback');
$$;

REVOKE ALL ON FUNCTION private.sale_loyalty_net(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.sale_loyalty_net(uuid) TO service_role;

CREATE OR REPLACE FUNCTION public.process_sale_loyalty(p_lightspeed_sale_id text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  sale public.sales%ROWTYPE;
  earn_on boolean := false;
  desired integer := 0;
  net integer := 0;
  needed integer := 0;
  bal integer := 0;
  ledger_key text;
  ledger_reason public.ledger_reason_enum;
BEGIN
  IF NULLIF(btrim(p_lightspeed_sale_id), '') IS NULL THEN
    RAISE EXCEPTION 'lightspeed_sale_id is required'
      USING ERRCODE = '22023';
  END IF;

  SELECT *
  INTO sale
  FROM public.sales
  WHERE lightspeed_sale_id = btrim(p_lightspeed_sale_id)
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'reason', 'sale_not_found');
  END IF;

  IF sale.customer_id IS NOT NULL
    AND lower(coalesce(sale.state, '')) = 'closed'
  THEN
    PERFORM public.touch_customer_last_seen(sale.customer_id, sale.occurred_at);
  END IF;

  IF sale.customer_id IS NULL THEN
    RETURN jsonb_build_object('ok', true, 'reason', 'unidentified_ignored');
  END IF;

  IF sale.store_id IS NOT NULL THEN
    SELECT loyalty_earn_enabled
    INTO earn_on
    FROM public.stores
    WHERE id = sale.store_id;
  END IF;

  IF NOT COALESCE(earn_on, false) THEN
    RETURN jsonb_build_object('ok', true, 'reason', 'earn_disabled');
  END IF;

  IF lower(coalesce(sale.state, '')) = 'closed' THEN
    desired := GREATEST(0, COALESCE(sale.eligible_cents, sale.total_cents, 0)) / 100;
  ELSE
    desired := 0;
  END IF;

  net := private.sale_loyalty_net(sale.id);
  needed := desired - net;

  IF needed < 0 THEN
    SELECT COALESCE(balance, 0)
    INTO bal
    FROM public.customer_balance
    WHERE customer_id = sale.customer_id;

    needed := -LEAST(-needed, GREATEST(COALESCE(bal, 0), 0));
  END IF;

  IF needed = 0 THEN
    UPDATE public.sales
    SET points_earned = GREATEST(net, 0), updated_at = now()
    WHERE id = sale.id;

    RETURN jsonb_build_object('ok', true, 'reason', 'in_sync', 'net', net);
  END IF;

  IF needed > 0 THEN
    ledger_reason := 'earn';
    IF net = 0 THEN
      ledger_key := 'earn:sale:' || sale.lightspeed_sale_id;
    ELSE
      ledger_key :=
        'earn_adjust:sale:'
        || sale.lightspeed_sale_id
        || ':'
        || COALESCE(sale.eligible_cents, 0)::text;
    END IF;
  ELSE
    ledger_reason := 'return_clawback';
    ledger_key :=
      'clawback:sale:'
      || sale.lightspeed_sale_id
      || ':'
      || coalesce(sale.state, 'unknown');
  END IF;

  INSERT INTO public.points_ledger (
    customer_id,
    store_id,
    delta,
    reason,
    ref_type,
    ref_id,
    idempotency_key
  )
  VALUES (
    sale.customer_id,
    sale.store_id,
    needed,
    ledger_reason,
    'sale',
    sale.id,
    ledger_key
  )
  ON CONFLICT (idempotency_key) DO NOTHING;

  net := private.sale_loyalty_net(sale.id);
  needed := desired - net;

  IF needed > 0 THEN
    INSERT INTO public.points_ledger (
      customer_id,
      store_id,
      delta,
      reason,
      ref_type,
      ref_id,
      idempotency_key
    )
    VALUES (
      sale.customer_id,
      sale.store_id,
      needed,
      'earn',
      'sale',
      sale.id,
      'earn:sale:'
        || sale.lightspeed_sale_id
        || ':reopen:'
        || COALESCE(sale.eligible_cents, 0)::text
    )
    ON CONFLICT (idempotency_key) DO NOTHING;

    net := private.sale_loyalty_net(sale.id);
  END IF;

  UPDATE public.sales
  SET points_earned = GREATEST(net, 0), updated_at = now()
  WHERE id = sale.id;

  RETURN jsonb_build_object(
    'ok', true,
    'reason', 'applied',
    'net', net,
    'desired', desired
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.process_sales_loyalty(p_lightspeed_sale_ids text[])
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  sale_id text;
  processed integer := 0;
BEGIN
  IF p_lightspeed_sale_ids IS NULL THEN
    RETURN jsonb_build_object('processed', 0);
  END IF;

  FOREACH sale_id IN ARRAY p_lightspeed_sale_ids
  LOOP
    PERFORM public.process_sale_loyalty(sale_id);
    processed := processed + 1;
  END LOOP;

  RETURN jsonb_build_object('processed', processed);
END;
$$;

REVOKE ALL ON FUNCTION public.enrol_customer(text, uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.enrol_customer(text, uuid, text)
  TO authenticated, service_role;

REVOKE ALL ON FUNCTION public.touch_customer_last_seen(uuid, timestamptz)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.touch_customer_last_seen(uuid, timestamptz)
  TO service_role;

REVOKE ALL ON FUNCTION public.backfill_last_seen_from_sales()
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.backfill_last_seen_from_sales()
  TO service_role;

REVOKE ALL ON FUNCTION public.process_sale_loyalty(text)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.process_sale_loyalty(text)
  TO service_role;

REVOKE ALL ON FUNCTION public.process_sales_loyalty(text[])
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.process_sales_loyalty(text[])
  TO service_role;

COMMENT ON COLUMN public.stores.loyalty_earn_enabled IS
  'Pilot switch. Default false — process_sale_loyalty never writes earn/clawback while off.';
COMMENT ON FUNCTION public.process_sale_loyalty(text) IS
  'Touch last_seen for identified closed sales. Earn/clawback only when the store flag is on. Unidentified sales are ignored.';

COMMIT;
