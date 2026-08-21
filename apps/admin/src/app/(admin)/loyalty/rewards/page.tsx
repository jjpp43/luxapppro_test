import { ComingSoon } from "@/components/ui/ComingSoon";

export default function Page() {
  return (
    <ComingSoon
      title="Rewards"
      crumbs={[{ label: "Home", href: "/" }, { label: "Loyalty Program", href: "/loyalty" }, { label: "Rewards" }]}
    />
  );
}
