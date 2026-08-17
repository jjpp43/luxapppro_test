"use client";

import Link from "next/link";
import { useState } from "react";

const ROLE_OPTIONS = [
  "Merchant Admin",
  "User",
  "Manager",
  "Marketing Admin",
  "Billing Admin",
  "API",
];

const LOCATION_OPTIONS = [
  "Hairway 2 Heaven",
  "Hollywood Beauty",
  "Lux Beauty Supply - West Sahara Avenue",
];

const DEVICE_OPTIONS = [
  "Tablet — West Sahara",
  "Tablet — Hollywood",
  "Tablet — Hairway",
];

const RESTRICTIONS: { id: string; label: string; kind: "disable" | "allow" }[] =
  [
    { id: "disable_dashboard", label: "Disable Dashboard (Portal)", kind: "disable" },
    {
      id: "disable_point_adjustment",
      label: "Disable Point Adjustment (Portal)",
      kind: "disable",
    },
    {
      id: "disable_dollar_portal",
      label: "Disable Dollar Amount Entry (Portal)",
      kind: "disable",
    },
    {
      id: "disable_group_assignment",
      label: "Disable Customer Group Assignment (Portal & Tablet)",
      kind: "disable",
    },
    {
      id: "disable_voucher_assignment",
      label: "Disable Voucher Assignment (Portal & Tablet)",
      kind: "disable",
    },
    {
      id: "disable_dollar_tablet",
      label: "Disable Dollar Amount Entry (Tablet)",
      kind: "disable",
    },
    {
      id: "disable_pay_wallet",
      label: "Disable Pay from Wallet Entry (Tablet)",
      kind: "disable",
    },
    {
      id: "disable_add_wallet",
      label: "Disable Add to Wallet Entry (Tablet)",
      kind: "disable",
    },
    {
      id: "disable_referrer",
      label: "Disable Adding Referrer (Portal & Tablet)",
      kind: "disable",
    },
    {
      id: "disable_gift_card",
      label: "Disable Gift Card Creation (Portal & Tablet)",
      kind: "disable",
    },
    {
      id: "allow_catering",
      label: "Allow Catering Order Approval (Portal & Tablet)",
      kind: "allow",
    },
    {
      id: "allow_override_max_points",
      label: "Allow Override Max Points Per Day (Portal & Tablet)",
      kind: "allow",
    },
    {
      id: "disable_adding_rewards",
      label: "Disable Adding Rewards (Portal)",
      kind: "disable",
    },
    {
      id: "disable_adding_vouchers",
      label: "Disable Adding Vouchers (Portal)",
      kind: "disable",
    },
    {
      id: "disable_reward_redemption_portal",
      label: "Disable Reward Redemption (Portal)",
      kind: "disable",
    },
    {
      id: "disable_reward_redemption_tablet",
      label: "Disable Reward Redemption (Tablet)",
      kind: "disable",
    },
    {
      id: "disable_voucher_redemption_portal",
      label: "Disable Voucher Redemption (Portal)",
      kind: "disable",
    },
    {
      id: "disable_voucher_redemption_tablet",
      label: "Disable Voucher Redemption (Tablet)",
      kind: "disable",
    },
  ];

export type UserFormValues = {
  roles: string[];
  username: string;
  password: string;
  confirmPassword: string;
  firstName: string;
  lastName: string;
  email: string;
  adminTagId: string;
  tabletPin: string;
  receiveDailyReports: boolean;
  receiveWeeklyReports: boolean;
  receiveOnlineOrderingReports: boolean;
  receiveAlerts: boolean;
  locations: string[];
  defaultDevices: string[];
  restrictions: Record<string, boolean>;
  active: boolean;
};

const emptyValues: UserFormValues = {
  roles: [],
  username: "",
  password: "",
  confirmPassword: "",
  firstName: "",
  lastName: "",
  email: "",
  adminTagId: "",
  tabletPin: "",
  receiveDailyReports: false,
  receiveWeeklyReports: false,
  receiveOnlineOrderingReports: false,
  receiveAlerts: false,
  locations: [],
  defaultDevices: [],
  restrictions: Object.fromEntries(RESTRICTIONS.map((r) => [r.id, false])),
  active: true,
};

