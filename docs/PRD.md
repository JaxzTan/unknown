# PRD: Social Media Management Platform

| Field | Value |
|---|---|
| Author | Jaxz Tan |
| Status | Draft |
| Version | 1.2 |
| Last updated | 2026-10-20 |
| Related docs | TRD.md (v1.3), Prototype_Blueprint.md (v1.2) |

This PRD serves two purposes: the LaunchX demo / pitch, and a later production launch. Items marked "Demo" apply only to the demo; everything else is a launch requirement.

### Changes in v1.2

- **Content creators are the only target user.** SME owners are removed from scope (no longer a Phase 2).
- FR-16 festival templates kept as Could, for creators' festive content.

### Changes in v1.1

- **Platforms are YouTube + Instagram + Facebook.** TikTok is removed from the product scope.
- **FR-4 is now "Connect Facebook Page"** (was TikTok).
- Facebook publishing requires a Facebook Page; Instagram connects via Instagram Login with no Page needed.

### Changes in v1.0 (kept)

- Targets content creators only; freelancers / agencies stay on the roadmap.
- Media Kit (FR-17) upgraded from Could to Should.
- Role selection removed from onboarding.

## 1. Problem statement

Malaysian content creators with roughly 10k–50k followers usually cut each long video into a short vertical clip and post it to YouTube Shorts, Instagram Reels and Facebook Reels. Every clip is uploaded three times, with the title and hashtags rewritten in each app, and posting times tracked from memory. To check results, they open YouTube Studio, Instagram's professional dashboard and Meta Business Suite separately. Each platform measures "performance" differently, so creators can't answer the basic questions: which content works, what to make next, and which platform to focus on. Enterprise tools such as Sprout Social and Hootsuite are priced for teams, and cheaper tools show each platform's numbers separately, with no local-language support.

## 2. Goals & success metrics

| Goal | Metric | Target |
|---|---|---|
| Save time: publish once to three platforms | Time to publish one short video to YouTube Shorts, IG Reels and Facebook Reels | Under 5 minutes (vs uploading manually one by one) |
| Easy to understand: one unified score | Share of new users who see their first Content Score after first login | 80% within the first session |
| Actionable: AI suggestions get used | Share of active users who schedule at least 1 video per week based on a suggestion | 30% |
| Retention | Share of users still active weekly 30 days after sign-up | 40% |
| Willingness to pay | Share of test users who state a monthly RM price they would pay | Collected in every user test; target set after first 10 interviews |

> ⚠️ Assumption: targets are a first draft and will be adjusted with real data after beta testing.

## 3. Target users

### Phase 1 (this version)

| Persona | Context | Trigger moment | Biggest need |
|---|---|---|---|
| Small creator (e.g. a local food YouTuber with 10k–50k followers) | Main channel on YouTube; cuts each video into Shorts / Reels; runs an Instagram professional account and a Facebook Page; works alone from a phone or laptop | A new long video goes live and the short clip needs to go out on three platforms | Publish one clip to three platforms in one go; know which content and which platform perform best |

