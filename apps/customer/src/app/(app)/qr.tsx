import { type Href, Redirect } from "expo-router";
import { StyleSheet, View } from "react-native";
import QRCode from "react-native-qrcode-svg";

import { Screen } from "@/components/screen";
import { ThemedText } from "@/components/themed-text";
import { Spacing } from "@/constants/theme";
import { useTheme } from "@/hooks/use-theme";
import { productsByIds } from "@/lib/catalog";
import { encodeReferralQr, promoCodeFor } from "@/lib/referral-qr";
import { useSession } from "@/lib/session";

export default function QrScreen() {
  const theme = useTheme();
  const { session } = useSession();

  if (!session) return <Redirect href="/phone" />;
  if (!session.beauticianTools) return <Redirect href="/account" />;

  const products = productsByIds(session.listProductIds);
  if (products.length === 0) return <Redirect href={"/list" as Href} />;

  const names = products.map((p) => p.name);
  const promoCode = promoCodeFor(names);
  const value = encodeReferralQr(names, promoCode);

  return (
    <Screen tabbed scroll>
      <View style={styles.copy}>
        <ThemedText style={styles.title}>QR</ThemedText>
        <ThemedText themeColor="textSecondary">
          Customer opens Scan on the other phone and points at this. Fake token.
          Sharing this QR or the code is fine. The 5% lasts 3 days after they claim.
        </ThemedText>
      </View>

      <View
        style={[
          styles.qrCard,
          {
            backgroundColor: theme.backgroundElement,
            borderColor: theme.border,
          },
        ]}>
        <QRCode value={value} size={220} color={theme.text} backgroundColor={theme.backgroundElement} />
        <ThemedText type="smallBold" style={styles.code}>
          {promoCode}
        </ThemedText>
      </View>

      <View
        style={[
          styles.listCard,
          {
            backgroundColor: theme.backgroundElement,
            borderColor: theme.border,
          },
        ]}>
        <ThemedText type="smallBold" themeColor="accent">
          This list, 5% off, $20 min ticket
        </ThemedText>
        {names.map((name) => (
          <ThemedText key={name} type="small" themeColor="textSecondary">
            {name}
          </ThemedText>
        ))}
      </View>
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
  qrCard: {
    borderWidth: 1,
    borderRadius: 16,
    padding: Spacing.four,
    alignItems: "center",
    gap: Spacing.three,
  },
  code: {
    letterSpacing: 1,
  },
  listCard: {
    borderWidth: 1,
    borderRadius: 16,
    padding: Spacing.four,
    gap: Spacing.two,
  },
});
