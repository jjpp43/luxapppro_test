import { PageHeader } from "./PageHeader";

export function ComingSoon({
  title,
  crumbs,
  note,
}: {
  title: string;
  crumbs: { label: string; href?: string }[];
  note?: string;
}) {
  return (
    <div>
      <PageHeader title={title} crumbs={crumbs} />
      <div className="rounded-xl border border-dashed border-[var(--border-strong)] bg-white/70 px-6 py-16 text-center">
        <p className="font-[family-name:var(--font-display)] text-xl text-[var(--ink)]">
          Coming soon
        </p>
        <p className="mx-auto mt-2 max-w-md text-sm text-[var(--muted)]">
          {note ??
            "Shell placeholder — wired to match TapMango navigation. Live data for this area lands after the next build phase."}
        </p>
      </div>
    </div>
  );
}
