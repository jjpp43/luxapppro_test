import Link from "next/link";
import { PageHeader } from "@/components/ui/PageHeader";
import { requireAdminStaff } from "@/lib/auth/staff";
import { createAdminClient } from "@/lib/supabase/admin";

type UsersPageProps = {
  searchParams: Promise<{
    invited?: string;
    updated?: string;
  }>;
};

export default async function UsersPage({ searchParams }: UsersPageProps) {
  const currentStaff = await requireAdminStaff();
  const { invited, updated } = await searchParams;
  const admin = createAdminClient();
  let query = admin
    .from("staff")
    .select("id, name, email, role, active, store_id, auth_user_id, stores(name)")
    .in("role", ["manager", "owner"])
    .order("name");

  if (currentStaff.role === "manager") {
    query = query.eq("store_id", currentStaff.storeId);
  }

  const { data: users, error } = await query;

  return (
    <div>
      <PageHeader
        title="Users"
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Account", href: "/account/users" },
          { label: "Users" },
        ]}
        actions={
          currentStaff.role === "owner" ? (
            <Link
              href="/account/users/new"
              className="rounded-lg bg-[var(--accent)] px-3.5 py-2 text-sm font-semibold text-white transition-[transform,background-color] duration-150 hover:bg-[var(--accent-hover)] active:scale-[0.98]"
            >
              Invite staff
            </Link>
          ) : undefined
        }
      />

      {invited ? (
        <div className="mb-4 rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-800">
          Invitation sent to {invited}.
        </div>
      ) : null}

      {updated ? (
        <div className="mb-4 rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-800">
          Staff access updated.
        </div>
      ) : null}

      <div className="overflow-hidden rounded-xl border border-[var(--border)] bg-white">
        {error ? (
          <div className="border-b border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
            Unable to load staff: {error.message}
          </div>
        ) : null}
        <table className="w-full text-left text-sm">
          <thead className="bg-[var(--canvas)] text-xs uppercase tracking-wide text-[var(--muted)]">
            <tr>
              <th className="px-4 py-2.5 font-medium">Name</th>
              <th className="px-4 py-2.5 font-medium">Email</th>
              <th className="px-4 py-2.5 font-medium">Role</th>
              <th className="px-4 py-2.5 font-medium">Store</th>
              <th className="px-4 py-2.5 font-medium">Status</th>
              {currentStaff.role === "owner" ? (
                <th className="px-4 py-2.5 font-medium">Actions</th>
              ) : null}
            </tr>
          </thead>
          <tbody>
            {(users ?? []).map((u) => {
              const store = Array.isArray(u.stores) ? u.stores[0] : u.stores;
              return (
              <tr key={u.id} className="border-t border-[var(--border)]">
                <td className="px-4 py-2.5 font-medium">{u.name}</td>
                <td className="px-4 py-2.5 text-[var(--ink-soft)]">
                  {u.email || "—"}
                </td>
                <td className="px-4 py-2.5 capitalize">{u.role}</td>
                <td className="px-4 py-2.5 text-[var(--ink-soft)]">
                  {store?.name ?? "Chain-wide"}
                </td>
                <td className="px-4 py-2.5">
                  <span
                    className={[
                      "rounded-full px-2 py-0.5 text-xs font-medium",
                      u.active
                        ? "bg-emerald-50 text-[var(--good)]"
                        : "bg-stone-100 text-[var(--muted)]",
                    ].join(" ")}
                  >
                    {u.active
                      ? u.auth_user_id
                        ? "Active"
                        : "Pending link"
                      : "Inactive"}
                  </span>
                </td>
                {currentStaff.role === "owner" ? (
                  <td className="px-4 py-2.5 text-xs">
                    <Link
                      href={`/account/users/${u.id}/edit`}
                      className="text-[var(--info)] hover:underline"
                    >
                      Edit
                    </Link>
                  </td>
                ) : null}
              </tr>
              );
            })}
            {!users?.length ? (
              <tr>
                <td
                  colSpan={currentStaff.role === "owner" ? 6 : 5}
                  className="px-4 py-8 text-center text-sm text-[var(--muted)]"
                >
                  No admin staff found.
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>
    </div>
  );
}
