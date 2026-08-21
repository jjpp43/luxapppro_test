export type AdminRole = "cashier" | "manager" | "owner";

export type AdminAccessRecord = {
  active: boolean;
  role: AdminRole;
} | null;

export function canAccessAdmin(staff: AdminAccessRecord) {
  return Boolean(
    staff?.active && (staff.role === "manager" || staff.role === "owner"),
  );
}

export function canInviteStaff(staff: AdminAccessRecord) {
  return Boolean(staff?.active && staff.role === "owner");
}

export function safeRedirectPath(value: unknown, fallback = "/") {
  if (typeof value !== "string") return fallback;

  const expectedOrigin = "https://lux-pro.local";

  try {
    const url = new URL(value, expectedOrigin);
    if (url.origin !== expectedOrigin || !value.startsWith("/")) return fallback;
    return `${url.pathname}${url.search}${url.hash}`;
  } catch {
    return fallback;
  }
}
