import { PageHeader } from "@/components/ui/PageHeader";

const SAMPLE_GROUPS = [
  {
    id: 1,
    name: "*Recent*",
    description: "Customers who've signed up within 31 days.",
    type: "Filters",
  },
  {
    id: 2,
    name: "1 Month",
    description: "Visited in the last 30 days.",
    type: "Filters",
  },
  {
    id: 3,
    name: "High points",
    description: "Placeholder — real group rules come later.",
    type: "Filters",
  },
];

export default function GroupsPage() {
  return (
    <div>
      <PageHeader
        title="Customer Groups"
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Audience", href: "/customers" },
          { label: "Customer Groups" },
        ]}
      />

      <div className="overflow-hidden rounded-xl border border-[var(--border)] bg-white">
        <div className="flex items-center justify-between border-b border-[var(--border)] px-4 py-3">
          <p className="text-sm text-[var(--muted)]">
            UI shell only — groups are not in the staging schema yet.
          </p>
          <button
            type="button"
            className="rounded-lg bg-[var(--accent)] px-3 py-2 text-sm font-semibold text-white hover:bg-[var(--accent-hover)]"
          >
            Create New
          </button>
        </div>
        <table className="w-full text-left text-sm">
          <thead className="bg-[var(--canvas)] text-xs uppercase tracking-wide text-[var(--muted)]">
            <tr>
              <th className="px-4 py-2.5 font-medium">GroupId</th>
              <th className="px-4 py-2.5 font-medium">Name</th>
              <th className="px-4 py-2.5 font-medium">Description</th>
              <th className="px-4 py-2.5 font-medium">Type</th>
              <th className="px-4 py-2.5 font-medium">Actions</th>
            </tr>
          </thead>
          <tbody>
            {SAMPLE_GROUPS.map((g) => (
              <tr key={g.id} className="border-t border-[var(--border)]">
                <td className="px-4 py-2.5 text-[var(--info)]">{g.id}</td>
                <td className="px-4 py-2.5 font-medium text-[var(--info)]">{g.name}</td>
                <td className="px-4 py-2.5 text-[var(--ink-soft)]">{g.description}</td>
                <td className="px-4 py-2.5">{g.type}</td>
                <td className="px-4 py-2.5 text-xs text-[var(--muted)]">
                  Edit | Delete | See Customers
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
