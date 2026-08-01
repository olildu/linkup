CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- EXTENSIONS (optional for cron jobs, comment out if not needed)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;


-- UNIVERSITIES
CREATE TABLE universities (
   id SERIAL PRIMARY KEY,
   name VARCHAR NOT NULL,
   location TEXT NOT NULL
);


-- USERS
CREATE TABLE users (
   id SERIAL PRIMARY KEY,
   email VARCHAR NOT NULL UNIQUE,
   username VARCHAR,                      -- now nullable
   password_hash TEXT NOT NULL,
   university_id INTEGER REFERENCES universities(id), -- now nullable
   gender VARCHAR,                        -- now nullable
   profile_picture JSON,                  -- now nullable
   is_profile_complete BOOLEAN DEFAULT FALSE, -- added flag
   is_deleted BOOLEAN DEFAULT FALSE,      -- <--- ADD THIS LINE
   times_queued INTEGER NOT NULL DEFAULT 0, -- exposure balancing: times placed in another user's match_queue
   created_at TIMESTAMP DEFAULT NOW()
);


CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_university_id ON users(university_id);


-- USER PREFERENCES
CREATE TABLE user_preferences (
   id SERIAL PRIMARY KEY,
   user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
   key VARCHAR NOT NULL,
   value TEXT,
   UNIQUE (user_id, key)
);


CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);
CREATE INDEX idx_user_preferences_key ON user_preferences(key);


-- USER METADATA
CREATE TABLE user_metadata (
   id SERIAL PRIMARY KEY,
   user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
   key VARCHAR NOT NULL,
   value TEXT
);


CREATE INDEX idx_user_metadata_user_id ON user_metadata(user_id);
CREATE INDEX idx_user_metadata_key ON user_metadata(key);


-- MESSAGES (create this before chats to prevent FK errors)
CREATE TABLE messages (
   id UUID PRIMARY KEY,
   chat_id INTEGER NOT NULL,
   sender_id INTEGER NOT NULL,
   message TEXT NOT NULL,
   timestamp TIMESTAMP DEFAULT NOW(),
   reply_id UUID REFERENCES messages(id) ON DELETE SET NULL
);


-- CHATS (supporting both private and group)
CREATE TABLE chats (
   id SERIAL PRIMARY KEY,
   group_name VARCHAR, -- NULL for 1-1 chats
   created_at TIMESTAMP DEFAULT NOW(),
   last_message_media_type VARCHAR,
   last_message_id UUID REFERENCES messages(id) ON DELETE SET NULL
);


-- Alter MESSAGES now to add FK constraints
ALTER TABLE messages
ADD CONSTRAINT fk_chat_id FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_sender_id FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE;


CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);


-- CHAT PARTICIPANTS (handles n-participant model, unseen counters etc.)
CREATE TABLE chat_participants (
   chat_id INT REFERENCES chats(id) ON DELETE CASCADE,
   user_id INT REFERENCES users(id) ON DELETE CASCADE,
   unseen_count INT DEFAULT 0,
   last_seen_message_id UUID,
   last_seen_at TIMESTAMP,
   PRIMARY KEY (chat_id, user_id)
);


CREATE TABLE media_files (
   id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
   message_id UUID REFERENCES messages(id) ON DELETE CASCADE,
   file_key TEXT NOT NULL,
   media_type TEXT NOT NULL,
   size_bytes INT,
   metadata JSONB,
   uploaded_at TIMESTAMP DEFAULT NOW(),
   user_id INTEGER REFERENCES users(id) ON DELETE CASCADE
);


-- LIKES
CREATE TABLE likes (
   id SERIAL PRIMARY KEY,
   liker_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
   liked_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
   liked BOOLEAN NOT NULL,
   created_at TIMESTAMP DEFAULT NOW()
);


CREATE INDEX idx_likes_liker_id ON likes(liker_id);
CREATE INDEX idx_likes_liked_id ON likes(liked_id);


-- MATCHES
CREATE TABLE matches (
   id SERIAL PRIMARY KEY,
   user1_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
   user2_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
   matched_at TIMESTAMP DEFAULT NOW()
);


CREATE INDEX idx_matches_user1_id ON matches(user1_id);
CREATE INDEX idx_matches_user2_id ON matches(user2_id);


-- USER DISCOVERY POOL
CREATE TABLE user_discovery_pool (
   user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
   match_queue INTEGER[] NOT NULL DEFAULT '{}',
   already_interacted INTEGER[] NOT NULL DEFAULT '{}',
   last_updated TIMESTAMP NOT NULL DEFAULT NOW()
);

-- BLOCKED USERS 
CREATE TABLE IF NOT EXISTS blocked_users (
    id SERIAL PRIMARY KEY,
    blocker_id INT NOT NULL REFERENCES users(id),
    blocked_id INT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(blocker_id, blocked_id)
);

-- REPORTED USERS
CREATE TABLE IF NOT EXISTS reported_users (
    id SERIAL PRIMARY KEY,
    reporter_id INT NOT NULL REFERENCES users(id),
    reported_id INT NOT NULL REFERENCES users(id),
    reason TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- DEFAULT UNIVERSITY
INSERT INTO universities (id, name, location)
VALUES (1, 'Manipal University', 'Manipal, Karnataka')
ON CONFLICT (id) DO NOTHING;


-- CRON CLEANUP EXAMPLE
CREATE OR REPLACE FUNCTION delete_old_likes()
RETURNS void AS $$
BEGIN
   DELETE FROM likes
   WHERE created_at < NOW() - INTERVAL '5 days';
END;
$$ LANGUAGE plpgsql;


-- SELECT cron.schedule('daily_like_cleanup', '0 0 * * *', 'SELECT delete_old_likes();');






