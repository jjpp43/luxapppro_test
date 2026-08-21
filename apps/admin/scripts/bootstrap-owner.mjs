import { createClient } from "@supabase/supabase-js";

const [emailArg, ...nameParts] = process.argv.slice(2);
const email = emailArg?.trim().toLowerCase();
const name = nameParts.join(" ").trim();
const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const adminKey =
  process.env.SUPABASE_SECRET_KEY ?? process.env.SUPABASE_SERVICE_ROLE_KEY;
const siteUrl = (
  process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000"
).replace(/\/$/, "");

if (!email || !name) {
  console.error(
    'Usage: npm run bootstrap:owner -- owner@example.com "Owner Name"',
  );
  process.exit(1);
}

if (!url || !adminKey) {
  console.error(
    "NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SECRET_KEY or SUPABASE_SERVICE_ROLE_KEY are required",
  );
  process.exit(1);
}

const admin = createClient(url, adminKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
    detectSessionInUrl: false,
  },
  global: {
    fetch(input, init) {
      const headers = new Headers(init?.headers);
      if (
        adminKey.startsWith("sb_secret_") &&
        headers.get("authorization") === `Bearer ${adminKey}`
      ) {
        headers.delete("authorization");
      }
      return fetch(input, { ...init, headers });
    },
  },
});

const redirectTo = `${siteUrl}/auth/callback?next=/auth/set-password`;

async function inviteOwner() {
  const { data, error } = await admin.auth.admin.inviteUserByEmail(email, {
    data: { name },
    redirectTo,
  });

  if (error || !data.user) {
    console.error(error?.message ?? "Unable to invite owner");
    process.exit(1);
  }

  return data.user;
}

const { data: existing } = await admin
  .from("staff")
  .select("id, auth_user_id, role")
  .ilike("email", email)
  .maybeSingle();

if (existing) {
  if (existing.role !== "owner" || !existing.auth_user_id) {
    console.error(`A non-owner staff record already exists for ${email}`);
    process.exit(1);
  }

  const { data: authUser, error: authUserError } =
    await admin.auth.admin.getUserById(existing.auth_user_id);

  if (authUserError || !authUser.user) {
    console.error(authUserError?.message ?? "Unable to load linked owner");
    process.exit(1);
  }

  if (authUser.user.email_confirmed_at) {
    const { error } = await admin.auth.resetPasswordForEmail(email, {
      redirectTo,
    });
    if (error) {
      console.error(error.message);
      process.exit(1);
    }
    console.log(`Owner password setup email sent to ${email}`);
    process.exit(0);
  }

  const invitedUser = await inviteOwner();
  if (invitedUser.id !== existing.auth_user_id) {
    console.error("Invitation user does not match the linked owner");
    process.exit(1);
  }

  console.log(`Owner invitation resent to ${email}`);
  process.exit(0);
}

const invitedUser = await inviteOwner();

const { error: staffError } = await admin.from("staff").insert({
  auth_user_id: invitedUser.id,
  store_id: null,
  email,
  name,
  role: "owner",
  active: true,
});

if (staffError) {
  await admin.auth.admin.deleteUser(invitedUser.id);
  console.error(staffError.message);
  process.exit(1);
}

console.log(`Owner invitation sent to ${email}`);
