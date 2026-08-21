import { ComingSoon } from "@/components/ui/ComingSoon";

export default function Page() {
  return (
    <ComingSoon
      title="Branding"
      crumbs={[{ label: "Home", href: "/" }, { label: "Customize", href: "/customize/branding" }, { label: "Branding" }]}
    />
  );
}
