import { type Href, useRouter } from "expo-router";
import { Pressable, StyleSheet, Switch, View } from "react-native";

import { PrimaryButton } from "@/components/primary-button";
import { Screen } from "@/components/screen";
import { ThemedText } from "@/components/themed-text";
import { Spacing } from "@/constants/theme";
import { useTheme } from "@/hooks/use-theme";
import { formatDollars } from "@/lib/deal";
import { displayPhone } from "@/lib/phone";
import { useSession } from "@/lib/session";

export default function AccountScreen() {
  const theme = useTheme();
  const router = useRouter();
  const { session, setBeauticianTools, signOut } = useSession();
  const tools = session?.beauticianTools ?? false;

  return (
    <Screen tabbed scroll>
      <ThemedText style={styles.title}>Account</ThemedText>
      <ThemedText type="smallBold">
        {session ? displayPhone(session.phone) : ""}
      </ThemedText>

      <View
        style={[
          styles.card,
          {
            backgroundColor: theme.backgroundElement,
            borderColor: theme.border,
          },
        ]}>
        <View style={styles.toggleRow}>
          <View style={styles.toggleCopy}>
            <ThemedText type="smallBold">Beautician tools</ThemedText>
            <ThemedText type="small" themeColor="textSecondary">
              Lists and QR for your clients.
            </ThemedText>
          </View>
          <Switch
            value={tools}
            onValueChange={setBeauticianTools}
            trackColor={{ false: theme.border, true: theme.accent }}
            thumbColor="#ffffff"
          />
        </View>
      </View>

      {tools ? (
        <View
          style={[
            styles.card,
            {
              backgroundColor: theme.backgroundElement,
              borderColor: theme.border,
            },
          ]}>
          <ThemedText type="smallBold" themeColor="textSecondary">
            Store credit
          </ThemedText>
          <ThemedText style={styles.credit}>
            {formatDollars(session?.storeCreditCents ?? 0)}
          </ThemedText>
          <ThemedText type="small" themeColor="textSecondary">
            5% of listed products your clients buy.
          </ThemedText>
          <Pressable
            onPress={() => router.push("/list" as Href)}
            style={({ pressed }) => [
              styles.linkBtn,
              { opacity: pressed ? 0.7 : 1 },
            ]}>
            <ThemedText type="smallBold" themeColor="accent">
              Build a shopping list
            </ThemedText>
          </Pressable>
        </View>
      ) : null}

      <View style={styles.footer}>
        <PrimaryButton label="Sign out" onPress={signOut} />
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  title: {
    fontSize: 32,
    lineHeight: 38,
    fontWeight: "600",
  },
  card: {
    borderWidth: 1,
    borderRadius: 16,
    padding: Spacing.four,
    gap: Spacing.two,
  },
  toggleRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: Spacing.three,
  },
  toggleCopy: {
    flex: 1,
    gap: 4,
  },
  credit: {
    fontSize: 44,
    lineHeight: 48,
    fontWeight: "700",
  },
  linkBtn: {
    paddingTop: Spacing.one,
  },
  footer: {
    marginTop: Spacing.two,
  },
});
