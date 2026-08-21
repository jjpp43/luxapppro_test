import Link from "next/link";
import { PerPageSelect } from "./PerPageSelect";
import { PageHeader } from "@/components/ui/PageHeader";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

type SearchParams = Promise<{ q?: string; store?: string; per?: string; page?: string }>;
type SupabaseClient = Awaited<ReturnType<typeof createClient>>;

const PAGE_SIZES = [50, 100, 200] as const;

function parsePer(raw?: string) {
  const n = Number(raw);
  return (PAGE_SIZES as readonly number[]).includes(n) ? n : 50;
}

function parsePage(raw?: string) {
  const n = Number(raw);
  return Number.isInteger(n) && n > 1 ? n : 1;
}

function customersHref({
  q,
  store,
  per,
  page,
}: {
  q?: string;
  store?: string;
  per?: number;
  page?: number;
}) {
  const p = new URLSearchParams();
  if (q) p.set("q", q);
  if (store) p.set("store", store);
  if (per && per !== 50) p.set("per", String(per));
  if (page && page > 1) p.set("page", String(page));
  const qs = p.toString();
  return qs ? `/customers?${qs}` : "/customers";
}

function displayStoreName(name: string) {
  return name.replace(/^Lux Beauty Supply - /, "").replace(" - ", " – ");
}

async function countCustomers(supabase: SupabaseClient, storeId?: string) {
  let q = supabase.from("customers").select("id", { count: "exact", head: true });
  if (storeId) q = q.eq("home_store_id", storeId);
  const { count, error } = await q;
  if (error) return 0;
  return count ?? 0;
}

