# Lux Pro

Loyalty platform for Las Vegas beauty supply (leaving TapMango).

## Apps

| Path | Purpose |
|---|---|
| `apps/admin` | Next.js staging admin — verify sample import |
| `docs/` | Architecture, schema, RLS |
| `supabase/migrations/` | Schema applied to `luxproapp_test` |
| `data/tapmango/` | Sample CSV (gitignored, PII) |

## Quick start (admin)

```bash
cd apps/admin
cp .env.example .env.local   # add Supabase URL + anon key
npm install
npm run dev
```

Expect overview: **100** customers · **3** stores · **9,547** points.
