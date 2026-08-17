"use client";

import { useMemo, useState } from "react";
import {
  activeRatePct,
  type LocationPerformanceData,
  type LocationPerformanceRow,
  type LocationWindowDays,
} from "@/lib/location-performance";

type SortKey =
  | "name"
  | "totalCustomers"
  | "activeRate"
  | "avgSpend"
  | "visitFrequency"
  | "lapsing";

const COLUMNS: {
  key: SortKey;
  label: string;
  tip: string;
  align?: "right";
}[] = [
  {
    key: "totalCustomers",
    label: "Total Customers",
    tip: "Enrolled customers whose home store is this location.",
    align: "right",
  },
  {
    key: "activeRate",
    label: "Active Rate",
    tip: "Customers who visited in the selected period, divided by this location’s enrolled customer base.",
    align: "right",
  },
  {
    key: "avgSpend",
    label: "Avg Spend/Visit",
    tip: "Average paid ticket per visit over the selected window. Requires Lightspeed sales.",
    align: "right",
  },
  {
    key: "visitFrequency",
    label: "Visit Frequency",
    tip: "Average visits per enrolled customer per month over the selected window. Requires Lightspeed sales.",
    align: "right",
  },
  {
    key: "lapsing",
    label: "Lapsing Customers",
    tip: "Customers whose last visit was 121–240 days ago — slipping toward inactive.",
    align: "right",
  },
];

function formatCount(n: number) {
  return n.toLocaleString("en-US");
}

function displayName(name: string) {
  return name.replace(" - ", " – ");
}

function InfoTip({ text }: { text: string }) {
  return (
    <span className="group relative inline-flex">
      <button
        type="button"
        aria-label={text}
        className="flex h-3.5 w-3.5 items-center justify-center rounded-full border border-[#c5cdd6] text-[9px] font-semibold leading-none text-[#8b95a1] hover:border-[#9aa3ad] hover:text-[#5c6570]"
      >
        i
      </button>
      <span className="pointer-events-none absolute left-1/2 top-[calc(100%+8px)] z-20 hidden w-56 -translate-x-1/2 rounded-md bg-[#1f2933] px-3 py-2 text-left text-xs font-normal leading-snug text-white shadow-lg group-hover:block group-focus-within:block">
        {text}
      </span>
    </span>
  );
}

function sortValue(
  row: LocationPerformanceRow,
  key: SortKey,
  window: LocationWindowDays
): number | string {
  switch (key) {
    case "name":
      return row.name;
    case "totalCustomers":
      return row.totalCustomers;
    case "activeRate":
      return activeRatePct(row, window);
    case "avgSpend":
      return row.avgSpendCents ?? -1;
    case "visitFrequency":
      return row.visitFrequency ?? -1;
    case "lapsing":
      return row.lapsing;
  }
}

