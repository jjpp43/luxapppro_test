import Link from "next/link";
import { notFound } from "next/navigation";
import { PageHeader } from "@/components/ui/PageHeader";
import { supabase } from "@/lib/supabase";

export const dynamic = "force-dynamic";

type Params = Promise<{ id: string }>;

export default async function CustomerDetailPage({
  params,
}: {
  params: Params;
}) {
  const { id } = await params;

  const { data: customer, error } = await supabase
    .from("customers")
    .select(
      "id, phone, name, email, legacy_tapmango_id, registered_at, last_seen_at, lifetime_points_at_migration, sms_subscribed, email_subscribed, stores(name), customer_balance(balance)"
    )
    .eq("id", id)
    .maybeSingle();

  if (error || !customer) notFound();

  const { data: ledger } = await supabase
    .from("points_ledger")
    .select("id, delta, reason, created_at, idempotency_key")
    .eq("customer_id", id)
    .order("created_at", { ascending: false });

  const store = Array.isArray(customer.stores)
    ? customer.stores[0]
    : customer.stores;
  const bal = Array.isArray(customer.customer_balance)
    ? customer.customer_balance[0]
    : customer.customer_balance;
  const balance = bal?.balance ?? 0;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Customer"
        subtitle="Customer Details"
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Customers", href: "/customers" },
          { label: "Details" },
        ]}
      />

      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
        <Metric label="Points" value={String(balance)} />
        <Metric
          label="Lifetime Points"
          value={String(customer.lifetime_points_at_migration ?? "—")}
        />
        <Metric label="Total Visit(s)" value="—" />
        <Metric
          label="Last visit"
          value={
            customer.last_seen_at
              ? new Date(customer.last_seen_at).toLocaleString()
              : "—"
          }
        />
        <Metric label="Wallet" value="$0.00" />
      </div>

      <div className="overflow-hidden rounded-xl border border-[var(--border)] bg-white">
        <div className="flex gap-1 overflow-x-auto border-b border-[var(--border)] px-2 pt-2">
          {["Details", "History", "Referred Customers", "Customer privacy"].map(
            (tab, i) => (
              <span
                key={tab}
                className={[
                  "rounded-t-md px-3 py-2 text-sm",
                  i === 0
                    ? "border border-b-white border-[var(--border)] bg-white font-semibold text-[var(--ink)]"
                    : "text-[var(--muted)]",
                ].join(" ")}
              >
                {tab}
              </span>
            )
          )}
        </div>

        <div className="grid gap-8 p-5 md:grid-cols-2">
          <dl className="space-y-3 text-sm">
            <Row label="Name" value={customer.name || "—"} />
            <Row label="Email" value={customer.email || "—"} />
            <Row label="Phone #" value={customer.phone} mono />
            <Row
              label="Registered On"
              value={
                customer.registered_at
                  ? new Date(customer.registered_at).toLocaleString()
                  : "—"
              }
            />
            <Row label="TapMango id" value={customer.legacy_tapmango_id || "—"} mono />
            <Row label="Location" value={store?.name ?? "—"} />
          </dl>
          <div className="space-y-4 text-sm">
            <div>
              <div className="text-[var(--muted)]">Communication Preferences</div>
              <ul className="mt-2 space-y-1.5">
                <Pref
                  label="Can Receive SMS/MMS"
                  on={Boolean(customer.sms_subscribed)}
                />
                <Pref
                  label="Can Receive Emails"
                  on={Boolean(customer.email_subscribed)}
                />
              </ul>
            </div>
            <div className="rounded-lg bg-[var(--canvas)] px-3 py-2 text-xs text-[var(--muted)]">
              Adjust Points / Rewards / Check in actions will wire after staff auth.
            </div>
          </div>
        </div>

        <div className="flex flex-wrap gap-2 border-t border-[var(--border)] bg-[var(--canvas)]/60 px-5 py-3">
          <Action tone="green">Adjust Points</Action>
          <Action tone="green">Rewards</Action>
          <Action tone="accent">Check in</Action>
          <Action tone="blue">Edit</Action>
          <Link
            href="/customers"
            className="rounded-md border border-[var(--border)] bg-white px-3 py-1.5 text-sm"
          >
            Cancel
          </Link>
        </div>
      </div>

      <div className="overflow-hidden rounded-xl border border-[var(--border)] bg-white">
        <div className="border-b border-[var(--border)] px-5 py-3">
          <h2 className="font-semibold">Points ledger</h2>
        </div>
        <table className="w-full text-left text-sm">
          <thead className="bg-[var(--canvas)] text-xs uppercase tracking-wide text-[var(--muted)]">
            <tr>
              <th className="px-5 py-2 font-medium">When</th>
              <th className="px-5 py-2 font-medium">Reason</th>
              <th className="px-5 py-2 font-medium text-right">Delta</th>
              <th className="px-5 py-2 font-medium">Idempotency</th>
            </tr>
          </thead>
          <tbody>
            {(ledger ?? []).map((row) => (
              <tr key={row.id} className="border-t border-[var(--border)]">
                <td className="px-5 py-2.5 text-[var(--muted)]">
                  {new Date(row.created_at).toLocaleString()}
                </td>
                <td className="px-5 py-2.5">{row.reason}</td>
                <td className="px-5 py-2.5 text-right tabular-nums font-medium">
                  {row.delta > 0 ? `+${row.delta}` : row.delta}
                </td>
                <td className="px-5 py-2.5 font-mono text-xs text-[var(--muted)]">
                  {row.idempotency_key}
                </td>
              </tr>
            ))}
            {(ledger ?? []).length === 0 ? (
              <tr>
                <td colSpan={4} className="px-5 py-8 text-center text-[var(--muted)]">
                  No ledger rows (zero opening balance)
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function Metric({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-lg border border-[var(--border)] bg-[var(--canvas)] px-3 py-3">
      <div className="text-xs text-[var(--muted)]">{label}</div>
      <div className="mt-1 text-lg font-semibold tabular-nums text-[var(--info)]">
        {value}
      </div>
    </div>
  );
}

function Row({
  label,
  value,
  mono,
}: {
  label: string;
  value: string;
  mono?: boolean;
}) {
  return (
    <div className="grid grid-cols-[140px_1fr] gap-2">
      <dt className="text-[var(--muted)]">{label}</dt>
      <dd className={mono ? "font-mono text-xs break-all" : "font-medium"}>
        {value}
      </dd>
    </div>
  );
}

function Pref({ label, on }: { label: string; on: boolean }) {
  return (
    <li className="flex items-center justify-between rounded-md border border-[var(--border)] px-3 py-2">
      <span>{label}</span>
      <span
        className={
          on ? "font-medium text-[var(--good)]" : "font-medium text-[var(--muted)]"
        }
      >
        {on ? "Yes" : "No"}
      </span>
    </li>
  );
}

function Action({
  children,
  tone,
}: {
  children: React.ReactNode;
  tone: "green" | "accent" | "blue";
}) {
  const cls =
    tone === "green"
      ? "bg-[var(--good)] text-white"
      : tone === "accent"
        ? "bg-[var(--accent)] text-white"
        : "bg-[var(--info)] text-white";
  return (
    <button type="button" className={`rounded-md px-3 py-1.5 text-sm font-medium ${cls}`}>
      {children}
    </button>
  );
}
