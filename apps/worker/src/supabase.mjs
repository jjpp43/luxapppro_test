import { createClient } from "@supabase/supabase-js";

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

export function createServiceClient() {
  const url = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key =
    process.env.SUPABASE_SECRET_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !key) {
    throw new Error("Missing SUPABASE_URL or SUPABASE_SECRET_KEY");
  }
  return createClient(url, key, {
    auth: { persistSession: false, autoRefreshToken: false },
    global: { fetch: createAdminFetch(key) },
  });
}

export async function loadOutletMap(supabase) {
  const { data, error } = await supabase
    .from("stores")
    .select("id, name, lightspeed_outlet_id")
    .not("lightspeed_outlet_id", "is", null);
  if (error) throw new Error(error.message);
  const map = new Map();
  for (const store of data ?? []) {
    if (store.lightspeed_outlet_id) {
      map.set(store.lightspeed_outlet_id, store.id);
    }
  }
  return map;
}

export function mapSale(sale, outletToStore) {
  const saleId = sale?.id;
  if (!saleId) return null;

  const totals = sale.totals || {};
  const total = Number(
    totals.price_incl_tax ??
      sale.total_price_incl ??
      totals.price ??
      sale.total_price ??
      0,
  );
  const totalCents = Math.round(total * 100);
  const occurred = sale.sale_date || sale.date || sale.created_at;
  if (!occurred) return null;

  let outletId = sale.outlet_id ?? null;
  if (sale.source && typeof sale.source === "object") {
    outletId = sale.source.outlet_id || outletId;
  }
  const storeId = outletId ? outletToStore.get(outletId) : undefined;

  const row = {
    lightspeed_sale_id: String(saleId),
    lightspeed_outlet_id: outletId,
    lightspeed_customer_id: sale.customer_id ?? null,
    state: sale.state ?? null,
    total_cents: totalCents,
    eligible_cents: totalCents,
    occurred_at: occurred,
    raw: {
      id: sale.id,
      state: sale.state,
      sale_date: sale.sale_date,
      created_at: sale.created_at,
      outlet_id: outletId,
      customer_id: sale.customer_id,
      total_price_incl: sale.total_price_incl ?? sale.total_price,
    },
  };
  if (storeId) row.store_id = storeId;
  return row;
}
