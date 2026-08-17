import { ComingSoon } from "@/components/ui/ComingSoon";

export default function Page() {
  return (
    <ComingSoon
      title="Help and Tutorials"
      crumbs={[{ label: "Home", href: "/" }, { label: "Help and Tutorials" }]}
    />
  );
}
