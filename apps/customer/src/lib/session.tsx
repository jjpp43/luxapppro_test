import AsyncStorage from "@react-native-async-storage/async-storage";
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";

import { dealFromNames } from "@/lib/referral-qr";

const SESSION_KEY = "lux-pro-demo-session";

/** Staging only. Swap for Twilio later; same screens. */
export const FAKE_OTP = "000000";

/** Demo stub so the beautician screen is not $0 in a client meeting. */
export const DEMO_STORE_CREDIT_CENTS = 1200;

export type ActiveDeal = {
  productNames: string[];
  percentOff: number;
  minPurchaseCents: number;
  expiresAt: string;
  promoCode: string;
};

export const SAMPLE_DEAL_NAMES = [
  "Olaplex No.3 Hair Perfector",
  "Denman D3 Brush",
  "Cantu Shea Leave In",
];

export const SAMPLE_DEAL: ActiveDeal = {
  productNames: SAMPLE_DEAL_NAMES,
  percentOff: 5,
  minPurchaseCents: 2000,
  expiresAt: "",
  promoCode: "LUX TEST 5",
};

function sampleDeal(): ActiveDeal {
  return dealFromNames(SAMPLE_DEAL_NAMES, SAMPLE_DEAL.promoCode);
}

type Session = {
  phone: string;
  points: number;
  activeDeal: ActiveDeal | null;
  beauticianTools: boolean;
  storeCreditCents: number;
  listProductIds: string[];
};

type VerifyResult = { ok: true } | { ok: false; error: string };

type SessionContextValue = {
  ready: boolean;
  session: Session | null;
  pendingPhone: string | null;
  startOtp: (e164: string) => void;
  verifyOtp: (code: string) => VerifyResult;
  claimDeal: (deal: ActiveDeal) => void;
  claimSampleDeal: () => void;
  setBeauticianTools: (on: boolean) => void;
  toggleListProduct: (id: string) => void;
  signOut: () => void;
};

const SessionContext = createContext<SessionContextValue | null>(null);

function emptySession(phone: string): Session {
  return {
    phone,
    points: 0,
    activeDeal: null,
    beauticianTools: false,
    storeCreditCents: 0,
    listProductIds: [],
  };
}

function readStoredSession(raw: string | null): Session | null {
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw) as Session;
    if (!parsed || typeof parsed.phone !== "string") return null;
    return {
      phone: parsed.phone,
      points: typeof parsed.points === "number" ? parsed.points : 0,
      activeDeal: parsed.activeDeal ?? null,
      beauticianTools: Boolean(parsed.beauticianTools),
      storeCreditCents:
        typeof parsed.storeCreditCents === "number" ? parsed.storeCreditCents : 0,
      listProductIds: Array.isArray(parsed.listProductIds)
        ? parsed.listProductIds.filter((id) => typeof id === "string")
        : [],
    };
  } catch {
    return null;
  }
}

export function SessionProvider({ children }: { children: ReactNode }) {
  const [ready, setReady] = useState(false);
  const [session, setSession] = useState<Session | null>(null);
  const [pendingPhone, setPendingPhone] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    AsyncStorage.getItem(SESSION_KEY)
      .then((raw) => {
        if (!cancelled) setSession(readStoredSession(raw));
      })
      .finally(() => {
        if (!cancelled) setReady(true);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    if (!ready) return;
    if (session) {
      void AsyncStorage.setItem(SESSION_KEY, JSON.stringify(session));
    } else {
      void AsyncStorage.removeItem(SESSION_KEY);
    }
  }, [ready, session]);

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
          error: "That code is not right.",
        };
      }
      setSession(emptySession(pendingPhone));
      setPendingPhone(null);
      return { ok: true };
    },
    [pendingPhone],
  );

  const claimDeal = useCallback((deal: ActiveDeal) => {
    setSession((current) => (current ? { ...current, activeDeal: deal } : current));
  }, []);

  const claimSampleDeal = useCallback(() => {
    claimDeal(sampleDeal());
  }, [claimDeal]);

  const setBeauticianTools = useCallback((on: boolean) => {
    setSession((current) =>
      current
        ? {
            ...current,
            beauticianTools: on,
            storeCreditCents: on ? DEMO_STORE_CREDIT_CENTS : 0,
          }
        : current,
    );
  }, []);

  const toggleListProduct = useCallback((id: string) => {
    setSession((current) => {
      if (!current) return current;
      const has = current.listProductIds.includes(id);
      return {
        ...current,
        listProductIds: has
          ? current.listProductIds.filter((item) => item !== id)
          : [...current.listProductIds, id],
      };
    });
  }, []);

  const signOut = useCallback(() => {
    setSession(null);
    setPendingPhone(null);
  }, []);

  const value = useMemo(
    () => ({
      ready,
      session,
      pendingPhone,
      startOtp,
      verifyOtp,
      claimDeal,
      claimSampleDeal,
      setBeauticianTools,
      toggleListProduct,
      signOut,
    }),
    [
      ready,
      session,
      pendingPhone,
      startOtp,
      verifyOtp,
      claimDeal,
      claimSampleDeal,
      setBeauticianTools,
      toggleListProduct,
      signOut,
    ],
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
