import { UserForm } from "@/components/account/UserForm";
import { PageHeader } from "@/components/ui/PageHeader";

type Params = Promise<{ id: string }>;

const SAMPLE_BY_ID: Record<
  string,
  {
    roles: string[];
    username: string;
    firstName: string;
    lastName: string;
    email: string;
    tabletPin: string;
    receiveDailyReports: boolean;
    active: boolean;
  }
> = {
  "1": {
    roles: ["Merchant Admin"],
    username: "jjung",
    firstName: "James",
    lastName: "Jung",
    email: "james@luxbeautysupply.com",
    tabletPin: "1234",
    receiveDailyReports: true,
    active: true,
  },
  "2": {
    roles: ["Manager"],
    username: "manager.sahara",
    firstName: "Store",
    lastName: "Manager",
    email: "manager@luxbeautysupply.com",
    tabletPin: "2468",
    receiveDailyReports: true,
    active: true,
  },
  "3": {
    roles: ["User"],
    username: "cashier1",
    firstName: "Front",
    lastName: "Counter",
    email: "",
    tabletPin: "0000",
    receiveDailyReports: false,
    active: true,
  },
};

export default async function EditUserPage({ params }: { params: Params }) {
  const { id } = await params;
  const sample = SAMPLE_BY_ID[id] ?? {
    roles: ["User"],
    username: `user${id}`,
    firstName: "",
    lastName: "",
    email: "",
    tabletPin: "",
    receiveDailyReports: false,
    active: true,
  };

  return (
    <div>
      <PageHeader
        title="Users"
        subtitle="Add / Edit"
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Users", href: "/account/users" },
          { label: "Edit" },
        ]}
      />
      <UserForm mode="edit" initial={sample} />
    </div>
  );
}
