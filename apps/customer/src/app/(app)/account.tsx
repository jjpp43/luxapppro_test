import { type Href, useRouter } from "expo-router";
import { Pressable, StyleSheet, Switch, View } from "react-native";

import { DemoBanner } from "@/components/demo-banner";
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
      <ThemedText themeColor="textSecondary">
        Signed in as a customer. Beautician tools are a demo switch. Production
        only shows them if the owner added this phone.
      </ThemedText>
      <ThemedText type="smallBold">
        {session ? displayPhone(session.phone) : ""}
      </ThemedText>

      <DemoBanner />

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
              Turn on for the phone that builds the list.
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
            Demo amount. Production is 5% of listed SKUs they actually bought,
            in dollars, not shopper points.
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

      <View
        style={[
          styles.card,
          {
            backgroundColor: theme.backgroundElement,
            borderColor: theme.border,
          },
        ]}>
        <ThemedText type="smallBold">How to demo this</ThemedText>
        <ThemedText type="small" themeColor="textSecondary">
          1. This phone: turn on Beautician tools, build a list, show the QR.
        </ThemedText>
        <ThemedText type="small" themeColor="textSecondary">
          2. Other phone: sign in (any number, code 000000), open Scan.
        </ThemedText>
        <ThemedText type="small" themeColor="textSecondary">
          3. Scan the QR. Home shows 5% and a register code.
        </ThemedText>
        <ThemedText type="small" themeColor="textSecondary">
          4. Tell them the cashier would type that code. Lightspeed is not
          connected. Use a development build, not Expo Go.
        </ThemedText>
      </View>

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
