import { ComingSoon } from "@/components/ui/ComingSoon";

export default function Page() {
  return (
    <ComingSoon
      title="Loyalty Program"
      crumbs={[{ label: "Home", href: "/" }, { label: "Loyalty Program" }]}
    />
  );
}
