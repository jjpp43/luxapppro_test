"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { requireOwner, type StaffRole } from "@/lib/auth/staff";
import { createAdminClient } from "@/lib/supabase/admin";

function text(formData: FormData, key: string) {
  return String(formData.get(key) ?? "").trim();
}

function errorRedirect(path: string, message: string): never {
  const separator = path.includes("?") ? "&" : "?";
  redirect(`${path}${separator}error=${encodeURIComponent(message)}`);
}

function parseAdminRole(value: string): Extract<StaffRole, "manager" | "owner"> {
  if (value !== "manager" && value !== "owner") {
    throw new Error("Role must be manager or owner");
  }
  return value;
}

function getSiteUrl() {
  const configured = process.env.NEXT_PUBLIC_SITE_URL;
  if (configured) return new URL(configured).origin;

  const vercelUrl =
    process.env.VERCEL_PROJECT_PRODUCTION_URL ?? process.env.VERCEL_URL;
  if (vercelUrl) return `https://${vercelUrl}`;

  return "http://localhost:3000";
}

async function validateStore(
  admin: ReturnType<typeof createAdminClient>,
  role: "manager" | "owner",
  storeId: string,
) {
  if (role === "owner" && !storeId) return null;
  if (!storeId) throw new Error("Managers must be assigned to a store");

  const { data, error } = await admin
    .from("stores")
    .select("id")
    .eq("id", storeId)
    .eq("active", true)
    .maybeSingle();

  if (error || !data) {
    throw new Error("Select an active store");
  }

  return data.id as string;
}

export async function inviteStaffAction(formData: FormData) {
  await requireOwner();

  const name = text(formData, "name");
  const email = text(formData, "email").toLowerCase();
  const roleValue = text(formData, "role");
  const storeIdValue = text(formData, "store_id");

  if (!name || !email) {
    errorRedirect("/account/users/new", "Name and email are required");
  }

  let role: "manager" | "owner";
  try {
    role = parseAdminRole(roleValue);
  } catch (error) {
    errorRedirect(
      "/account/users/new",
      error instanceof Error ? error.message : "Invalid role",
    );
  }

  const admin = createAdminClient();
  let storeId: string | null;

  try {
    storeId = await validateStore(admin, role, storeIdValue);
  } catch (error) {
    errorRedirect(
      "/account/users/new",
      error instanceof Error ? error.message : "Invalid store",
    );
  }

  const { data: existing } = await admin
    .from("staff")
    .select("id")
    .ilike("email", email)
    .maybeSingle();

  if (existing) {
    errorRedirect("/account/users/new", "A staff record already uses this email");
  }

  const redirectTo = `${getSiteUrl()}/auth/callback?next=/auth/set-password`;
  const { data: invitation, error: invitationError } =
    await admin.auth.admin.inviteUserByEmail(email, {
      data: { name },
      redirectTo,
    });

  if (invitationError || !invitation.user) {
    errorRedirect(
      "/account/users/new",
      invitationError?.message ?? "Unable to create invitation",
    );
  }

  const { error: staffError } = await admin.from("staff").insert({
    auth_user_id: invitation.user.id,
    store_id: storeId,
    email,
    name,
    role,
    active: true,
  });

  if (staffError) {
    await admin.auth.admin.deleteUser(invitation.user.id);
    errorRedirect("/account/users/new", staffError.message);
  }

  revalidatePath("/account/users");
  redirect(`/account/users?invited=${encodeURIComponent(email)}`);
}

export async function updateStaffAction(formData: FormData) {
  const actor = await requireOwner();
  const id = text(formData, "id");
  const name = text(formData, "name");
  const roleValue = text(formData, "role");
  const storeIdValue = text(formData, "store_id");
  const active = formData.get("active") === "on";
  const editPath = `/account/users/${encodeURIComponent(id)}/edit`;

  if (!id || !name) {
    errorRedirect(editPath, "Name is required");
  }

  let role: "manager" | "owner";
  try {
    role = parseAdminRole(roleValue);
  } catch (error) {
    errorRedirect(
      editPath,
      error instanceof Error ? error.message : "Invalid role",
    );
  }

  const admin = createAdminClient();

  let storeId: string | null;
  try {
    storeId = await validateStore(admin, role, storeIdValue);
  } catch (error) {
    errorRedirect(
      editPath,
      error instanceof Error ? error.message : "Invalid store",
    );
  }

  const { error } = await admin.rpc("update_admin_staff", {
    p_actor_id: actor.id,
    p_staff_id: id,
    p_name: name,
    p_role: role,
    p_store_id: storeId,
    p_active: active,
  });

  if (error) {
    errorRedirect(editPath, error.message);
  }

  revalidatePath("/account/users");
  redirect("/account/users?updated=1");
}
