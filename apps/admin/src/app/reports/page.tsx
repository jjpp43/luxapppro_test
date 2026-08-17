import { ComingSoon } from "@/components/ui/ComingSoon";

export default function Page() {
  return (
    <ComingSoon
      title="Reports"
      crumbs={[{ label: "Home", href: "/" }, { label: "Reports" }]}
    />
  );
}
