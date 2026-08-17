import {
  HEALTH_DEFINITIONS,
  type CustomerHealthSnapshotData,
  type HealthBucket,
} from "@/lib/customer-health";

function formatCount(n: number) {
  return n.toLocaleString("en-US");
}

function niceCeiling(max: number) {
  if (max <= 0) return 10;
  const padded = max * 1.1;
  const step =
    padded > 20_000
      ? 5_000
      : padded > 5_000
        ? 1_000
        : padded > 1_000
          ? 250
          : padded > 100
            ? 20
            : padded > 20
              ? 5
              : 1;
  return Math.max(step, Math.ceil(padded / step) * step);
}

function formatTick(n: number) {
  if (n >= 1000) {
    const k = n / 1000;
    return Number.isInteger(k) ? `${k}k` : `${k.toFixed(1)}k`;
  }
  return String(n);
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
      <span className="pointer-events-none absolute left-0 top-[calc(100%+8px)] z-20 hidden w-64 rounded-md bg-[#1f2933] px-3 py-2 text-left text-xs font-normal leading-snug text-white shadow-lg group-hover:block group-focus-within:block">
        {text}
      </span>
    </span>
  );
}

function Trend({ value }: { value: number | null }) {
  if (value === null) {
    return <span className="text-xs text-[#c5cdd6]">—</span>;
  }
  const up = value > 0;
  const flat = value === 0;
  const color = flat
    ? "text-[#8b95a1]"
    : up
      ? "text-[#18a34a]"
      : "text-[#e11d48]";
  const arrow = flat ? "→" : up ? "↑" : "↓";
  const label = `${up ? "+" : ""}${value}%`;
  return (
    <span className={`text-sm font-medium tabular-nums ${color}`}>
      {arrow} {label}
    </span>
  );
}

function HealthChart({
  buckets,
  yMax,
}: {
  buckets: HealthBucket[];
  yMax: number;
}) {
  const ticks = 10;
  const tickValues = Array.from(
    { length: ticks },
    (_, i) => (yMax / (ticks - 1)) * i,
  ).reverse();

  return (
    <div className="flex min-h-[260px] min-w-0 flex-1 gap-1">
      <div className="flex w-8 shrink-0 items-center justify-center pb-8">
        <span
          className="text-[11px] text-[#9aa3ad]"
          style={{ writingMode: "vertical-rl", transform: "rotate(180deg)" }}
        >
          Customers
        </span>
      </div>
      <div className="flex min-w-0 flex-1 flex-col">
        <div className="relative flex min-h-[220px] flex-1">
          <div className="flex w-8 shrink-0 flex-col justify-between pr-1 text-right text-[11px] leading-none text-[#9aa3ad]">
            {tickValues.map((v) => (
              <span key={v}>{formatTick(v)}</span>
            ))}
          </div>
          <div className="relative min-w-0 flex-1">
            <div className="absolute inset-0 flex flex-col justify-between">
              {tickValues.map((v) => (
                <div key={v} className="border-t border-[#eef1f4]" />
              ))}
            </div>
            <div className="absolute inset-0 flex items-end justify-around px-6 pb-0 pt-1">
              {buckets.map((bucket) => {
                const h = yMax > 0 ? (bucket.count / yMax) * 100 : 0;
                return (
                  <div
                    key={bucket.key}
                    className="flex h-full w-full max-w-[108px] items-end justify-center px-2"
                  >
                    <div
                      className="w-full rounded-t-md"
                      style={{
                        height: `${Math.max(h, bucket.count > 0 ? 1.5 : 0)}%`,
                        background: bucket.color,
                      }}
                      title={`${bucket.label}: ${formatCount(bucket.count)}`}
                    />
                  </div>
                );
              })}
            </div>
          </div>
        </div>
        <div className="flex">
          <div className="w-8 shrink-0" />
          <div className="flex min-w-0 flex-1 justify-around px-6 pt-2">
            {buckets.map((bucket) => (
              <div
                key={bucket.key}
                className="w-full max-w-[72px] text-center text-xs text-[#6b7280]"
              >
                {bucket.label}
              </div>
            ))}
          </div>
        </div>
        <div className="mt-1 pr-2 text-center text-[11px] text-[#9aa3ad]">
          Status
        </div>
      </div>
    </div>
  );
}

function BucketRow({ bucket }: { bucket: HealthBucket }) {
  const definition = HEALTH_DEFINITIONS[bucket.key];
  return (
    <div className="flex flex-col gap-1 rounded-lg bg-[#f5f6f8] px-3.5 py-3">
      <div className="flex items-start justify-between gap-3">
        <div className="flex items-center gap-2">
          <span
            className="h-2.5 w-2.5 rounded-full"
            style={{ background: bucket.color }}
            aria-hidden
          />
          <span className="text-sm font-semibold text-[#111827]">
            {bucket.label}
          </span>
          <InfoTip text={definition} />
        </div>
        <Trend value={bucket.trendPct} />
      </div>
      <div className="pl-[18px] text-sm font-semibold tabular-nums text-[#111827]">
        {formatCount(bucket.count)}{" "}
        <span className="font-normal text-[#6b7280]">Customers</span>
      </div>
      <div className="pl-[18px] text-xs text-[#9aa3ad]">
        {bucket.pctOfTotal}% of total
      </div>
    </div>
  );
}

export function CustomerHealthSnapshot({
  data,
}: {
  data: CustomerHealthSnapshotData;
}) {
  const chartBuckets = data.buckets.filter((b) => b.inChart);
  const yMax = niceCeiling(Math.max(0, ...chartBuckets.map((b) => b.count)));

  return (
    <section className="rounded-xl border border-[#e6e8eb] bg-white px-6 py-5 shadow-[0_1px_2px_rgba(16,24,40,0.04)]">
      <h2 className="text-lg font-semibold tracking-tight text-[#111827]">
        Customer Health Snapshot
      </h2>
      <p className="mt-0.5 text-sm text-[#6b7280]">
        Lifecycle distribution across your customer base
      </p>
      <p className="mt-4 text-[28px] font-semibold leading-none tracking-tight text-[#111827]">
        {formatCount(data.total)}{" "}
        <span className="text-base font-medium text-[#6b7280]">
          Total Customers Enrolled
        </span>
      </p>

      <div className="mt-6 grid gap-8 lg:grid-cols-[minmax(0,1.35fr)_minmax(240px,0.75fr)] lg:items-stretch">
        <HealthChart buckets={chartBuckets} yMax={yMax} />
        <div className="flex min-w-0 flex-col gap-2">
          {data.buckets.map((bucket) => (
            <BucketRow key={bucket.key} bucket={bucket} />
          ))}
        </div>
      </div>
    </section>
  );
}
