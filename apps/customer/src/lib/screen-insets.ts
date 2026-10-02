import { Platform } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

/** Extra space after the device safe area (island, notch, status bar, home indicator). */
export const ScreenGutter = {
  x: 20,
  rest: 20,
} as const;

/**
 * Desktop web reports 0 insets, so screenshots and the laptop demo sit flush
 * on the chrome. Floor to a status-bar / home-indicator stand-in. Real phones
 * keep their native insets.
 */
const WebFallback = {
  top: 44,
  bottom: 28,
} as const;

function useEdges() {
  const insets = useSafeAreaInsets();
  if (Platform.OS !== "web") return insets;
  return {
    top: Math.max(insets.top, WebFallback.top),
    right: insets.right,
    bottom: Math.max(insets.bottom, WebFallback.bottom),
    left: insets.left,
  };
}

export function useScreenPadding(tabbed = false) {
  const insets = useEdges();

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
  const insets = useEdges();

  return {
    paddingTop: ScreenGutter.rest,
    paddingLeft: insets.left + ScreenGutter.x,
    paddingRight: insets.right + ScreenGutter.x,
    paddingBottom: insets.bottom + ScreenGutter.rest,
  };
}
