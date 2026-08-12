import Link from "next/link";
import { supabase } from "@/lib/supabase";

export const dynamic = "force-dynamic";

type SearchParams = Promise<{ q?: string }>;

export default async function CustomersPage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  const { q } = await searchParams;
  const query = (q ?? "").trim();

  let customersQuery = supabase
    .from("customers")
    .select(
      "id, phone, name, email, legacy_tapmango_id, registered_at, stores(name), customer_balance(balance)"
    )
    .order("created_at", { ascending: true })
    .limit(200);

  if (query) {
    customersQuery = customersQuery.or(
      `phone.ilike.%${query}%,name.ilike.%${query}%,email.ilike.%${query}%,legacy_tapmango_id.eq.${query}`
    );
  }

  const { data: customers, error } = await customersQuery;

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Customers</h1>
          <p className="mt-1 text-sm text-zinc-600">
            Sample import — phone, store, opening balance
          </p>
        </div>
        <form className="flex gap-2">
          <input
            type="search"
            name="q"
            defaultValue={query}
            placeholder="Phone, name, email, TapMango id"
            className="w-72 rounded-md border border-zinc-300 bg-white px-3 py-2 text-sm outline-none focus:border-zinc-500"
          />
          <button
            type="submit"
            className="rounded-md bg-zinc-900 px-3 py-2 text-sm font-medium text-white hover:bg-zinc-800"
          >
            Search
          </button>
        </form>
      </div>

      {error ? (
        <p className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-800">
          {error.message}
        </p>
      ) : null}

      <div className="overflow-hidden rounded-lg border border-zinc-200 bg-white">
        <table className="w-full text-left text-sm">
          <thead className="border-b border-zinc-200 bg-zinc-50 text-xs uppercase tracking-wide text-zinc-500">
            <tr>
              <th className="px-3 py-2 font-medium">Name</th>
              <th className="px-3 py-2 font-medium">Phone</th>
              <th className="px-3 py-2 font-medium">Store</th>
              <th className="px-3 py-2 font-medium text-right">Balance</th>
              <th className="px-3 py-2 font-medium">TapMango id</th>
            </tr>
          </thead>
          <tbody>
            {(customers ?? []).map((c) => {
              const store = Array.isArray(c.stores) ? c.stores[0] : c.stores;
              const bal = Array.isArray(c.customer_balance)
                ? c.customer_balance[0]
                : c.customer_balance;
              return (
                <tr key={c.id} className="border-b border-zinc-100 last:border-0">
                  <td className="px-3 py-2">
                    <Link
                      href={`/customers/${c.id}`}
                      className="font-medium text-zinc-900 hover:underline"
                    >
                      {c.name || "—"}
                    </Link>
                  </td>
                  <td className="px-3 py-2 font-mono text-xs">{c.phone}</td>
                  <td className="px-3 py-2 text-zinc-600">
                    {store?.name ?? "—"}
                  </td>
                  <td className="px-3 py-2 text-right tabular-nums font-medium">
                    {bal?.balance ?? 0}
                  </td>
                  <td className="px-3 py-2 font-mono text-xs text-zinc-500">
                    {c.legacy_tapmango_id}
                  </td>
                </tr>
              );
            })}
            {(customers ?? []).length === 0 ? (
              <tr>
                <td colSpan={5} className="px-3 py-8 text-center text-zinc-500">
                  No customers found
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>
    </div>
  );
}
