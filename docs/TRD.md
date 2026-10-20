# TRD: Social Media Management Platform

| Field | Value |
|---|---|
| Author | Jaxz Tan |
| Status | Draft |
| Version | 1.0 |
| Last updated | 2026-10-20 |
| Related PRD | PRD.md (v1.0) |

### Changes from v0.1

- Phase 1 platforms: **YouTube + Instagram + TikTok**. The Facebook adapter is deferred to Phase 2.
- Instagram switches from **Facebook Login (Graph API via a Page)** to **Instagram Login** (`graph.instagram.com`), so no Facebook Page is needed.
- TikTok adapter is now on the critical path (FR-4 is Must); build sequence updated.
- `users.persona` removed from Phase 1 logic; `brands` kept as a 1:1 creator profile so Phase 2 (SME, multi-brand) needs no migration.
- Media pipeline specified for short vertical video.

## 1. Architecture overview

This TRD covers PRD v1.0 FR-1 to FR-18 for Phase 1 (FR-16 and FR-19 deferred). Monolith-first: one Next.js API plus one background worker, sharing one TypeScript codebase.

```mermaid
flowchart LR
    Flutter["Flutter app<br/>Android · iOS · Web"]
    API["Next.js API<br/>REST API · OAuth callbacks<br/>Creates scheduled jobs"]
    Redis["Redis<br/>BullMQ job queue"]
    Worker["Worker (Node.js)<br/>Scheduled publishing · retries<br/>Data sync every 6 hours<br/>Scoring · AI weekly summary"]
    Supabase["Supabase<br/>PostgreSQL · Auth · Storage"]
    FCM["FCM<br/>Publish-failure push"]
    Platforms["Platform APIs<br/>YouTube · Instagram · TikTok"]
    Claude["Claude API<br/>Trilingual captions · weekly summary"]

    Flutter -- "REST + JWT" --> API
    Flutter -- "Login (Supabase Auth)" --> Supabase
    API -- "Read / write" --> Supabase
    API -- "Enqueue job" --> Redis
    Redis -- "Run on time" --> Worker
    Worker -- "Write" --> Supabase
    Worker -- "On failure" --> FCM
    FCM -- "Push" --> Flutter
    Worker -- "Publish · pull data" --> Platforms
    Worker -- "Generate" --> Claude
```

Flutter only calls the Next.js API; publishing, data sync, scoring and the AI weekly summary go through the Redis queue to the worker.

> Demo option (from earlier discussion, not yet decided): replace BullMQ + worker with a cron that calls a Next.js endpoint every minute, and upgrade to a queue at launch.

## 2. Tech stack & rationale

Flutter and Next.js are team decisions; other layers are recommendations.

| Layer | Choice | Why | Alternative |
|---|---|---|---|
| Frontend | Flutter (Android / iOS / Web) | Team decision; one codebase, three platforms | — |
| Backend API | Next.js Route Handlers (TypeScript) | Team decision; REST JSON API for Flutter | — |
| Background jobs | Node.js worker + BullMQ (recommended) | Scheduled publishing, retries, data sync; shares TypeScript code | Cron (demo), Upstash QStash |
| Queue / cache | Redis (recommended) | Required by BullMQ; rate-limit counters | — |
| Database | PostgreSQL (Supabase) + Prisma (recommended) | Relational data; TypeScript type safety | Neon |
| Auth | Supabase Auth (recommended) | Official Flutter SDK; Next.js only verifies the JWT | Firebase Auth |
| Media storage | Supabase Storage (recommended) | Instagram and TikTok can pull media from a public HTTPS URL | AWS S3 |
| AI | Claude API (recommended) | Trilingual captions and weekly summaries | — |
| Push | Firebase Cloud Messaging (recommended) | Publish-failure alerts | — |
| Deployment | Railway: Next.js + worker (recommended) | Both run continuously; one platform | Fly.io |

## 3. Platform integration

Each platform: OAuth → publish → pull data periodically. All three require review before public publishing.

