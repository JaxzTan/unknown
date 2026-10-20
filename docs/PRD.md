# PRD: Social Media Management Platform

| Field | Value |
|---|---|
| Author | Jaxz Tan |
| Status | Draft |
| Version | 0.1 |
| Last updated | 2026-10-19 |
| Related TRD | TRD-launchx.md |

This PRD serves two purposes: the LaunchX demo / pitch, and a later real production launch. Items marked "Demo" apply only to the demo; everything else is a launch requirement.

## 1. Problem statement

Malaysian SME owners and creators usually run Facebook, Instagram, TikTok and YouTube at the same time. Every time they post, they re-upload and rewrite captions across several apps; to check results, they open Meta Business Suite, TikTok Studio and YouTube Studio separately. Each platform measures "performance" differently, so they cannot answer the most basic question: which content actually works, and what should they post next. Enterprise tools are too expensive, and cheap tools only show each platform's data separately, with no local-language or local-market support.

## 2. Goals & success metrics

| Goal | Metric | Target |
|---|---|---|
| Save time: publish once to many platforms | Time for a user to publish one piece of content to 3 platforms | Under 5 minutes (vs posting manually one by one) |
| Easy to understand: a unified performance score | Share of new users who see their first Content Score after first login | 80% within the first session |
| Actionable: AI suggestions get used | Share of active users who schedule at least 1 post per week based on a suggestion | 30% |
| Retention | Share of users still active weekly 30 days after sign-up | 40% |

> ⚠️ Assumption: these targets are a first draft and will be adjusted with real data after beta testing.

## 3. Target users

The MVP serves two user types. They share scheduling and the Content Score, but the home screen and suggestions emphasise different things.

| Persona | Context | Trigger moment | Biggest need |
|---|---|---|---|
| SME owner (e.g. a café owner in PJ) | No dedicated marketer; posts from their phone; runs FB + IG + TikTok | Launching a new menu and promoting it on three platforms at once | Publish everything in one go; understand in plain language which post brought in business |
| Creator / YouTuber (e.g. a local food YouTuber with 10k–50k followers) | Mainly on YouTube; also cuts content into Shorts / Reels / TikTok | A new video goes live and needs cross-platform traffic | Compare performance across platforms; know what content and timing work best |

> ⚠️ Assumption: both user types already have, or are willing to switch to, a Business / Creator account (the Instagram API only supports these two types).

## 4. User stories & functional requirements

Priority uses MoSCoW: Must, Should, Could, Won't (not in this version).

| ID | Module | User story | Priority | Acceptance criteria |
|---|---|---|---|---|
| FR-1 | Account | As a user, I want to sign up and log in with email or Google so I can manage my brand | Must | Can sign up, log in, log out; one account can create 1+ brands |
| FR-2 | Account | As a user, I want to connect my Facebook Page and Instagram account | Must | Connected accounts shown after OAuth; prompt to reconnect when the token expires |
| FR-3 | Account | As a user, I want to connect my YouTube channel | Must | Same as FR-2 |
| FR-4 | Account | As a user, I want to connect my TikTok account | Should | Demo: works end to end with a private test account; launch: opened after the TikTok audit passes |
| FR-5 | Publishing | As a user, I want to upload an image / video and write one caption once, then choose to post it to several platforms | Must | One submission can target 1–4 platforms; caption can be edited per platform |
| FR-6 | Publishing | As a user, I want to schedule publish times on a calendar | Must | Calendar shows weekly / monthly schedule; posts publish automatically within 5 minutes of the set time |
| FR-7 | Publishing | As a user, I want to know whether each post was published successfully | Must | Each platform shows "Scheduled / Published / Failed"; on failure, the reason is shown and a push notification is sent |
| FR-8 | Analytics | As a user, I want the system to pull raw data for each post automatically | Must | Views, likes, comments, shares, saves updated at least every 6 hours |
| FR-9 | Analytics | As a user, I want every post to have a 0–100 Content Score | Must | Score calculated with the TRD formula; "Collecting data" shown when the account has fewer than 5 past posts |
| FR-10 | Analytics | As a user, I want one dashboard showing scores and trends across all platforms | Must | One page shows post scores per platform, the last-30-day trend, and the top 3 posts |
| FR-11 | Analytics | As a user, I want to drill into a single post to see the raw numbers | Should | Shows raw metrics and the score calculation breakdown |
| FR-12 | AI | As a user, I want a weekly plain-language performance summary with suggestions | Should | Generated every Monday; user picks BM / Chinese / English; content cites specific posts and numbers |
| FR-13 | AI | As a user, I want AI to help write trilingual captions | Should | Input one sentence of description, output captions in three languages, editable before use |
| FR-14 | AI | As a user, I want to know the best time to post | Could | With 20+ past posts, suggests time slots per platform |
| FR-15 | Localisation | As a user, I want a BM / Chinese / English interface | Should | All UI text switchable between the three languages |
| FR-16 | Localisation | As a user, I want local festival content calendar templates | Could | Built-in Raya, CNY, Deepavali templates, addable to the schedule in one tap |
| FR-17 | Creator | As a creator, I want to generate a Media Kit link for brands in one tap | Could | Generates a public link showing followers per platform and average Content Score |
| FR-18 | Billing | As a user, I want to subscribe to a paid plan in RM | Should | Required for launch; not in the demo |
| FR-19 | Future | WhatsApp / TikTok Shop integration, agency multi-client mode, SME–creator matching marketplace, long-to-short video repurposing | Won't | On the roadmap |

