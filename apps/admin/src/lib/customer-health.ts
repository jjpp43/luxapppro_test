import { supabase } from "@/lib/supabase";

/** Mutually exclusive lifecycle buckets. New wins over visit windows. */
export const HEALTH_WINDOWS = {
  newDays: 60,
  activeDays: 120,
  lapsingFromDays: 121,
  lapsingToDays: 240,
  atRiskFromDays: 241,
  atRiskToDays: 365,
} as const;

export const HEALTH_DEFINITIONS = {
  new: "Recently enrolled customers who haven't returned yet, or who first visited shortly after signing up. Enrolled in the last 60 days.",
  active:
    "Customers who visited within the last 120 days — the active window for your business type.",
  lapsing:
    "Customers whose last visit was 121–240 days ago and are slipping toward inactive. A good re-engagement target.",
  atRisk:
    "Customers whose last visit was 241–365 days ago and are at risk of churning. Your most urgent re-engagement target.",
  inactive:
    "Customers whose last visit was more than 365 days ago and are effectively churned.",
} as const;

export type HealthKey = keyof typeof HEALTH_DEFINITIONS;

export type HealthBucket = {
  key: HealthKey;
  label: string;
  count: number;
  pctOfTotal: number;
  /** Period-over-period %; null when we cannot compute it honestly. */
  trendPct: number | null;
  color: string;
  inChart: boolean;
};

export type CustomerHealthSnapshotData = {
  total: number;
  buckets: HealthBucket[];
};

type CountQuery = PromiseLike<{ count: number | null; error: { message: string } | null }>;

export function pacificDateDaysAgo(days: number): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "America/Los_Angeles",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(new Date());
  const y = Number(parts.find((p) => p.type === "year")?.value);
  const m = Number(parts.find((p) => p.type === "month")?.value);
  const d = Number(parts.find((p) => p.type === "day")?.value);
  const noonUtc = new Date(Date.UTC(y, m - 1, d, 12, 0, 0));
  noonUtc.setUTCDate(noonUtc.getUTCDate() - days);
  return noonUtc.toISOString().slice(0, 10);
}

function notNewOrFilter(enrolledSince: string) {
  return `registered_at.lt.${enrolledSince},and(registered_at.is.null,created_at.lt.${enrolledSince})`;
}

async function count(run: CountQuery) {
  const { count, error } = await run;
  if (error) throw new Error(error.message);
  return count ?? 0;
}

function pct(part: number, total: number) {
  if (total <= 0) return 0;
  return Math.round((part / total) * 100);
}

function trendPct(current: number, previous: number): number | null {
  if (previous <= 0) return current > 0 ? 100 : null;
  return Math.round(((current - previous) / previous) * 100);
}

export async function fetchCustomerHealth(): Promise<CustomerHealthSnapshotData> {
  const enrolledSince = pacificDateDaysAgo(HEALTH_WINDOWS.newDays);
  const priorEnrolledFrom = pacificDateDaysAgo(HEALTH_WINDOWS.newDays * 2);
  const activeSince = pacificDateDaysAgo(HEALTH_WINDOWS.activeDays);
  const lapsingSince = pacificDateDaysAgo(HEALTH_WINDOWS.lapsingToDays);
  const atRiskSince = pacificDateDaysAgo(HEALTH_WINDOWS.atRiskToDays);
  const notNew = notNewOrFilter(enrolledSince);

  const customers = () =>
    supabase.from("customers").select("id", { count: "exact", head: true });

  let total: number;
  let newCount: number;
  let priorNew: number;
  let active: number;
  let lapsing: number;
  let atRisk: number;

  try {
    [total, newCount, priorNew, active, lapsing, atRisk] = await Promise.all([
      count(customers()),
      count(
        customers().or(
          `registered_at.gte.${enrolledSince},and(registered_at.is.null,created_at.gte.${enrolledSince})`
        )
      ),
      count(
        customers()
          .lt("registered_at", enrolledSince)
          .gte("registered_at", priorEnrolledFrom)
      ),
      count(customers().gte("last_seen_at", activeSince).or(notNew)),
      count(
        customers()
          .gte("last_seen_at", lapsingSince)
          .lt("last_seen_at", activeSince)
          .or(notNew)
      ),
      count(
        customers()
          .gte("last_seen_at", atRiskSince)
          .lt("last_seen_at", lapsingSince)
          .or(notNew)
      ),
    ]);
  } catch {
    return {
      total: 0,
      buckets: [
        { key: "new", label: "New", count: 0, pctOfTotal: 0, trendPct: null, color: "#4C8DFF", inChart: true },
        { key: "active", label: "Active", count: 0, pctOfTotal: 0, trendPct: null, color: "#22C57A", inChart: true },
        { key: "lapsing", label: "Lapsing", count: 0, pctOfTotal: 0, trendPct: null, color: "#F0B27A", inChart: true },
        { key: "atRisk", label: "At-Risk", count: 0, pctOfTotal: 0, trendPct: null, color: "#E67E4D", inChart: true },
        { key: "inactive", label: "Inactive", count: 0, pctOfTotal: 0, trendPct: null, color: "#D1D5DB", inChart: false },
      ],
    };
  }

  const classified = newCount + active + lapsing + atRisk;
  const inactive = Math.max(0, total - classified);

  const buckets: HealthBucket[] = [
    {
      key: "new",
      label: "New",
      count: newCount,
      pctOfTotal: pct(newCount, total),
      trendPct: trendPct(newCount, priorNew),
      color: "#4C8DFF",
      inChart: true,
    },
    {
      key: "active",
      label: "Active",
      count: active,
      pctOfTotal: pct(active, total),
      trendPct: null,
      color: "#22C57A",
      inChart: true,
    },
    {
      key: "lapsing",
      label: "Lapsing",
      count: lapsing,
      pctOfTotal: pct(lapsing, total),
      trendPct: null,
      color: "#F0B27A",
      inChart: true,
    },
    {
      key: "atRisk",
      label: "At-Risk",
      count: atRisk,
      pctOfTotal: pct(atRisk, total),
      trendPct: null,
      color: "#E67E4D",
      inChart: true,
    },
    {
      key: "inactive",
      label: "Inactive",
      count: inactive,
      pctOfTotal: pct(inactive, total),
      trendPct: null,
      color: "#D1D5DB",
      inChart: false,
    },
  ];

  return { total, buckets };
}
