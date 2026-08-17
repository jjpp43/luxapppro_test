import { UserForm } from "@/components/account/UserForm";
import { PageHeader } from "@/components/ui/PageHeader";

export default function NewUserPage() {
  return (
    <div>
      <PageHeader
        title="Users"
        subtitle="Add / Edit"
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Users", href: "/account/users" },
          { label: "Add" },
        ]}
      />
      <UserForm mode="create" />
    </div>
  );
}