### Main flow (happy path)

1. User signs up and chooses a role (SME or creator) and interface language.
2. Connects Facebook / Instagram / YouTube; the system pulls data for the last 30 posts automatically.
3. The dashboard immediately shows a Content Score for each post (this is the key "aha" moment).
4. User creates a post: uploads the media once, generates trilingual captions with AI, picks platforms and a time.
5. The system publishes on time and keeps updating data and scores afterwards.
6. Every Monday, the user receives a plain-language summary and suggestions for next week.

## 5. Non-functional requirements

| ID | Category | Requirement | Rationale |
|---|---|---|---|
| NFR-1 | Performance | Dashboard loads within 3 seconds on 4G | Main users are on mobile |
| NFR-2 | Reliability | Scheduled publish success rate ≥ 99% (excluding platform outages); failures retried automatically 3 times | A failed post directly hurts the owner's business |
| NFR-3 | Security | Platform OAuth tokens stored encrypted and never sent to the client | A token equals control of the user's social account |
| NFR-4 | Privacy / compliance | Comply with Malaysia's PDPA: get consent at sign-up, explain what data is collected and why, let users delete their account and all data | We store personal and social-account data; the team wants to minimise legal risk |
| NFR-5 | Platform policy | Follow Meta, TikTok and YouTube developer terms; request only the permissions needed | Violations can revoke API access and stop the product entirely |
| NFR-6 | Localisation | UI, notifications and AI output support BM / Chinese / English | Localisation is a core differentiator |
| NFR-7 | Platforms | One Flutter codebase supports Android, iOS and Web | Maintenance cost for a small team |

> ⚠️ Assumption: specific PDPA obligations need to be confirmed with someone who knows the regulation before launch. This document is not legal advice.

## 6. Demo scope

The demo only needs to prove one thing: publish once to many platforms, and understand performance through one unified score. Everything else can be faked or left out.

| Treatment | Items |
|---|---|
| Build for real | FR-1, FR-2, FR-3, FR-5, FR-6, FR-7, FR-8, FR-9, FR-10 (using the team's own test accounts) |
| Fake / simplify | TikTok (FR-4) with a private test account; AI weekly summary (FR-12) can use pre-generated output; trilingual UI (FR-15) at least Chinese + English |
| Not in demo | Paid subscription (FR-18), Media Kit (FR-17), festival templates (FR-16), everything in FR-19 |

Platform constraints: content posted by TikTok and YouTube apps that have not passed review is restricted to private visibility; Instagram only allows posting to Business / Creator accounts. So the demo must use team-controlled test accounts, and the pitch should explain the review plan.

## 7. Assumptions & open questions

Assumptions (the plan changes if any are false):

- Target users are willing to authorise us to connect their social accounts.
- The raw data from each platform API is enough to calculate the Content Score.
- Meta, TikTok and YouTube reviews can be passed before launch.

Open questions:

- [ ] Final Content Score weights (owner: TBD)
- [ ] Pricing plans and RM prices (owner: TBD)
- [ ] Demo date (owner: TBD)
- [ ] Team roles: who owns Flutter, Next.js and design (owner: Jaxz)

## 8. Milestones

| Milestone | Scope | Target date |
|---|---|---|
| M1: Account connection + data pull | FR-1, FR-2, FR-3, FR-8 | TBD |
| M2: Content Score + dashboard | FR-9, FR-10, FR-11 | TBD |
| M3: Publishing & scheduling (demo version) | FR-5, FR-6, FR-7, FR-4 (test account) | Before demo |
| M4: AI & localisation | FR-12, FR-13, FR-15 | After demo |
| M5: Launch readiness | FR-18, platform reviews, PDPA compliance | TBD |

## Sources

Platform constraints are from web search results on 19 October 2026; competitor analysis is in the team's "Feature and Differentiation Analysis" document.

- [Content Sharing Guidelines — TikTok for Developers](https://developers.tiktok.com/doc/content-sharing-guidelines)
- [Content Posting API: Direct Post — TikTok for Developers](https://developers.tiktok.com/doc/content-posting-api-reference-direct-post)
- [Content Publishing — Meta for Developers](https://developers.facebook.com/docs/instagram-platform/content-publishing)
- [Instagram Graph API production guide — bundle.social](https://bundle.social/blog/instagram-graph-api)
- [Videos: insert — YouTube Data API](https://developers.google.com/youtube/v3/docs/videos/insert)
