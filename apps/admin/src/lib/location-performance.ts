import type { SupabaseClient } from "@supabase/supabase-js";
import {
  HEALTH_WINDOWS,
  pacificDateDaysAgo,
  pacificDateDaysAgoFrom,
} from "@/lib/customer-health";

export type LocationWindowDays = 30 | 90;

export type LocationPerformanceRow = {
  id: string;
  name: string;
  sortRank: number;
  totalCustomers: number;
  visited30: number;
  visited90: number;
  lapsing: number;
  /** Null when this location has no closed sales in the window. */
  avgSpendCents30: number | null;
  avgSpendCents90: number | null;
  /** Avg visits per enrolled customer per month. Null without sales. */
  visitFrequency30: number | null;
  visitFrequency90: number | null;
};

export type LocationPerformanceData = {
  rows: LocationPerformanceRow[];
  /** ISO timestamp of newest ingested sale; sales windows are anchored here. */
  salesAsOf: string | null;
};

async function countOrZero(
  run: PromiseLike<{ count: number | null; error: { message: string } | null }>
) {
  const { count, error } = await run;
  if (error) throw new Error(error.message);
  return count ?? 0;
}

type SaleRow = {
  store_id: string | null;
  total_cents: number;
  occurred_at: string;
};

async function fetchClosedSalesSince(
  supabase: SupabaseClient,
  sinceDate: string,
): Promise<SaleRow[]> {
  const pageSize = 1000;
  const all: SaleRow[] = [];
  for (let from = 0; ; from += pageSize) {
    const { data, error } = await supabase
      .from("sales")
      .select("store_id, total_cents, occurred_at")
      .eq("state", "closed")
      .gte("occurred_at", sinceDate)
      .order("occurred_at", { ascending: true })
      .range(from, from + pageSize - 1);

    if (error) throw new Error(error.message);
    if (!data?.length) break;
    all.push(...(data as SaleRow[]));
    if (data.length < pageSize) break;
  }
  return all;
}

function aggregateSales(
  sales: SaleRow[],
  storeId: string,
  sinceDate: string,
  windowDays: LocationWindowDays,
  enrolled: number
): { avgSpendCents: number | null; visitFrequency: number | null } {
  const inWindow = sales.filter(
    (s) => s.store_id === storeId && s.occurred_at.slice(0, 10) >= sinceDate
  );
  if (inWindow.length === 0) {
    return { avgSpendCents: null, visitFrequency: null };
  }

  const sum = inWindow.reduce((acc, s) => acc + (s.total_cents ?? 0), 0);
  const avgSpendCents = Math.round(sum / inWindow.length);
  const months = windowDays / 30;
  const visitFrequency =
    enrolled > 0 ? inWindow.length / enrolled / months : null;

  return { avgSpendCents, visitFrequency };
}

export async function fetchLocationPerformance(
  supabase: SupabaseClient,
): Promise<LocationPerformanceData> {
  const since30Live = pacificDateDaysAgo(30);
  const since90Live = pacificDateDaysAgo(90);
  const lapsingFrom = pacificDateDaysAgo(HEALTH_WINDOWS.lapsingToDays);
  const lapsingTo = pacificDateDaysAgo(HEALTH_WINDOWS.activeDays);

  const { data: stores, error } = await supabase
    .from("stores")
    .select("id, name, sort_rank")
    .eq("active", true)
    .order("sort_rank");

  if (error || !stores?.length) {
    return { rows: [], salesAsOf: null };
  }

  const { data: latestSale, error: latestError } = await supabase
    .from("sales")
    .select("occurred_at")
    .eq("state", "closed")
    .order("occurred_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (latestError) throw new Error(latestError.message);

  const salesAsOf = latestSale?.occurred_at ?? null;
  // Anchor spend/frequency to newest ingested sale so historical imports still compute.
  const asOfDate = salesAsOf ? new Date(salesAsOf) : new Date();
  const since30Sales = pacificDateDaysAgoFrom(asOfDate, 30);
  const since90Sales = pacificDateDaysAgoFrom(asOfDate, 90);

  const sales = salesAsOf
    ? await fetchClosedSalesSince(supabase, since90Sales)
    : [];

  const rows = await Promise.all(
    stores.map(async (store) => {
      const base = () =>
        supabase
          .from("customers")
          .select("id", { count: "exact", head: true })
          .eq("home_store_id", store.id);

      const [totalCustomers, visited30, visited90, lapsing] = await Promise.all([
        countOrZero(base()),
        countOrZero(base().gte("last_seen_at", since30Live)),
        countOrZero(base().gte("last_seen_at", since90Live)),
        countOrZero(
          base().gte("last_seen_at", lapsingFrom).lt("last_seen_at", lapsingTo)
        ),
      ]);

      const m30 = aggregateSales(sales, store.id, since30Sales, 30, totalCustomers);
      const m90 = aggregateSales(sales, store.id, since90Sales, 90, totalCustomers);

      return {
        id: store.id,
        name: store.name,
        sortRank: Number(store.sort_rank),
        totalCustomers,
        visited30,
        visited90,
        lapsing,
        avgSpendCents30: m30.avgSpendCents,
        avgSpendCents90: m90.avgSpendCents,
        visitFrequency30: m30.visitFrequency,
        visitFrequency90: m90.visitFrequency,
      } satisfies LocationPerformanceRow;
    })
  );

  return { rows, salesAsOf };
}

export function activeCount(row: LocationPerformanceRow, window: LocationWindowDays) {
  return window === 30 ? row.visited30 : row.visited90;
}

export function activeRatePct(row: LocationPerformanceRow, window: LocationWindowDays) {
  if (row.totalCustomers <= 0) return 0;
  return Math.round((activeCount(row, window) / row.totalCustomers) * 100);
}

export function avgSpendCents(
  row: LocationPerformanceRow,
  window: LocationWindowDays
): number | null {
  return window === 30 ? row.avgSpendCents30 : row.avgSpendCents90;
}

export function visitFrequency(
  row: LocationPerformanceRow,
  window: LocationWindowDays
): number | null {
  return window === 30 ? row.visitFrequency30 : row.visitFrequency90;
}
