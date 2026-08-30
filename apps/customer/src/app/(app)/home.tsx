import { useRouter } from "expo-router";
import { Pressable, StyleSheet, View } from "react-native";

import { PrimaryButton } from "@/components/primary-button";
import { Screen } from "@/components/screen";
import { ThemedText } from "@/components/themed-text";
import { Spacing } from "@/constants/theme";
import { useTheme } from "@/hooks/use-theme";
import { dealSummary, formatMinPurchase, formatPoints } from "@/lib/deal";
import { displayPhone } from "@/lib/phone";
import { useSession } from "@/lib/session";

export default function HomeScreen() {
  const theme = useTheme();
  const router = useRouter();
  const { session } = useSession();
  const deal = session?.activeDeal ?? null;
  const points = session?.points ?? 0;

  return (
    <Screen tabbed scroll>
      <View style={styles.copy}>
        <ThemedText type="smallBold" themeColor="accent" style={styles.kicker}>
          Lux Pro
        </ThemedText>
        <ThemedText style={styles.title}>Home</ThemedText>
        <ThemedText themeColor="textSecondary">
          {session ? displayPhone(session.phone) : "—"}
        </ThemedText>
      </View>

      <View
        style={[
          styles.pointsCard,
          {
            backgroundColor: theme.backgroundElement,
            borderColor: theme.border,
          },
        ]}>
        <ThemedText type="smallBold" themeColor="textSecondary">
          Point balance
        </ThemedText>
        <ThemedText style={styles.points}>{formatPoints(points)}</ThemedText>
        <ThemedText type="small" themeColor="textSecondary">
          Lux points — not TapMango. Earn is off. Redeem still happens in
          TapMango. A referral is 5% off products, not extra points here.
        </ThemedText>
      </View>

      <PrimaryButton
        label="Scan QR for a referral"
        onPress={() => router.push("/scan")}
      />

      {deal ? (
        <View
          style={[
            styles.dealCard,
            {
              backgroundColor: theme.backgroundElement,
              borderColor: theme.accent,
            },
          ]}>
          <ThemedText type="smallBold" themeColor="accent">
            Active deal
          </ThemedText>
          <ThemedText style={styles.promo}>{deal.promoCode}</ThemedText>
          <ThemedText themeColor="textSecondary">{dealSummary(deal)}</ThemedText>
          <ThemedText type="smallBold">Show this code at the register</ThemedText>
          {deal.productNames.map((name) => (
            <ThemedText key={name} type="small" themeColor="textSecondary">
              · {name}
            </ThemedText>
          ))}
          <ThemedText type="small" themeColor="textSecondary">
            5% applies to every unit of those products. Ticket must be at least{" "}
            {formatMinPurchase(deal.minPurchaseCents)}. Extra items stay full
            price.
          </ThemedText>
        </View>
      ) : (
        <Pressable
          onPress={() => router.push("/scan")}
          style={({ pressed }) => [
            styles.emptyCard,
            {
              backgroundColor: theme.backgroundElement,
              borderColor: theme.border,
              transform: [{ scale: pressed ? 0.98 : 1 }],
            },
          ]}>
          <ThemedText type="smallBold">No referral yet</ThemedText>
          <ThemedText type="small" themeColor="textSecondary">
            Scan your beautician’s QR for 5% off the items on their list. You
            have 3 days after you claim it.
          </ThemedText>
        </Pressable>
      )}
    </Screen>
  );
}

const styles = StyleSheet.create({
  copy: {
    gap: Spacing.one,
  },
  kicker: {
    letterSpacing: 0.6,
    textTransform: "uppercase",
  },
  title: {
    fontSize: 32,
    lineHeight: 38,
    fontWeight: "600",
  },
  pointsCard: {
    borderWidth: 1,
    borderRadius: 16,
    padding: Spacing.four,
    gap: Spacing.two,
  },
  points: {
    fontSize: 44,
    lineHeight: 48,
    fontWeight: "700",
  },
  dealCard: {
    borderWidth: 1.5,
    borderRadius: 16,
    padding: Spacing.four,
    gap: Spacing.two,
  },
  promo: {
    fontSize: 28,
    lineHeight: 34,
    fontWeight: "700",
    letterSpacing: 1,
  },
  emptyCard: {
    borderWidth: 1,
    borderRadius: 16,
    padding: Spacing.four,
    gap: Spacing.two,
  },
});
