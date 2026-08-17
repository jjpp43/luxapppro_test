import { ComingSoon } from "@/components/ui/ComingSoon";

export default function Page() {
  return (
    <ComingSoon
      title="Resources"
      crumbs={[{ label: "Home", href: "/" }, { label: "Resources" }]}
    />
  );
}
