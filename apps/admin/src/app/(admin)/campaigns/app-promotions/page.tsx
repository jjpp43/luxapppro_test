import { ComingSoon } from "@/components/ui/ComingSoon";

export default function Page() {
  return (
    <ComingSoon
      title="App Promotions"
      crumbs={[{ label: "Home", href: "/" }, { label: "Campaigns", href: "/campaigns/app-promotions" }, { label: "App Promotions" }]}
    />
  );
}
