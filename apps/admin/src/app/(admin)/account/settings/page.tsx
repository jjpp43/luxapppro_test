import { ComingSoon } from "@/components/ui/ComingSoon";

export default function Page() {
  return (
    <ComingSoon
      title="Settings"
      crumbs={[{ label: "Home", href: "/" }, { label: "Account", href: "/account/settings" }, { label: "Settings" }]}
    />
  );
}
