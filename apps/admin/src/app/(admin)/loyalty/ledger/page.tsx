import Link from "next/link";
import { PageHeader } from "@/components/ui/PageHeader";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

type SearchParams = Promise<{
  reason?: string;
  store?: string;
  page?: string;
}>;

const PAGE_SIZE = 50;
const REASONS = [
  "earn",
  "redemption",
  "migration_opening",
  "correction",
  "referral_bonus",
  "expiry",
  "return_clawback",
] as const;

function href(next: { reason?: string; store?: string; page?: number }) {
  const p = new URLSearchParams();
  if (next.reason) p.set("reason", next.reason);
  if (next.store) p.set("store", next.store);
  if (next.page && next.page > 1) p.set("page", String(next.page));
  const qs = p.toString();
  return qs ? `/loyalty/ledger?${qs}` : "/loyalty/ledger";
}

export default async function LedgerPage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  const { reason: reasonParam, store: storeParam, page: pageParam } =
    await searchParams;
  const reason = REASONS.includes(reasonParam as (typeof REASONS)[number])
    ? reasonParam
    : "";
  const selectedStore = (storeParam ?? "").trim();
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
    .from("points_ledger")
    .select(
      "id, created_at, delta, reason, idempotency_key, customer_id, stores(name), customers(id, name, phone)",
      { count: "exact" },
    )
    .order("created_at", { ascending: false })
    .range(from, from + PAGE_SIZE - 1);

  if (reason) query = query.eq("reason", reason);
  if (selectedStore) query = query.eq("store_id", selectedStore);

  const { data: rows, count, error } = await query;
  const total = count ?? 0;
  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));

  return (
    <div>
      <PageHeader
        title="Points ledger"
        subtitle="Append-only history. New earn rows will not appear until a store flag is on."
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Loyalty Program", href: "/loyalty" },
          { label: "Points ledger" },
        ]}
      />

      <div className="mb-4 flex flex-wrap gap-2">
        <FilterChip href={href({ store: selectedStore || undefined })} label="All reasons" active={!reason} />
        {REASONS.map((r) => (
          <FilterChip
            key={r}
            href={href({ reason: r, store: selectedStore || undefined })}
            label={r.replaceAll("_", " ")}
            active={reason === r}
          />
        ))}
      </div>
      <div className="mb-4 flex flex-wrap gap-2">
        <FilterChip href={href({ reason: reason || undefined })} label="All stores" active={!selectedStore} />
        {(stores ?? []).map((s) => (
          <FilterChip
            key={s.id}
            href={href({ reason: reason || undefined, store: s.id })}
            label={s.name.replace(/^Lux Beauty Supply - /, "")}
            active={selectedStore === s.id}
          />
        ))}
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
                <th className="px-4 py-2.5 font-medium">Customer</th>
                <th className="px-4 py-2.5 font-medium">Store</th>
                <th className="px-4 py-2.5 font-medium">Reason</th>
                <th className="px-4 py-2.5 font-medium text-right">Delta</th>
              </tr>
            </thead>
            <tbody>
              {(rows ?? []).map((row) => {
                const store = Array.isArray(row.stores) ? row.stores[0] : row.stores;
                const customer = Array.isArray(row.customers)
                  ? row.customers[0]
                  : row.customers;
                return (
                  <tr key={row.id} className="border-t border-[var(--border)]">
                    <td className="px-4 py-2.5 text-[var(--muted)]">
                      {new Date(row.created_at).toLocaleString()}
                    </td>
                    <td className="px-4 py-2.5">
                      {customer ? (
                        <Link
                          href={`/customers/${customer.id}`}
                          className="font-medium text-[var(--info)] hover:underline"
                        >
                          {customer.name || customer.phone}
                        </Link>
                      ) : (
                        "—"
                      )}
                    </td>
                    <td className="px-4 py-2.5">{store?.name ?? "—"}</td>
                    <td className="px-4 py-2.5 font-mono text-xs">{row.reason}</td>
                    <td
                      className={[
                        "px-4 py-2.5 text-right tabular-nums font-medium",
                        row.delta < 0 ? "text-red-700" : "text-[var(--ink)]",
                      ].join(" ")}
                    >
                      {row.delta > 0 ? `+${row.delta}` : row.delta}
                    </td>
                  </tr>
                );
              })}
              {(rows ?? []).length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-4 py-10 text-center text-[var(--muted)]">
                    No ledger rows found
                  </td>
                </tr>
              ) : null}
            </tbody>
          </table>
        </div>
        {total > PAGE_SIZE ? (
          <div className="flex items-center justify-between border-t border-[var(--border)] px-4 py-3 text-sm">
            <span className="text-[var(--muted)]">
              Page {page} of {totalPages} · {total.toLocaleString("en-US")} rows
            </span>
            <div className="flex gap-2">
              {page > 1 ? (
                <Link
                  href={href({
                    reason: reason || undefined,
                    store: selectedStore || undefined,
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
                    reason: reason || undefined,
                    store: selectedStore || undefined,
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
