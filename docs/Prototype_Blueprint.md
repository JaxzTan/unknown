# Prototype Blueprint: Social Media Management Platform

| Field | Value |
|---|---|
| Team lead | Jaxz Tan |
| Version | 1.2 |
| Model | One product, one user type: small content creators |
| Market | Malaysia first, then wider Asia |
| Related docs | PRD.md (v1.2), TRD.md (v1.3) |
| Last updated | 2026-10-20 |

---

## Page 1: User, Problem, Proof, Outcome

### Who is my user?

| Persona | Who exactly | Platforms they run |
|---|---|---|
| Small creator | A Malaysian creator with roughly 10k–50k followers (e.g. a food YouTuber) who cuts each long video into a short vertical clip for Shorts / Reels | YouTube + Instagram + Facebook Page |

> **Out of scope:** freelancers managing several clients (need multi-client features, PRD FR-19, on the roadmap).

### What is their problem?

1. **The same clip is uploaded three times.** After cutting one vertical video, they upload it separately to YouTube Shorts, Instagram Reels and Facebook Reels, rewrite the title and hashtags in each app, and track posting times by memory.
2. **Analytics are in three places.** To see results, they open YouTube Studio, Instagram's professional dashboard and Meta Business Suite one by one.
3. **No common measure of performance.** Each platform counts and grades "performance" differently, so they can't tell which video worked best, or on which platform.
4. **Existing tools don't fit their budget.** Sprout Social (USD 199–249/month) and Hootsuite (USD 99–149/month) are priced and designed for teams, not a solo creator.

### What difficulty does this cause?

| Problem | Difficulty for the creator |
|---|---|
| Repeated uploading | Hours lost every week; clips go out late or get skipped on one platform, missing the traffic window |
| Scattered analytics | Checking results is a chore, so most creators only watch their main platform |
| No common measure | They can't answer: *which content works, what should I make next, and which platform should I focus on?* |
| Expensive tools | They're stuck with free, single-platform tools, so the first three problems never get solved |

### What must the prototype prove?

- **Q1:** Can a creator publish one short video to YouTube Shorts, Instagram Reels and Facebook Reels in **under 5 minutes**, from one screen?
- **Q2:** After connecting their accounts, can a creator point to their **best-performing video across all three platforms** using one Content Score, without opening any platform's own analytics?

### Outcome (what to achieve)

- The creator uses one session instead of three apps to publish.
- The creator sees a 0–100 Content Score on every video and can name their top video in one sentence.
- Target from the PRD: 80% of test users see their first Content Score in their first session.
- Every test also records the monthly RM price the creator says they would pay, and whether they own a Facebook Page.

### Goal of the prototype

> **In one test session, a creator can** connect their YouTube, Instagram and Facebook Page, publish one short video to all three in under 5 minutes, and see on one dashboard which of their videos performed best, using a single 0–100 Content Score.

### Check before moving on

- [x] **User is a specific group.** Malaysian creators with roughly 10k–50k followers running YouTube + Instagram + a Facebook Page.
- [x] **Problem describes a struggle, not a solution.** "Uploading the same clip three times" and "can't tell which video works on which platform" are struggles; the Content Score is our answer.
- [x] **Q1 and Q2 can be seen in a test.** A tester times the publish (Q1) and asks "which video did best?" while the creator looks at the dashboard (Q2).

---

## Page 2: Core Functions

### Feature list

