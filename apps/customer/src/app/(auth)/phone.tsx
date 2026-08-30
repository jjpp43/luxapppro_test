import { useRouter } from "expo-router";
import { useState } from "react";
import { StyleSheet, TextInput, View } from "react-native";

import { OnboardingScreen } from "@/components/onboarding-screen";
import { PrimaryButton } from "@/components/primary-button";
import { ThemedText } from "@/components/themed-text";
import { Spacing } from "@/constants/theme";
import { useTheme } from "@/hooks/use-theme";
import { formatUsPhone, toE164 } from "@/lib/phone";
import { useSession } from "@/lib/session";

export default function PhoneScreen() {
  const theme = useTheme();
  const router = useRouter();
  const { startOtp } = useSession();
  const [value, setValue] = useState("");
  const [error, setError] = useState<string | null>(null);
  const e164 = toE164(value);

  function onContinue() {
    if (!e164) {
      setError("Enter a 10-digit US number.");
      return;
    }
    setError(null);
    startOtp(e164);
    router.push("/otp");
  }

  return (
    <OnboardingScreen>
      <View style={styles.copy}>
        <ThemedText type="smallBold" themeColor="accent" style={styles.kicker}>
          Lux Pro
        </ThemedText>
        <ThemedText style={styles.title}>What’s your phone?</ThemedText>
        <ThemedText themeColor="textSecondary" style={styles.lede}>
          We’ll use this to sign you in. For now the code is always 000000 —
          not a real text.
        </ThemedText>
      </View>

      <View style={styles.field}>
        <ThemedText type="smallBold" themeColor="textSecondary">
          Phone
        </ThemedText>
        <TextInput
          autoFocus
          autoComplete="tel"
          keyboardType="phone-pad"
          textContentType="telephoneNumber"
          placeholder="(702) 555-0100"
          placeholderTextColor={theme.textSecondary}
          value={formatUsPhone(value)}
          onChangeText={(next) => {
            setError(null);
            setValue(next);
          }}
          style={[
            styles.input,
            {
              color: theme.text,
              backgroundColor: theme.backgroundElement,
              borderColor: error ? theme.danger : theme.border,
            },
          ]}
        />
        {error ? (
          <ThemedText type="small" style={{ color: theme.danger }}>
            {error}
          </ThemedText>
        ) : null}
      </View>

      <View style={styles.footer}>
        <PrimaryButton
          label="Continue"
          disabled={!e164}
          onPress={onContinue}
        />
      </View>
    </OnboardingScreen>
  );
}

const styles = StyleSheet.create({
  copy: {
    gap: Spacing.two,
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
  lede: {
    maxWidth: 360,
  },
  field: {
    gap: Spacing.two,
    marginTop: Spacing.two,
  },
  input: {
    minHeight: 52,
    borderWidth: 1,
    borderRadius: 14,
    paddingHorizontal: Spacing.three,
    fontSize: 18,
    fontWeight: "500",
  },
  footer: {
    marginTop: "auto",
  },
});
