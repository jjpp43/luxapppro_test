export function TopBar() {
  return (
    <header className="flex h-14 shrink-0 items-center justify-between border-b border-[var(--border)] bg-white/90 px-5 backdrop-blur-sm">
      <div className="flex items-center gap-2 text-sm text-[var(--muted)]">
        <span className="hidden rounded-md border border-[var(--accent)]/30 px-2.5 py-1 text-[12px] font-medium text-[var(--accent)] sm:inline">
          Staging · luxproapp_test
        </span>
      </div>
      <div className="flex items-center gap-2">
        <button
          type="button"
          className="hidden rounded-md border border-[var(--border)] px-3 py-1.5 text-sm text-[var(--ink-soft)] transition-colors hover:bg-black/[0.02] md:inline"
        >
          Share Links
        </button>
        <div className="flex items-center gap-2 rounded-full border border-[var(--border)] bg-white py-1 pl-1 pr-3">
          <div className="flex h-7 w-7 items-center justify-center rounded-full bg-[var(--ink)] text-[10px] font-bold tracking-wide text-white">
            LUX
          </div>
          <span className="text-sm font-medium text-[var(--ink)]">Lux Beauty Supply</span>
        </div>
      </div>
    </header>
  );
}
