import { HEALTH_WINDOWS, pacificDateDaysAgo } from "@/lib/customer-health";
import { supabase } from "@/lib/supabase";

export type LocationWindowDays = 30 | 90;

export type LocationPerformanceRow = {
  id: string;
  name: string;
  totalCustomers: number;
  visited30: number;
  visited90: number;
  lapsing: number;
  /** Null until Lightspeed sales are ingested. */
  avgSpendCents: number | null;
  /** Avg visits per customer per month in the window. Null until sales exist. */
  visitFrequency: number | null;
};

export type LocationPerformanceData = {
  rows: LocationPerformanceRow[];
};

async function countOrZero(
  run: PromiseLike<{ count: number | null; error: { message: string } | null }>
) {
  const { count, error } = await run;
  if (error) throw new Error(error.message);
  return count ?? 0;
}

export async function fetchLocationPerformance(): Promise<LocationPerformanceData> {
  const since30 = pacificDateDaysAgo(30);
  const since90 = pacificDateDaysAgo(90);
  const lapsingFrom = pacificDateDaysAgo(HEALTH_WINDOWS.lapsingToDays);
  const lapsingTo = pacificDateDaysAgo(HEALTH_WINDOWS.activeDays);

  const { data: stores, error } = await supabase
    .from("stores")
    .select("id, name")
    .eq("active", true)
    .order("name");

  if (error || !stores?.length) {
    return { rows: [] };
  }

  const rows = await Promise.all(
    stores.map(async (store) => {
      const base = () =>
        supabase
          .from("customers")
          .select("id", { count: "exact", head: true })
          .eq("home_store_id", store.id);

      const [totalCustomers, visited30, visited90, lapsing] = await Promise.all([
        countOrZero(base()),
        countOrZero(base().gte("last_seen_at", since30)),
        countOrZero(base().gte("last_seen_at", since90)),
        countOrZero(
          base().gte("last_seen_at", lapsingFrom).lt("last_seen_at", lapsingTo)
        ),
      ]);

      return {
        id: store.id,
        name: store.name,
        totalCustomers,
        visited30,
        visited90,
        lapsing,
        avgSpendCents: null,
        visitFrequency: null,
      } satisfies LocationPerformanceRow;
    })
  );

  return { rows };
}

export function activeCount(row: LocationPerformanceRow, window: LocationWindowDays) {
  return window === 30 ? row.visited30 : row.visited90;
}

export function activeRatePct(row: LocationPerformanceRow, window: LocationWindowDays) {
  if (row.totalCustomers <= 0) return 0;
  return Math.round((activeCount(row, window) / row.totalCustomers) * 100);
}
