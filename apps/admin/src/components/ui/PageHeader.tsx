import Link from "next/link";

export function PageHeader({
  title,
  subtitle,
  crumbs,
  actions,
}: {
  title: string;
  subtitle?: string;
  crumbs?: { label: string; href?: string }[];
  actions?: React.ReactNode;
}) {
  return (
    <div className="mb-6 flex flex-wrap items-start justify-between gap-4">
      <div>
        <h1 className="font-[family-name:var(--font-display)] text-3xl tracking-tight text-[var(--ink)]">
          {title}
        </h1>
        {subtitle ? (
          <p className="mt-1 text-sm text-[var(--muted)]">{subtitle}</p>
        ) : null}
        {crumbs?.length ? (
          <nav className="mt-2 flex flex-wrap items-center gap-1.5 text-xs text-[var(--muted)]">
            {crumbs.map((c, i) => (
              <span key={`${c.label}-${i}`} className="flex items-center gap-1.5">
                {i > 0 ? <span aria-hidden>›</span> : null}
                {c.href ? (
                  <Link href={c.href} className="hover:text-[var(--ink)]">
                    {c.label}
                  </Link>
                ) : (
                  <span className="text-[var(--ink-soft)]">{c.label}</span>
                )}
              </span>
            ))}
          </nav>
        ) : null}
      </div>
      {actions}
    </div>
  );
}
