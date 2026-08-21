import { createServerClient } from "@supabase/ssr";
import type { EmailOtpType } from "@supabase/supabase-js";
import { NextResponse, type NextRequest } from "next/server";
import { safeRedirectPath } from "@/lib/auth/rules";
import { getSupabasePublicEnv } from "@/lib/supabase/env";

const EMAIL_OTP_TYPES = new Set<EmailOtpType>([
  "email",
  "invite",
  "magiclink",
  "recovery",
  "email_change",
]);
const AUTH_RESPONSE_HEADERS = ["cache-control", "expires", "pragma"] as const;

function copyAuthState(source: NextResponse, target: NextResponse) {
  source.cookies.getAll().forEach((cookie) => target.cookies.set(cookie));
  AUTH_RESPONSE_HEADERS.forEach((name) => {
    const value = source.headers.get(name);
    if (value) target.headers.set(name, value);
  });
  return target;
}

export async function GET(request: NextRequest) {
  const code = request.nextUrl.searchParams.get("code");
  const tokenHash = request.nextUrl.searchParams.get("token_hash");
  const rawType = request.nextUrl.searchParams.get("type");
  const next = safeRedirectPath(
    request.nextUrl.searchParams.get("next"),
    "/auth/set-password",
  );
  const response = NextResponse.redirect(new URL(next, request.url));
  const { url, key } = getSupabasePublicEnv();
  const supabase = createServerClient(url, key, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet, headers) {
        cookiesToSet.forEach(({ name, value, options }) => {
          response.cookies.set(name, value, options);
        });
        Object.entries(headers).forEach(([name, value]) => {
          response.headers.set(name, value);
        });
      },
    },
  });

  let error: Error | null = null;

  if (code) {
    const result = await supabase.auth.exchangeCodeForSession(code);
    error = result.error;
  } else if (
    tokenHash &&
    rawType &&
    EMAIL_OTP_TYPES.has(rawType as EmailOtpType)
  ) {
    const result = await supabase.auth.verifyOtp({
      token_hash: tokenHash,
      type: rawType as EmailOtpType,
    });
    error = result.error;
  } else {
    error = new Error("Missing or invalid invitation token");
  }

  if (error) {
    const loginUrl = new URL("/login", request.url);
    loginUrl.searchParams.set(
      "error",
      "Invitation is invalid or expired. Request a new invitation",
    );
    return copyAuthState(response, NextResponse.redirect(loginUrl));
  }

  return response;
}
