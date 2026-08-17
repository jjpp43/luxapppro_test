import { ComingSoon } from "@/components/ui/ComingSoon";

export default function Page() {
  return (
    <ComingSoon
      title="POS Transactions"
      crumbs={[{ label: "Home", href: "/" }, { label: "Audience", href: "/customers" }, { label: "POS Transactions" }]}
    />
  );
}
