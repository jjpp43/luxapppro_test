import { StyleSheet, View } from "react-native";

import { PrimaryButton } from "@/components/primary-button";
import { Screen } from "@/components/screen";
import { ThemedText } from "@/components/themed-text";
import { displayPhone } from "@/lib/phone";
import { useSession } from "@/lib/session";

export default function AccountScreen() {
  const { session, signOut } = useSession();

  return (
    <Screen tabbed>
      <ThemedText style={styles.title}>Account</ThemedText>
      <ThemedText themeColor="textSecondary">
        Signed in as a customer. Beautician tools will show here only after the
        owner adds this phone.
      </ThemedText>
      <ThemedText type="smallBold">
        {session ? displayPhone(session.phone) : "—"}
      </ThemedText>
      <View style={styles.footer}>
        <PrimaryButton label="Sign out" onPress={signOut} />
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  title: {
    fontSize: 32,
    lineHeight: 38,
    fontWeight: "600",
  },
  footer: {
    marginTop: "auto",
  },
});
