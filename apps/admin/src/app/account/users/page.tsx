import Link from "next/link";
import { PageHeader } from "@/components/ui/PageHeader";

const SAMPLE_USERS = [
  {
    id: "1",
    name: "James Jung",
    username: "jjung",
    email: "james@luxbeautysupply.com",
    roles: "Merchant Admin",
    active: true,
  },
  {
    id: "2",
    name: "Store Manager",
    username: "manager.sahara",
    email: "manager@luxbeautysupply.com",
    roles: "Manager",
    active: true,
  },
  {
    id: "3",
    name: "Front Counter",
    username: "cashier1",
    email: "",
    roles: "User",
    active: true,
  },
];

export default function UsersPage() {
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
          <Link
            href="/account/users/new"
            className="rounded-lg bg-[var(--accent)] px-3.5 py-2 text-sm font-semibold text-white transition-[transform,background-color] duration-150 hover:bg-[var(--accent-hover)] active:scale-[0.98]"
          >
            Create New
          </Link>
        }
      />

      <div className="overflow-hidden rounded-xl border border-[var(--border)] bg-white">
        <div className="border-b border-[var(--border)] px-4 py-3 text-sm text-[var(--muted)]">
          Sample rows for layout only — not connected to Supabase yet.
        </div>
        <table className="w-full text-left text-sm">
          <thead className="bg-[var(--canvas)] text-xs uppercase tracking-wide text-[var(--muted)]">
            <tr>
              <th className="px-4 py-2.5 font-medium">Name</th>
              <th className="px-4 py-2.5 font-medium">Username</th>
              <th className="px-4 py-2.5 font-medium">Email</th>
              <th className="px-4 py-2.5 font-medium">Roles</th>
              <th className="px-4 py-2.5 font-medium">Status</th>
              <th className="px-4 py-2.5 font-medium">Actions</th>
            </tr>
          </thead>
          <tbody>
            {SAMPLE_USERS.map((u) => (
              <tr key={u.id} className="border-t border-[var(--border)]">
                <td className="px-4 py-2.5 font-medium">{u.name}</td>
                <td className="px-4 py-2.5 font-mono text-xs">{u.username}</td>
                <td className="px-4 py-2.5 text-[var(--ink-soft)]">
                  {u.email || "—"}
                </td>
                <td className="px-4 py-2.5">{u.roles}</td>
                <td className="px-4 py-2.5">
                  <span
                    className={[
                      "rounded-full px-2 py-0.5 text-xs font-medium",
                      u.active
                        ? "bg-emerald-50 text-[var(--good)]"
                        : "bg-stone-100 text-[var(--muted)]",
                    ].join(" ")}
                  >
                    {u.active ? "Active" : "Inactive"}
                  </span>
                </td>
                <td className="px-4 py-2.5 text-xs">
                  <Link
                    href={`/account/users/${u.id}/edit`}
                    className="text-[var(--info)] hover:underline"
                  >
                    Edit
                  </Link>
                  <span className="mx-1 text-[var(--border-strong)]">|</span>
                  <span className="text-[var(--muted)]">Delete</span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
