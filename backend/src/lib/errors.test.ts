import { describe, expect, it, vi } from "vitest";
import { z } from "zod";
import { ApiError, PlatformError, handle, redactTokens } from "@/lib/errors";

describe("handle", () => {
  it("passes through a normal response", async () => {
    const route = handle(() => Response.json({ ok: true }));
    const res = await route(new Request("http://test"), {});
    expect(res.status).toBe(200);
  });

  it("returns the contract error shape for ApiError", async () => {
    const route = handle(() => {
      throw new ApiError("NOT_FOUND", "Account not found");
    });
    const res = await route(new Request("http://test"), {});
    expect(res.status).toBe(404);
    expect(await res.json()).toEqual({
      error: { code: "NOT_FOUND", message: "Account not found" },
    });
  });

  it("maps a revoked token to 409 ACCOUNT_NEEDS_RECONNECT", async () => {
    const route = handle(() => {
      throw new PlatformError("Token revoked", true);
    });
    const res = await route(new Request("http://test"), {});
    expect(res.status).toBe(409);
    expect((await res.json()).error.code).toBe("ACCOUNT_NEEDS_RECONNECT");
  });

  it("maps a Zod error to 400 VALIDATION_ERROR", async () => {
    const route = handle(() => {
      z.object({ limit: z.number().max(50) }).parse({ limit: 99 });
      return Response.json({});
    });
    const res = await route(new Request("http://test"), {});
    expect(res.status).toBe(400);
    expect((await res.json()).error.code).toBe("VALIDATION_ERROR");
  });

  it("hides unknown errors and never leaks a token", async () => {
    const log = vi.spyOn(console, "error").mockImplementation(() => {});
    const route = handle(() => {
      throw new Error("fetch failed: https://graph.instagram.com/me?access_token=IGQVJsecret123");
    });
    const res = await route(new Request("http://test"), {});
    const body = await res.text();

    expect(res.status).toBe(500);
    expect(body).not.toContain("IGQVJsecret123");
    expect(JSON.stringify(log.mock.calls)).not.toContain("IGQVJsecret123");
    log.mockRestore();
  });
});

describe("redactTokens", () => {
  it("removes token values from query strings", () => {
    expect(redactTokens("a?access_token=abc&client_secret=xyz&limit=30")).toBe(
      "a?access_token=[REDACTED]&client_secret=[REDACTED]&limit=30",
    );
  });
});
