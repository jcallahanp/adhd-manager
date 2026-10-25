import { describe, expect, it } from "vitest";
import { health } from "./health.js";

describe("health", () => {
  it("reports ok with the shared app name", () => {
    expect(health()).toEqual({ status: "ok", app: "ADHD Manager" });
  });
});
