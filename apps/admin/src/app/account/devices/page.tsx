import { ComingSoon } from "@/components/ui/ComingSoon";

export default function Page() {
  return (
    <ComingSoon
      title="Devices"
      crumbs={[
        { label: "Home", href: "/" },
        { label: "Account", href: "/account/users" },
        { label: "Devices" },
      ]}
    />
  );
}
