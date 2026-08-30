import { ScrollView, StyleSheet, View, type ViewProps } from "react-native";

import { MaxContentWidth, Spacing } from "@/constants/theme";
import { useTheme } from "@/hooks/use-theme";
import { useScreenPadding } from "@/lib/screen-insets";

type Props = ViewProps & {
  /** Screens above the tab bar — bottom inset lives on the tab bar, not here. */
  tabbed?: boolean;
  scroll?: boolean;
};

export function Screen({ tabbed = false, scroll = false, children, style, ...rest }: Props) {
  const theme = useTheme();
  const padding = useScreenPadding(tabbed);

  const inner = (
    <View style={[styles.inner, !scroll && styles.flex, style]} {...rest}>
      {children}
    </View>
  );

  return (
    <View style={[styles.shell, { backgroundColor: theme.background }, padding]}>
      {scroll ? (
        <ScrollView
          style={styles.flex}
          contentContainerStyle={styles.scroll}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}>
          {inner}
        </ScrollView>
      ) : (
        inner
      )}
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
  scroll: {
    flexGrow: 1,
  },
  inner: {
    width: "100%",
    maxWidth: MaxContentWidth,
    alignSelf: "center",
    gap: Spacing.three,
  },
});
