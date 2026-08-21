-- Roadmap 0.6: remaining v1 organization, loyalty, and referral tables.
-- Authentication links/credentials intentionally remain out of scope (0.8 / 2.5).

BEGIN;

CREATE TYPE public.staff_role_enum AS ENUM (
  'cashier',
  'manager',
  'owner'
);

CREATE TYPE public.reward_kind_enum AS ENUM (
  'fixed_discount',
  'percent',
  'free_item'
);

CREATE TYPE public.referral_status_enum AS ENUM (
  'pending',
  'qualified',
  'approved',
  'paid',
  'expired',
  'rejected'
);

CREATE TYPE public.referral_capture_method_enum AS ENUM (
  'qr_scan',
  'manual_phone'
);

CREATE TABLE public.staff (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id uuid REFERENCES public.stores (id) ON DELETE SET NULL,
  email text,
  name text NOT NULL,
  role public.staff_role_enum NOT NULL DEFAULT 'cashier',
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT staff_manager_owner_email_required
    CHECK (role = 'cashier' OR email IS NOT NULL),
  CONSTRAINT staff_cashier_manager_store_required
    CHECK (role = 'owner' OR store_id IS NOT NULL)
);

CREATE UNIQUE INDEX staff_email_lower_uidx
  ON public.staff (lower(email))
  WHERE email IS NOT NULL;

CREATE INDEX staff_store_id_idx
  ON public.staff (store_id);

CREATE TABLE public.devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id uuid NOT NULL REFERENCES public.stores (id) ON DELETE RESTRICT,
  label text NOT NULL,
  active boolean NOT NULL DEFAULT true,
  last_seen_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT devices_store_label_unique UNIQUE (store_id, label)
);

CREATE INDEX devices_store_active_idx
  ON public.devices (store_id, active);

CREATE TABLE public.rewards (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  cost_points integer NOT NULL CHECK (cost_points > 0),
  kind public.reward_kind_enum NOT NULL,
  value_cents integer CHECK (value_cents > 0),
  value_percent numeric(5, 2)
    CHECK (value_percent > 0 AND value_percent <= 100),
  item_reference text,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT rewards_value_matches_kind CHECK (
    (
      kind = 'fixed_discount'
      AND value_cents IS NOT NULL
      AND value_percent IS NULL
      AND item_reference IS NULL
    )
    OR (
      kind = 'percent'
      AND value_cents IS NULL
      AND value_percent IS NOT NULL
      AND item_reference IS NULL
    )
    OR (
      kind = 'free_item'
      AND value_cents IS NULL
      AND value_percent IS NULL
      AND item_reference IS NOT NULL
    )
  )
);

CREATE TABLE public.redemptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL
    REFERENCES public.customers (id) ON DELETE RESTRICT,
  reward_id uuid NOT NULL
    REFERENCES public.rewards (id) ON DELETE RESTRICT,
  store_id uuid NOT NULL
    REFERENCES public.stores (id) ON DELETE RESTRICT,
  ledger_id uuid NOT NULL UNIQUE
    REFERENCES public.points_ledger (id) ON DELETE RESTRICT,
  redeemed_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX redemptions_customer_redeemed_idx
  ON public.redemptions (customer_id, redeemed_at DESC);

CREATE INDEX redemptions_reward_id_idx
  ON public.redemptions (reward_id);

CREATE INDEX redemptions_store_redeemed_idx
  ON public.redemptions (store_id, redeemed_at DESC);

CREATE TABLE public.referral_partners (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL UNIQUE
    REFERENCES public.customers (id) ON DELETE RESTRICT,
  name text NOT NULL,
  salon_name text,
  payout_terms text,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.referrals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL
    REFERENCES public.referral_partners (id) ON DELETE RESTRICT,
  customer_id uuid NOT NULL
    REFERENCES public.customers (id) ON DELETE RESTRICT,
  sale_id uuid
    REFERENCES public.sales (id) ON DELETE SET NULL,
  capture_method public.referral_capture_method_enum NOT NULL,
  status public.referral_status_enum NOT NULL DEFAULT 'pending',
  attributed_amount_cents integer
    CHECK (attributed_amount_cents >= 0),
  referred_at timestamptz NOT NULL DEFAULT now(),
  qualified_at timestamptz,
  hold_until timestamptz,
  approved_at timestamptz,
  paid_at timestamptz,
  rejected_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX referrals_partner_referred_idx
  ON public.referrals (partner_id, referred_at DESC);

CREATE INDEX referrals_customer_referred_idx
  ON public.referrals (customer_id, referred_at DESC);

CREATE INDEX referrals_status_hold_idx
  ON public.referrals (status, hold_until);

CREATE UNIQUE INDEX referrals_sale_id_uidx
  ON public.referrals (sale_id)
  WHERE sale_id IS NOT NULL;

CREATE TABLE public.referral_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL
    REFERENCES public.referral_partners (id) ON DELETE CASCADE,
  token_hash text NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  consumed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT referral_tokens_expiry_after_creation
    CHECK (expires_at > created_at),
  CONSTRAINT referral_tokens_consumed_after_creation
    CHECK (consumed_at IS NULL OR consumed_at >= created_at)
);

