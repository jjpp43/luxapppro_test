import { pacificDateDaysAgoFrom } from "@/lib/customer-health";
import { supabase } from "@/lib/supabase";

export type PulseMetric = {
  value: number | null;
  trendPct: number | null;
  series: number[];
  footnote: string;
};

export type BusinessPulseData = {
  periodStart: string;
  periodEnd: string;
  totalCustomers: PulseMetric;
  engaged: PulseMetric;
  avgSpendCents: PulseMetric;
  monthlyVisitRate: PulseMetric;
};

function pacificYmd(d: Date): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "America/Los_Angeles",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(d);
  const y = parts.find((p) => p.type === "year")?.value;
  const m = parts.find((p) => p.type === "month")?.value;
  const day = parts.find((p) => p.type === "day")?.value;
  return `${y}-${m}-${day}`;
}

function addDaysYmd(ymd: string, days: number): string {
  const [y, m, d] = ymd.split("-").map(Number);
  const dt = new Date(Date.UTC(y, m - 1, d, 12, 0, 0));
  dt.setUTCDate(dt.getUTCDate() + days);
  return dt.toISOString().slice(0, 10);
}

function enumerateDays(startYmd: string, endYmd: string): string[] {
  const days: string[] = [];
  for (let d = startYmd; d <= endYmd; d = addDaysYmd(d, 1)) {
    days.push(d);
  }
  return days;
}

async function countOrZero(
  run: PromiseLike<{ count: number | null; error: { message: string } | null }>
) {
  const { count, error } = await run;
  if (error) throw new Error(error.message);
  return count ?? 0;
}

async function registeredAtInRange(fromIso: string, toIsoExclusive: string) {
  const pageSize = 1000;
  const stamps: string[] = [];
  for (let from = 0; ; from += pageSize) {
    const { data, error } = await supabase
      .from("customers")
      .select("registered_at")
      .gte("registered_at", fromIso)
      .lt("registered_at", toIsoExclusive)
      .range(from, from + pageSize - 1);
    if (error) throw new Error(error.message);
    if (!data?.length) break;
    for (const row of data) {
      if (row.registered_at) stamps.push(row.registered_at);
    }
    if (data.length < pageSize) break;
  }
  return stamps;
}

function pendingMetric(footnote: string): PulseMetric {
  return { value: null, trendPct: null, series: [], footnote };
}

export async function fetchBusinessPulse(): Promise<BusinessPulseData> {
  const now = new Date();
  const periodEnd = pacificDateDaysAgoFrom(now, 1);
  const periodStart = addDaysYmd(periodEnd, -89);
  const nextDay = addDaysYmd(periodEnd, 1);

  const startIso = `${periodStart}T00:00:00-07:00`;
  const endExclusiveIso = `${nextDay}T00:00:00-07:00`;

  const [total, stamps] = await Promise.all([
    countOrZero(supabase.from("customers").select("id", { count: "exact", head: true })),
    registeredAtInRange(startIso, endExclusiveIso),
  ]);

  const dayKeys = enumerateDays(periodStart, periodEnd);
  const enrolledByDay = new Map(dayKeys.map((d) => [d, 0]));
  for (const stamp of stamps) {
    const day = pacificYmd(new Date(stamp));
    if (enrolledByDay.has(day)) {
      enrolledByDay.set(day, (enrolledByDay.get(day) ?? 0) + 1);
    }
  }

  const enrolled = stamps.length;
  const base = Math.max(0, total - enrolled);
  let running = base;
  const series = dayKeys.map((d) => {
    running += enrolledByDay.get(d) ?? 0;
    return running;
  });

  const trendPct =
    base > 0 ? Math.round((enrolled / base) * 100) : enrolled > 0 ? 100 : 0;

  return {
    periodStart,
    periodEnd,
    totalCustomers: {
      value: total,
      trendPct,
      series,
      footnote: `${enrolled.toLocaleString("en-US")} enrolled in last 90 days`,
    },
    engaged: pendingMetric(
      "Unique customers who visited this period — waiting on other stores’ POS"
    ),
    avgSpendCents: pendingMetric("Across visits — waiting on other stores’ POS"),
    monthlyVisitRate: pendingMetric(
      "Visits per engaged customer / month — waiting on other stores’ POS"
    ),
  };
}
