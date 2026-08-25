import { loadOutletMap, mapSale } from "./supabase.mjs";
import { pollWindow, searchSales } from "./lightspeed.mjs";

const DEFAULT_STATES = ["closed"];

function saleStates() {
  const raw = process.env.LIGHTSPEED_SALE_STATES;
  if (raw == null || raw.trim() === "") return DEFAULT_STATES;
  if (raw.trim() === "*") return [];
  return raw.split(",").map((s) => s.trim()).filter(Boolean);
}

async function upsertAndProcess(supabase, rows) {
  if (!rows.length) return { upserted: 0, processed: 0 };
  const { error } = await supabase.from("sales").upsert(rows, {
    onConflict: "lightspeed_sale_id",
  });
  if (error) throw new Error(error.message);

  const ids = rows.map((row) => row.lightspeed_sale_id);
  const { error: rpcError } = await supabase.rpc("process_sales_loyalty", {
    p_lightspeed_sale_ids: ids,
  });
  if (rpcError) throw new Error(rpcError.message);
  return { upserted: rows.length, processed: ids.length };
}

export async function pollAllSources(supabase, sources) {
  const outletToStore = await loadOutletMap(supabase);
  const lookbackHours = Number(process.env.LIGHTSPEED_LOOKBACK_HOURS ?? 48);
  const { dateFrom, dateTo } = pollWindow(lookbackHours);
  const states = saleStates();
  const pageSize = Math.min(Number(process.env.LIGHTSPEED_PAGE_SIZE ?? 200), 1000);
  const maxPages = Number(process.env.LIGHTSPEED_MAX_PAGES ?? 40);

  const results = [];
  for (const source of sources) {
    let offset = 0;
    let seen = 0;
    let kept = 0;
    for (let page = 1; page <= maxPages; page += 1) {
      const payload = await searchSales(source, {
        dateFrom,
        dateTo,
        states,
        pageSize,
        offset,
      });
      const sales = payload.data || [];
      seen += sales.length;
      const mapped = [];
      for (const sale of sales) {
        if (states.length && !states.includes(sale.state)) continue;
        const row = mapSale(sale, outletToStore);
        if (row) mapped.push(row);
      }
      kept += mapped.length;
      if (mapped.length) await upsertAndProcess(supabase, mapped);

      offset += sales.length;
      const totalCount = payload.total_count;
      const hasNext = payload.page_info?.has_next_page;
      if (!sales.length) break;
      if (totalCount != null && offset >= Number(totalCount)) break;
      if (hasNext === false) break;
    }
    results.push({ source: source.id, seen, kept });
    console.log(
      `poll ${source.id}: seen=${seen} kept=${kept} window=${dateFrom}→${dateTo}`,
    );
  }
  return { dateFrom, dateTo, results };
}

export async function ingestWebhookPayload(supabase, payload) {
  const outletToStore = await loadOutletMap(supabase);
  const sale = payload?.sale ?? payload?.data ?? payload;
  const mapped = mapSale(sale, outletToStore);
  if (!mapped) {
    return { ok: false, reason: "missing_sale_id" };
  }

  const { error: eventError } = await supabase.from("lightspeed_webhook_events").insert({
    lightspeed_sale_id: mapped.lightspeed_sale_id,
    event_type: payload.type || payload.event_type || "sale.update",
    payload,
  });
  if (eventError && eventError.code !== "23505") {
    return { ok: false, reason: eventError.message };
  }

  const { error: upsertError } = await supabase
    .from("sales")
    .upsert(mapped, { onConflict: "lightspeed_sale_id" });
  if (upsertError) return { ok: false, reason: upsertError.message };

  const { data, error: rpcError } = await supabase.rpc("process_sale_loyalty", {
    p_lightspeed_sale_id: mapped.lightspeed_sale_id,
  });
  await supabase
    .from("lightspeed_webhook_events")
    .update({
      processed_at: new Date().toISOString(),
      process_error: rpcError?.message ?? null,
    })
    .eq("lightspeed_sale_id", mapped.lightspeed_sale_id)
    .is("processed_at", null);

  return {
    ok: !rpcError,
    result: data,
    error: rpcError?.message,
  };
}
