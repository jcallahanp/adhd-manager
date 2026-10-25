import { describe, expect, it } from "vitest";
import { APP_NAME } from "./index.js";

describe("@adhd/core", () => {
  it("exports the app name shared by every app", () => {
    expect(APP_NAME).toBe("ADHD Manager");
  });
});
