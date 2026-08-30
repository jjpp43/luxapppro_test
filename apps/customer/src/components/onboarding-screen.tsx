import {
  KeyboardAvoidingView,
  Platform,
  StyleSheet,
  View,
  type ViewProps,
} from "react-native";

import { MaxContentWidth, Spacing } from "@/constants/theme";
import { useTheme } from "@/hooks/use-theme";
import { useScreenPadding } from "@/lib/screen-insets";

export function OnboardingScreen({ children, style, ...rest }: ViewProps) {
  const theme = useTheme();
  const padding = useScreenPadding(false);

  return (
    <View style={[styles.shell, { backgroundColor: theme.background }, padding]}>
      <KeyboardAvoidingView
        behavior={Platform.OS === "ios" ? "padding" : undefined}
        style={styles.flex}>
        <View style={[styles.inner, style]} {...rest}>
          {children}
        </View>
      </KeyboardAvoidingView>
    </View>
  );
}

const styles = StyleSheet.create({
  shell: {
    flex: 1,
  },
  flex: {
    flex: 1,
  },
  inner: {
    flex: 1,
    width: "100%",
    maxWidth: MaxContentWidth,
    alignSelf: "center",
    gap: Spacing.three,
  },
});