| Platform | APIs used | Review & limits | Demo handling |
|---|---|---|---|
| Instagram | Instagram API with Instagram Login (`graph.instagram.com`); scopes `instagram_business_basic`, `instagram_business_content_publish`; Reels via `media_type=REELS` | No Facebook Page required, professional (Business / Creator) accounts only ([Meta](https://developers.facebook.com/docs/instagram-platform/instagram-api-with-instagram-login)); media insights available on this API, Advanced Access needed for any app user ([Meta blog](https://developers.facebook.com/blog/post/2025/03/24/user-and-media-insights-on-instagram-api-with-instagram-login/)); 100 API posts per account per 24 hours ([Wireflow docs](https://www.wireflow.ai/docs/publishing-to-instagram.md)) | Team test accounts in development mode |
| YouTube | Data API v3 `videos.insert` (upload) + YouTube Analytics API (data) | Uploads from unverified projects created after 28 July 2020 are locked to private until the Audit and Quota Extension passes ([YouTube API](https://developers.google.com/youtube/v3/docs/videos/insert)) | Private uploads to a test channel |
| TikTok | Content Posting API (Direct Post) for publishing; Display API (`video.list`) for metrics | Unaudited: content private only, private accounts only, max 5 posting users per 24 hours ([TikTok](https://developers.tiktok.com/doc/content-posting-api-reference-direct-post), [guidelines](https://developers.tiktok.com/doc/content-sharing-guidelines)). Media pulled from a public HTTPS URL ([Postiz docs](https://docs.postiz.com/providers/tiktok.md)). Video list returns `view_count`, `like_count`, `comment_count`, `share_count` for the user's **public** videos ([TikTok](https://developers.tiktok.com/doc/tiktok-api-v1-video-list/)) | Private test account |

Design principle: each platform is an adapter implementing `connect`, `publish`, `fetchMetrics`, `refreshToken`, so the Facebook adapter can be added in Phase 2 without touching core logic.

> ⚠️ `[reasoning]` TikTok data gap: demo posts must be private, but `video.list` returns public videos. Newly published TikTok demo videos may have no metrics until audit. Mitigation: score TikTok from past public videos on a read-only account; verify the behaviour in the sandbox before demo day.

> ⚠️ `[reasoning]` TikTok's Display API fields above don't include saves, so TikTok scores use the missing-metric rule in section 4.

## 4. Unified Content Score specification

Unchanged from v0.1. Score = the post's weighted engagement rate, expressed as a percentile (0–100) among the same account's last 30 posts on the same platform.

1. Raw metrics: views, likes, comments, shares, saves. A metric a platform doesn't provide is missing, not 0, and its weight is removed from the denominator.
2. Weighted engagement rate:

   ```
   ER = (w_l·likes + w_c·comments + w_s·shares + w_v·saves) / views
        × (Σ w_all / Σ w_available)
   ```

3. Initial weights: likes 1, comments 2, shares 3, saves 3.
4. Same-age comparison: snapshots at 48 hours and 7 days after publishing; compare only against historical snapshots at the same point. Before the 48-hour snapshot, show a provisional score labelled "Collecting data".
5. Percentile: Score = percentile rank of ER within the baseline (same account, same platform, same snapshot point, last 30 posts).
6. Cold start: fewer than 5 posts in the baseline → "Collecting data" (FR-9).

All raw metrics and results are stored so scores can be recalculated when weights change.

## 5. Data model & API

| Entity | Key fields | Relations |
|---|---|---|
| users | id, email, language | A user has one brand in Phase 1 (many in Phase 2) |
| brands | id, user_id, name, type (`creator` default; `sme` in Phase 2) | A brand has many social_accounts |
| social_accounts | id, brand_id, platform (`youtube` / `instagram` / `tiktok`), external_id, access_token (encrypted), refresh_token (encrypted), expires_at, status, is_private | Belongs to a brand |
| posts | id, brand_id, caption_base, media_url, media_duration_s, aspect_ratio, scheduled_at, created_at | A post has many post_targets |
| post_targets | id, post_id, social_account_id, caption_override, status, external_post_id, error, published_at | One row per platform |
| metric_snapshots | id, post_target_id, snapshot_type (48h / 7d / latest), views, likes, comments, shares, saves (nullable), fetched_at | Append-only |
| content_scores | id, post_target_id, snapshot_type, er, score, is_provisional, weights_version, computed_at | Recalculable |

Main API (all require a Supabase JWT):

| Method | Path | Purpose | Maps to FR |
|---|---|---|---|
| GET | /api/accounts/{platform}/connect | Start OAuth (`youtube` / `instagram` / `tiktok`) | FR-2, FR-3, FR-4 |
| GET | /api/accounts/{platform}/callback | OAuth callback; store token encrypted | FR-2, FR-3, FR-4 |
| POST | /api/media/upload-url | Signed upload URL for the video | FR-5 |
| POST | /api/posts | Create a post and schedule to multiple platforms | FR-5, FR-6 |
| GET | /api/posts?from=&to= | Calendar view | FR-6, FR-7 |
| GET | /api/dashboard | Scores per platform, trends, top 3 videos | FR-10 |
| GET | /api/posts/{id}/metrics | Single video raw data and score breakdown | FR-11 |
| POST | /api/ai/captions | Trilingual captions + hashtags | FR-13 |
| GET | /api/insights/weekly | Latest weekly summary | FR-12 |
| POST | /api/media-kit | Generate public Media Kit link | FR-17 |

## 6. Technical requirements

| ID | Technical requirement | Implements | Notes |
|---|---|---|---|
| TR-1 | Supabase Auth handles sign-up and login; Next.js middleware verifies the JWT | FR-1 | |
| TR-2 | Adapters for YouTube, Instagram (Instagram Login) and TikTok implementing connect / publish / fetchMetrics / refreshToken | FR-2, FR-3, FR-4 | TikTok connects to test accounts only in the demo |
| TR-3 | Worker refreshes tokens near expiry; on failure marks the account as needing reconnection | FR-2, FR-3, FR-4 | |
| TR-4 | Video uploaded to Supabase Storage first; validated as MP4 / MOV and vertical; passed to platforms as a public HTTPS URL (YouTube receives the file via resumable upload) | FR-5, NFR-8 | |
| TR-5 | Creating a post creates one delayed job per target platform | FR-6, NFR-2 | |
| TR-6 | Failed publishes retry 3 times with exponential backoff; then write the error and push via FCM | FR-7, NFR-2 | |
| TR-7 | Metrics sync every 6 hours plus snapshots at 48 hours and 7 days | FR-8 | Respect platform rate limits |
| TR-8 | After each snapshot, compute ER and percentile; mark provisional scores before 48h | FR-9 | Section 4 |
| TR-9 | Dashboard API aggregates across the three platforms; cached in Redis for 10 minutes | FR-10, NFR-1 | |
| TR-10 | Single-video API returns raw metrics, weights and breakdown | FR-11 | |
| TR-11 | Monday job aggregates data and calls the Claude API for a summary in the user's language | FR-12 | Demo can use pre-generated output |
| TR-12 | Caption API calls the Claude API for trilingual captions and hashtags | FR-13 | |
| TR-13 | Flutter intl / ARB files for BM, Chinese, English | FR-15, NFR-6 | |
| TR-14 | Media Kit: public read-only page with followers per platform and average Content Score; revocable link | FR-17 | |
| TR-15 | Subscription billing via a local payment gateway | FR-18 | Choose before launch |
| TR-16 | Tokens encrypted with AES-256-GCM; key in environment variables only | NFR-3 | |
| TR-17 | "Delete account" API removes all data and revokes platform authorisations | NFR-4 | |

## 7. Security, compliance & risks

- Auth: every API requires a Supabase JWT and checks resource ownership.
- Secrets: platform app secrets, encryption key and Claude API key only in server environment variables.
- Input validation: Zod on all requests; uploads restricted by type and size.
- Rate limiting: Redis counters for AI and publish requests per user.
- Data retention: store only data needed for publishing and analytics; full deletion on account delete (TR-17).
- Media Kit links expose only aggregate stats the creator chooses to share.

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| TikTok audit fails or is slow (now blocks a Must feature) | Medium | High | Submit this week (PRD M0); demo on private test account; launch YouTube + IG first if TikTok lags |
| TikTok demo posts produce no metrics (private) | Medium | Medium | Score TikTok from past public videos; verify in sandbox |
| YouTube or Meta review delays | Medium | High | Submit with TikTok in M0 |
| Platform API rules or quotas change | Medium | High | Adapters isolate logic; monitor error rates |
| Missing metrics per platform (e.g. TikTok saves) | High | Low | Missing-metric rule in section 4 |
| Scheduled jobs missed | Low | High | Persistence + retries + failure push |
| Token leak | Low | High | Encryption (TR-16), key rotation |

### Build sequence

Critical path: platform reviews submitted → account connection → data pull → scoring. Flutter UI runs in parallel with mock data.

0. Submit TikTok audit, YouTube audit, Meta App Review (S, this week)
1. Supabase project, Prisma schema, Next.js skeleton, auth (S)
2. Instagram adapter (Instagram Login): OAuth + data pull (M)
3. YouTube adapter: OAuth + data pull (M)
4. TikTok adapter: OAuth + `video.list` data pull (M)
5. Content Score calculation + dashboard API (M)
6. Flutter: login, account connection, dashboard (M, parallel with 2–5)
7. Publishing & scheduling: worker + Reels / Shorts / TikTok Direct Post (M)
8. AI captions and weekly summary (S)
9. Pre-demo smoke test: connect three accounts, schedule one vertical video to three platforms, see scores on past videos, see a failure alert
