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

## Run the demo

iOS Simulator on a Mac. No Lightspeed token, no Supabase. Do not install Expo Go. Do not use the browser.

You need Node 22, Xcode (open it once so the Simulator is installed), and CocoaPods (`brew install cocoapods`).

```bash
git clone https://github.com/jjpp43/luxapppro_test.git
cd luxapppro_test/apps/customer
npm install
npx expo run:ios
```

The first build compiles the native app and can take several minutes. When it finishes, the Simulator opens Lux Pro.

Any US phone number, then code `000000`. Nothing is texted. The app does not show that code.

**Beautician:** Account → turn on Beautician tools → List → pick a few products → Show QR. The `$12` credit is a placeholder.

**Customer claim:** the Simulator has no camera, so it cannot scan that QR. Open Scan and press **Load a sample referral**. Home shows `LUX TEST 5`, 5% off, a `$20` minimum, and a code to read at the register.

This is a clickable fake. The product list is not Decatur stock, and nothing is sent to Lightspeed.

Longer meeting script: [`docs/demo-for-pm.md`](docs/demo-for-pm.md). Run those steps in the Simulator. On Scan, use **Load a sample referral**.

## Quick start (admin)

```bash
cd apps/admin
cp .env.example .env.local   # add Supabase URL + anon key
npm install
npm run dev
```

Expect overview: **196,493** customers · **6** stores · **20,100,952** opening points.

Live earn is **off** on every store (`stores.loyalty_earn_enabled = false`). Do not flip that flag until a pilot store is chosen. Import with `--enable-earn` still no-ops until then.
