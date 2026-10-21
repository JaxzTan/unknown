-- CreateEnum
CREATE TYPE "Language" AS ENUM ('en', 'ms', 'zh');

-- CreateEnum
CREATE TYPE "Platform" AS ENUM ('youtube', 'facebook', 'instagram');

-- CreateEnum
CREATE TYPE "AccountStatus" AS ENUM ('active', 'expired', 'revoked');

-- CreateEnum
CREATE TYPE "PostTargetStatus" AS ENUM ('scheduled', 'publishing', 'published', 'failed');

-- CreateEnum
CREATE TYPE "SnapshotType" AS ENUM ('48h', '7d', 'latest');

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "email" TEXT NOT NULL,
    "language" "Language" NOT NULL DEFAULT 'en',
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "brands" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "brands_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "social_accounts" (
    "id" UUID NOT NULL,
    "brand_id" UUID NOT NULL,
    "platform" "Platform" NOT NULL,
    "external_id" TEXT NOT NULL,
    "display_name" TEXT,
    "access_token" TEXT NOT NULL,
    "refresh_token" TEXT,
    "expires_at" TIMESTAMPTZ,
    "status" "AccountStatus" NOT NULL DEFAULT 'active',
    "follower_count" INTEGER,
    "last_synced_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "social_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "posts" (
    "id" UUID NOT NULL,
    "brand_id" UUID NOT NULL,
    "caption_base" TEXT NOT NULL,
    "media_url" TEXT NOT NULL,
    "media_duration_s" INTEGER NOT NULL,
    "aspect_ratio" TEXT NOT NULL,
    "scheduled_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "posts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "post_targets" (
    "id" UUID NOT NULL,
    "post_id" UUID NOT NULL,
    "social_account_id" UUID NOT NULL,
    "caption_override" TEXT,
    "status" "PostTargetStatus" NOT NULL DEFAULT 'scheduled',
    "external_post_id" TEXT,
    "error" TEXT,
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "published_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "post_targets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "metric_snapshots" (
    "id" UUID NOT NULL,
    "post_target_id" UUID NOT NULL,
    "snapshot_type" "SnapshotType" NOT NULL,
    "views" INTEGER NOT NULL,
    "likes" INTEGER NOT NULL,
    "comments" INTEGER NOT NULL,
    "shares" INTEGER NOT NULL,
    "saves" INTEGER,
    "fetched_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "metric_snapshots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "content_scores" (
    "id" UUID NOT NULL,
    "post_target_id" UUID NOT NULL,
    "snapshot_type" "SnapshotType" NOT NULL,
    "er" DECIMAL(8,6) NOT NULL,
    "score" DECIMAL(6,2) NOT NULL,
    "is_provisional" BOOLEAN NOT NULL DEFAULT false,
    "weights_version" INTEGER NOT NULL,
    "computed_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "content_scores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "weekly_insights" (
    "id" UUID NOT NULL,
    "brand_id" UUID NOT NULL,
    "week_start" DATE NOT NULL,
    "language" "Language" NOT NULL,
    "summary" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "weekly_insights_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "media_kits" (
    "id" UUID NOT NULL,
    "brand_id" UUID NOT NULL,
    "slug" TEXT NOT NULL,
    "revoked_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "media_kits_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "brands_user_id_key" ON "brands"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "social_accounts_brand_id_platform_external_id_key" ON "social_accounts"("brand_id", "platform", "external_id");

-- CreateIndex
CREATE INDEX "posts_brand_id_scheduled_at_idx" ON "posts"("brand_id", "scheduled_at");

-- CreateIndex
CREATE INDEX "post_targets_status_idx" ON "post_targets"("status");

-- CreateIndex
CREATE UNIQUE INDEX "post_targets_post_id_social_account_id_key" ON "post_targets"("post_id", "social_account_id");

-- CreateIndex
CREATE INDEX "metric_snapshots_post_target_id_snapshot_type_fetched_at_idx" ON "metric_snapshots"("post_target_id", "snapshot_type", "fetched_at");

-- CreateIndex
CREATE UNIQUE INDEX "content_scores_post_target_id_snapshot_type_weights_version_key" ON "content_scores"("post_target_id", "snapshot_type", "weights_version");

-- CreateIndex
CREATE UNIQUE INDEX "weekly_insights_brand_id_week_start_language_key" ON "weekly_insights"("brand_id", "week_start", "language");

-- CreateIndex
CREATE UNIQUE INDEX "media_kits_slug_key" ON "media_kits"("slug");

-- AddForeignKey
ALTER TABLE "brands" ADD CONSTRAINT "brands_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "social_accounts" ADD CONSTRAINT "social_accounts_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "brands"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "posts" ADD CONSTRAINT "posts_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "brands"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "post_targets" ADD CONSTRAINT "post_targets_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "post_targets" ADD CONSTRAINT "post_targets_social_account_id_fkey" FOREIGN KEY ("social_account_id") REFERENCES "social_accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "metric_snapshots" ADD CONSTRAINT "metric_snapshots_post_target_id_fkey" FOREIGN KEY ("post_target_id") REFERENCES "post_targets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "content_scores" ADD CONSTRAINT "content_scores_post_target_id_fkey" FOREIGN KEY ("post_target_id") REFERENCES "post_targets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "weekly_insights" ADD CONSTRAINT "weekly_insights_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "brands"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "media_kits" ADD CONSTRAINT "media_kits_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "brands"("id") ON DELETE CASCADE ON UPDATE CASCADE;
