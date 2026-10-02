import { Redirect, Stack } from "expo-router";

import { useSession } from "@/lib/session";

export default function AuthLayout() {
  const { ready, session } = useSession();
  if (!ready) return null;
  if (session) return <Redirect href="/home" />;

  return (
    <Stack
      screenOptions={{
        headerShown: false,
        animation: "slide_from_right",
      }}
    />
  );
}
