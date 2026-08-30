# Lux Pro

Loyalty platform for Las Vegas beauty supply. **Current build:** beautician **referral sidecar** (Expo) next to TapMango + Lightspeed — not a TapMango cutover.

Canonical product write-up: [`docs/referral-sidecar.md`](docs/referral-sidecar.md).

## Apps

| Path | Purpose |
|---|---|
| `apps/admin` | Next.js staging admin — verify sample import |
| `apps/customer` | Expo customer + partner app (EAS). Not wired to Supabase yet. |
| `apps/worker` | Lightspeed ingest (poll now, webhooks later). Add another store = another token. Not deployed. |
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

Expect overview: **196,493** customers · **6** stores · **20,100,952** opening points.

Live earn is **off** on every store (`stores.loyalty_earn_enabled = false`). Do not flip that flag until a pilot store is chosen. Import with `--enable-earn` still no-ops until then.
