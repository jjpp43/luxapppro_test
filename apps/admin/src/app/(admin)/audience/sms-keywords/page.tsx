import { ComingSoon } from "@/components/ui/ComingSoon";

export default function Page() {
  return (
    <ComingSoon
      title="SMS Keywords"
      crumbs={[{ label: "Home", href: "/" }, { label: "Audience", href: "/customers" }, { label: "SMS Keywords" }]}
    />
  );
}
