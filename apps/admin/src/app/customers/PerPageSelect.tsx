"use client";

import { useRouter } from "next/navigation";
import { SelectMenu } from "@/components/ui/SelectMenu";

const PAGE_SIZES = ["50", "100", "200"] as const;

export function PerPageSelect({
  per,
  q,
  store,
}: {
  per: number;
  q?: string;
  store?: string;
}) {
  const router = useRouter();

  function onChange(value: string) {
    const p = new URLSearchParams();
    if (q) p.set("q", q);
    if (store) p.set("store", store);
    if (value !== "50") p.set("per", value);
    const qs = p.toString();
    router.push(qs ? `/customers?${qs}` : "/customers");
  }

  return (
    <div className="flex items-center gap-2 text-sm text-[var(--muted)]">
      <span>Per page</span>
      <SelectMenu
        ariaLabel="Rows per page"
        value={String(per) as (typeof PAGE_SIZES)[number]}
        options={PAGE_SIZES.map((n) => ({ value: n, label: n }))}
        onChange={onChange}
        align="right"
      />
    </div>
  );
}
