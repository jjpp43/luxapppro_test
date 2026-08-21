import Link from "next/link";
import { PageHeader } from "@/components/ui/PageHeader";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

type SearchParams = Promise<{
  store?: string;
  identified?: string;
  page?: string;
}>;

const PAGE_SIZE = 50;

function money(cents: number) {
  return `$${(cents / 100).toLocaleString("en-US", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })}`;
}

function href(next: { store?: string; identified?: string; page?: number }) {
  const p = new URLSearchParams();
  if (next.store) p.set("store", next.store);
  if (next.identified === "1") p.set("identified", "1");
  if (next.page && next.page > 1) p.set("page", String(next.page));
  const qs = p.toString();
  return qs ? `/audience/pos-transactions?${qs}` : "/audience/pos-transactions";
}

export default async function PosTransactionsPage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  const { store: storeParam, identified: identifiedParam, page: pageParam } =
    await searchParams;
  const selectedStore = (storeParam ?? "").trim();
  const identifiedOnly = identifiedParam === "1";
  const page = Number.isInteger(Number(pageParam)) && Number(pageParam) > 1
    ? Number(pageParam)
    : 1;
  const from = (page - 1) * PAGE_SIZE;

  const supabase = await createClient();
  const { data: stores } = await supabase
    .from("stores")
    .select("id, name")
    .order("sort_rank");

  let query = supabase
    .from("sales")
    .select(
      "id, occurred_at, state, total_cents, points_earned, lightspeed_sale_id, customer_id, stores(name), customers(id, name, phone)",
      { count: "exact" },
    )
    .order("occurred_at", { ascending: false })
    .range(from, from + PAGE_SIZE - 1);

  if (selectedStore) query = query.eq("store_id", selectedStore);
  if (identifiedOnly) query = query.not("customer_id", "is", null);

  const { data: sales, count, error } = await query;
  const total = count ?? 0;
  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));

  return (
    <div>
      <PageHeader
        title="POS Transactions"
        subtitle="Lightspeed sales. Points stay off until a store’s earn flag is turned on."
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Audience", href: "/customers" },
          { label: "POS Transactions" },
        ]}
      />

      <div className="mb-4 flex flex-wrap gap-2">
        <FilterChip
          href={href({ identified: identifiedOnly ? "1" : undefined })}
          label="All stores"
          active={!selectedStore}
        />
        {(stores ?? []).map((s) => (
          <FilterChip
            key={s.id}
            href={href({ store: s.id, identified: identifiedOnly ? "1" : undefined })}
            label={s.name.replace(/^Lux Beauty Supply - /, "")}
            active={selectedStore === s.id}
          />
        ))}
        <FilterChip
          href={href({
            store: selectedStore || undefined,
            identified: identifiedOnly ? undefined : "1",
          })}
          label={identifiedOnly ? "Identified only" : "Include WALKIN"}
          active={identifiedOnly}
        />
      </div>

      <div className="overflow-hidden rounded-xl border border-[var(--border)] bg-white">
        {error ? (
          <p className="mx-4 my-3 rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-800">
            {error.message}
          </p>
        ) : null}
        <div className="overflow-x-auto">
          <table className="w-full min-w-[760px] text-left text-sm">
            <thead className="bg-[var(--canvas)] text-xs uppercase tracking-wide text-[var(--muted)]">
              <tr>
                <th className="px-4 py-2.5 font-medium">When</th>
                <th className="px-4 py-2.5 font-medium">Store</th>
                <th className="px-4 py-2.5 font-medium">Customer</th>
                <th className="px-4 py-2.5 font-medium">State</th>
                <th className="px-4 py-2.5 font-medium text-right">Total</th>
                <th className="px-4 py-2.5 font-medium text-right">Points</th>
              </tr>
            </thead>
            <tbody>
              {(sales ?? []).map((row) => {
                const store = Array.isArray(row.stores) ? row.stores[0] : row.stores;
                const customer = Array.isArray(row.customers)
                  ? row.customers[0]
                  : row.customers;
                return (
                  <tr key={row.id} className="border-t border-[var(--border)]">
                    <td className="px-4 py-2.5 text-[var(--muted)]">
                      {new Date(row.occurred_at).toLocaleString()}
                    </td>
                    <td className="px-4 py-2.5">{store?.name ?? "—"}</td>
                    <td className="px-4 py-2.5">
                      {customer ? (
                        <Link
                          href={`/customers/${customer.id}`}
                          className="font-medium text-[var(--info)] hover:underline"
                        >
                          {customer.name || customer.phone}
                        </Link>
                      ) : (
                        <span className="text-[var(--muted)]">WALKIN</span>
                      )}
                    </td>
                    <td className="px-4 py-2.5 font-mono text-xs">{row.state || "—"}</td>
                    <td className="px-4 py-2.5 text-right tabular-nums">
                      {money(row.total_cents ?? 0)}
                    </td>
                    <td className="px-4 py-2.5 text-right tabular-nums text-[var(--muted)]">
                      {row.points_earned ?? "—"}
                    </td>
                  </tr>
                );
              })}
              {(sales ?? []).length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-4 py-10 text-center text-[var(--muted)]">
                    No sales found
                  </td>
                </tr>
              ) : null}
            </tbody>
          </table>
        </div>
        {total > PAGE_SIZE ? (
          <div className="flex items-center justify-between border-t border-[var(--border)] px-4 py-3 text-sm">
            <span className="text-[var(--muted)]">
              Page {page} of {totalPages} · {total.toLocaleString("en-US")} sales
            </span>
            <div className="flex gap-2">
              {page > 1 ? (
                <Link
                  href={href({
                    store: selectedStore || undefined,
                    identified: identifiedOnly ? "1" : undefined,
                    page: page - 1,
                  })}
                  className="rounded-md border border-[var(--border)] bg-[var(--canvas)] px-3 py-1.5 font-medium hover:bg-white"
                >
                  Previous
                </Link>
              ) : null}
              {page < totalPages ? (
                <Link
                  href={href({
                    store: selectedStore || undefined,
                    identified: identifiedOnly ? "1" : undefined,
                    page: page + 1,
                  })}
                  className="rounded-md border border-[var(--border)] bg-[var(--canvas)] px-3 py-1.5 font-medium hover:bg-white"
                >
                  Next
                </Link>
              ) : null}
            </div>
          </div>
        ) : null}
      </div>
    </div>
  );
}

function FilterChip({
  href,
  label,
  active,
}: {
  href: string;
  label: string;
  active?: boolean;
}) {
  return (
    <Link
      href={href}
      className={[
        "inline-flex items-center rounded-full border px-3 py-1.5 text-xs font-medium",
        active
          ? "border-[var(--info)] bg-[var(--info)] text-white"
          : "border-[var(--border)] bg-white text-[var(--ink-soft)] hover:border-[var(--info)] hover:text-[var(--info)]",
      ].join(" ")}
    >
      {label}
    </Link>
  );
}
