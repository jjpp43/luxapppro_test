import { StyleSheet, View } from "react-native";

import { ThemedText } from "@/components/themed-text";
import { Spacing } from "@/constants/theme";
import { useTheme } from "@/hooks/use-theme";

export function DemoBanner() {
  const theme = useTheme();

  return (
    <View
      style={[
        styles.banner,
        {
          backgroundColor: theme.backgroundSelected,
          borderColor: theme.accent,
        },
      ]}>
      <ThemedText type="smallBold" themeColor="accent">
        Demo
      </ThemedText>
      <ThemedText type="small" themeColor="textSecondary">
        OTP is always 000000. Lists, QR, and store credit are fake. Nothing is
        sent to Lightspeed.
      </ThemedText>
    </View>
  );
}

const styles = StyleSheet.create({
  banner: {
    borderWidth: 1,
    borderRadius: 14,
    padding: Spacing.three,
    gap: Spacing.one,
  },
});
