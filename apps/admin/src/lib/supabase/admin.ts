import "server-only";

import { createClient } from "@supabase/supabase-js";
import { getSupabasePublicEnv } from "./env";

function createAdminFetch(apiKey: string): typeof fetch {
  return (input, init) => {
    const headers = new Headers(init?.headers);

    if (
      apiKey.startsWith("sb_secret_") &&
      headers.get("authorization") === `Bearer ${apiKey}`
    ) {
      headers.delete("authorization");
    }

    return fetch(input, { ...init, headers });
  };
}

export function createAdminClient() {
  const { url } = getSupabasePublicEnv();
  const adminKey =
    process.env.SUPABASE_SECRET_KEY ??
    process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!adminKey) {
    throw new Error("Missing SUPABASE_SECRET_KEY or SUPABASE_SERVICE_ROLE_KEY");
  }

  return createClient(url, adminKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
      detectSessionInUrl: false,
    },
    global: {
      fetch: createAdminFetch(adminKey),
    },
  });
}
