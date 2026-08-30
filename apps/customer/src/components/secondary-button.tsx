import { Pressable, StyleSheet, Text } from "react-native";

import { Spacing } from "@/constants/theme";
import { useTheme } from "@/hooks/use-theme";

type Props = {
  label: string;
  onPress: () => void;
  disabled?: boolean;
};

export function SecondaryButton({ label, onPress, disabled }: Props) {
  const theme = useTheme();

  return (
    <Pressable
      accessibilityRole="button"
      disabled={disabled}
      onPress={onPress}
      style={({ pressed }) => [
        styles.button,
        {
          borderColor: theme.accent,
          backgroundColor: pressed ? theme.backgroundSelected : "transparent",
          opacity: disabled ? 0.45 : 1,
          transform: [{ scale: pressed && !disabled ? 0.97 : 1 }],
        },
      ]}>
      <Text style={[styles.label, { color: theme.accent }]}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  button: {
    minHeight: 52,
    borderRadius: 14,
    borderWidth: 1.5,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: Spacing.four,
  },
  label: {
    fontSize: 17,
    fontWeight: "600",
  },
});
