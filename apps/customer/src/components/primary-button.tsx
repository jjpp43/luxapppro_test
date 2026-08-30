import { Pressable, StyleSheet, Text } from "react-native";

import { Spacing } from "@/constants/theme";
import { useTheme } from "@/hooks/use-theme";

type Props = {
  label: string;
  onPress: () => void;
  disabled?: boolean;
};

export function PrimaryButton({ label, onPress, disabled }: Props) {
  const theme = useTheme();

  return (
    <Pressable
      accessibilityRole="button"
      disabled={disabled}
      onPress={onPress}
      style={({ pressed }) => [
        styles.button,
        {
          backgroundColor: disabled
            ? theme.border
            : pressed
              ? theme.accentPressed
              : theme.accent,
          transform: [{ scale: pressed && !disabled ? 0.97 : 1 }],
        },
      ]}>
      <Text style={[styles.label, { color: disabled ? theme.textSecondary : "#ffffff" }]}>
        {label}
      </Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  button: {
    minHeight: 52,
    borderRadius: 14,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: Spacing.four,
  },
  label: {
    fontSize: 17,
    fontWeight: "600",
  },
});
