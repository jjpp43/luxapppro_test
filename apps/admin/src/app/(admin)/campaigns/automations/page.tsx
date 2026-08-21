import { ComingSoon } from "@/components/ui/ComingSoon";

export default function Page() {
  return (
    <ComingSoon
      title="Automations"
      crumbs={[{ label: "Home", href: "/" }, { label: "Campaigns", href: "/campaigns/automations" }, { label: "Automations" }]}
    />
  );
}
