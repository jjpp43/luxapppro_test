import { Redirect, Slot } from "expo-router";
import { StyleSheet, View } from "react-native";

import { AppTabBar } from "@/components/app-tab-bar";
import { useSession } from "@/lib/session";
import { useTheme } from "@/hooks/use-theme";

export default function AppLayout() {
  const { session } = useSession();
  const theme = useTheme();

  if (!session) return <Redirect href="/phone" />;

  return (
    <View style={[styles.shell, { backgroundColor: theme.background }]}>
      <View style={styles.body}>
        <Slot />
      </View>
      <AppTabBar />
    </View>
  );
}

const styles = StyleSheet.create({
  shell: {
    flex: 1,
  },
  body: {
    flex: 1,
  },
});