| Feature | Must have / Nice to have | Why | If removed, can the user still reach the goal? |
|---|---|---|---|
| Sign up / log in (FR-1) | Must | Holds the creator profile and connected accounts | No, nowhere to store accounts or posts |
| Connect Instagram + YouTube (FR-2, FR-3) | Must | Every other feature depends on platform access; Instagram connects without a Facebook Page | No, nothing can be published or measured |
| Connect Facebook Page (FR-4) | Must | Third platform in Q1; Reels can only be published to Pages | No, Q1's "three platforms" breaks |
| Upload once, post to many (FR-5) | Must | The "save time" half of the goal | No, back to uploading app by app |
| Schedule on a calendar (FR-6) | Must | Creators time posts to each platform's peak hours | Partly: they could post now, but the real workflow is scheduling |
| Publish status (FR-7) | Must | Creators must trust the video actually went out | No, they'd have to open each app to check |
| Automatic data pull (FR-8) | Must | The score needs raw numbers | No, nothing to score |
| Unified Content Score 0–100 (FR-9) | Must | The "understand performance" half of the goal | No, back to comparing incompatible numbers |
| Unified dashboard (FR-10) | Must | Compares all three platforms' videos in one place | No, scores alone don't answer "what works?" |
| Media Kit link (FR-17) | Nice to have (top priority, Should in PRD) | Direct tool for brand deals and creator income | Yes |
| Single-video score breakdown (FR-11) | Nice to have | Builds trust in the score | Yes |
| AI trilingual captions + hashtags (FR-13) | Nice to have | Saves writing time; local differentiator | Yes |
| AI weekly summary (FR-12) | Nice to have | Turns the score into "what to make next" | Yes |
| BM / Chinese / English UI (FR-15) | Nice to have | Demo works in English (+ Chinese) | Yes |
| Best time to post (FR-14) | Nice to have | Needs 20+ past posts | Yes |
| Paid plan in RM (FR-18) | Nice to have (launch only) | Needed for business, not for proving value | Yes |
| Festival calendar templates (FR-16) | Nice to have | Raya / CNY / Deepavali content ideas for creators | Yes |

### My 5 core features (without these, the prototype can't work)

1. **Account connection** — connect YouTube, Instagram and a Facebook Page in one place.
2. **Post once, publish to three** — upload one vertical video, write one caption, pick platforms, schedule, and see each platform's publish status.
3. **Automatic data pull** — fetch views, likes, comments, shares and saves (where provided) for every video.
4. **Unified Content Score** — turn each platform's numbers into one comparable 0–100 score.
5. **Unified dashboard** — all scores, the 30-day trend and the top 3 videos on one page.

> Test: remove any one of these five and the goal sentence on page 1 breaks. Remove anything else and it still holds.

---

## Page 3: Part A — The User Journey

From the moment the creator opens the app to the moment they know which video performed best.

| Step | What the user does | What the user sees | Feature |
|---|---|---|---|
| 1 | Opens the app and signs up with email or Google | Sign-up screen, then a short PDPA consent note | Sign up / log in |
| 2 | Picks a language | Language selector (no role selection) | Sign up / log in |
| 3 | Taps "Connect" for YouTube, Instagram and Facebook, approves each login, and picks which Facebook Page to use | Each platform's login page, a Page picker for Facebook, then a green "Connected" tick beside each account | Account connection |
| 4 | Waits a moment after connecting | "Pulling your last 30 videos…" progress message | Automatic data pull |
| 5 | Lands on the dashboard | Every past video with a 0–100 Content Score, a 30-day trend line, and the top 3 highlighted ("aha" moment; **Q2 is tested here**) | Content Score + dashboard |
| 6 | Taps "Create post" and uploads one vertical video (MP4 / MOV) | Video preview and one caption box | Post once, publish to three |
| 7 | Writes the caption and adjusts it per platform if needed | Platform tabs (YouTube Shorts / IG Reels / Facebook Reels) with editable caption and hashtags under each | Post once, publish to three |
| 8 | Selects the three platforms and picks a date and time | The video appears on a weekly calendar as "Scheduled" | Scheduling |
| 9 | Waits for the scheduled time (or taps "Post now") | Status changes to "Published" on each platform; if one fails, a push alert with the reason (**Q1 timer stops here**) | Publish status |
| 10 | Returns later in the day | The new video's numbers updating, with a provisional score marked "Collecting data" | Automatic data pull |
| 11 | Opens the dashboard after 48 hours | The new video's stable Content Score, ranked against older videos across all three platforms; the creator names their best video (**goal reached**) | Content Score + dashboard |

> Notes for the demo:
> - Scores need at least 5 past posts per platform, and new posts need about 48 hours before their score is stable. Use team test accounts that already have post history, so step 5 shows real scores. Step 11 only shows a provisional score on demo day.
> - **YouTube:** uploads from an unverified project are locked to private ([YouTube API](https://developers.google.com/youtube/v3/docs/videos/insert)).
> - **Instagram:** the account must be a Business or Creator account; no Facebook Page needed ([Meta](https://developers.facebook.com/docs/instagram-platform/instagram-api-with-instagram-login)).
> - **Facebook:** Reels can only be published to a Page, not a personal profile, with at most 30 API-published Reels per Page per 24 hours ([Meta](https://developers.facebook.com/docs/video-api/guides/reels-publishing)). The team needs a test Page with post history.
> - Submit Meta App Review and the YouTube audit this week (PRD milestone M0).
