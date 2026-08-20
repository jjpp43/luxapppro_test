import Link from "next/link";
import { BusinessPulse } from "@/components/dashboard/BusinessPulse";
import { CustomerHealthSnapshot } from "@/components/dashboard/CustomerHealthSnapshot";
import { LocationPerformance } from "@/components/dashboard/LocationPerformance";
import { PageHeader } from "@/components/ui/PageHeader";
import { fetchBusinessPulse } from "@/lib/business-pulse";
import { fetchCustomerHealth } from "@/lib/customer-health";
import { fetchLocationPerformance } from "@/lib/location-performance";
import { supabase } from "@/lib/supabase";

export const dynamic = "force-dynamic";

export default async function DashboardPage() {
  const [health, locations, pulse, { data: recent }] = await Promise.all([
    fetchCustomerHealth(),
    fetchLocationPerformance(),
    fetchBusinessPulse(),
    supabase
      .from("customers")
      .select("id, name, phone, last_seen_at, stores(name)")
      .order("last_seen_at", { ascending: false, nullsFirst: false })
      .limit(5),
  ]);

  return (
    <div className="space-y-8">
      <PageHeader
        title="Dashboard"
        subtitle="Business pulse for Lux Beauty Supply."
        crumbs={[{ label: "Home", href: "/" }, { label: "Dashboard" }]}
      />

      <BusinessPulse data={pulse} />

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
