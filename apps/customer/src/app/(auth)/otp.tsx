import { Redirect, useRouter } from "expo-router";
import { useState } from "react";
import { Pressable, StyleSheet, TextInput, View } from "react-native";

import { OnboardingScreen } from "@/components/onboarding-screen";
import { PrimaryButton } from "@/components/primary-button";
import { ThemedText } from "@/components/themed-text";
import { Spacing } from "@/constants/theme";
import { useTheme } from "@/hooks/use-theme";
import { displayPhone } from "@/lib/phone";
import { FAKE_OTP, useSession } from "@/lib/session";

export default function OtpScreen() {
  const theme = useTheme();
  const router = useRouter();
  const { pendingPhone, verifyOtp } = useSession();
  const [code, setCode] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [resent, setResent] = useState(false);

  if (!pendingPhone) {
    return <Redirect href="/phone" />;
  }

  function onVerify() {
    const result = verifyOtp(code);
    if (!result.ok) {
      setError(result.error);
      return;
    }
    router.replace("/home");
  }

  return (
    <OnboardingScreen>
      <Pressable onPress={() => router.back()} hitSlop={12} style={styles.back}>
        <ThemedText type="smallBold" themeColor="accent">
          Change number
        </ThemedText>
      </Pressable>

      <View style={styles.copy}>
        <ThemedText style={styles.title}>Enter the code</ThemedText>
        <ThemedText themeColor="textSecondary">
          Sent to {displayPhone(pendingPhone)}. For now the code is always{" "}
          {FAKE_OTP}.
        </ThemedText>
      </View>

      <View style={styles.field}>
        <TextInput
          autoFocus
          autoComplete="one-time-code"
          keyboardType="number-pad"
          textContentType="oneTimeCode"
          maxLength={6}
          placeholder="000000"
          placeholderTextColor={theme.textSecondary}
          value={code}
          onChangeText={(next) => {
            setError(null);
            setResent(false);
            setCode(next.replace(/\D/g, "").slice(0, 6));
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

      <Pressable
        onPress={() => {
          setResent(true);
          setError(null);
        }}
        hitSlop={8}>
        <ThemedText type="small" themeColor="accent">
          {resent ? "Use 000000 — nothing was texted." : "Resend code"}
        </ThemedText>
      </Pressable>

      <View style={styles.footer}>
        <PrimaryButton
          label="Verify"
          disabled={code.length !== 6}
          onPress={onVerify}
        />
      </View>
    </OnboardingScreen>
  );
}

const styles = StyleSheet.create({
  back: {
    alignSelf: "flex-start",
    marginBottom: Spacing.one,
  },
  copy: {
    gap: Spacing.two,
  },
  title: {
    fontSize: 32,
    lineHeight: 38,
    fontWeight: "600",
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
    fontSize: 28,
    fontWeight: "600",
    letterSpacing: 8,
    textAlign: "center",
  },
  footer: {
    marginTop: "auto",
  },
});