export function LocationPerformance({ data }: { data: LocationPerformanceData }) {
  const [windowDays, setWindowDays] = useState<LocationWindowDays>(90);
  const [sortKey, setSortKey] = useState<SortKey>("activeRate");
  const [sortDir, setSortDir] = useState<"asc" | "desc">("desc");

  const ranked = useMemo(() => {
    const copy = [...data.rows];
    copy.sort((a, b) => {
      const av = sortValue(a, sortKey, windowDays);
      const bv = sortValue(b, sortKey, windowDays);
      if (typeof av === "string" && typeof bv === "string") {
        return sortDir === "asc" ? av.localeCompare(bv) : bv.localeCompare(av);
      }
      const an = Number(av);
      const bn = Number(bv);
      return sortDir === "asc" ? an - bn : bn - an;
    });
    return copy;
  }, [data.rows, sortKey, sortDir, windowDays]);

  const leader = ranked[0];
  const leaderRate = leader ? activeRatePct(leader, windowDays) : 0;

  function onSort(key: SortKey) {
    if (sortKey === key) {
      setSortDir((d) => (d === "desc" ? "asc" : "desc"));
      return;
    }
    setSortKey(key);
    setSortDir(key === "name" ? "asc" : "desc");
  }

  return (
    <section className="rounded-xl border border-[#e6e8eb] bg-white px-6 py-5 shadow-[0_1px_2px_rgba(16,24,40,0.04)]">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h2 className="text-lg font-semibold tracking-tight text-[#111827]">
            Location Performance
          </h2>
          <p className="mt-0.5 text-sm text-[#6b7280]">
            Your locations ranked by customer base and engagement health.
          </p>
        </div>
        <label className="sr-only" htmlFor="location-window">
          Time window
        </label>
        <select
          id="location-window"
          value={windowDays}
          onChange={(e) => setWindowDays(Number(e.target.value) as LocationWindowDays)}
          className="rounded-md border border-[#e6e8eb] bg-white px-3 py-1.5 text-sm text-[#111827] outline-none focus:border-[var(--accent)]"
        >
          <option value={90}>Last 90 days</option>
          <option value={30}>Last 30 days</option>
        </select>
      </div>

      {leader ? (
        <div className="mt-4 rounded-lg bg-[#e8f8ef] px-4 py-3 text-sm text-[#146c3a]">
          <span className="font-semibold">{displayName(leader.name)} is leading.</span>{" "}
          <span>
            {leaderRate}% active rate
            {leader.avgSpendCents != null
              ? ` · $${(leader.avgSpendCents / 100).toFixed(2)} avg spend`
              : ""}
            {leader.visitFrequency != null
              ? ` · ${leader.visitFrequency.toFixed(1)}x frequency`
              : ""}
            {leader.avgSpendCents == null
              ? " · Spend and frequency appear when Lightspeed sales are connected."
              : ""}
          </span>
        </div>
      ) : null}

      <div className="mt-4 overflow-x-auto">
        <table className="w-full min-w-[720px] text-left text-sm">
          <thead>
            <tr className="border-b border-[#eef1f4] text-xs text-[#6b7280]">
              <th className="w-12 py-2.5 pr-2 font-medium">#</th>
              <th className="py-2.5 pr-3 font-medium">
                <SortButton
                  label="Location"
                  active={sortKey === "name"}
                  dir={sortDir}
                  onClick={() => onSort("name")}
                />
              </th>
              {COLUMNS.map((col) => (
                <th
                  key={col.key}
                  className={`py-2.5 font-medium ${col.align === "right" ? "pl-3 text-right" : "pr-3"}`}
                >
                  <span
                    className={`inline-flex items-center gap-1 ${col.align === "right" ? "justify-end" : ""}`}
                  >
                    <SortButton
                      label={col.label}
                      active={sortKey === col.key}
                      dir={sortDir}
                      onClick={() => onSort(col.key)}
                    />
                    <InfoTip text={col.tip} />
                  </span>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {ranked.map((row, i) => {
              const rate = activeRatePct(row, windowDays);
              return (
                <tr key={row.id} className="border-b border-[#eef1f4] last:border-b-0">
                  <td className="py-3 pr-2 font-medium text-[#9aa3ad]">#{i + 1}</td>
                  <td className="py-3 pr-3 font-medium text-[#111827]">
                    {displayName(row.name)}
                  </td>
                  <td className="py-3 pl-3 text-right tabular-nums text-[#111827]">
                    {formatCount(row.totalCustomers)}
                  </td>
                  <td className="py-3 pl-3 text-right tabular-nums font-medium text-[#111827]">
                    {rate}%
                  </td>
                  <td className="py-3 pl-3 text-right tabular-nums text-[#9aa3ad]">—</td>
                  <td className="py-3 pl-3 text-right tabular-nums text-[#9aa3ad]">—</td>
                  <td className="py-3 pl-3 text-right tabular-nums text-[#111827]">
                    {formatCount(row.lapsing)}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </section>
  );
}

function SortButton({
  label,
  active,
  dir,
  onClick,
}: {
  label: string;
  active: boolean;
  dir: "asc" | "desc";
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`inline-flex items-center gap-0.5 ${active ? "text-[#2563eb]" : "text-[#6b7280] hover:text-[#111827]"}`}
    >
      {label}
      <span className="inline-flex flex-col text-[8px] leading-[0.7] text-[#c5cdd6]" aria-hidden>
        <span className={active && dir === "asc" ? "text-[#2563eb]" : ""}>▲</span>
        <span className={active && dir === "desc" ? "text-[#2563eb]" : ""}>▼</span>
      </span>
    </button>
  );
}
