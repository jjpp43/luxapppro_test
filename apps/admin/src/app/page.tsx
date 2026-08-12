import Link from "next/link";
import { supabase } from "@/lib/supabase";

export const dynamic = "force-dynamic";

export default async function HomePage() {
  const [{ count: customerCount }, { data: ledgerAgg }, { count: storeCount }] =
    await Promise.all([
      supabase.from("customers").select("*", { count: "exact", head: true }),
      supabase.from("points_ledger").select("delta"),
      supabase.from("stores").select("*", { count: "exact", head: true }),
    ]);

  const pointsSum = (ledgerAgg ?? []).reduce(
    (sum, row) => sum + (row.delta ?? 0),
    0
  );

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Overview</h1>
        <p className="mt-1 text-sm text-zinc-600">
          TapMango 100-row sample on Supabase project{" "}
          <code className="rounded bg-zinc-100 px-1">luxproapp_test</code>
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <Stat label="Customers" value={customerCount ?? 0} hint="expect 100" />
        <Stat label="Stores" value={storeCount ?? 0} hint="expect 3" />
        <Stat
          label="Opening points sum"
          value={pointsSum.toLocaleString()}
          hint="expect 9,547"
        />
      </div>

      <Link
        href="/customers"
        className="inline-flex rounded-md bg-zinc-900 px-4 py-2 text-sm font-medium text-white hover:bg-zinc-800"
      >
        Browse customers
      </Link>
    </div>
  );
}

function Stat({
  label,
  value,
  hint,
}: {
  label: string;
  value: string | number;
  hint: string;
}) {
  return (
    <div className="rounded-lg border border-zinc-200 bg-white p-4">
      <div className="text-sm text-zinc-500">{label}</div>
      <div className="mt-1 text-3xl font-semibold tabular-nums">{value}</div>
      <div className="mt-1 text-xs text-zinc-400">{hint}</div>
    </div>
  );
}
