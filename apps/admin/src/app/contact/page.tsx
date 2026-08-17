import { ComingSoon } from "@/components/ui/ComingSoon";

export default function Page() {
  return (
    <ComingSoon
      title="Contact Us"
      crumbs={[{ label: "Home", href: "/" }, { label: "Contact Us" }]}
    />
  );
}
