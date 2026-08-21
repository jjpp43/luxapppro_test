import { ComingSoon } from "@/components/ui/ComingSoon";

export default function Page() {
  return (
    <ComingSoon
      title="Points ledger"
      crumbs={[{ label: "Home", href: "/" }, { label: "Loyalty Program", href: "/loyalty" }, { label: "Points ledger" }]}
    />
  );
}
