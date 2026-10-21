// Shared CORS headers for the Flutter web client (CORS_ORIGIN in .env)
export const corsHeaders = {
  "Access-Control-Allow-Origin": process.env.CORS_ORIGIN ?? "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

export function preflight() {
  return new Response(null, { status: 204, headers: corsHeaders });
}
