"use client";

import { useEffect, useId, useRef, useState } from "react";

export type SelectOption<T extends string> = {
  value: T;
  label: string;
};

export function SelectMenu<T extends string>({
  value,
  options,
  onChange,
  ariaLabel,
  align = "left",
}: {
  value: T;
  options: SelectOption<T>[];
  onChange: (value: T) => void;
  ariaLabel: string;
  align?: "left" | "right";
}) {
  const [open, setOpen] = useState(false);
  const rootRef = useRef<HTMLDivElement>(null);
  const listId = useId();
  const selected = options.find((o) => o.value === value) ?? options[0];

  useEffect(() => {
    if (!open) return;
    function onPointer(e: MouseEvent) {
      if (!rootRef.current?.contains(e.target as Node)) setOpen(false);
    }
    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") setOpen(false);
    }
    document.addEventListener("mousedown", onPointer);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onPointer);
      document.removeEventListener("keydown", onKey);
    };
  }, [open]);

  return (
    <div ref={rootRef} className="relative">
      <button
        type="button"
        aria-label={ariaLabel}
        aria-haspopup="listbox"
        aria-expanded={open}
        aria-controls={listId}
        onClick={() => setOpen((v) => !v)}
        className={[
          "inline-flex min-w-[5.5rem] items-center justify-between gap-2 rounded-lg border bg-white px-3 py-1.5 text-sm font-medium text-[var(--ink)] transition-colors",
          open
            ? "border-[var(--accent)]"
            : "border-[var(--border)] hover:border-[var(--border-strong)]",
        ].join(" ")}
      >
        {selected?.label}
        <svg
          className={[
            "h-3.5 w-3.5 shrink-0 text-[var(--muted)] transition-transform duration-150",
            open ? "rotate-180" : "",
          ].join(" ")}
          viewBox="0 0 12 12"
          fill="none"
          aria-hidden
        >
          <path
            d="M2.5 4.5 6 8l3.5-3.5"
            stroke="currentColor"
            strokeWidth="1.5"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </button>
      {open ? (
        <ul
          id={listId}
          role="listbox"
          aria-label={ariaLabel}
          className={[
            "absolute z-30 mt-1 min-w-full overflow-hidden rounded-lg border border-[var(--border)] bg-white py-1 shadow-[0_8px_24px_rgba(28,20,18,0.12)]",
            align === "right" ? "right-0" : "left-0",
          ].join(" ")}
        >
          {options.map((opt) => {
            const isSelected = opt.value === value;
            return (
              <li key={opt.value} role="presentation">
                <button
                  type="button"
                  role="option"
                  aria-selected={isSelected}
                  onClick={() => {
                    onChange(opt.value);
                    setOpen(false);
                  }}
                  className={[
                    "flex w-full items-center justify-between gap-3 px-3 py-2 text-left text-sm",
                    isSelected
                      ? "bg-[var(--accent-soft)] font-semibold text-[var(--accent)]"
                      : "text-[var(--ink-soft)] hover:bg-black/[0.03]",
                  ].join(" ")}
                >
                  {opt.label}
                  {isSelected ? <span aria-hidden>✓</span> : null}
                </button>
              </li>
            );
          })}
        </ul>
      ) : null}
    </div>
  );
}