> ⚠️ Assumption: creators have, or are willing to switch to, an Instagram Business or Creator account. Instagram Login works without a Facebook Page, but the account must be professional ([Meta](https://developers.facebook.com/docs/instagram-platform/instagram-api-with-instagram-login)).

> ⚠️ Assumption: creators have a Facebook Page. Reels can only be published to Pages, not personal profiles ([Meta](https://developers.facebook.com/docs/video-api/guides/reels-publishing)). `[reasoning]` Many small creators only have a personal profile, so the user test should check how many have a Page.

> ⚠️ Assumption `[reasoning]`: creators are the largest group by number of potential users. Their willingness to pay is unverified; the willingness-to-pay metric in section 2 tests this.

### Out of scope

| Persona | Status | Why |
|---|---|---|
| Freelancer / agency managing multiple clients | Roadmap | Needs multi-client features (FR-19) |

## 4. User stories & functional requirements

Priority uses MoSCoW: Must, Should, Could, Won't (not in this phase).

| ID | Module | User story | Priority | Acceptance criteria |
|---|---|---|---|---|
| FR-1 | Account | As a creator, I want to sign up and log in with email or Google | Must | Can sign up, log in, log out; one account = one creator profile in Phase 1 |
| FR-2 | Account | As a creator, I want to connect my Instagram professional account | Must | Connects via Instagram Login (no Facebook Page needed); prompt to reconnect when the token expires |
| FR-3 | Account | As a creator, I want to connect my YouTube channel | Must | Same as FR-2 |
| FR-4 | Account | As a creator, I want to connect my Facebook Page | Must | Connects via Facebook Login; user picks which Page to connect; prompt to reconnect when the token expires |
| FR-5 | Publishing | As a creator, I want to upload one short vertical video and write one caption, then post it to several platforms | Must | One submission targets 1–3 platforms (YouTube Shorts, IG Reels, Facebook Reels); caption and hashtags editable per platform |
| FR-6 | Publishing | As a creator, I want to schedule publish times on a calendar | Must | Weekly / monthly calendar; posts publish within 5 minutes of the set time |
| FR-7 | Publishing | As a creator, I want to know whether each video was published | Must | Each platform shows "Scheduled / Published / Failed"; on failure, reason shown and push notification sent |
| FR-8 | Analytics | As a creator, I want the system to pull raw data for each video automatically | Must | Views, likes, comments, shares, saves (where the platform provides them) updated at least every 6 hours |
| FR-9 | Analytics | As a creator, I want every video to have a 0–100 Content Score | Must | Score calculated with the TRD formula; "Collecting data" shown when the account has fewer than 5 past posts on that platform; new posts show a provisional score until the 48-hour snapshot |
| FR-10 | Analytics | As a creator, I want one dashboard showing scores and trends across all three platforms | Must | One page shows scores per platform, the last-30-day trend, and the top 3 videos |
| FR-11 | Analytics | As a creator, I want to drill into a single video to see the raw numbers | Should | Shows raw metrics and the score breakdown |
| FR-12 | AI | As a creator, I want a weekly plain-language summary with suggestions | Should | Generated every Monday in BM / Chinese / English; cites specific videos and numbers |
| FR-13 | AI | As a creator, I want AI to write trilingual captions and hashtags | Should | One-line description in, captions in three languages out, editable before use |
| FR-14 | AI | As a creator, I want to know the best time to post | Could | With 20+ past posts, suggests time slots per platform |
| FR-15 | Localisation | As a creator, I want a BM / Chinese / English interface | Should | All UI text switchable between the three languages |
| FR-16 | Localisation | As a creator, I want festival content calendar templates (Raya, CNY, Deepavali) | Could | Built-in templates addable to the schedule in one tap |
| FR-17 | Creator | As a creator, I want to generate a Media Kit link for brands in one tap | Should | Public link showing followers per platform and average Content Score |
| FR-18 | Billing | As a creator, I want to subscribe to a paid plan in RM | Should | Required for launch; not in the demo |
| FR-19 | Future | WhatsApp integration, agency multi-client mode, brand–creator matching, long-to-short video repurposing | Won't | Roadmap |

### Main flow (happy path)

1. Creator signs up and picks an interface language.
2. Connects YouTube, Instagram and a Facebook Page; the system pulls data for the last 30 posts on each.
3. The dashboard shows a Content Score for each past video and highlights the top 3 (the "aha" moment).
4. Creator creates a post: uploads one vertical video, writes one caption (or generates trilingual captions with AI), adjusts per platform, picks platforms and a time.
5. The system publishes on time, shows status per platform, and keeps updating data and scores.
6. After 48 hours, the new video has a stable score ranked against older videos across all three platforms.
7. Every Monday, the creator receives a plain-language summary and suggestions for next week.

## 5. Non-functional requirements

| ID | Category | Requirement | Rationale |
|---|---|---|---|
| NFR-1 | Performance | Dashboard loads within 3 seconds on 4G | Creators check results on mobile |
| NFR-2 | Reliability | Scheduled publish success rate ≥ 99% (excluding platform outages); failures retried automatically 3 times | A missed post loses the traffic window |
| NFR-3 | Security | Platform OAuth tokens stored encrypted and never sent to the client | A token equals control of the creator's account |
| NFR-4 | Privacy / compliance | Comply with Malaysia's PDPA: consent at sign-up, explain what data is collected and why, allow full account and data deletion | We store personal and social-account data |
| NFR-5 | Platform policy | Follow YouTube and Meta developer terms; request only needed permissions | Violations can revoke API access |
| NFR-6 | Localisation | UI, notifications and AI output support BM / Chinese / English | Core differentiator |
| NFR-7 | Platforms | One Flutter codebase supports Android, iOS and Web | Maintenance cost for a small team |
| NFR-8 | Media | Accept vertical MP4 / MOV short videos | Instagram Reels only accept MP4 or MOV ([Wireflow docs](https://www.wireflow.ai/docs/publishing-to-instagram.md)) |

> ⚠️ Assumption: specific PDPA obligations must be confirmed with someone who knows the regulation before launch. This document is not legal advice.

## 6. Demo scope

The demo proves one thing: a creator publishes one short video to three platforms and sees which video performed best through one unified score.

| Treatment | Items |
|---|---|
| Build for real | FR-1 to FR-10, using team test accounts (YouTube channel, IG professional account, Facebook Page) with existing post history |
| Fake / simplify | AI weekly summary (FR-12) can use pre-generated output; trilingual UI (FR-15) at least Chinese + English |
| Not in demo | Paid subscription (FR-18), Media Kit (FR-17), everything in FR-19 |

Platform constraints:

- **YouTube:** videos uploaded by unverified projects are locked to private ([YouTube API](https://developers.google.com/youtube/v3/docs/videos/insert)).
- **Instagram:** only professional accounts can publish through the API ([Meta](https://developers.facebook.com/docs/instagram-platform/instagram-api-with-instagram-login)).
- **Facebook:** Reels can only be published to Pages, with a limit of 30 API-published Reels per Page per rolling 24 hours ([Meta](https://developers.facebook.com/docs/video-api/guides/reels-publishing)).

Before review passes, the demo runs in development mode on team-controlled accounts. Q2 is tested on past videos (dashboard step), which needs no publishing permission.

## 7. Assumptions & open questions

Assumptions (the plan changes if any are false):

- Creators are willing to authorise us to connect their YouTube, Instagram and Facebook accounts.
- Creators have a Facebook Page (see section 3).
- The raw data from each platform API is enough to calculate the Content Score.
- Meta App Review and the YouTube audit can be passed before launch.

Open questions:

- [ ] Meta App Review submission (Facebook + Instagram): owner and date (owner: TBD, submit this week)
- [ ] YouTube Audit and Quota Extension submission (owner: TBD)
- [ ] Final Content Score weights (owner: TBD)
- [ ] Phase 1 pricing in RM, informed by user-test answers (owner: TBD)
- [ ] Demo date (owner: TBD)
- [ ] Team roles: Flutter, Next.js, design (owner: Jaxz)

## 8. Milestones

| Milestone | Scope | Target date |
|---|---|---|
| M0: Platform reviews submitted | Meta App Review, YouTube audit | This week |
| M1: Account connection + data pull | FR-1, FR-2, FR-3, FR-4, FR-8 | TBD |
| M2: Content Score + dashboard | FR-9, FR-10, FR-11 | TBD |
| M3: Publishing & scheduling (demo version) | FR-5, FR-6, FR-7 | Before demo |
| M4: AI, localisation & Media Kit | FR-12, FR-13, FR-15, FR-16, FR-17 | After demo |
| M5: Launch readiness | FR-18, platform reviews passed, PDPA compliance | TBD |

## Sources

Platform constraints from web search on 19–20 October 2026.

- [Instagram API with Instagram Login — Meta for Developers](https://developers.facebook.com/docs/instagram-platform/instagram-api-with-instagram-login)
- [Content Publishing — Meta for Developers](https://developers.facebook.com/docs/instagram-platform/content-publishing)
- [Reels Publishing API — Meta for Developers](https://developers.facebook.com/docs/video-api/guides/reels-publishing)
- [Videos: insert — YouTube Data API](https://developers.google.com/youtube/v3/docs/videos/insert)
- [Publishing to Instagram — Wireflow docs](https://www.wireflow.ai/docs/publishing-to-instagram.md)
