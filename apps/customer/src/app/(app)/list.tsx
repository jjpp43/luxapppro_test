import { type Href, Redirect, useRouter } from "expo-router";
import { Pressable, ScrollView, StyleSheet, View } from "react-native";

import { PrimaryButton } from "@/components/primary-button";
import { Screen } from "@/components/screen";
import { ThemedText } from "@/components/themed-text";
import { Spacing } from "@/constants/theme";
import { useTheme } from "@/hooks/use-theme";
import {
  CATALOG,
  CATALOG_CATEGORIES,
  formatPrice,
} from "@/lib/catalog";
import { useSession } from "@/lib/session";

export default function ListScreen() {
  const theme = useTheme();
  const router = useRouter();
  const { session, toggleListProduct } = useSession();

  if (!session) return <Redirect href="/phone" />;
  if (!session.beauticianTools) return <Redirect href="/account" />;

  const selected = new Set(session.listProductIds);
  const count = selected.size;

  return (
    <Screen tabbed>
      <View style={styles.copy}>
        <ThemedText style={styles.title}>List</ThemedText>
        <ThemedText themeColor="textSecondary">
          Pick products for this client. They get 5% off every unit.
        </ThemedText>
      </View>

      <ScrollView
        style={styles.flex}
        contentContainerStyle={styles.catalog}
        showsVerticalScrollIndicator={false}>
        {CATALOG_CATEGORIES.map((category) => {
          const items = CATALOG.filter((p) => p.category === category);
          return (
            <View key={category} style={styles.group}>
              <ThemedText type="smallBold" themeColor="textSecondary">
                {category}
              </ThemedText>
              {items.map((product) => {
                const on = selected.has(product.id);
                return (
                  <Pressable
                    key={product.id}
                    accessibilityRole="checkbox"
                    accessibilityState={{ checked: on }}
                    onPress={() => toggleListProduct(product.id)}
                    style={({ pressed }) => [
                      styles.row,
                      {
                        backgroundColor: on
                          ? theme.backgroundSelected
                          : theme.backgroundElement,
                        borderColor: on ? theme.accent : theme.border,
                        transform: [{ scale: pressed ? 0.98 : 1 }],
                      },
                    ]}>
                    <View style={styles.rowCopy}>
                      <ThemedText type="smallBold">{product.name}</ThemedText>
                      <ThemedText type="small" themeColor="textSecondary">
                        {formatPrice(product.priceCents)}
                      </ThemedText>
                    </View>
                    <ThemedText
                      type="smallBold"
                      themeColor={on ? "accent" : "textSecondary"}>
                      {on ? "On list" : "Add"}
                    </ThemedText>
                  </Pressable>
                );
              })}
            </View>
          );
        })}
      </ScrollView>

      <PrimaryButton
        label={
          count === 0
            ? "Pick at least one product"
            : `Show QR, ${count} ${count === 1 ? "product" : "products"}`
        }
        disabled={count === 0}
        onPress={() => router.push("/qr" as Href)}
      />
    </Screen>
  );
}

const styles = StyleSheet.create({
  copy: {
    gap: Spacing.one,
  },
  title: {
    fontSize: 32,
    lineHeight: 38,
    fontWeight: "600",
  },
  flex: {
    flex: 1,
  },
  catalog: {
    gap: Spacing.three,
    paddingBottom: Spacing.two,
  },
  group: {
    gap: Spacing.two,
  },
  row: {
    minHeight: 56,
    borderWidth: 1,
    borderRadius: 14,
    paddingHorizontal: Spacing.three,
    paddingVertical: Spacing.two,
    flexDirection: "row",
    alignItems: "center",
    gap: Spacing.two,
  },
  rowCopy: {
    flex: 1,
    gap: 2,
  },
});
