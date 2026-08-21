import { UserForm } from "@/components/account/UserForm";
import { PageHeader } from "@/components/ui/PageHeader";
import { requireOwner } from "@/lib/auth/staff";
import { createAdminClient } from "@/lib/supabase/admin";
import { inviteStaffAction } from "../actions";

type NewUserPageProps = {
  searchParams: Promise<{ error?: string }>;
};

export default async function NewUserPage({
  searchParams,
}: NewUserPageProps) {
  await requireOwner();
  const { error } = await searchParams;
  const admin = createAdminClient();
  const { data: stores } = await admin
    .from("stores")
    .select("id, name")
    .eq("active", true)
    .order("name");

  return (
    <div>
      <PageHeader
        title="Invite staff"
        subtitle="Manager and owner dashboard access"
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Users", href: "/account/users" },
          { label: "Add" },
        ]}
      />
      <UserForm
        mode="create"
        action={inviteStaffAction}
        stores={stores ?? []}
        error={error}
      />
    </div>
  );
}
