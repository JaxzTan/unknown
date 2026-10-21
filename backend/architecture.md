# Backend architecture

Next.js 16 (App Router, TypeScript) used as an **API server** for the Flutter app.
The web pages in `src/app/page.tsx` are scaffold leftovers; the product surface is `/api/*`.

## Request flow

```
Flutter app ──HTTP/JSON──▶ /api/<name>  ──▶ src/app/api/<name>/route.ts ──▶ JSON response
                                                  │
                                                  ├──▶ src/lib/prisma.ts ──▶ Supabase Postgres
                                                  └──▶ Redis "jobs" queue ──▶ src/worker/index.ts
```

## Layout

```
backend/
├── src/
│   ├── app/
│   │   ├── api/
│   │   │   └── health/route.ts   # GET /api/health → { status, time }
│   │   ├── layout.tsx            # root layout (web only)
│   │   └── page.tsx              # placeholder home page (web only)
│   ├── lib/
│   │   └── prisma.ts             # shared PrismaClient (pg adapter, DATABASE_URL)
│   ├── worker/
│   │   └── index.ts              # BullMQ worker for the "jobs" queue (stub, logs jobs)
│   └── generated/prisma/         # Prisma client output — generated, gitignored
├── prisma/
│   ├── schema.prisma             # data model (docs/TRD.md §5)
│   └── migrations/               # SQL migrations, committed
├── prisma.config.ts              # Prisma CLI config: loads ../.env, migrates via DIRECT_URL
├── Dockerfile                    # stages: dev, api (standalone), worker — see docs/docker.md
├── .dockerignore
├── next.config.ts                # output: "standalone" for the Docker image
└── package.json
```

## Conventions

- **One folder per endpoint:** `src/app/api/<resource>/route.ts`. Export one function per HTTP method (`GET`, `POST`, ...).
- **Dynamic segments:** `src/app/api/<resource>/[id]/route.ts`.
- **JSON only:** return `Response.json(data, { status, headers })`.
- **CORS:** every route sends CORS headers and handles `OPTIONS`. The allowed origin comes from `CORS_ORIGIN` (default `*`). When a second route needs CORS, move the headers into a shared `src/lib/cors.ts`.
- **Shared logic** (DB clients, validation, auth helpers) goes in `src/lib/`. Route files stay thin.
- **Database access:** always `import { prisma } from "@/lib/prisma"`; never create another `PrismaClient`.
- **Schema changes:** edit `prisma/schema.prisma`, then `npx prisma migrate dev --name <change>`. Commit the new folder in `prisma/migrations/`.
- **Slow or scheduled work** (publishing, data sync, scoring, AI summaries) is enqueued to Redis and runs in `src/worker/`, not in a route.

## Scripts

| Command | Does |
|---|---|
| `npm run dev` | Next.js dev server on :3000 |
| `npm run worker` / `worker:dev` | run the worker (`tsx`, `watch` in dev) |
| `npm run db:migrate` | `prisma migrate dev` |
| `npm run db:generate` | regenerate `src/generated/prisma` (also runs on `postinstall`) |
| `npm run db:studio` | Prisma Studio |

## Config

All variables live in the repo-root `.env` (template: `.env.example`).

| Env var | Default | Purpose |
|---|---|---|
| `CORS_ORIGIN` | `*` | Allowed origin for API calls |
| `DATABASE_URL` | — | Supabase transaction pooler (:6543), used at runtime |
| `DIRECT_URL` | — | Supabase session pooler (:5432), used by migrations |
| `REDIS_URL` | `redis://localhost:6379` | BullMQ queue (Docker sets `redis://redis:6379`) |
| `NEXT_PUBLIC_SUPABASE_URL` / `_PUBLISHABLE_KEY` | — | Supabase project |

## Decided

- **Database / ORM:** Supabase Postgres + Prisma 7 (`prisma-client` generator, `@prisma/adapter-pg`)
- **Queue:** Redis + BullMQ (`ioredis` client)
- **Local run:** Docker Compose — see `docs/docker.md`

## Not yet decided

- Auth implementation (TRD recommends Supabase Auth; Next.js verifies the JWT)
- Request validation library (e.g. zod)
- Deployment target (TRD recommends Railway for API + worker)
