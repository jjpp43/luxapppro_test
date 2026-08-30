import type { ActiveDeal } from "@/lib/session";

export function formatPoints(points: number): string {
  return points.toLocaleString("en-US");
}

export function formatMinPurchase(cents: number): string {
  return `$${(cents / 100).toFixed(0)}`;
}

export function daysLeft(expiresAt: string, now = new Date()): number {
  const ms = new Date(expiresAt).getTime() - now.getTime();
  return Math.max(0, Math.ceil(ms / (24 * 60 * 60 * 1000)));
}

export function dealSummary(deal: ActiveDeal): string {
  const left = daysLeft(deal.expiresAt);
  const window = left === 1 ? "1 day left" : `${left} days left`;
  return `${deal.percentOff}% off listed items · ${formatMinPurchase(deal.minPurchaseCents)} min ticket · ${window}`;
}
