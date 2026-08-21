import { AppShell } from "@/components/shell/AppShell";
import { requireAdminStaff } from "@/lib/auth/staff";

export default async function AdminLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const staff = await requireAdminStaff();
  return <AppShell staff={staff}>{children}</AppShell>;
}
