import Link from "next/link";
import { notFound } from "next/navigation";
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
      "id, phone, name, email, legacy_tapmango_id, registered_at, last_seen_at, lifetime_points_at_migration, stores(name), customer_balance(balance)"
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

  return (
    <div className="space-y-8">
      <div>
        <Link href="/customers" className="text-sm text-zinc-500 hover:text-zinc-800">
          ← Customers
        </Link>
        <h1 className="mt-2 text-2xl font-semibold tracking-tight">
          {customer.name || "Unnamed customer"}
        </h1>
        <p className="mt-1 font-mono text-sm text-zinc-600">{customer.phone}</p>
      </div>

      <dl className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <Field label="Balance" value={String(bal?.balance ?? 0)} />
        <Field label="Store" value={store?.name ?? "—"} />
        <Field label="Email" value={customer.email ?? "—"} />
        <Field label="TapMango id" value={customer.legacy_tapmango_id ?? "—"} />
        <Field
          label="Lifetime at migration"
          value={String(customer.lifetime_points_at_migration ?? "—")}
        />
        <Field
          label="Registered"
          value={
            customer.registered_at
              ? new Date(customer.registered_at).toLocaleString()
              : "—"
          }
        />
        <Field
          label="Last seen"
          value={
            customer.last_seen_at
              ? new Date(customer.last_seen_at).toLocaleString()
              : "—"
          }
        />
      </dl>

      <div>
        <h2 className="text-lg font-semibold">Points ledger</h2>
        <div className="mt-3 overflow-hidden rounded-lg border border-zinc-200 bg-white">
          <table className="w-full text-left text-sm">
            <thead className="border-b border-zinc-200 bg-zinc-50 text-xs uppercase tracking-wide text-zinc-500">
              <tr>
                <th className="px-3 py-2 font-medium">When</th>
                <th className="px-3 py-2 font-medium">Reason</th>
                <th className="px-3 py-2 font-medium text-right">Delta</th>
                <th className="px-3 py-2 font-medium">Idempotency</th>
              </tr>
            </thead>
            <tbody>
              {(ledger ?? []).map((row) => (
                <tr key={row.id} className="border-b border-zinc-100 last:border-0">
                  <td className="px-3 py-2 text-zinc-600">
                    {new Date(row.created_at).toLocaleString()}
                  </td>
                  <td className="px-3 py-2">{row.reason}</td>
                  <td className="px-3 py-2 text-right tabular-nums font-medium">
                    {row.delta > 0 ? `+${row.delta}` : row.delta}
                  </td>
                  <td className="px-3 py-2 font-mono text-xs text-zinc-500">
                    {row.idempotency_key}
                  </td>
                </tr>
              ))}
              {(ledger ?? []).length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-3 py-6 text-center text-zinc-500">
                    No ledger rows (zero opening balance)
                  </td>
                </tr>
              ) : null}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

function Field({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-lg border border-zinc-200 bg-white p-3">
      <dt className="text-xs text-zinc-500">{label}</dt>
      <dd className="mt-1 text-sm font-medium break-all">{value}</dd>
    </div>
  );
}
