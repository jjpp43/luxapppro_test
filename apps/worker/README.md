# Lightspeed ingest worker

Always-on process that copies Lightspeed sales into Supabase. Apps do not call it.

## Why it exists

Lightspeed owns the register. This worker is the only place that should pull (or later receive) those tickets, upsert `sales`, and call `process_sale_loyalty`. Earn still respects `stores.loyalty_earn_enabled` (default off).

## One worker, many stores

Each Lightspeed **retailer login** is a source (`domain` + personal token). Decatur is `luxbeauty4` today. Craig / East Twain / West Sahara are more sources when those tokens exist — same poll loop, no new app.

Outlets map through `stores.lightspeed_outlet_id`.

## Run locally

```bash
cd apps/worker
cp .env.example .env
# fill SUPABASE_* and LIGHTSPEED_DOMAIN / LIGHTSPEED_PERSONAL_TOKEN
npm install
npm start
```

- `GET /health` — configured sources (no tokens)
- `POST /jobs/poll` — pull the lookback window now
- `POST /webhooks/lightspeed` — disabled until `LOYALTY_WEBHOOKS_ENABLED=true`

Polling uses the same search API as `scripts/import_lightspeed_sales.py`. Webhooks are not registered on the retailer yet (roadmap 3.16).

## Deploy (Fly.io)

Config is in `fly.toml`. Do not deploy until the Fly org is in the client name.

From this directory:

```bash
fly launch --copy-config --no-deploy   # first time only, if the app does not exist yet
fly secrets set SUPABASE_URL=... SUPABASE_SECRET_KEY=... LIGHTSPEED_DOMAIN=... LIGHTSPEED_PERSONAL_TOKEN=...
fly deploy
```

Must stay true in `fly.toml`: region `sjc`, `auto_stop_machines = "off"`, `min_machines_running = 1`.
