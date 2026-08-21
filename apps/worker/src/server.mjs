/**
 * Lightspeed webhook receiver. Disabled by default.
 * Persist raw event → upsert sale → process_sale_loyalty (earn still DB-gated).
 */
import { createServer } from "node:http";
import { createClient } from "@supabase/supabase-js";

const PORT = Number(process.env.PORT ?? 8787);
const supabaseUrl = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey =
  process.env.SUPABASE_SECRET_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
const webhooksEnabled = process.env.LOYALTY_WEBHOOKS_ENABLED === "true";
const earnGlobal = process.env.LOYALTY_EARN_GLOBAL === "true";

function json(res, status, body) {
  res.writeHead(status, { "content-type": "application/json" });
  res.end(JSON.stringify(body));
}

function createAdminFetch(apiKey) {
  return (input, init) => {
    const headers = new Headers(init?.headers);
    if (
      apiKey.startsWith("sb_secret_") &&
      headers.get("authorization") === `Bearer ${apiKey}`
    ) {
      headers.delete("authorization");
    }
    return fetch(input, { ...init, headers });
  };
}

function mapSale(payload) {
  const sale = payload?.sale ?? payload?.data ?? payload;
  const saleId = sale?.id;
  if (!saleId) return null;
  const totals = sale.totals || {};
  const total = Number(
    totals.price_incl_tax ?? sale.total_price_incl ?? totals.price ?? sale.total_price ?? 0,
  );
  const totalCents = Math.round(total * 100);
  const occurred = sale.sale_date || sale.date || sale.created_at;
  if (!occurred) return null;
  return {
    lightspeed_sale_id: String(saleId),
    lightspeed_outlet_id: sale.outlet_id ?? sale.source?.outlet_id ?? null,
    lightspeed_customer_id: sale.customer_id ?? null,
    state: sale.state ?? null,
    total_cents: totalCents,
    eligible_cents: totalCents,
    occurred_at: occurred,
    raw: {
      id: sale.id,
      state: sale.state,
      sale_date: sale.sale_date,
      customer_id: sale.customer_id,
      outlet_id: sale.outlet_id,
      total_price_incl: sale.total_price_incl,
    },
  };
}

const server = createServer(async (req, res) => {
  const url = new URL(req.url ?? "/", `http://127.0.0.1:${PORT}`);

  if (req.method === "GET" && url.pathname === "/health") {
    json(res, 200, {
      ok: true,
      webhooksEnabled,
      earnGlobal,
    });
    return;
  }

  if (req.method === "POST" && url.pathname === "/webhooks/lightspeed") {
    if (!webhooksEnabled) {
      json(res, 503, { ok: false, reason: "webhooks_disabled" });
      return;
    }
    if (!supabaseUrl || !supabaseKey) {
      json(res, 500, { ok: false, reason: "missing_supabase" });
      return;
    }

    const chunks = [];
    for await (const chunk of req) chunks.push(chunk);
    let payload;
    try {
      payload = JSON.parse(Buffer.concat(chunks).toString("utf8") || "{}");
    } catch {
      json(res, 400, { ok: false, reason: "invalid_json" });
      return;
    }

    const supabase = createClient(supabaseUrl, supabaseKey, {
      auth: { persistSession: false, autoRefreshToken: false },
      global: { fetch: createAdminFetch(supabaseKey) },
    });

    const mapped = mapSale(payload);
    const saleId = mapped?.lightspeed_sale_id;
    if (!saleId) {
      json(res, 400, { ok: false, reason: "missing_sale_id" });
      return;
    }

    const { error: eventError } = await supabase.from("lightspeed_webhook_events").insert({
      lightspeed_sale_id: saleId,
      event_type: payload.type || payload.event_type || "sale.update",
      payload,
    });
    if (eventError && eventError.code !== "23505") {
      json(res, 500, { ok: false, reason: eventError.message });
      return;
    }

    const { error: upsertError } = await supabase
      .from("sales")
      .upsert(mapped, { onConflict: "lightspeed_sale_id" });
    if (upsertError) {
      json(res, 500, { ok: false, reason: upsertError.message });
      return;
    }

    const { data, error: rpcError } = await supabase.rpc("process_sale_loyalty", {
      p_lightspeed_sale_id: saleId,
    });
    await supabase
      .from("lightspeed_webhook_events")
      .update({
        processed_at: new Date().toISOString(),
        process_error: rpcError?.message ?? null,
      })
      .eq("lightspeed_sale_id", saleId)
      .is("processed_at", null);

    json(res, rpcError ? 500 : 200, { ok: !rpcError, result: data, error: rpcError?.message });
    return;
  }

  json(res, 404, { ok: false });
});

server.listen(PORT, () => {
  console.log(`worker listening on :${PORT} webhooks=${webhooksEnabled} earn_global=${earnGlobal}`);
});
