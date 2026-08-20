import type { BusinessPulseData, PulseMetric } from "@/lib/business-pulse";

const TIPS = {
  total:
    "All enrolled loyalty customers across locations. Trend is new enrollments this period as a share of the base at the start of the window.",
  engaged:
    "Unique customers who visited this period. Lightspeed-identified visits only — not anonymous WALKIN tickets.",
  spend:
    "Average paid ticket per visit over the selected window. Across all closed visits, including unmatched tickets once POS is connected.",
  rate:
    "Visits per engaged customer per month (visits ÷ engaged ÷ months). Matches TapMango — not visits ÷ all enrolled.",
} as const;

function formatRange(start: string, end: string) {
  const fmt = (ymd: string) =>
    new Date(`${ymd}T12:00:00`).toLocaleDateString("en-US", {
      month: "short",
      day: "numeric",
      year: "numeric",
    });
  return `${fmt(start)} – ${fmt(end)}`;
}

function Sparkline({ series }: { series: number[] }) {
  if (series.length < 2) return <div className="h-12" />;
  const min = Math.min(...series);
  const max = Math.max(...series);
  const span = max - min || 1;
  const w = 100;
  const h = 36;
  const pts = series.map((v, i) => {
    const x = (i / (series.length - 1)) * w;
    const y = h - ((v - min) / span) * (h - 4) - 2;
    return `${x.toFixed(2)},${y.toFixed(2)}`;
  });
  const line = pts.join(" ");
  const area = `0,${h} ${line} ${w},${h}`;

  return (
    <svg
      viewBox={`0 0 ${w} ${h}`}
      className="h-12 w-full"
      preserveAspectRatio="none"
      aria-hidden
    >
      <polygon points={area} fill="rgba(255,255,255,0.22)" />
      <polyline
        points={line}
        fill="none"
        stroke="white"
        strokeWidth="1.6"
        strokeLinejoin="round"
        strokeLinecap="round"
        vectorEffect="non-scaling-stroke"
      />
    </svg>
  );
}

function InfoTip({ text }: { text: string }) {
  return (
    <span className="group relative inline-flex">
      <button
        type="button"
        aria-label={text}
        className="flex h-3.5 w-3.5 items-center justify-center rounded-full border border-white/45 text-[8px] font-semibold leading-none text-white/80 hover:border-white hover:text-white"
      >
        i
      </button>
      <span className="pointer-events-none absolute left-0 top-[calc(100%+8px)] z-20 hidden w-56 rounded-md bg-[#1f2933] px-3 py-2 text-left text-xs font-normal leading-snug text-white shadow-lg group-hover:block group-focus-within:block">
        {text}
      </span>
    </span>
  );
}

function Trend({ pct }: { pct: number | null }) {
  if (pct == null) return null;
  const up = pct > 0;
  const flat = pct === 0;
  return (
    <span className="text-sm font-medium tabular-nums text-white/90">
      {flat ? "→" : up ? "↑" : "↓"} {up ? "+" : ""}
      {pct}%
    </span>
  );
}

