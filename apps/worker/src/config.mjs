export function envFlag(name, fallback = false) {
  const value = process.env[name];
  if (value == null || value === "") return fallback;
  return ["1", "true", "yes"].includes(value.toLowerCase());
}

export function loadSources() {
  const raw = process.env.LIGHTSPEED_SOURCES?.trim();
  if (raw) {
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) {
      throw new Error("LIGHTSPEED_SOURCES must be a JSON array");
    }
    return parsed
      .map((row, index) => ({
        id: String(row.id || row.name || `source_${index + 1}`),
        domain: String(row.domain || "").replace(/^https?:\/\//, "").split(".")[0],
        token: String(row.token || row.personal_token || ""),
      }))
      .filter((row) => row.domain && row.token);
  }

  const domain = process.env.LIGHTSPEED_DOMAIN;
  const token = process.env.LIGHTSPEED_PERSONAL_TOKEN;
  if (domain && token) {
    return [
      {
        id: "decatur",
        domain: domain.replace(/^https?:\/\//, "").split(".")[0],
        token,
      },
    ];
  }

  return [];
}

export function lightspeedBase(domain) {
  if (domain.startsWith("http")) {
    const host = new URL(domain).hostname;
    return `https://${host}`;
  }
  const slug = domain.replace(/\.retail\.lightspeed\.app$/i, "");
  return `https://${slug}.retail.lightspeed.app`;
}
