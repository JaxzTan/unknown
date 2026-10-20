const corsHeaders = {
  "Access-Control-Allow-Origin": process.env.CORS_ORIGIN ?? "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

export function GET() {
  return Response.json(
    { status: "ok", time: new Date().toISOString() },
    { headers: corsHeaders },
  );
}

export function OPTIONS() {
  return new Response(null, { status: 204, headers: corsHeaders });
}
