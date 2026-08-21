import { setPasswordAction } from "../../actions";

type SetPasswordPageProps = {
  searchParams: Promise<{ error?: string }>;
};

export default async function SetPasswordPage({
  searchParams,
}: SetPasswordPageProps) {
  const { error } = await searchParams;

  return (
    <main className="flex min-h-dvh items-center justify-center bg-[var(--canvas)] px-5 py-10">
      <section className="w-full max-w-md rounded-2xl border border-[var(--border)] bg-white p-7 shadow-sm">
        <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[var(--accent)]">
          Staff invitation
        </p>
        <h1 className="mt-2 font-[family-name:var(--font-display)] text-3xl font-semibold text-[var(--ink)]">
          Set your password
        </h1>
        <p className="mt-2 text-sm text-[var(--muted)]">
          Choose a password to finish activating your admin account.
        </p>

        {error ? (
          <div
            role="alert"
            className="mt-5 rounded-lg border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-700"
          >
            {error}
          </div>
        ) : null}

        <form action={setPasswordAction} className="mt-6 space-y-4">
          <label className="block">
            <span className="mb-1.5 block text-sm font-medium text-[var(--ink-soft)]">
              New password
            </span>
            <input
              required
              minLength={8}
              name="password"
              type="password"
              autoComplete="new-password"
              className="w-full rounded-lg border border-[var(--border)] px-3 py-2.5 text-sm outline-none transition-colors focus:border-[var(--accent)]"
            />
          </label>

          <label className="block">
            <span className="mb-1.5 block text-sm font-medium text-[var(--ink-soft)]">
              Confirm password
            </span>
            <input
              required
              minLength={8}
              name="confirmation"
              type="password"
              autoComplete="new-password"
              className="w-full rounded-lg border border-[var(--border)] px-3 py-2.5 text-sm outline-none transition-colors focus:border-[var(--accent)]"
            />
          </label>

          <button
            type="submit"
            className="w-full rounded-lg bg-[var(--accent)] px-4 py-2.5 text-sm font-semibold text-white transition-[transform,background-color] hover:bg-[var(--accent-hover)] active:scale-[0.99]"
          >
            Activate account
          </button>
        </form>
      </section>
    </main>
  );
}
