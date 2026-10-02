import { Redirect } from "expo-router";

import { useSession } from "@/lib/session";

export default function Index() {
  const { ready, session } = useSession();
  if (!ready) return null;
  if (session) return <Redirect href="/home" />;
  return <Redirect href="/phone" />;
}
