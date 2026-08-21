import Link from "next/link";

type StoreOption = {
  id: string;
  name: string;
};

type StaffFormValues = {
  id?: string;
  name?: string;
  email?: string | null;
  role?: "manager" | "owner";
  storeId?: string | null;
  active?: boolean;
};

export function UserForm({
  mode,
  action,
  stores,
  initial = {},
  error,
}: {
  mode: "create" | "edit";
  action: (formData: FormData) => void | Promise<void>;
  stores: StoreOption[];
  initial?: StaffFormValues;
  error?: string;
}) {
  return (
    <form
      action={action}
      className="overflow-hidden rounded-xl border border-[var(--border)] bg-white"
    >
      {initial.id ? <input type="hidden" name="id" value={initial.id} /> : null}

      <div className="border-b border-[var(--border)] px-5 py-4 md:px-8">
        <h2 className="font-semibold text-[var(--ink)]">
          {mode === "create" ? "Invite admin staff" : "Edit staff access"}
        </h2>
        <p className="mt-1 text-sm text-[var(--muted)]">
          {mode === "create"
            ? "The staff member will receive an email to set their password."
            : "Email is managed by Supabase Auth and cannot be changed here."}
        </p>
      </div>

      {error ? (
        <div
          role="alert"
          className="mx-5 mt-5 rounded-lg border border-red-200 bg-red-50 px-3 py-2.5 text-sm text-red-700 md:mx-8"
        >
          {error}
        </div>
      ) : null}

      <div className="space-y-5 px-5 py-6 md:px-8">
        <label className="block">
          <span className="mb-1.5 block text-sm font-medium text-[var(--ink-soft)]">
            Name
          </span>
          <input
            required
            name="name"
            defaultValue={initial.name ?? ""}
            autoComplete="name"
            className="w-full max-w-lg rounded-lg border border-[var(--border)] px-3 py-2.5 text-sm outline-none focus:border-[var(--accent)]"
          />
        </label>

        <label className="block">
          <span className="mb-1.5 block text-sm font-medium text-[var(--ink-soft)]">
            Email
          </span>
          <input
            required
            readOnly={mode === "edit"}
            name="email"
            type="email"
            defaultValue={initial.email ?? ""}
            autoComplete="email"
            className="w-full max-w-lg rounded-lg border border-[var(--border)] px-3 py-2.5 text-sm outline-none read-only:bg-[var(--canvas)] read-only:text-[var(--muted)] focus:border-[var(--accent)]"
          />
        </label>

        <label className="block">
          <span className="mb-1.5 block text-sm font-medium text-[var(--ink-soft)]">
            Admin role
          </span>
          <select
            name="role"
            defaultValue={initial.role ?? "manager"}
            className="w-full max-w-lg rounded-lg border border-[var(--border)] bg-white px-3 py-2.5 text-sm outline-none focus:border-[var(--accent)]"
          >
            <option value="manager">Manager</option>
            <option value="owner">Owner</option>
          </select>
        </label>

        <label className="block">
          <span className="mb-1.5 block text-sm font-medium text-[var(--ink-soft)]">
            Store
          </span>
          <select
            name="store_id"
            defaultValue={initial.storeId ?? ""}
            className="w-full max-w-lg rounded-lg border border-[var(--border)] bg-white px-3 py-2.5 text-sm outline-none focus:border-[var(--accent)]"
          >
            <option value="">No store (owners only)</option>
            {stores.map((store) => (
              <option key={store.id} value={store.id}>
                {store.name}
              </option>
            ))}
          </select>
          <span className="mt-1.5 block text-xs text-[var(--muted)]">
            Managers must have a store. Owners may be chain-wide.
          </span>
        </label>

        {mode === "edit" ? (
          <label className="flex items-center gap-2 text-sm text-[var(--ink-soft)]">
            <input
              name="active"
              type="checkbox"
              defaultChecked={initial.active ?? true}
              className="h-4 w-4 accent-[var(--accent)]"
            />
            Active admin access
          </label>
        ) : null}
      </div>

      <div className="flex items-center gap-2 border-t border-[var(--border)] bg-[var(--canvas)]/50 px-5 py-4 md:px-8">
        <button
          type="submit"
          className="rounded-lg bg-[var(--accent)] px-4 py-2.5 text-sm font-semibold text-white transition-[transform,background-color] hover:bg-[var(--accent-hover)] active:scale-[0.99]"
        >
          {mode === "create" ? "Send invitation" : "Save changes"}
        </button>
        <Link
          href="/account/users"
          className="rounded-lg border border-[var(--border)] bg-white px-4 py-2.5 text-sm font-medium text-[var(--ink-soft)] hover:bg-[var(--canvas)]"
        >
          Cancel
        </Link>
      </div>
    </form>
  );
}
