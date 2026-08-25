/**
 * Lightspeed ingest worker.
 * Polls every configured retailer (Decatur today; add tokens later).
 * Webhooks stay off until the retailer enables them.
 * Earn is still gated by stores.loyalty_earn_enabled.
 */
import { createServer } from "node:http";
import { envFlag, loadSources } from "./config.mjs";
import { ingestWebhookPayload, pollAllSources } from "./ingest.mjs";
import { createServiceClient } from "./supabase.mjs";

const PORT = Number(process.env.PORT ?? 8787);
const webhooksEnabled = envFlag("LOYALTY_WEBHOOKS_ENABLED");
const earnGlobal = envFlag("LOYALTY_EARN_GLOBAL");
const pollMinutes = Number(process.env.POLL_INTERVAL_MINUTES ?? 15);
const jobSecret = process.env.WORKER_JOB_SECRET || "";

let pollInFlight = false;
let lastPoll = null;

function json(res, status, body) {
  res.writeHead(status, { "content-type": "application/json" });
  res.end(JSON.stringify(body));
}

async function readJson(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  return JSON.parse(Buffer.concat(chunks).toString("utf8") || "{}");
}

function authorizeJob(req) {
  if (!jobSecret) return true;
  return req.headers["x-job-secret"] === jobSecret;
}

async function runPoll() {
  if (pollInFlight) return { ok: false, reason: "poll_in_flight" };
  const sources = loadSources();
  if (!sources.length) return { ok: false, reason: "no_lightspeed_sources" };
  pollInFlight = true;
  try {
    const supabase = createServiceClient();
    const result = await pollAllSources(supabase, sources);
    lastPoll = { at: new Date().toISOString(), ...result };
    return { ok: true, ...lastPoll };
  } finally {
    pollInFlight = false;
  }
}

const server = createServer(async (req, res) => {
  const url = new URL(req.url ?? "/", `http://127.0.0.1:${PORT}`);

  try {
    if (req.method === "GET" && url.pathname === "/health") {
      const sources = loadSources();
      json(res, 200, {
        ok: true,
        webhooksEnabled,
        earnGlobal,
        pollMinutes,
        pollInFlight,
        lastPoll,
        sources: sources.map((s) => ({ id: s.id, domain: s.domain })),
      });
      return;
    }

    if (req.method === "POST" && url.pathname === "/jobs/poll") {
      if (!authorizeJob(req)) {
        json(res, 401, { ok: false, reason: "unauthorized" });
        return;
      }
      const result = await runPoll();
      json(res, result.ok ? 200 : 503, result);
      return;
    }

    if (req.method === "POST" && url.pathname === "/webhooks/lightspeed") {
      if (!webhooksEnabled) {
        json(res, 503, { ok: false, reason: "webhooks_disabled" });
        return;
      }
      const payload = await readJson(req);
      const supabase = createServiceClient();
      const result = await ingestWebhookPayload(supabase, payload);
      json(res, result.ok ? 200 : 400, result);
      return;
    }

    json(res, 404, { ok: false });
  } catch (error) {
    console.error(error);
    json(res, 500, { ok: false, reason: error instanceof Error ? error.message : "error" });
  }
});

server.listen(PORT, () => {
  const sources = loadSources();
  console.log(
    `worker :${PORT} sources=${sources.map((s) => s.id).join(",") || "none"} poll=${pollMinutes}m webhooks=${webhooksEnabled}`,
  );
  if (pollMinutes > 0 && sources.length) {
    runPoll().catch((error) => console.error("startup poll failed", error));
    setInterval(() => {
      runPoll().catch((error) => console.error("scheduled poll failed", error));
    }, pollMinutes * 60 * 1000);
  }
});
