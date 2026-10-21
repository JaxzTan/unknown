import { corsHeaders, preflight } from "@/lib/cors";

export function GET() {
  return Response.json(
    { status: "ok", time: new Date().toISOString() },
    { headers: corsHeaders },
  );
}

export const OPTIONS = preflight;
