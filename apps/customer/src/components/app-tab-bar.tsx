import { Pressable, StyleSheet, View } from "react-native";
import { usePathname, useRouter } from "expo-router";

import { ThemedText } from "@/components/themed-text";
import { useTheme } from "@/hooks/use-theme";
import { useTabBarPadding } from "@/lib/screen-insets";

const TABS = [
  { href: "/home", label: "Home", match: "home" },
  { href: "/scan", label: "Scan", match: "scan" },
  { href: "/account", label: "Account", match: "account" },
] as const;

export function AppTabBar() {
  const theme = useTheme();
  const pathname = usePathname();
  const router = useRouter();
  const insetsPad = useTabBarPadding();

  return (
    <View
      style={[
        styles.bar,
        {
          backgroundColor: theme.backgroundElement,
          borderTopColor: theme.border,
        },
        insetsPad,
      ]}>
      {TABS.map((tab) => {
        const selected = pathname.includes(tab.match);
        return (
          <Pressable
            key={tab.href}
            accessibilityRole="tab"
            accessibilityState={{ selected }}
            onPress={() => router.replace(tab.href)}
            style={({ pressed }) => [
              styles.tab,
              selected && { backgroundColor: theme.backgroundSelected },
              pressed && { transform: [{ scale: 0.97 }] },
            ]}>
            <ThemedText
              type="smallBold"
              themeColor={selected ? "accent" : "textSecondary"}>
              {tab.label}
            </ThemedText>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  bar: {
    flexDirection: "row",
    borderTopWidth: 1,
    gap: 8,
  },
  tab: {
    flex: 1,
    minHeight: 44,
    borderRadius: 12,
    alignItems: "center",
    justifyContent: "center",
  },
});
