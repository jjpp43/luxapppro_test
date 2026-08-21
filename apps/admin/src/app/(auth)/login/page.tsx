import { signInAction } from "../actions";
import { LoginSubmitButton } from "./LoginSubmitButton";

type LoginPageProps = {
  searchParams: Promise<{
    error?: string;
    next?: string;
  }>;
};

export default async function LoginPage({ searchParams }: LoginPageProps) {
  const { error, next } = await searchParams;

  return (
    <main className="flex min-h-dvh items-center justify-center bg-[var(--canvas)] px-5 py-10">
      <section className="w-full max-w-md rounded-2xl border border-[var(--border)] bg-white p-7 shadow-sm">
        <div className="mb-7">
          <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[var(--accent)]">
            Lux Beauty Supply
          </p>
          <h1 className="mt-2 font-[family-name:var(--font-display)] text-3xl font-semibold text-[var(--ink)]">
            Admin sign in
          </h1>
          <p className="mt-2 text-sm text-[var(--muted)]">
            Managers and owners can access the loyalty dashboard.
          </p>
        </div>

        {error ? (
          <div
            role="alert"
            className="mb-5 rounded-lg border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-700"
          >
            {error}
          </div>
        ) : null}

        <form action={signInAction} className="space-y-4">
          <input type="hidden" name="next" value={next ?? "/"} />

          <label className="block">
            <span className="mb-1.5 block text-sm font-medium text-[var(--ink-soft)]">
              Email
            </span>
            <input
              required
              name="email"
              type="email"
              autoComplete="email"
              className="w-full rounded-lg border border-[var(--border)] px-3 py-2.5 text-sm outline-none transition-colors focus:border-[var(--accent)]"
            />
          </label>

          <label className="block">
            <span className="mb-1.5 block text-sm font-medium text-[var(--ink-soft)]">
              Password
            </span>
            <input
              required
              name="password"
              type="password"
              autoComplete="current-password"
              className="w-full rounded-lg border border-[var(--border)] px-3 py-2.5 text-sm outline-none transition-colors focus:border-[var(--accent)]"
            />
          </label>

          <LoginSubmitButton />
        </form>
      </section>
    </main>
  );
}
