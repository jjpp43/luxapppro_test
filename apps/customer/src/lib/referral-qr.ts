import type { ActiveDeal } from "@/lib/session";

export const DEMO_PERCENT_OFF = 5;
export const DEMO_MIN_CENTS = 2000;
export const BUY_WINDOW_DAYS = 3;

const PREFIX = "lux1";

type PayloadV1 = {
  n: string[];
  c: string;
};

export function promoCodeFor(names: string[]): string {
  const seed = names.join("|");
  let hash = 0;
  for (let i = 0; i < seed.length; i += 1) {
    hash = (hash * 31 + seed.charCodeAt(i)) >>> 0;
  }
  return `LUX ${hash.toString(36).toUpperCase().slice(0, 4).padStart(4, "0")}`;
}

export function dealFromNames(
  productNames: string[],
  promoCode: string,
  now = new Date(),
): ActiveDeal {
  const expires = new Date(now);
  expires.setDate(expires.getDate() + BUY_WINDOW_DAYS);
  return {
    productNames,
    percentOff: DEMO_PERCENT_OFF,
    minPurchaseCents: DEMO_MIN_CENTS,
    expiresAt: expires.toISOString(),
    promoCode,
  };
}

export function encodeReferralQr(productNames: string[], promoCode: string): string {
  const payload: PayloadV1 = { n: productNames, c: promoCode };
  return `${PREFIX}${JSON.stringify(payload)}`;
}

export function dealFromQrData(raw: string): ActiveDeal | null {
  const text = raw.trim();
  if (!text.startsWith(PREFIX)) return null;
  try {
    const parsed = JSON.parse(text.slice(PREFIX.length)) as PayloadV1;
    if (!Array.isArray(parsed.n) || parsed.n.length === 0) return null;
    const names = parsed.n
      .filter((name): name is string => typeof name === "string")
      .map((name) => name.trim())
      .filter(Boolean);
    if (names.length === 0) return null;
    const code =
      typeof parsed.c === "string" && parsed.c.trim()
        ? parsed.c.trim()
        : promoCodeFor(names);
    return dealFromNames(names, code);
  } catch {
    return null;
  }
}
