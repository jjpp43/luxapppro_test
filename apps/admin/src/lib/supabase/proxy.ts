import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";
import { getSupabasePublicEnv } from "./env";

const PUBLIC_PATHS = ["/login", "/auth", "/unauthorized"];
const AUTH_RESPONSE_HEADERS = ["cache-control", "expires", "pragma"] as const;

function isPublicPath(pathname: string) {
  return PUBLIC_PATHS.some(
    (path) => pathname === path || pathname.startsWith(`${path}/`),
  );
}

function redirectWithAuthState(url: URL, response: NextResponse) {
  const redirect = NextResponse.redirect(url);

  response.cookies.getAll().forEach((cookie) => {
    redirect.cookies.set(cookie);
  });

  AUTH_RESPONSE_HEADERS.forEach((name) => {
    const value = response.headers.get(name);
    if (value) redirect.headers.set(name, value);
  });

  return redirect;
}

export async function updateSession(request: NextRequest) {
  let response = NextResponse.next({ request });
  const { url, key } = getSupabasePublicEnv();

  const supabase = createServerClient(url, key, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet, headers) {
        cookiesToSet.forEach(({ name, value }) => {
          request.cookies.set(name, value);
        });

        response = NextResponse.next({ request });

        cookiesToSet.forEach(({ name, value, options }) => {
          response.cookies.set(name, value, options);
        });

        Object.entries(headers).forEach(([name, value]) => {
          response.headers.set(name, value);
        });
      },
    },
  });

  const { data: claimsData } = await supabase.auth.getClaims();
  const claims = claimsData?.claims;

  const pathname = request.nextUrl.pathname;
  const publicPath = isPublicPath(pathname);

  if (!claims && !publicPath) {
    const loginUrl = request.nextUrl.clone();
    loginUrl.pathname = "/login";
    loginUrl.searchParams.set("next", `${pathname}${request.nextUrl.search}`);
    return redirectWithAuthState(loginUrl, response);
  }

  if (claims && pathname === "/login") {
    return redirectWithAuthState(new URL("/", request.url), response);
  }

  return response;
}
