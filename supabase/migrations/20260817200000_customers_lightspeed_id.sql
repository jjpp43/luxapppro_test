-- Link Lux customers ↔ Lightspeed X customer ids (phone-matched).

ALTER TABLE public.customers
  ADD COLUMN IF NOT EXISTS lightspeed_customer_id text;

CREATE UNIQUE INDEX IF NOT EXISTS customers_lightspeed_customer_id_uidx
  ON public.customers (lightspeed_customer_id)
  WHERE lightspeed_customer_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS sales_lightspeed_customer_idx
  ON public.sales (lightspeed_customer_id);