export function UserForm({
  mode,
  initial,
}: {
  mode: "create" | "edit";
  initial?: Partial<UserFormValues>;
}) {
  const [values, setValues] = useState<UserFormValues>({
    ...emptyValues,
    ...initial,
    restrictions: {
      ...emptyValues.restrictions,
      ...initial?.restrictions,
    },
  });

  function setField<K extends keyof UserFormValues>(key: K, value: UserFormValues[K]) {
    setValues((prev) => ({ ...prev, [key]: value }));
  }

  function toggleInList(key: "roles" | "locations" | "defaultDevices", item: string) {
    setValues((prev) => {
      const list = prev[key];
      return {
        ...prev,
        [key]: list.includes(item)
          ? list.filter((x) => x !== item)
          : [...list, item],
      };
    });
  }

  return (
    <form
      className="overflow-hidden rounded-xl border border-[var(--border)] bg-white"
      onSubmit={(e) => {
        e.preventDefault();
        // UI only — not wired to Supabase yet
      }}
    >
      <div className="border-b border-[var(--border)] px-4 pt-3">
        <span className="inline-block border-b-2 border-[var(--accent)] px-1 pb-2 text-sm font-semibold text-[var(--ink)]">
          Details
        </span>
      </div>

      <div className="space-y-0 px-5 py-2 md:px-8">
        <FieldRow label="Roles">
          <div className="flex flex-wrap gap-2">
            {ROLE_OPTIONS.map((role) => {
              const on = values.roles.includes(role);
              return (
                <button
                  key={role}
                  type="button"
                  onClick={() => toggleInList("roles", role)}
                  className={[
                    "rounded-full border px-3 py-1 text-xs font-medium transition-colors",
                    on
                      ? "border-[var(--accent)] bg-[var(--accent-soft)] text-[var(--accent)]"
                      : "border-[var(--border)] text-[var(--ink-soft)] hover:bg-[var(--canvas)]",
                  ].join(" ")}
                >
                  {role}
                </button>
              );
            })}
          </div>
        </FieldRow>

        <Divider />

        <FieldRow label="User name">
          <TextInput
            value={values.username}
            onChange={(v) => setField("username", v)}
            autoComplete="username"
          />
        </FieldRow>
        <FieldRow label="Password">
          <TextInput
            type="password"
            value={values.password}
            onChange={(v) => setField("password", v)}
            autoComplete="new-password"
          />
        </FieldRow>
        <FieldRow label="Confirm password">
          <TextInput
            type="password"
            value={values.confirmPassword}
            onChange={(v) => setField("confirmPassword", v)}
            autoComplete="new-password"
          />
        </FieldRow>
        <FieldRow label="">
          <ul className="list-disc space-y-0.5 pl-4 text-xs text-[var(--muted)]">
            <li>different from the current password</li>
            <li>length of at least 8 characters</li>
            <li>at least 5 letters</li>
            <li>at least 1 number</li>
            <li>at least 1 special character: #?!@$%^&amp;*-+=</li>
          </ul>
        </FieldRow>

        <FieldRow label="First Name">
          <TextInput
            value={values.firstName}
            onChange={(v) => setField("firstName", v)}
          />
        </FieldRow>
        <FieldRow label="Last Name">
          <TextInput
            value={values.lastName}
            onChange={(v) => setField("lastName", v)}
          />
        </FieldRow>
        <FieldRow label="Email">
          <TextInput
            type="email"
            value={values.email}
            onChange={(v) => setField("email", v)}
          />
        </FieldRow>
        <FieldRow label="Admin Tag Id">
          <TextInput
            value={values.adminTagId}
            onChange={(v) => setField("adminTagId", v)}
          />
        </FieldRow>
        <FieldRow label="Tablet PIN">
          <TextInput
            value={values.tabletPin}
            onChange={(v) => setField("tabletPin", v)}
            inputMode="numeric"
          />
        </FieldRow>

        <Divider />

        <FieldRow label="Receive Daily Reports">
          <Checkbox
            checked={values.receiveDailyReports}
            onChange={(v) => setField("receiveDailyReports", v)}
          />
        </FieldRow>
        <FieldRow label="Receive Weekly Reports">
          <Checkbox
            checked={values.receiveWeeklyReports}
            onChange={(v) => setField("receiveWeeklyReports", v)}
          />
        </FieldRow>
        <FieldRow label="Receive Online Ordering Reports">
          <Checkbox
            checked={values.receiveOnlineOrderingReports}
            onChange={(v) => setField("receiveOnlineOrderingReports", v)}
          />
        </FieldRow>
        <FieldRow label="Receive Alerts">
          <Checkbox
            checked={values.receiveAlerts}
            onChange={(v) => setField("receiveAlerts", v)}
          />
        </FieldRow>

        <FieldRow label="Restrict to Locations">
          <MultiSelect
            options={LOCATION_OPTIONS}
            selected={values.locations}
            onToggle={(item) => toggleInList("locations", item)}
            placeholder="Restrict to locations"
          />
        </FieldRow>
        <FieldRow label="Default User for Device(s)">
          <MultiSelect
            options={DEVICE_OPTIONS}
            selected={values.defaultDevices}
            onToggle={(item) => toggleInList("defaultDevices", item)}
            placeholder="Default User for Device(s)"
          />
        </FieldRow>

        <Divider />

        {RESTRICTIONS.map((r) => (
          <FieldRow key={r.id} label={r.label}>
            <Checkbox
              checked={Boolean(values.restrictions[r.id])}
              onChange={(v) =>
                setField("restrictions", {
                  ...values.restrictions,
                  [r.id]: v,
                })
              }
            />
          </FieldRow>
        ))}

        <Divider />

        <FieldRow label="Active">
          <Checkbox
            checked={values.active}
            onChange={(v) => setField("active", v)}
          />
        </FieldRow>
      </div>

      <div className="flex flex-wrap items-center gap-2 border-t border-[var(--border)] bg-[var(--canvas)]/50 px-5 py-4 md:px-8">
        <button
          type="submit"
          className="rounded-md bg-[var(--good)] px-4 py-2 text-sm font-semibold text-white transition-[transform] duration-150 active:scale-[0.98]"
        >
          Submit
        </button>
        <Link
          href="/account/users"
          className="rounded-md border border-[var(--border)] bg-white px-4 py-2 text-sm font-medium text-[var(--ink-soft)] hover:bg-[var(--canvas)]"
        >
          Cancel
        </Link>
        <span className="ml-auto text-xs text-[var(--muted)]">
          {mode === "create" ? "UI only — not saved yet" : "UI only — edits not saved yet"}
        </span>
      </div>
    </form>
  );
}

