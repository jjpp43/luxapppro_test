import { UserForm } from "@/components/account/UserForm";
import { PageHeader } from "@/components/ui/PageHeader";
import { requireOwner } from "@/lib/auth/staff";
import { createAdminClient } from "@/lib/supabase/admin";
import { updateStaffAction } from "../../actions";

type Params = Promise<{ id: string }>;
type SearchParams = Promise<{ error?: string }>;

export default async function EditUserPage({
  params,
  searchParams,
}: {
  params: Params;
  searchParams: SearchParams;
}) {
  await requireOwner();
  const { id } = await params;
  const { error } = await searchParams;
  const admin = createAdminClient();
  const [{ data: staff }, { data: stores }] = await Promise.all([
    admin
      .from("staff")
      .select("id, name, email, role, store_id, active")
      .eq("id", id)
      .in("role", ["manager", "owner"])
      .maybeSingle(),
    admin.from("stores").select("id, name").eq("active", true).order("sort_rank"),
  ]);

  return (
    <div>
      <PageHeader
        title={staff ? `Edit ${staff.name}` : "Staff not found"}
        subtitle="Admin access"
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Users", href: "/account/users" },
          { label: "Edit" },
        ]}
      />
      {staff ? (
        <UserForm
          mode="edit"
          action={updateStaffAction}
          stores={stores ?? []}
          error={error}
          initial={{
            id: staff.id,
            name: staff.name,
            email: staff.email,
            role: staff.role,
            storeId: staff.store_id,
            active: staff.active,
          }}
        />
      ) : (
        <div className="rounded-xl border border-[var(--border)] bg-white p-6 text-sm text-[var(--muted)]">
          This staff record does not exist.
        </div>
      )}
    </div>
  );
}
