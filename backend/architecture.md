# Backend architecture

Next.js 16 (App Router, TypeScript) used as an **API server** for the Flutter app.
The web pages in `src/app/page.tsx` are scaffold leftovers; the product surface is `/api/*`.

## Request flow

```
Flutter app ──HTTP/JSON──▶ /api/<name>  ──▶ src/app/api/<name>/route.ts ──▶ JSON response
```

## Layout

```
backend/
├── src/app/
│   ├── api/
│   │   └── health/route.ts   # GET /api/health → { status, time }
│   ├── layout.tsx            # root layout (web only)
│   └── page.tsx              # placeholder home page (web only)
├── next.config.ts
└── package.json
```

## Conventions

- **One folder per endpoint:** `src/app/api/<resource>/route.ts`. Export one function per HTTP method (`GET`, `POST`, ...).
- **Dynamic segments:** `src/app/api/<resource>/[id]/route.ts`.
- **JSON only:** return `Response.json(data, { status, headers })`.
- **CORS:** every route sends CORS headers and handles `OPTIONS`. The allowed origin comes from `CORS_ORIGIN` (default `*`). When a second route needs CORS, move the headers into a shared `src/lib/cors.ts`.
- **Shared logic** (DB clients, validation, auth helpers) goes in `src/lib/`. Route files stay thin.

## Config

| Env var       | Default | Purpose                      |
|---------------|---------|------------------------------|
| `CORS_ORIGIN` | `*`     | Allowed origin for API calls |

## Not yet decided

- Database / ORM
- Auth (session vs JWT for the mobile client)
- Request validation library (e.g. zod)
- Deployment target
