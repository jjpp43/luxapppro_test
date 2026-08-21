import type { SupabaseClient } from "@supabase/supabase-js";

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

export const HEALTH_LABELS: Record<HealthKey, string> = {
  new: "New",
  active: "Active",
  lapsing: "Lapsing",
  atRisk: "At-Risk",
  inactive: "Inactive",
};

export const HEALTH_QUERY_VALUES: Record<HealthKey, string> = {
  new: "new",
  active: "active",
  lapsing: "lapsing",
  atRisk: "at-risk",
  inactive: "inactive",
};

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

export function pacificDateDaysAgoFrom(from: Date, days: number): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "America/Los_Angeles",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(from);
  const y = Number(parts.find((p) => p.type === "year")?.value);
  const m = Number(parts.find((p) => p.type === "month")?.value);
  const d = Number(parts.find((p) => p.type === "day")?.value);
  const noonUtc = new Date(Date.UTC(y, m - 1, d, 12, 0, 0));
  noonUtc.setUTCDate(noonUtc.getUTCDate() - days);
  return noonUtc.toISOString().slice(0, 10);
}

export function pacificDateDaysAgo(days: number): string {
  return pacificDateDaysAgoFrom(new Date(), days);
}

export function parseHealthQuery(value: string | undefined): HealthKey | null {
  if (!value) return null;
  const match = Object.entries(HEALTH_QUERY_VALUES).find(
    ([, queryValue]) => queryValue === value,
  );
  return (match?.[0] as HealthKey | undefined) ?? null;
}

export function healthCustomersHref(key: HealthKey) {
  return `/customers?health=${HEALTH_QUERY_VALUES[key]}`;
}

function notNewOrFilter(enrolledSince: string) {
  return `registered_at.lt.${enrolledSince},and(registered_at.is.null,created_at.lt.${enrolledSince})`;
}

export function healthFilterExpression(key: HealthKey, now = new Date()) {
  const enrolledSince = pacificDateDaysAgoFrom(now, HEALTH_WINDOWS.newDays);
  const activeSince = pacificDateDaysAgoFrom(now, HEALTH_WINDOWS.activeDays);
  const lapsingSince = pacificDateDaysAgoFrom(
    now,
    HEALTH_WINDOWS.lapsingToDays,
  );
  const atRiskSince = pacificDateDaysAgoFrom(
    now,
    HEALTH_WINDOWS.atRiskToDays,
  );
  const notNew = `or(${notNewOrFilter(enrolledSince)})`;

  switch (key) {
    case "new":
      return `registered_at.gte.${enrolledSince},and(registered_at.is.null,created_at.gte.${enrolledSince})`;
    case "active":
      return `and(${notNew},last_seen_at.gte.${activeSince})`;
    case "lapsing":
      return `and(${notNew},last_seen_at.gte.${lapsingSince},last_seen_at.lt.${activeSince})`;
    case "atRisk":
      return `and(${notNew},last_seen_at.gte.${atRiskSince},last_seen_at.lt.${lapsingSince})`;
    case "inactive":
      return `and(${notNew},or(last_seen_at.lt.${atRiskSince},last_seen_at.is.null))`;
  }
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

export async function fetchCustomerHealth(
  supabase: SupabaseClient,
): Promise<CustomerHealthSnapshotData> {
  const now = new Date();
  const enrolledSince = pacificDateDaysAgoFrom(now, HEALTH_WINDOWS.newDays);
  const priorEnrolledFrom = pacificDateDaysAgoFrom(
    now,
    HEALTH_WINDOWS.newDays * 2,
  );

  const customers = () =>
    supabase.from("customers").select("id", { count: "exact", head: true });

  let total: number;
  let newCount: number;
  let priorNew: number;
  let active: number;
  let lapsing: number;
  let atRisk: number;
  let inactive: number;

  try {
    [total, newCount, priorNew, active, lapsing, atRisk, inactive] =
      await Promise.all([
        count(customers()),
        count(customers().or(healthFilterExpression("new", now))),
        count(
          customers()
            .lt("registered_at", enrolledSince)
            .gte("registered_at", priorEnrolledFrom),
        ),
        count(customers().or(healthFilterExpression("active", now))),
        count(customers().or(healthFilterExpression("lapsing", now))),
        count(customers().or(healthFilterExpression("atRisk", now))),
        count(customers().or(healthFilterExpression("inactive", now))),
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

  const buckets: HealthBucket[] = [
    {
      key: "new",
      label: HEALTH_LABELS.new,
      count: newCount,
      pctOfTotal: pct(newCount, total),
      trendPct: trendPct(newCount, priorNew),
      color: "#4C8DFF",
      inChart: true,
    },
    {
      key: "active",
      label: HEALTH_LABELS.active,
      count: active,
      pctOfTotal: pct(active, total),
      trendPct: null,
      color: "#22C57A",
      inChart: true,
    },
    {
      key: "lapsing",
      label: HEALTH_LABELS.lapsing,
      count: lapsing,
      pctOfTotal: pct(lapsing, total),
      trendPct: null,
      color: "#F0B27A",
      inChart: true,
    },
    {
      key: "atRisk",
      label: HEALTH_LABELS.atRisk,
      count: atRisk,
      pctOfTotal: pct(atRisk, total),
      trendPct: null,
      color: "#E67E4D",
      inChart: true,
    },
    {
      key: "inactive",
      label: HEALTH_LABELS.inactive,
      count: inactive,
      pctOfTotal: pct(inactive, total),
      trendPct: null,
      color: "#D1D5DB",
      inChart: false,
    },
  ];

  return { total, buckets };
}
