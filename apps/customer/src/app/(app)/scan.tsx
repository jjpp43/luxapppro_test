import { CameraView, useCameraPermissions } from "expo-camera";
import { useRouter } from "expo-router";
import { useRef, useState } from "react";
import { Platform, StyleSheet, View } from "react-native";

import { PrimaryButton } from "@/components/primary-button";
import { Screen } from "@/components/screen";
import { SecondaryButton } from "@/components/secondary-button";
import { ThemedText } from "@/components/themed-text";
import { Spacing } from "@/constants/theme";
import { useTheme } from "@/hooks/use-theme";
import { dealFromQrData } from "@/lib/referral-qr";
import { useSession } from "@/lib/session";

export default function ScanScreen() {
  const theme = useTheme();
  const router = useRouter();
  const { claimDeal, claimSampleDeal } = useSession();
  const [permission, requestPermission] = useCameraPermissions();
  const [hint, setHint] = useState<string | null>(null);
  const locked = useRef(false);
  const lastBad = useRef(0);

  function goHomeWithSample() {
    if (locked.current) return;
    locked.current = true;
    claimSampleDeal();
    router.replace("/home");
  }

  const cameraReady = Platform.OS !== "web" && permission?.granted;

  return (
    <Screen tabbed>
      <ThemedText style={styles.title}>Scan</ThemedText>
      <ThemedText themeColor="textSecondary">
        Point the camera at your beautician’s QR. Only a Lux list loads a deal.
        The sample button still works if you have one phone.
      </ThemedText>

      <View
        style={[
          styles.preview,
          { backgroundColor: theme.backgroundElement, borderColor: theme.border },
        ]}>
        {cameraReady ? (
          <CameraView
            style={StyleSheet.absoluteFill}
            facing="back"
            barcodeScannerSettings={{ barcodeTypes: ["qr"] }}
            onBarcodeScanned={({ data }) => {
              if (locked.current) return;
              const deal = dealFromQrData(data);
              if (!deal) {
                const now = Date.now();
                if (now - lastBad.current > 1600) {
                  lastBad.current = now;
                  setHint("Not a Lux list. Scan the beautician QR, or load the sample.");
                }
                return;
              }
              locked.current = true;
              claimDeal(deal);
              router.replace("/home");
            }}
          />
        ) : (
          <View style={styles.previewCopy}>
            <ThemedText type="smallBold">Camera</ThemedText>
            <ThemedText type="small" themeColor="textSecondary">
              {Platform.OS === "web"
                ? "Use a phone to scan. On web, load the sample or show a QR from List."
                : permission?.granted
                  ? "Starting camera…"
                  : "Allow camera to scan a QR."}
            </ThemedText>
          </View>
        )}
      </View>

      {hint ? (
        <ThemedText type="small" style={{ color: theme.danger }}>
          {hint}
        </ThemedText>
      ) : null}

      {Platform.OS !== "web" && !permission?.granted ? (
        <PrimaryButton
          label="Allow camera"
          onPress={async () => {
            const result = await requestPermission();
            if (!result.granted) {
              setHint("Camera is off. You can still load a sample referral.");
            }
          }}
        />
      ) : null}

      <SecondaryButton label="Load a sample referral" onPress={goHomeWithSample} />
    </Screen>
  );
}

const styles = StyleSheet.create({
  title: {
    fontSize: 32,
    lineHeight: 38,
    fontWeight: "600",
  },
  preview: {
    minHeight: 240,
    borderRadius: 16,
    borderWidth: 1,
    overflow: "hidden",
    justifyContent: "center",
  },
  previewCopy: {
    padding: Spacing.four,
    gap: Spacing.two,
  },
});
