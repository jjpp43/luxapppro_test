import { describe, expect, it } from "vitest";
import {
  canAccessAdmin,
  canInviteStaff,
  safeRedirectPath,
} from "./rules";

describe("staff authorization rules", () => {
  it("allows active managers and owners into admin", () => {
    expect(canAccessAdmin({ active: true, role: "manager" })).toBe(true);
    expect(canAccessAdmin({ active: true, role: "owner" })).toBe(true);
  });

  it("denies cashiers, inactive staff, and unlinked users", () => {
    expect(canAccessAdmin({ active: true, role: "cashier" })).toBe(false);
    expect(canAccessAdmin({ active: false, role: "owner" })).toBe(false);
    expect(canAccessAdmin(null)).toBe(false);
  });

  it("allows only active owners to invite staff", () => {
    expect(canInviteStaff({ active: true, role: "owner" })).toBe(true);
    expect(canInviteStaff({ active: true, role: "manager" })).toBe(false);
    expect(canInviteStaff({ active: false, role: "owner" })).toBe(false);
  });
});

describe("auth redirect validation", () => {
  it("accepts local paths and rejects external or protocol-relative paths", () => {
    expect(safeRedirectPath("/customers?health=active")).toBe(
      "/customers?health=active",
    );
    expect(safeRedirectPath("//evil.example")).toBe("/");
    expect(safeRedirectPath("/\\evil.example")).toBe("/");
    expect(safeRedirectPath("https://evil.example")).toBe("/");
    expect(safeRedirectPath("javascript:alert(1)")).toBe("/");
    expect(safeRedirectPath(null, "/auth/set-password")).toBe(
      "/auth/set-password",
    );
  });
});
