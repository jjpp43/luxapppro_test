import Link from "next/link";
import { CustomerHealthSnapshot } from "@/components/dashboard/CustomerHealthSnapshot";
import { LocationPerformance } from "@/components/dashboard/LocationPerformance";
import { PageHeader } from "@/components/ui/PageHeader";
import { fetchCustomerHealth } from "@/lib/customer-health";
import { fetchLocationPerformance } from "@/lib/location-performance";
import { supabase } from "@/lib/supabase";

export const dynamic = "force-dynamic";

export default async function DashboardPage() {
  const [health, locations, { data: recent }] = await Promise.all([
    fetchCustomerHealth(),
    fetchLocationPerformance(),
    supabase
      .from("customers")
      .select("id, name, phone, last_seen_at, stores(name)")
      .order("last_seen_at", { ascending: false, nullsFirst: false })
      .limit(5),
  ]);
  const customerCount = health.total;

  return (
    <div className="space-y-8">
      <PageHeader
        title="Dashboard"
        subtitle="Business pulse for Lux Beauty Supply — last 90 days once sales ingest is live."
        crumbs={[{ label: "Home", href: "/" }, { label: "Dashboard" }]}
      />

      <section>
        <div className="mb-3 flex items-end justify-between gap-3">
          <div>
            <h2 className="text-lg font-semibold text-[var(--ink)]">Business Pulse</h2>
            <p className="text-sm text-[var(--muted)]">
              How your customers and revenue are performing across all locations.
            </p>
          </div>
          <span className="rounded-md border border-[var(--border)] bg-white px-2.5 py-1 text-xs text-[var(--muted)]">
            Last 90 days
          </span>
        </div>

        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <PulseCard
            label="Total Customers"
            value={(customerCount ?? 0).toLocaleString()}
            tone="rose"
            footnote="Enrolled in Lux Pro (full TapMango import)"
          />
          <PulseCard
            label="Engaged Customers"
            value="—"
            tone="blue"
            footnote="Unique customers who visited this period"
          />
          <PulseCard
            label="Avg Spend / Visit"
            value="—"
            tone="green"
            footnote="Across n visits — needs POS sales"
          />
          <PulseCard
            label="Monthly Visit Rate"
            value="—"
            tone="ink"
            footnote="Visits per customer / month"
          />
        </div>
      </section>

      <CustomerHealthSnapshot data={health} />

      <LocationPerformance data={locations} />

      <section className="rounded-xl border border-[var(--border)] bg-white">
        <div className="flex items-center justify-between border-b border-[var(--border)] px-5 py-4">
          <div>
            <h2 className="text-lg font-semibold">Recently seen</h2>
            <p className="text-sm text-[var(--muted)]">From sample last_seen_at</p>
          </div>
          <Link
            href="/customers"
            className="text-sm font-medium text-[var(--accent)] hover:text-[var(--accent-hover)]"
          >
            See all customers →
          </Link>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-[var(--canvas)] text-xs uppercase tracking-wide text-[var(--muted)]">
              <tr>
                <th className="px-5 py-2.5 font-medium">Name</th>
                <th className="px-5 py-2.5 font-medium">Phone</th>
                <th className="px-5 py-2.5 font-medium">Store</th>
                <th className="px-5 py-2.5 font-medium">Last seen</th>
              </tr>
            </thead>
            <tbody>
              {(recent ?? []).map((c) => {
                const store = Array.isArray(c.stores) ? c.stores[0] : c.stores;
                return (
                  <tr key={c.id} className="border-t border-[var(--border)]">
                    <td className="px-5 py-3">
                      <Link
                        href={`/customers/${c.id}`}
                        className="font-medium text-[var(--info)] hover:underline"
                      >
                        {c.name || "—"}
                      </Link>
                    </td>
                    <td className="px-5 py-3 font-mono text-xs">{c.phone}</td>
                    <td className="px-5 py-3 text-[var(--ink-soft)]">
                      {store?.name ?? "—"}
                    </td>
                    <td className="px-5 py-3 text-[var(--muted)]">
                      {c.last_seen_at
                        ? new Date(c.last_seen_at).toLocaleString()
                        : "—"}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}

function PulseCard({
  label,
  value,
  footnote,
  tone,
}: {
  label: string;
  value: string;
  footnote: string;
  tone: "rose" | "ink" | "green" | "blue";
}) {
  const bar =
    tone === "rose"
      ? "bg-[var(--accent)]"
      : tone === "green"
        ? "bg-[var(--good)]"
        : tone === "blue"
          ? "bg-[var(--info)]"
          : "bg-[var(--ink)]";

  return (
    <div className="overflow-hidden rounded-xl border border-[var(--border)] bg-white">
      <div className={`h-1 ${bar}`} />
      <div className="p-4">
        <div className="text-sm text-[var(--muted)]">{label}</div>
        <div className="mt-1 text-3xl font-semibold tabular-nums tracking-tight">
          {value}
        </div>
        <div className="mt-2 text-xs text-[var(--muted)]">{footnote}</div>
      </div>
    </div>
  );
}
