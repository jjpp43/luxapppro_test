import "server-only";

import { redirect } from "next/navigation";
import { canAccessAdmin, canInviteStaff } from "./rules";
import { createAdminClient } from "@/lib/supabase/admin";
import { createClient } from "@/lib/supabase/server";

export type StaffRole = "cashier" | "manager" | "owner";

export type StaffSession = {
  id: string;
  authUserId: string;
  storeId: string | null;
  email: string | null;
  name: string;
  role: StaffRole;
  active: true;
};

export async function getCurrentStaff(): Promise<StaffSession | null> {
  const supabase = await createClient();
  const { data: claimsData } = await supabase.auth.getClaims();
  const claims = claimsData?.claims;

  const authUserId = claims?.sub;
  if (!authUserId) return null;

  const admin = createAdminClient();
  const { data, error } = await admin
    .from("staff")
    .select("id, auth_user_id, store_id, email, name, role, active")
    .eq("auth_user_id", authUserId)
    .maybeSingle();

  if (error) {
    throw new Error(`Unable to resolve staff session: ${error.message}`);
  }

  if (!data?.active) return null;

  return {
    id: data.id,
    authUserId: data.auth_user_id,
    storeId: data.store_id,
    email: data.email,
    name: data.name,
    role: data.role as StaffRole,
    active: true,
  };
}

export async function requireAdminStaff() {
  const staff = await getCurrentStaff();

  if (!staff) {
    redirect("/unauthorized?reason=unlinked");
  }

  if (!canAccessAdmin(staff)) {
    redirect("/unauthorized?reason=role");
  }

  return staff;
}

export async function requireOwner() {
  const staff = await requireAdminStaff();

  if (!canInviteStaff(staff)) {
    redirect("/unauthorized?reason=owner");
  }

  return staff;
}