function PulseIcon({ name }: { name: "total" | "engaged" | "spend" | "rate" }) {
  const common = "h-[18px] w-[18px]";
  if (name === "total") {
    return (
      <svg className={common} viewBox="0 0 24 24" fill="none" aria-hidden>
        <circle cx="12" cy="8" r="3.25" stroke="currentColor" strokeWidth="1.75" />
        <path
          d="M5.5 19c.8-3.2 3.3-5 6.5-5s5.7 1.8 6.5 5"
          stroke="currentColor"
          strokeWidth="1.75"
          strokeLinecap="round"
        />
      </svg>
    );
  }
  if (name === "engaged") {
    return (
      <svg className={common} viewBox="0 0 24 24" fill="none" aria-hidden>
        <circle cx="9" cy="8.5" r="2.75" stroke="currentColor" strokeWidth="1.75" />
        <circle cx="16" cy="9" r="2.25" stroke="currentColor" strokeWidth="1.75" />
        <path
          d="M4.5 18.5c.7-2.6 2.7-4 5.3-4 2.6 0 4.6 1.4 5.3 4"
          stroke="currentColor"
          strokeWidth="1.75"
          strokeLinecap="round"
        />
        <path
          d="M14.5 18.5c.4-1.6 1.6-2.6 3.3-2.6 1.7 0 2.9 1 3.3 2.6"
          stroke="currentColor"
          strokeWidth="1.75"
          strokeLinecap="round"
        />
      </svg>
    );
  }
  if (name === "spend") {
    return (
      <svg className={common} viewBox="0 0 24 24" fill="none" aria-hidden>
        <rect x="3.5" y="6" width="17" height="12" rx="2" stroke="currentColor" strokeWidth="1.75" />
        <path d="M3.5 10h17" stroke="currentColor" strokeWidth="1.75" />
        <circle cx="16.5" cy="14.25" r="1.1" fill="currentColor" />
      </svg>
    );
  }
  return (
    <svg className={common} viewBox="0 0 24 24" fill="none" aria-hidden>
      <path
        d="M20 7.5A8.2 8.2 0 0 0 6.4 5.6M4 16.5A8.2 8.2 0 0 0 17.6 18.4"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
      />
      <path d="M20 3.5v4.2h-4.2M4 20.5v-4.2h4.2" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function Card({
  label,
  tip,
  icon,
  metric,
  format,
  tone,
}: {
  label: string;
  tip: string;
  icon: "total" | "engaged" | "spend" | "rate";
  metric: PulseMetric;
  format: (value: number) => string;
  tone: string;
}) {
  const empty = metric.value == null;

  return (
    <article
      className={`relative flex min-h-[188px] flex-col overflow-hidden rounded-2xl px-5 py-4 text-white shadow-[0_8px_24px_rgba(28,20,18,0.12)] ${tone}`}
    >
      <div className="flex items-start justify-between gap-3">
        <div className="flex items-center gap-2.5">
          <span className="flex h-9 w-9 items-center justify-center rounded-full bg-white/15">
            <PulseIcon name={icon} />
          </span>
          <span className="text-sm font-medium text-white/95">{label}</span>
          <InfoTip text={tip} />
        </div>
        <Trend pct={empty ? null : metric.trendPct} />
      </div>

      <div className="mt-3 text-[2rem] font-semibold leading-none tracking-tight tabular-nums">
        {empty ? "—" : format(metric.value!)}
      </div>

      <div className="mt-3 flex-1">
        {empty ? (
          <div className="h-12 opacity-30">
            <Sparkline series={[2, 2.1, 2, 2.2, 2.05, 2.15, 2.1]} />
          </div>
        ) : (
          <Sparkline series={metric.series} />
        )}
      </div>

      <p className="mt-1 text-xs leading-snug text-white/80">{metric.footnote}</p>
    </article>
  );
}

export function BusinessPulse({ data }: { data: BusinessPulseData }) {
  return (
    <section>
      <div className="mb-3 flex flex-wrap items-end justify-between gap-3">
        <div>
          <h2 className="text-lg font-semibold text-[var(--ink)]">Business Pulse</h2>
          <p className="text-sm text-[var(--muted)]">
            How your customers and revenue are performing across all locations.
          </p>
        </div>
        <div className="flex items-center gap-2 text-sm text-[var(--muted)]">
          <svg className="h-4 w-4" viewBox="0 0 24 24" fill="none" aria-hidden>
            <rect x="4" y="5" width="16" height="15" rx="2" stroke="currentColor" strokeWidth="1.6" />
            <path d="M8 3.5v3M16 3.5v3M4 10h16" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" />
          </svg>
          <span>
            {formatRange(data.periodStart, data.periodEnd)} vs. Prior 90 days
          </span>
        </div>
      </div>

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        <Card
          label="Total Customers"
          tip={TIPS.total}
          icon="total"
          metric={data.totalCustomers}
          format={(n) => n.toLocaleString("en-US")}
          tone="bg-[linear-gradient(160deg,#6a4de8_0%,#7b63f0_55%,#8a74f4_100%)]"
        />
        <Card
          label="Engaged Customers"
          tip={TIPS.engaged}
          icon="engaged"
          metric={data.engaged}
          format={(n) => n.toLocaleString("en-US")}
          tone="bg-[linear-gradient(160deg,#1d8fff_0%,#2b9bff_55%,#4aaaff_100%)]"
        />
        <Card
          label="Avg Spend / Visit"
          tip={TIPS.spend}
          icon="spend"
          metric={data.avgSpendCents}
          format={(cents) =>
            `$${(cents / 100).toLocaleString("en-US", {
              minimumFractionDigits: 2,
              maximumFractionDigits: 2,
            })}`
          }
          tone="bg-[linear-gradient(160deg,#12b39a_0%,#1ac4ab_55%,#2dd4bf_100%)]"
        />
        <Card
          label="Monthly Visit Rate"
          tip={TIPS.rate}
          icon="rate"
          metric={data.monthlyVisitRate}
          format={(n) => `${n.toFixed(1)}x`}
          tone="bg-[linear-gradient(160deg,#e94b8a_0%,#f15b98_55%,#f472b6_100%)]"
        />
      </div>
    </section>
  );
}
