"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { NavIconGlyph } from "./icons";
import { navItems } from "./nav";

function isActive(pathname: string, href?: string) {
  if (!href) return false;
  if (href === "/") return pathname === "/";
  return pathname === href || pathname.startsWith(`${href}/`);
}

function sectionOpen(pathname: string, children?: { href: string }[]) {
  return Boolean(children?.some((c) => isActive(pathname, c.href)));
}

function Submenu({
  open,
  children,
}: {
  open: boolean;
  children: React.ReactNode;
}) {
  return (
    <div
      className={[
        "grid transition-[grid-template-rows,opacity] duration-200 ease-[cubic-bezier(0.23,1,0.32,1)] motion-reduce:transition-none",
        open ? "grid-rows-[1fr] opacity-100" : "grid-rows-[0fr] opacity-0",
      ].join(" ")}
      aria-hidden={!open}
    >
      <div className="min-h-0 overflow-hidden">{children}</div>
    </div>
  );
}

export function Sidebar() {
  const pathname = usePathname();
  const [query, setQuery] = useState("");
  const [openLabel, setOpenLabel] = useState<string | null>(() => {
    const match = navItems.find((item) => sectionOpen(pathname, item.children));
    return match?.label ?? null;
  });

  useEffect(() => {
    const match = navItems.find((item) => sectionOpen(pathname, item.children));
    if (match) setOpenLabel(match.label);
  }, [pathname]);

  const filtered = navItems.filter((item) => {
    if (!query.trim()) return true;
    const q = query.toLowerCase();
    if (item.label.toLowerCase().includes(q)) return true;
    return item.children?.some((c) => c.label.toLowerCase().includes(q));
  });

  return (
    <aside className="sticky top-0 flex h-dvh w-[250px] shrink-0 flex-col border-r border-[var(--border)] bg-[var(--sidebar)]">
      <div className="shrink-0 border-b border-[var(--border)] px-4 py-4">
        <Link href="/" className="block">
          <div className="font-[family-name:var(--font-display)] text-[1.35rem] font-semibold tracking-tight text-[var(--ink)]">
            Lux Pro
          </div>
          <div className="mt-0.5 text-[11px] font-medium uppercase tracking-[0.14em] text-[var(--muted)]">
            Admin
          </div>
        </Link>
        <button
          type="button"
          className="mt-4 flex w-full items-center justify-center gap-1.5 rounded-lg bg-[var(--accent)] px-3 py-2.5 text-sm font-semibold text-white shadow-[0_1px_0_rgba(255,255,255,0.2)_inset] transition-[transform,background-color] duration-150 ease-out hover:bg-[var(--accent-hover)] active:scale-[0.98]"
        >
          <span className="text-base leading-none">+</span>
          Create a Campaign
        </button>
        <label className="mt-3 block">
          <span className="sr-only">Search menu</span>
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search menu"
            className="w-full rounded-md border border-[var(--border)] bg-white px-3 py-2 text-sm text-[var(--ink)] outline-none placeholder:text-[var(--muted)] focus:border-[var(--accent)]"
          />
        </label>
      </div>

      <nav className="min-h-0 flex-1 overflow-y-auto px-2 py-3">
        <ul className="space-y-0.5">
          {filtered.map((item) => {
            const hasChildren = Boolean(item.children?.length);
            const expanded = openLabel === item.label;
            const activeTop = item.href
              ? isActive(pathname, item.href)
              : sectionOpen(pathname, item.children);

            return (
              <li key={item.label}>
                {hasChildren ? (
                  <button
                    type="button"
                    aria-expanded={expanded}
                    onClick={() =>
                      setOpenLabel((current) =>
                        current === item.label ? null : item.label
                      )
                    }
                    className={[
                      "flex w-full items-center gap-2.5 rounded-md px-2.5 py-2 text-left text-sm transition-colors duration-150",
                      activeTop
                        ? "bg-[var(--accent-soft)] font-semibold text-[var(--accent)]"
                        : "text-[var(--ink-soft)] hover:bg-black/[0.03]",
                    ].join(" ")}
                  >
                    <NavIconGlyph
                      name={item.icon}
                      className="h-[18px] w-[18px] shrink-0"
                    />
                    <span className="flex-1">{item.label}</span>
                    <span
                      className={[
                        "inline-block text-[10px] text-[var(--muted)] transition-transform duration-200 ease-[cubic-bezier(0.23,1,0.32,1)] motion-reduce:transition-none",
                        expanded ? "rotate-90" : "rotate-0",
                      ].join(" ")}
                    >
                      ›
                    </span>
                  </button>
                ) : (
                  <Link
                    href={item.href!}
                    className={[
                      "flex items-center gap-2.5 rounded-md px-2.5 py-2 text-sm transition-colors duration-150",
                      activeTop
                        ? "bg-[var(--accent-soft)] font-semibold text-[var(--accent)]"
                        : "text-[var(--ink-soft)] hover:bg-black/[0.03]",
                    ].join(" ")}
                  >
                    <NavIconGlyph
                      name={item.icon}
                      className="h-[18px] w-[18px] shrink-0"
                    />
                    {item.label}
                  </Link>
                )}

                {hasChildren ? (
                  <Submenu open={expanded}>
                    <ul className="mb-1 ml-4 mt-0.5 space-y-0.5 border-l border-[var(--border)] pl-2">
                      {item.children!.map((child) => {
                        const childActive = isActive(pathname, child.href);
                        return (
                          <li key={child.href}>
                            <Link
                              href={child.href}
                              tabIndex={expanded ? undefined : -1}
                              className={[
                                "block rounded-md px-2.5 py-1.5 text-[13px] transition-colors duration-150",
                                childActive
                                  ? "border-l-2 border-[var(--accent)] bg-[var(--accent-soft)] font-semibold text-[var(--accent)]"
                                  : "text-[var(--ink-soft)] hover:bg-black/[0.03]",
                              ].join(" ")}
                            >
                              {child.label}
                            </Link>
                          </li>
                        );
                      })}
                    </ul>
                  </Submenu>
                ) : null}
              </li>
            );
          })}
        </ul>
      </nav>

      <div className="mt-auto shrink-0 border-t border-[var(--border)] px-3 py-3">
        <div className="flex items-center gap-2.5 rounded-md px-1 py-1">
          <div className="flex h-8 w-8 items-center justify-center rounded-full bg-[var(--accent-soft)] text-xs font-semibold text-[var(--accent)]">
            LX
          </div>
          <div className="min-w-0">
            <div className="truncate text-sm font-medium text-[var(--ink)]">
              Lux Beauty Supply
            </div>
            <div className="truncate text-[11px] text-[var(--muted)]">
              Staging sample
            </div>
          </div>
        </div>
      </div>
    </aside>
  );
}
