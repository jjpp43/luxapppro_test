# Lux Pro Admin (staging)

Next.js app to verify the TapMango sample import on Supabase project `luxproapp_test`.

## Setup

```bash
cd apps/admin
cp .env.example .env.local
# fill Supabase URL, publishable/anon key, secret key, and site URL
npm install
npm run bootstrap:owner -- owner@example.com "Owner Name"
npm run dev
```

The bootstrap command sends the first owner an invitation. The owner sets a
password from that email, signs in, and can invite managers or other owners.

## Notes

- Dashboard reads use the signed-in SSR session and authenticated RLS policies.
- Anonymous table grants and temporary staging policies have been removed.
- `SUPABASE_SECRET_KEY` (or legacy `SUPABASE_SERVICE_ROLE_KEY`) is server-only.
  Never prefix it with `NEXT_PUBLIC_`.
- Add local and deployed `/auth/callback` URLs to Supabase Auth redirect URLs.
- Sample CSV under `data/tapmango/` is gitignored (PII).
