-- Adds a unique constraint on user_metadata(user_id, key) so it can be
-- upserted with INSERT ... ON CONFLICT instead of a racy
-- select-then-insert-or-update. Idempotent: safe to run against a DB that
-- already has some or all of this applied.

-- Dedupe any pre-existing duplicate (user_id, key) rows first, keeping the
-- most recently inserted one, since the new constraint would otherwise fail.
DELETE FROM user_metadata a
USING user_metadata b
WHERE a.user_id = b.user_id
  AND a.key = b.key
  AND a.id < b.id;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'uq_user_metadata_user_id_key'
    ) THEN
        ALTER TABLE user_metadata ADD CONSTRAINT uq_user_metadata_user_id_key UNIQUE (user_id, key);
    END IF;
END $$;