export default async function CustomersPage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  const { q, store: storeParam, per: perParam, page: pageParam } = await searchParams;
  const query = (q ?? "").trim();
  const selectedStore = (storeParam ?? "").trim();
  const per = parsePer(perParam);
  const page = parsePage(pageParam);
  const supabase = await createClient();

  const { data: stores } = await supabase.from("stores").select("id, name").order("name");
  const storeList = stores ?? [];

  const [totalCount, storeCounts, customersResult, filteredCount] = await Promise.all([
    countCustomers(supabase),
    Promise.all(storeList.map((s) => countCustomers(supabase, s.id))),
    (async () => {
      let customersQuery = supabase
        .from("customers")
        .select(
          "id, phone, name, email, legacy_tapmango_id, last_seen_at, lifetime_points_at_migration, stores(name), customer_balance(balance)"
        )
        .order("created_at", { ascending: true })
        .range((page - 1) * per, page * per - 1);

      if (selectedStore) {
        customersQuery = customersQuery.eq("home_store_id", selectedStore);
      }
      if (query) {
        customersQuery = customersQuery.or(
          `phone.ilike.%${query}%,name.ilike.%${query}%,email.ilike.%${query}%,legacy_tapmango_id.eq.${query}`
        );
      }

      return customersQuery;
    })(),
    (async () => {
      let c = supabase.from("customers").select("id", { count: "exact", head: true });
      if (selectedStore) c = c.eq("home_store_id", selectedStore);
      if (query) {
        c = c.or(
          `phone.ilike.%${query}%,name.ilike.%${query}%,email.ilike.%${query}%,legacy_tapmango_id.eq.${query}`
        );
      }
      const { count } = await c;
      return count ?? 0;
    })(),
  ]);

  const { data: customers, error } = customersResult;
  const selectedName = storeList.find((s) => s.id === selectedStore)?.name;
  const totalPages = Math.max(1, Math.ceil(filteredCount / per));
  const from = filteredCount === 0 ? 0 : (page - 1) * per + 1;
  const to = Math.min(page * per, filteredCount);

  return (
    <div>
      <PageHeader
        title="Customers"
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Audience", href: "/customers" },
          { label: "Customers" },
        ]}
        actions={
          <button
            type="button"
            className="rounded-lg bg-[var(--accent)] px-3.5 py-2 text-sm font-semibold text-white transition-[transform,background-color] duration-150 hover:bg-[var(--accent-hover)] active:scale-[0.98]"
          >
            Create New
          </button>
        }
      />

      <div className="mb-4 flex flex-wrap gap-2">
        <FilterChip
          href={customersHref({ q: query || undefined, per })}
          label="All"
          count={totalCount}
          active={!selectedStore}
        />
        {storeList.map((s, i) => (
          <FilterChip
            key={s.id}
            href={customersHref({ q: query || undefined, store: s.id, per })}
            label={displayStoreName(s.name)}
            count={storeCounts[i] ?? 0}
            active={selectedStore === s.id}
          />
        ))}
      </div>

      <div className="overflow-hidden rounded-xl border border-[var(--border)] bg-white">
        <div className="flex flex-wrap items-center justify-between gap-3 border-b border-[var(--border)] px-4 py-3">
          <div className="text-sm text-[var(--muted)]">
            Showing {from.toLocaleString("en-US")}–{to.toLocaleString("en-US")} of{" "}
            {filteredCount.toLocaleString("en-US")}
            {selectedName ? ` · ${displayStoreName(selectedName)}` : ""}
          </div>
          <div className="flex flex-wrap items-center gap-3">
            <PerPageSelect
              per={per}
              q={query || undefined}
              store={selectedStore || undefined}
            />
            <form className="flex gap-2">
              {selectedStore ? (
                <input type="hidden" name="store" value={selectedStore} />
              ) : null}
              {per !== 50 ? <input type="hidden" name="per" value={per} /> : null}
              <input
                type="search"
                name="q"
                defaultValue={query}
                placeholder="Phone, name, email, TapMango id"
                className="w-72 rounded-md border border-[var(--border)] bg-white px-3 py-2 text-sm outline-none focus:border-[var(--accent)]"
              />
              <button
                type="submit"
                className="rounded-md border border-[var(--border)] bg-[var(--canvas)] px-3 py-2 text-sm font-medium hover:bg-white"
              >
                Search
              </button>
            </form>
          </div>
        </div>

        {error ? (
          <p className="mx-4 my-3 rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-800">
            {error.message}
          </p>
        ) : null}

        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-[var(--canvas)] text-xs uppercase tracking-wide text-[var(--muted)]">
              <tr>
                <th className="px-4 py-2.5 font-medium">Name</th>
                <th className="px-4 py-2.5 font-medium">Email</th>
                <th className="px-4 py-2.5 font-medium">Phone #</th>
                <th className="px-4 py-2.5 font-medium text-right">Points</th>
                <th className="px-4 py-2.5 font-medium text-right">Lifetime</th>
                <th className="px-4 py-2.5 font-medium">Last Visit</th>
                <th className="px-4 py-2.5 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody>
              {(customers ?? []).map((c) => {
                const bal = Array.isArray(c.customer_balance)
                  ? c.customer_balance[0]
                  : c.customer_balance;
                return (
                  <tr key={c.id} className="border-t border-[var(--border)]">
                    <td className="px-4 py-2.5">
                      <Link
                        href={`/customers/${c.id}`}
                        className="font-medium text-[var(--info)] hover:underline"
                      >
                        {c.name || "—"}
                      </Link>
                    </td>
                    <td className="px-4 py-2.5 text-[var(--ink-soft)]">
                      {c.email || "—"}
                    </td>
                    <td className="px-4 py-2.5 font-mono text-xs">{c.phone}</td>
                    <td className="px-4 py-2.5 text-right tabular-nums font-medium">
                      {bal?.balance ?? 0}
                    </td>
                    <td className="px-4 py-2.5 text-right tabular-nums text-[var(--muted)]">
                      {c.lifetime_points_at_migration ?? "—"}
                    </td>
                    <td className="px-4 py-2.5 text-[var(--muted)]">
                      {c.last_seen_at
                        ? new Date(c.last_seen_at).toLocaleString()
                        : "—"}
                    </td>
                    <td className="px-4 py-2.5 text-xs">
                      <Link
                        href={`/customers/${c.id}`}
                        className="text-[var(--info)] hover:underline"
                      >
                        Edit
                      </Link>
                      <span className="mx-1 text-[var(--border-strong)]">|</span>
                      <span className="text-[var(--muted)]">Check in</span>
                    </td>
                  </tr>
                );
              })}
              {(customers ?? []).length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-4 py-10 text-center text-[var(--muted)]">
                    No customers found
                  </td>
                </tr>
              ) : null}
            </tbody>
          </table>
        </div>

        {filteredCount > per ? (
          <div className="flex flex-wrap items-center justify-between gap-3 border-t border-[var(--border)] px-4 py-3 text-sm">
            <span className="text-[var(--muted)]">
              Page {page} of {totalPages}
            </span>
            <div className="flex gap-2">
              {page > 1 ? (
                <Link
                  href={customersHref({
                    q: query || undefined,
                    store: selectedStore || undefined,
                    per,
                    page: page - 1,
                  })}
                  className="rounded-md border border-[var(--border)] bg-[var(--canvas)] px-3 py-1.5 font-medium hover:bg-white"
                >
                  Previous
                </Link>
              ) : (
                <span className="rounded-md border border-[var(--border)] px-3 py-1.5 text-[var(--muted)]">
                  Previous
                </span>
              )}
              {page * per < filteredCount ? (
                <Link
                  href={customersHref({
                    q: query || undefined,
                    store: selectedStore || undefined,
                    per,
                    page: page + 1,
                  })}
                  className="rounded-md border border-[var(--border)] bg-[var(--canvas)] px-3 py-1.5 font-medium hover:bg-white"
                >
                  Next
                </Link>
              ) : (
                <span className="rounded-md border border-[var(--border)] px-3 py-1.5 text-[var(--muted)]">
                  Next
                </span>
              )}
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
  count,
  active,
}: {
  href: string;
  label: string;
  count: number;
  active?: boolean;
}) {
  return (
    <Link
      href={href}
      className={[
        "inline-flex items-center gap-1.5 rounded-full border px-3 py-1.5 text-xs font-medium transition-colors",
        active
          ? "border-[var(--info)] bg-[var(--info)] text-white"
          : "border-[var(--border)] bg-white text-[var(--ink-soft)] hover:border-[var(--info)] hover:text-[var(--info)]",
      ].join(" ")}
    >
      {label}
      <span
        className={[
          "tabular-nums",
          active ? "text-white/80" : "text-[var(--muted)]",
        ].join(" ")}
      >
        {count.toLocaleString("en-US")}
      </span>
    </Link>
  );
}
