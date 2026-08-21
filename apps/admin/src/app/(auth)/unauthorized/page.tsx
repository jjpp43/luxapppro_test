import { signOutAction } from "../actions";

type UnauthorizedPageProps = {
  searchParams: Promise<{ reason?: string }>;
};

const messages: Record<string, string> = {
  owner: "Only owners can manage staff invitations and access.",
  role: "Cashier accounts cannot access the admin dashboard.",
  unlinked:
    "This login is not linked to an active Lux Pro manager or owner account.",
};

export default async function UnauthorizedPage({
  searchParams,
}: UnauthorizedPageProps) {
  const { reason } = await searchParams;

  return (
    <main className="flex min-h-dvh items-center justify-center bg-[var(--canvas)] px-5 py-10">
      <section className="w-full max-w-md rounded-2xl border border-[var(--border)] bg-white p-7 text-center shadow-sm">
        <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[var(--accent)]">
          Lux Pro Admin
        </p>
        <h1 className="mt-2 font-[family-name:var(--font-display)] text-3xl font-semibold text-[var(--ink)]">
          Access unavailable
        </h1>
        <p className="mt-3 text-sm leading-6 text-[var(--muted)]">
          {messages[reason ?? ""] ??
            "Your account is not authorized to use this dashboard."}
        </p>
        <form action={signOutAction} className="mt-6">
          <button
            type="submit"
            className="rounded-lg border border-[var(--border)] bg-white px-4 py-2.5 text-sm font-semibold text-[var(--ink-soft)] hover:bg-[var(--canvas)]"
          >
            Sign out
          </button>
        </form>
      </section>
    </main>
  );
}
