import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
  type ReactNode,
} from "react";

/** Staging only. Swap for Twilio later; same screens. */
export const FAKE_OTP = "000000";

export type ActiveDeal = {
  productNames: string[];
  percentOff: number;
  minPurchaseCents: number;
  expiresAt: string;
  promoCode: string;
};

export const SAMPLE_DEAL: ActiveDeal = {
  productNames: ["Olaplex No.3", "Denman brush", "Shampoo"],
  percentOff: 5,
  minPurchaseCents: 2000,
  expiresAt: "",
  promoCode: "LUX-TEST-5",
};

function sampleDeal(): ActiveDeal {
  const expires = new Date();
  expires.setDate(expires.getDate() + 3);
  return { ...SAMPLE_DEAL, expiresAt: expires.toISOString() };
}

type Session = {
  phone: string;
  points: number;
  activeDeal: ActiveDeal | null;
};

type VerifyResult = { ok: true } | { ok: false; error: string };

type SessionContextValue = {
  session: Session | null;
  pendingPhone: string | null;
  startOtp: (e164: string) => void;
  verifyOtp: (code: string) => VerifyResult;
  claimSampleDeal: () => void;
  signOut: () => void;
};

const SessionContext = createContext<SessionContextValue | null>(null);

export function SessionProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [pendingPhone, setPendingPhone] = useState<string | null>(null);

  const startOtp = useCallback((phone: string) => {
    setPendingPhone(phone);
  }, []);

  const verifyOtp = useCallback(
    (code: string): VerifyResult => {
      if (!pendingPhone) {
        return { ok: false, error: "Enter your phone first." };
      }
      const trimmed = code.replace(/\D/g, "");
      if (trimmed !== FAKE_OTP) {
        return {
          ok: false,
          error: "That code is not right. Use 000000 for now.",
        };
      }
      setSession({ phone: pendingPhone, points: 0, activeDeal: null });
      setPendingPhone(null);
      return { ok: true };
    },
    [pendingPhone],
  );

  const claimSampleDeal = useCallback(() => {
    setSession((current) =>
      current ? { ...current, activeDeal: sampleDeal() } : current,
    );
  }, []);

  const signOut = useCallback(() => {
    setSession(null);
    setPendingPhone(null);
  }, []);

  const value = useMemo(
    () => ({
      session,
      pendingPhone,
      startOtp,
      verifyOtp,
      claimSampleDeal,
      signOut,
    }),
    [session, pendingPhone, startOtp, verifyOtp, claimSampleDeal, signOut],
  );

  return (
    <SessionContext.Provider value={value}>{children}</SessionContext.Provider>
  );
}

export function useSession() {
  const ctx = useContext(SessionContext);
  if (!ctx) {
    throw new Error("useSession must be used inside SessionProvider");
  }
  return ctx;
}
