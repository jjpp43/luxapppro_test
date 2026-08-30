import { useSafeAreaInsets } from "react-native-safe-area-context";

/** Extra space after the device safe area (island, notch, status bar, home indicator). */
export const ScreenGutter = {
  x: 20,
  rest: 12,
} as const;

export function useScreenPadding(tabbed = false) {
  const insets = useSafeAreaInsets();

  return {
    paddingTop: insets.top + ScreenGutter.rest,
    paddingLeft: insets.left + ScreenGutter.x,
    paddingRight: insets.right + ScreenGutter.x,
    paddingBottom: tabbed
      ? ScreenGutter.rest
      : insets.bottom + ScreenGutter.rest,
  };
}

export function useTabBarPadding() {
  const insets = useSafeAreaInsets();

  return {
    paddingTop: ScreenGutter.rest,
    paddingLeft: insets.left + ScreenGutter.x,
    paddingRight: insets.right + ScreenGutter.x,
    paddingBottom: insets.bottom + ScreenGutter.rest,
  };
}
