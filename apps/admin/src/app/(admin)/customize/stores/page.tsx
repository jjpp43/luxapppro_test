import { PageHeader } from "@/components/ui/PageHeader";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function StoresPage() {
  const supabase = await createClient();
  const { data: stores, error } = await supabase
    .from("stores")
    .select("id, name, lightspeed_outlet_id, active, created_at")
    .order("name");

  return (
    <div>
      <PageHeader
        title="Stores"
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Customize", href: "/customize/stores" },
          { label: "Stores" },
        ]}
      />

      {error ? (
        <p className="mb-4 rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-800">
          {error.message}
        </p>
      ) : null}

      <div className="overflow-hidden rounded-xl border border-[var(--border)] bg-white">
        <table className="w-full text-left text-sm">
          <thead className="bg-[var(--canvas)] text-xs uppercase tracking-wide text-[var(--muted)]">
            <tr>
              <th className="px-4 py-2.5 font-medium">Name</th>
              <th className="px-4 py-2.5 font-medium">Lightspeed outlet</th>
              <th className="px-4 py-2.5 font-medium">Status</th>
            </tr>
          </thead>
          <tbody>
            {(stores ?? []).map((s) => (
              <tr key={s.id} className="border-t border-[var(--border)]">
                <td className="px-4 py-3 font-medium">{s.name}</td>
                <td className="px-4 py-3 font-mono text-xs text-[var(--muted)]">
                  {s.lightspeed_outlet_id || "—"}
                </td>
                <td className="px-4 py-3">
                  <span
                    className={[
                      "rounded-full px-2 py-0.5 text-xs font-medium",
                      s.active
                        ? "bg-emerald-50 text-[var(--good)]"
                        : "bg-stone-100 text-[var(--muted)]",
                    ].join(" ")}
                  >
                    {s.active ? "Active" : "Inactive"}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
