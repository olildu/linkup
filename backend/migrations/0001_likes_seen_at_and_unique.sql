-- Brings an existing `likes` table up to date with schema.sql for the
-- Hinge-style Likes-You feature. Idempotent: safe to run against a DB that
-- already has some or all of these applied.

ALTER TABLE likes ADD COLUMN IF NOT EXISTS seen_at TIMESTAMP NULL DEFAULT NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'uq_likes_liker_liked'
    ) THEN
        ALTER TABLE likes ADD CONSTRAINT uq_likes_liker_liked UNIQUE (liker_id, liked_id);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_likes_liked_pending ON likes (liked_id, created_at) WHERE liked = TRUE;
