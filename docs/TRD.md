# TRD: Social Media Management Platform

| Field | Value |
|---|---|
| Author | Jaxz Tan |
| Status | Draft |
| Version | 1.3 |
| Last updated | 2026-10-20 |
| Related PRD | PRD.md (v1.2) |

### Changes in v1.3

- SME removed from scope: `brands.type` dropped; one brand = one creator profile. FR-16 now in scope (Could).

### Changes in v1.2

- TikTok removed from scope entirely. Facebook Page connection is now FR-4 in the PRD.

### Changes in v1.1

- Phase 1 platforms changed to **YouTube + Facebook + Instagram**.
- Facebook adapter added: publishes Reels and video to a **Facebook Page** via the Reels Publishing API.
- Instagram stays on **Instagram Login** (no Facebook Page needed for IG). Facebook uses **Facebook Login for Business** with a Page token. Both live in one Meta app.
- Build sequence and risks updated.

### Changes in v1.0 (kept)

- `users.persona` removed; `brands` kept as a 1:1 creator profile.
- Media pipeline specified for short vertical video.

## 1. Architecture overview

This TRD covers PRD FR-1 to FR-18; FR-19 is deferred. Monolith-first: one Next.js API plus one background worker, sharing one TypeScript codebase.

```mermaid
flowchart LR
    Flutter["Flutter app<br/>Android · iOS · Web"]
    API["Next.js API<br/>REST API · OAuth callbacks<br/>Creates scheduled jobs"]
    Redis["Redis<br/>BullMQ job queue"]
    Worker["Worker (Node.js)<br/>Scheduled publishing · retries<br/>Data sync every 6 hours<br/>Scoring · AI weekly summary"]
    Supabase["Supabase<br/>PostgreSQL · Auth · Storage"]
    FCM["FCM<br/>Publish-failure push"]
    Platforms["Platform APIs<br/>YouTube · Facebook · Instagram"]
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

> Demo option (not yet decided): replace BullMQ + worker with a cron that calls a Next.js endpoint every minute, and upgrade to a queue at launch.

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
| Media storage | Supabase Storage (recommended) | Instagram and Facebook can read media from a public HTTPS URL | AWS S3 |
| AI | Claude API (recommended) | Trilingual captions and weekly summaries | — |
| Push | Firebase Cloud Messaging (recommended) | Publish-failure alerts | — |
| Deployment | Railway: Next.js + worker (recommended) | Both run continuously; one platform | Fly.io |

## 3. Platform integration

Each platform: OAuth → publish → pull data periodically. All three require review before public use.

| Platform | APIs used | Review & limits | Demo handling |
|---|---|---|---|
| YouTube | Data API v3 `videos.insert` (upload) + YouTube Analytics API (data) | Uploads from unverified projects created after 28 July 2020 are locked to private until the Audit and Quota Extension passes ([YouTube API](https://developers.google.com/youtube/v3/docs/videos/insert)) | Private uploads to a test channel |
| Facebook | Graph API, Reels Publishing API (`/{page-id}/video_reels`, upload via `rupload.facebook.com`); Facebook Login for Business with a Page token; permission `pages_manage_posts` | Reels can only be published to Facebook Pages, not personal profiles; limit of 30 API-published Reels per Page per rolling 24 hours ([Meta](https://developers.facebook.com/docs/video-api/guides/reels-publishing)). `pages_manage_posts` needs Advanced Access ([bundle.social](https://bundle.social/blog/facebook-posting-api)) | Team test Page in development mode |
| Instagram | Instagram API with Instagram Login (`graph.instagram.com`); scopes `instagram_business_basic`, `instagram_business_content_publish`; Reels via `media_type=REELS` | No Facebook Page required; professional (Business / Creator) accounts only ([Meta](https://developers.facebook.com/docs/instagram-platform/instagram-api-with-instagram-login)); media insights available, Advanced Access needed for any app user ([Meta blog](https://developers.facebook.com/blog/post/2025/03/24/user-and-media-insights-on-instagram-api-with-instagram-login/)); 100 API posts per account per 24 hours ([Wireflow docs](https://www.wireflow.ai/docs/publishing-to-instagram.md)) | Team test accounts in development mode |

Design principle: each platform is an adapter implementing `connect`, `publish`, `fetchMetrics`, `refreshToken`, so a new platform can be added later without touching core logic.

Notes:

- Meta does not support `scheduled_publish_time` for Reels ([bundle.social](https://bundle.social/blog/facebook-posting-api)). This doesn't affect us: our worker holds the schedule and calls publish at the set time (TR-5).
- `[reasoning]` Facebook Reels metrics are read through Page / video insights; confirm which fields (views, reactions, comments, shares) are returned for Reels in Graph API Explorer before finalising TR-7. Missing fields follow the missing-metric rule in section 4.
- `[reasoning]` Instagram and Facebook use different login flows, so connecting both means two OAuth screens even though they share one Meta app.

## 4. Unified Content Score specification

Score = the post's weighted engagement rate, expressed as a percentile (0–100) among the same account's last 30 posts on the same platform.

1. Raw metrics: views, likes, comments, shares, saves. A metric a platform doesn't provide is missing, not 0, and its weight is removed from the denominator.
2. Weighted engagement rate:

   ```
   ER = (w_l·likes + w_c·comments + w_s·shares + w_v·saves) / views
        × (Σ w_all / Σ w_available)
   ```

3. Initial weights: likes 1, comments 2, shares 3, saves 3. For Facebook, reactions count as likes `[reasoning]`.
4. Same-age comparison: snapshots at 48 hours and 7 days after publishing; compare only against historical snapshots at the same point. Before the 48-hour snapshot, show a provisional score labelled "Collecting data".
5. Percentile: Score = percentile rank of ER within the baseline (same account, same platform, same snapshot point, last 30 posts).
6. Cold start: fewer than 5 posts in the baseline → "Collecting data" (FR-9).

All raw metrics and results are stored so scores can be recalculated when weights change.

## 5. Data model & API

| Entity | Key fields | Relations |
|---|---|---|
| users | id, email, language | A user has one brand (creator profile) |
| brands | id, user_id, name | A brand has many social_accounts |
| social_accounts | id, brand_id, platform (`youtube` / `facebook` / `instagram`), external_id (Page ID for Facebook), access_token (encrypted), refresh_token (encrypted), expires_at, status | Belongs to a brand |
| posts | id, brand_id, caption_base, media_url, media_duration_s, aspect_ratio, scheduled_at, created_at | A post has many post_targets |
| post_targets | id, post_id, social_account_id, caption_override, status, external_post_id, error, published_at | One row per platform |
| metric_snapshots | id, post_target_id, snapshot_type (48h / 7d / latest), views, likes, comments, shares, saves (nullable), fetched_at | Append-only |
| content_scores | id, post_target_id, snapshot_type, er, score, is_provisional, weights_version, computed_at | Recalculable |

Main API (all require a Supabase JWT):

| Method | Path | Purpose | Maps to FR |
|---|---|---|---|
| GET | /api/accounts/{platform}/connect | Start OAuth (`youtube` / `facebook` / `instagram`) | FR-2, FR-3, FR-4 |
| GET | /api/accounts/{platform}/callback | OAuth callback; store token encrypted; for Facebook, user picks which Page to connect | FR-2, FR-3, FR-4 |
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
| TR-2 | Adapters for YouTube, Facebook (Page, Reels API) and Instagram (Instagram Login) implementing connect / publish / fetchMetrics / refreshToken | FR-2, FR-3, FR-4 | |
| TR-3 | Worker refreshes tokens near expiry; on failure marks the account as needing reconnection | FR-2, FR-3, FR-4 | |
| TR-4 | Video uploaded to Supabase Storage first; validated as MP4 / MOV and vertical; Instagram reads it from a public HTTPS URL, Facebook via the Reels upload session, YouTube via resumable upload | FR-5, NFR-8 | |
| TR-5 | Creating a post creates one delayed job per target platform | FR-6, NFR-2 | Needed because Meta has no scheduled publish for Reels |
| TR-6 | Failed publishes retry 3 times with exponential backoff; then write the error and push via FCM | FR-7, NFR-2 | |
| TR-7 | Metrics sync every 6 hours plus snapshots at 48 hours and 7 days | FR-8 | Respect platform rate limits |
| TR-8 | After each snapshot, compute ER and percentile; mark provisional scores before 48h | FR-9 | Section 4 |
| TR-9 | Dashboard API aggregates across the three platforms; cached in Redis for 10 minutes | FR-10, NFR-1 | |
| TR-10 | Single-video API returns raw metrics, weights and breakdown | FR-11 | |
| TR-11 | Monday job aggregates data and calls the Claude API for a summary in the user's language | FR-12 | Demo can use pre-generated output |
| TR-12 | Caption API calls the Claude API for trilingual captions and hashtags | FR-13 | |
| TR-13 | Flutter intl / ARB files for BM, Chinese, English | FR-15, NFR-6 | |
| TR-13a | Festival templates stored as static JSON (name, date, suggested caption); "add to schedule" creates a draft post | FR-16 | Could |
| TR-14 | Media Kit: public read-only page with followers per platform and average Content Score; revocable link | FR-17 | |
| TR-15 | Subscription billing via a local payment gateway | FR-18 | Choose before launch |
| TR-16 | Tokens encrypted with AES-256-GCM; key in environment variables only | NFR-3 | |
| TR-17 | "Delete account" API removes all data and revokes platform authorisations | NFR-4 | |

## 7. Security, compliance & risks

- Auth: every API requires a Supabase JWT and checks resource ownership.
- Secrets: platform app secrets, encryption key and Claude API key only in server environment variables.
- Input validation: Zod on all requests; uploads restricted by type and size.
- Rate limiting: Redis counters for AI and publish requests per user; respect the 30 Reels / Page / 24h Facebook limit.
- Data retention: store only data needed for publishing and analytics; full deletion on account delete (TR-17).
- Media Kit links expose only aggregate stats the creator chooses to share.

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Meta App Review (Facebook + Instagram) or YouTube audit delayed | Medium | High | Submit both this week; demo in development mode with team accounts |
| Creators without a Facebook Page can't use Facebook publishing | High | Medium | `[reasoning]` Check Page ownership in user tests; demo uses a team test Page |
| Facebook Reels metrics differ from IG / YouTube | Medium | Medium | Missing-metric rule (section 4); verify fields before TR-7 |
| Platform API rules or quotas change | Medium | High | Adapters isolate logic; monitor error rates |
| Scheduled jobs missed | Low | High | Persistence + retries + failure push |
| Token leak | Low | High | Encryption (TR-16), key rotation |

### Build sequence

Critical path: platform reviews submitted → account connection → data pull → scoring. Flutter UI runs in parallel with mock data.

0. Submit Meta App Review (Facebook + Instagram) and YouTube audit (S, this week)
1. Supabase project, Prisma schema, Next.js skeleton, auth (S)
2. Instagram adapter (Instagram Login): OAuth + data pull (M)
3. Facebook adapter (Page token, Reels API): OAuth + Page picker + data pull (M)
4. YouTube adapter: OAuth + data pull (M)
5. Content Score calculation + dashboard API (M)
6. Flutter: login, account connection, dashboard (M, parallel with 2–5)
7. Publishing & scheduling: worker + IG Reels / Facebook Reels / YouTube Shorts (M)
8. AI captions and weekly summary (S)
9. Pre-demo smoke test: connect three accounts, schedule one vertical video to three platforms, see scores on past videos, see a failure alert
