export type NavItem = {
  label: string;
  href?: string;
  icon: NavIcon;
  children?: { label: string; href: string }[];
};

export type NavIcon =
  | "home"
  | "campaigns"
  | "audience"
  | "loyalty"
  | "memberships"
  | "customize"
  | "reports"
  | "account"
  | "resources"
  | "help"
  | "contact";

export const navItems: NavItem[] = [
  { label: "Dashboard", href: "/", icon: "home" },
  {
    label: "Campaigns",
    icon: "campaigns",
    children: [
      { label: "Automations", href: "/campaigns/automations" },
      { label: "App Promotions", href: "/campaigns/app-promotions" },
    ],
  },
  {
    label: "Audience",
    icon: "audience",
    children: [
      { label: "Customers", href: "/customers" },
      { label: "Groups", href: "/audience/groups" },
      { label: "SMS Keywords", href: "/audience/sms-keywords" },
      { label: "POS Transactions", href: "/audience/pos-transactions" },
    ],
  },
  {
    label: "Loyalty Program",
    icon: "loyalty",
    children: [
      { label: "Overview", href: "/loyalty" },
      { label: "Rewards", href: "/loyalty/rewards" },
      { label: "Points ledger", href: "/loyalty/ledger" },
    ],
  },
  {
    label: "Memberships",
    icon: "memberships",
    children: [{ label: "Plans", href: "/memberships" }],
  },
  {
    label: "Customize",
    icon: "customize",
    children: [
      { label: "Branding", href: "/customize/branding" },
      { label: "Stores", href: "/customize/stores" },
    ],
  },
  {
    label: "Reports",
    icon: "reports",
    children: [{ label: "Overview", href: "/reports" }],
  },
  {
    label: "Account",
    icon: "account",
    children: [
      { label: "Users", href: "/account/users" },
      { label: "Settings", href: "/account/settings" },
      { label: "Devices", href: "/account/devices" },
    ],
  },
  { label: "Resources", href: "/resources", icon: "resources" },
  { label: "Help and Tutorials", href: "/help", icon: "help" },
  { label: "Contact Us", href: "/contact", icon: "contact" },
];
