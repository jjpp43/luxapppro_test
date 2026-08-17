# Lux Pro Admin (staging)

Next.js app to verify the TapMango sample import on Supabase project `luxproapp_test`.

## Setup

```bash
cd apps/admin
cp .env.example .env.local
# fill NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY
npm install
npm run dev
```

Open http://localhost:3000 — overview should show **196,493** customers, **6** stores, **20,100,952** opening points.

## Notes

- Uses the **anon** key plus temporary staging `SELECT` RLS policies (not production-safe).
- Sample CSV under `data/tapmango/` is gitignored (PII).
