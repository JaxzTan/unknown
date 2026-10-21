// Platform adapter contract (TRD §3, TR-2).
// Every platform implements PlatformAdapter so API routes and the worker
// never call a platform API directly. Shared with the YouTube adapter (B6).

export type Platform = "youtube" | "facebook" | "instagram";

// One connectable account returned by the OAuth code exchange
export interface ConnectResult {
  externalId: string; // Instagram user ID, Facebook Page ID or YouTube channel ID
  displayName: string | null; // Instagram username, Page name or channel title
  accessToken: string; // plain text here; encrypt before saving (TR-16)
  refreshToken: string | null; // Instagram and Facebook have none
  expiresAt: Date | null; // null = no fixed expiry (Facebook Page token)
}

// null = the platform does not provide the metric. Never use 0 for missing (TRD §4)
export interface NormalisedMetrics {
  views: number | null;
  likes: number | null; // Facebook: sum of all reactions
  comments: number | null;
  shares: number | null;
  saves: number | null; // always null for Facebook
}

export interface NormalisedPost {
  externalPostId: string;
  caption: string | null;
  mediaType: string; // "REELS", "FEED", "FB_REEL", "SHORT", "VIDEO"
  permalink: string | null;
  publishedAt: Date;
  metrics: NormalisedMetrics;
  raw: unknown; // original API responses, kept for debugging and re-scoring
}

export interface AccountCredentials {
  externalId: string; // Facebook needs the Page ID in the URL
  accessToken: string; // decrypted just before the call
}

export interface PlatformAdapter {
  platform: Platform;

  // OAuth step 1: URL the user opens to approve access.
  // codeChallenge is only used by YouTube (PKCE).
  getAuthUrl(state: string, codeChallenge?: string): string;

  // OAuth step 2: swap the callback code for tokens.
  // Returns one result per connectable account: Instagram and YouTube return
  // one, Facebook returns one per Page so the user can pick.
  exchangeCode(code: string, codeVerifier?: string): Promise<ConnectResult[]>;

  // Most recent posts with metrics, newest first, at most `limit`
  fetchRecentPosts(account: AccountCredentials, limit: number): Promise<NormalisedPost[]>;

  // New tokens, or null when the platform has nothing to refresh (Facebook)
  refreshToken(accessToken: string, refreshToken: string | null): Promise<ConnectResult | null>;

  // publish() is added in M3
}
