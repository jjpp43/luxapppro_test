import { lightspeedBase } from "./config.mjs";

export async function searchSales(source, { dateFrom, dateTo, states, pageSize, offset }) {
  const params = new URLSearchParams({
    type: "sales",
    date_from: dateFrom,
    date_to: dateTo,
    page_size: String(pageSize),
    offset: String(offset),
  });
  if (states?.length) params.set("status", states.join(","));

  const url = `${lightspeedBase(source.domain)}/api/2026-04/search?${params}`;
  const response = await fetch(url, {
    headers: {
      Authorization: `Bearer ${source.token}`,
      Accept: "application/json",
      "User-Agent": "lux-pro-worker/0.1",
    },
  });
  if (!response.ok) {
    const body = await response.text();
    throw new Error(`${source.id} search HTTP ${response.status}: ${body.slice(0, 400)}`);
  }
  return response.json();
}

export function pollWindow(lookbackHours) {
  const to = new Date(Date.now() + 60 * 60 * 1000);
  const from = new Date(Date.now() - lookbackHours * 60 * 60 * 1000);
  return {
    dateFrom: from.toISOString(),
    dateTo: to.toISOString(),
  };
}
