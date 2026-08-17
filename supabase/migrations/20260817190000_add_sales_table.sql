-- Lightspeed X-Series sales ingest + staging write policy
-- Applied to luxproapp_test as add_sales_table + staging_sales_anon_write

CREATE TABLE IF NOT EXISTS public.sales (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id uuid REFERENCES public.stores (id),
  customer_id uuid REFERENCES public.customers (id),
  lightspeed_sale_id text NOT NULL UNIQUE,
  lightspeed_outlet_id text,
  lightspeed_customer_id text,
  state text,
  total_cents integer NOT NULL DEFAULT 0,
  eligible_cents integer NOT NULL DEFAULT 0,
  occurred_at timestamptz NOT NULL,
  raw jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS sales_occurred_at_idx ON public.sales (occurred_at DESC);
CREATE INDEX IF NOT EXISTS sales_store_occurred_idx ON public.sales (store_id, occurred_at DESC);
CREATE INDEX IF NOT EXISTS sales_lightspeed_outlet_idx ON public.sales (lightspeed_outlet_id);
CREATE INDEX IF NOT EXISTS sales_customer_idx ON public.sales (customer_id);

ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS staging_anon_select_sales ON public.sales;
CREATE POLICY staging_anon_select_sales
  ON public.sales FOR SELECT TO anon USING (true);

-- TEMP: remove once worker uses service role
DROP POLICY IF EXISTS staging_anon_write_sales ON public.sales;
CREATE POLICY staging_anon_write_sales
  ON public.sales FOR ALL TO anon USING (true) WITH CHECK (true);

GRANT SELECT, INSERT, UPDATE ON public.sales TO anon;
