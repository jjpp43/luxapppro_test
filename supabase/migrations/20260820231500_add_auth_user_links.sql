-- Roadmap 0.8: link Supabase Auth identities to domain records.
-- Login/enrol flows and RLS helpers are implemented later in roadmap 2.x.

BEGIN;

ALTER TABLE public.customers
  ADD COLUMN auth_user_id uuid;

ALTER TABLE public.customers
  ADD CONSTRAINT customers_auth_user_id_fkey
  FOREIGN KEY (auth_user_id)
  REFERENCES auth.users (id)
  ON DELETE SET NULL;

ALTER TABLE public.customers
  ADD CONSTRAINT customers_auth_user_id_key
  UNIQUE (auth_user_id);

COMMENT ON COLUMN public.customers.auth_user_id IS
  'Supabase Auth identity linked after customer authentication; null for unclaimed/imported accounts.';

ALTER TABLE public.staff
  ADD COLUMN auth_user_id uuid;

ALTER TABLE public.staff
  ADD CONSTRAINT staff_auth_user_id_fkey
  FOREIGN KEY (auth_user_id)
  REFERENCES auth.users (id)
  ON DELETE SET NULL;

ALTER TABLE public.staff
  ADD CONSTRAINT staff_auth_user_id_key
  UNIQUE (auth_user_id);

COMMENT ON COLUMN public.staff.auth_user_id IS
  'Supabase Auth identity linked by a trusted staff invitation or provisioning flow.';

COMMIT;
