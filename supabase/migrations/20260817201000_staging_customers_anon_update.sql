-- TEMP: staging-only — allow match script via anon key
DROP POLICY IF EXISTS staging_anon_update_customers ON public.customers;
CREATE POLICY staging_anon_update_customers
  ON public.customers FOR UPDATE TO anon USING (true) WITH CHECK (true);

GRANT UPDATE ON public.customers TO anon;
