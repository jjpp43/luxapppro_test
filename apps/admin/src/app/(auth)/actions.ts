"use server";

import { redirect } from "next/navigation";
import { canAccessAdmin, safeRedirectPath } from "@/lib/auth/rules";
import { createAdminClient } from "@/lib/supabase/admin";
import { createClient } from "@/lib/supabase/server";

function errorRedirect(path: string, message: string): never {
  redirect(`${path}?error=${encodeURIComponent(message)}`);
}

export async function signInAction(formData: FormData) {
  const email = String(formData.get("email") ?? "")
    .trim()
    .toLowerCase();
  const password = String(formData.get("password") ?? "");
  const next = safeRedirectPath(formData.get("next"));

  if (!email || !password) {
    errorRedirect("/login", "Email and password are required");
  }

  const supabase = await createClient();
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error || !data.user) {
    errorRedirect("/login", "Invalid email or password");
  }

  const admin = createAdminClient();
  const { data: staff, error: staffError } = await admin
    .from("staff")
    .select("active, role")
    .eq("auth_user_id", data.user.id)
    .maybeSingle();

  if (staffError || !canAccessAdmin(staff)) {
    await supabase.auth.signOut();
    errorRedirect("/login", "This account does not have active admin access");
  }

  redirect(next);
}

export async function signOutAction() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/login");
}

export async function setPasswordAction(formData: FormData) {
  const password = String(formData.get("password") ?? "");
  const confirmation = String(formData.get("confirmation") ?? "");

  if (password.length < 8) {
    errorRedirect("/auth/set-password", "Password must be at least 8 characters");
  }

  if (password !== confirmation) {
    errorRedirect("/auth/set-password", "Passwords do not match");
  }

  const supabase = await createClient();
  const { data } = await supabase.auth.getClaims();
  const claims = data?.claims;

  if (!claims?.sub) {
    errorRedirect("/login", "Invitation session expired. Request a new invitation");
  }

  const admin = createAdminClient();
  const { data: staff } = await admin
    .from("staff")
    .select("active, role")
    .eq("auth_user_id", claims.sub)
    .maybeSingle();

  if (!canAccessAdmin(staff)) {
    await supabase.auth.signOut();
    errorRedirect("/login", "This invitation is not linked to active admin staff");
  }

  const { error } = await supabase.auth.updateUser({ password });

  if (error) {
    errorRedirect("/auth/set-password", error.message);
  }

  redirect("/");
}