function FieldRow({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="grid gap-2 border-b border-[var(--border)]/70 py-3 last:border-0 md:grid-cols-[minmax(220px,280px)_1fr] md:items-start md:gap-6">
      <div className="pt-1.5 text-sm text-[var(--ink-soft)] md:text-right">
        {label}
      </div>
      <div>{children}</div>
    </div>
  );
}

function Divider() {
  return <div className="border-t border-[var(--border)]" />;
}

function TextInput({
  value,
  onChange,
  type = "text",
  autoComplete,
  inputMode,
}: {
  value: string;
  onChange: (v: string) => void;
  type?: string;
  autoComplete?: string;
  inputMode?: React.HTMLAttributes<HTMLInputElement>["inputMode"];
}) {
  return (
    <input
      type={type}
      value={value}
      autoComplete={autoComplete}
      inputMode={inputMode}
      onChange={(e) => onChange(e.target.value)}
      className="w-full max-w-md rounded-md border border-[var(--border)] bg-white px-3 py-2 text-sm outline-none focus:border-[var(--accent)]"
    />
  );
}

function Checkbox({
  checked,
  onChange,
}: {
  checked: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <input
      type="checkbox"
      checked={checked}
      onChange={(e) => onChange(e.target.checked)}
      className="mt-2 h-4 w-4 accent-[var(--accent)]"
    />
  );
}

function MultiSelect({
  options,
  selected,
  onToggle,
  placeholder,
}: {
  options: string[];
  selected: string[];
  onToggle: (item: string) => void;
  placeholder: string;
}) {
  const [open, setOpen] = useState(false);

  return (
    <div className="relative max-w-md">
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        className="flex w-full items-center justify-between rounded-md border border-[var(--border)] bg-white px-3 py-2 text-left text-sm outline-none focus:border-[var(--accent)]"
      >
        <span className={selected.length ? "text-[var(--ink)]" : "text-[var(--muted)]"}>
          {selected.length ? selected.join(", ") : placeholder}
        </span>
        <span className="text-[var(--muted)]">▾</span>
      </button>
      {open ? (
        <div className="absolute z-10 mt-1 w-full rounded-md border border-[var(--border)] bg-white p-2 shadow-sm">
          {options.map((opt) => (
            <label
              key={opt}
              className="flex cursor-pointer items-center gap-2 rounded px-2 py-1.5 text-sm hover:bg-[var(--canvas)]"
            >
              <input
                type="checkbox"
                checked={selected.includes(opt)}
                onChange={() => onToggle(opt)}
                className="accent-[var(--accent)]"
              />
              {opt}
            </label>
          ))}
        </div>
      ) : null}
    </div>
  );
}
