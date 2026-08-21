import Link from "next/link";
import { PageHeader } from "@/components/ui/PageHeader";
import {
  HEALTH_DEFINITIONS,
  fetchCustomerHealth,
  healthCustomersHref,
} from "@/lib/customer-health";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function GroupsPage() {
  const supabase = await createClient();
  const health = await fetchCustomerHealth(supabase);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Customer Groups"
        subtitle="Live lifecycle audiences calculated from enrolment and visit history."
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Audience", href: "/customers" },
          { label: "Customer Groups" },
        ]}
        actions={
          <Link
            href="/customers"
            className="rounded-lg border border-[var(--border)] bg-white px-3.5 py-2 text-sm font-semibold text-[var(--ink-soft)] transition-[transform,border-color,color] duration-150 hover:border-[var(--info)] hover:text-[var(--info)] active:scale-[0.98]"
          >
            View all customers
          </Link>
        }
      />

      <section className="grid gap-3 sm:grid-cols-3">
        <SummaryCard
          label="Customers grouped"
          value={health.total.toLocaleString("en-US")}
        />
        <SummaryCard label="Live groups" value={String(health.buckets.length)} />
        <SummaryCard label="Refresh" value="Automatic" />
      </section>

      <div className="overflow-hidden rounded-xl border border-[var(--border)] bg-white">
        <div className="flex flex-wrap items-center justify-between gap-3 border-b border-[var(--border)] px-4 py-3">
          <p className="text-sm text-[var(--muted)]">
            These system groups stay in sync automatically. Custom rule-based
            groups come later.
          </p>
          <span className="rounded-full bg-[var(--canvas)] px-2.5 py-1 text-xs font-semibold text-[var(--muted)]">
            System groups
          </span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full min-w-[760px] text-left text-sm">
            <thead className="bg-[var(--canvas)] text-xs uppercase tracking-wide text-[var(--muted)]">
              <tr>
                <th className="px-4 py-2.5 font-medium">Group</th>
                <th className="px-4 py-2.5 font-medium text-right">
                  Customers
                </th>
                <th className="px-4 py-2.5 font-medium text-right">
                  Share
                </th>
                <th className="px-4 py-2.5 font-medium">Definition</th>
                <th className="px-4 py-2.5 font-medium">Action</th>
              </tr>
            </thead>
            <tbody>
              {health.buckets.map((group) => (
                <tr
                  key={group.key}
                  className="border-t border-[var(--border)]"
                >
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2.5">
                      <span
                        className="size-2.5 rounded-full"
                        style={{ backgroundColor: group.color }}
                        aria-hidden="true"
                      />
                      <div>
                        <div className="font-semibold text-[var(--ink)]">
                          {group.label}
                        </div>
                        <div className="text-xs text-[var(--muted)]">
                          Lifecycle
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-right font-semibold tabular-nums text-[var(--ink)]">
                    {group.count.toLocaleString("en-US")}
                  </td>
                  <td className="px-4 py-3 text-right tabular-nums text-[var(--ink-soft)]">
                    {group.pctOfTotal}%
                  </td>
                  <td className="max-w-md px-4 py-3 text-[var(--ink-soft)]">
                    {HEALTH_DEFINITIONS[group.key]}
                  </td>
                  <td className="px-4 py-3">
                    <Link
                      href={healthCustomersHref(group.key)}
                      className="inline-flex rounded-md px-2.5 py-1.5 text-sm font-semibold text-[var(--info)] transition-[transform,background-color] duration-150 hover:bg-[var(--canvas)] active:scale-[0.97]"
                    >
                      See customers →
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

function SummaryCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl border border-[var(--border)] bg-white px-4 py-3.5 shadow-sm">
      <div className="text-xs font-medium uppercase tracking-wide text-[var(--muted)]">
        {label}
      </div>
      <div className="mt-1 text-2xl font-semibold tracking-tight text-[var(--ink)]">
        {value}
      </div>
    </div>
  );
}