CREATE INDEX referral_tokens_partner_expires_idx
  ON public.referral_tokens (partner_id, expires_at DESC);

CREATE OR REPLACE FUNCTION public.set_row_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER staff_set_updated_at
  BEFORE UPDATE ON public.staff
  FOR EACH ROW EXECUTE FUNCTION public.set_row_updated_at();

CREATE TRIGGER devices_set_updated_at
  BEFORE UPDATE ON public.devices
  FOR EACH ROW EXECUTE FUNCTION public.set_row_updated_at();

CREATE TRIGGER rewards_set_updated_at
  BEFORE UPDATE ON public.rewards
  FOR EACH ROW EXECUTE FUNCTION public.set_row_updated_at();

CREATE TRIGGER referral_partners_set_updated_at
  BEFORE UPDATE ON public.referral_partners
  FOR EACH ROW EXECUTE FUNCTION public.set_row_updated_at();

CREATE TRIGGER referrals_set_updated_at
  BEFORE UPDATE ON public.referrals
  FOR EACH ROW EXECUTE FUNCTION public.set_row_updated_at();

CREATE OR REPLACE FUNCTION public.prevent_referral_self_attribution()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
DECLARE
  partner_customer_id uuid;
BEGIN
  SELECT customer_id
  INTO partner_customer_id
  FROM public.referral_partners
  WHERE id = NEW.partner_id;

  IF partner_customer_id = NEW.customer_id THEN
    RAISE EXCEPTION 'A referral partner cannot refer their own customer account';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER referrals_prevent_self_attribution
  BEFORE INSERT OR UPDATE OF partner_id, customer_id ON public.referrals
  FOR EACH ROW EXECUTE FUNCTION public.prevent_referral_self_attribution();

ALTER TABLE public.points_ledger
  ADD CONSTRAINT points_ledger_created_by_fkey
  FOREIGN KEY (created_by)
  REFERENCES public.staff (id)
  ON DELETE SET NULL;

CREATE INDEX points_ledger_created_by_idx
  ON public.points_ledger (created_by);

ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.redemptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_tokens ENABLE ROW LEVEL SECURITY;

-- Temporary staging read access, matching the existing core-table setup.
-- Replace these policies during roadmap 2.8.
CREATE POLICY staging_anon_select_staff
  ON public.staff FOR SELECT TO anon USING (true);

CREATE POLICY staging_anon_select_devices
  ON public.devices FOR SELECT TO anon USING (true);

CREATE POLICY staging_anon_select_rewards
  ON public.rewards FOR SELECT TO anon USING (true);

CREATE POLICY staging_anon_select_redemptions
  ON public.redemptions FOR SELECT TO anon USING (true);

CREATE POLICY staging_anon_select_referral_partners
  ON public.referral_partners FOR SELECT TO anon USING (true);

CREATE POLICY staging_anon_select_referrals
  ON public.referrals FOR SELECT TO anon USING (true);

CREATE POLICY staging_anon_select_referral_tokens
  ON public.referral_tokens FOR SELECT TO anon USING (true);

GRANT SELECT ON
  public.staff,
  public.devices,
  public.rewards,
  public.redemptions,
  public.referral_partners,
  public.referrals,
  public.referral_tokens
TO anon;

INSERT INTO public.rewards (
  code,
  name,
  cost_points,
  kind,
  value_cents
)
VALUES
  ('discount_10', '$10 off', 250, 'fixed_discount', 1000),
  ('discount_25', '$25 off', 500, 'fixed_discount', 2500);

COMMIT;
