import { describe, expect, it } from "vitest";
import {
  healthCustomersHref,
  healthFilterExpression,
  parseHealthQuery,
} from "./customer-health";

describe("customer health query values", () => {
  it("parses supported URL values and rejects unknown values", () => {
    expect(parseHealthQuery("new")).toBe("new");
    expect(parseHealthQuery("at-risk")).toBe("atRisk");
    expect(parseHealthQuery("inactive")).toBe("inactive");
    expect(parseHealthQuery("unknown")).toBeNull();
    expect(parseHealthQuery(undefined)).toBeNull();
  });

  it("builds stable customer links", () => {
    expect(healthCustomersHref("active")).toBe("/customers?health=active");
    expect(healthCustomersHref("atRisk")).toBe(
      "/customers?health=at-risk",
    );
  });
});

describe("health filter expressions", () => {
  const now = new Date("2026-08-20T19:00:00Z");

  it("uses the same Pacific lifecycle windows for every segment", () => {
    expect(healthFilterExpression("new", now)).toContain(
      "registered_at.gte.2026-06-21",
    );
    expect(healthFilterExpression("active", now)).toContain(
      "last_seen_at.gte.2026-04-22",
    );
    expect(healthFilterExpression("lapsing", now)).toContain(
      "last_seen_at.gte.2025-12-23",
    );
    expect(healthFilterExpression("atRisk", now)).toContain(
      "last_seen_at.gte.2025-08-20",
    );
  });

  it("includes never-seen customers only in the inactive expression", () => {
    expect(healthFilterExpression("inactive", now)).toContain(
      "last_seen_at.is.null",
    );
    expect(healthFilterExpression("active", now)).not.toContain(
      "last_seen_at.is.null",
    );
  });
});
