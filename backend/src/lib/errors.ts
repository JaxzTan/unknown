// Standard error JSON from docs/api-contract.md §1.5:
// { "error": { "code": "NOT_FOUND", "message": "..." } }
import { ZodError } from "zod";
import { corsHeaders } from "@/lib/cors";

export type ErrorCode =
  | "VALIDATION_ERROR"
  | "UNAUTHORIZED"
  | "NOT_FOUND"
  | "ACCOUNT_NEEDS_RECONNECT"
  | "STATE_EXPIRED"
  | "NO_SELECTABLE_PAGE"
  | "PLATFORM_ERROR"
  | "INTERNAL_ERROR";

const statusByCode: Record<ErrorCode, number> = {
  VALIDATION_ERROR: 400,
  UNAUTHORIZED: 401,
  NOT_FOUND: 404,
  ACCOUNT_NEEDS_RECONNECT: 409,
  STATE_EXPIRED: 410,
  NO_SELECTABLE_PAGE: 422,
  PLATFORM_ERROR: 502,
  INTERNAL_ERROR: 500,
};

// Throw this from a route; handle() turns it into the error JSON
export class ApiError extends Error {
  readonly status: number;

  constructor(
    readonly code: ErrorCode,
    message: string,
  ) {
    super(message);
    this.name = "ApiError";
    this.status = statusByCode[code];
  }
}

// Thrown by adapters when a platform API fails.
// needsReconnect = token invalid or revoked (Meta error 190); caller sets the account status.
export class PlatformError extends ApiError {
  constructor(
    message: string,
    readonly needsReconnect = false,
  ) {
    super(needsReconnect ? "ACCOUNT_NEEDS_RECONNECT" : "PLATFORM_ERROR", message);
    this.name = "PlatformError";
  }
}

// Removes token values from text before it reaches a log or response (NFR-3)
export function redactTokens(text: string): string {
  return text.replace(
    /((?:access_token|refresh_token|client_secret|fb_exchange_token|code)=)[^&\s"']+/gi,
    "$1[REDACTED]",
  );
}

export function errorResponse(code: ErrorCode, message: string) {
  return Response.json(
    { error: { code, message: redactTokens(message) } },
    { status: statusByCode[code], headers: corsHeaders },
  );
}

export function toErrorResponse(err: unknown): Response {
  if (err instanceof ApiError) return errorResponse(err.code, err.message);

  if (err instanceof ZodError) {
    const issue = err.issues[0];
    const field = issue?.path.join(".");
    return errorResponse("VALIDATION_ERROR", field ? `${field}: ${issue.message}` : "Invalid request");
  }

  // Unknown error: log a redacted copy, never send details to the client
  const detail = err instanceof Error ? `${err.name}: ${err.message}` : String(err);
  console.error("[api] unhandled error", redactTokens(detail));
  return errorResponse("INTERNAL_ERROR", "Something went wrong");
}

// Wraps a route handler so every thrown error returns the standard JSON.
// Usage: export const GET = handle(async (req) => { ... });
export function handle<Ctx>(fn: (req: Request, ctx: Ctx) => Promise<Response> | Response) {
  return async (req: Request, ctx: Ctx): Promise<Response> => {
    try {
      return await fn(req, ctx);
    } catch (err) {
      return toErrorResponse(err);
    }
  };
}
