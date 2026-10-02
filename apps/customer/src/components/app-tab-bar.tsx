import { Pressable, StyleSheet, View } from "react-native";
import { type Href, usePathname, useRouter } from "expo-router";

import { ThemedText } from "@/components/themed-text";
import { useTheme } from "@/hooks/use-theme";
import { useTabBarPadding } from "@/lib/screen-insets";
import { useSession } from "@/lib/session";

const BASE_TABS = [
  { href: "/home", label: "Home", match: "home" },
  { href: "/scan", label: "Scan", match: "scan" },
  { href: "/account", label: "Account", match: "account" },
] as const;

const LIST_TAB = { href: "/list", label: "List", match: "list" } as const;

export function AppTabBar() {
  const theme = useTheme();
  const pathname = usePathname();
  const router = useRouter();
  const insetsPad = useTabBarPadding();
  const { session } = useSession();
  const tools = session?.beauticianTools ?? false;

  const tabs = tools
    ? [BASE_TABS[0], BASE_TABS[1], LIST_TAB, BASE_TABS[2]]
    : [...BASE_TABS];

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
      {tabs.map((tab) => {
        const selected =
          pathname.includes(tab.match) ||
          (tab.match === "list" && pathname.includes("qr"));
        return (
          <Pressable
            key={tab.href}
            accessibilityRole="tab"
            accessibilityState={{ selected }}
            onPress={() => router.replace(tab.href as Href)}
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
