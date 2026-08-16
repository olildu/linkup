import random
from typing import List, Optional
from pydantic import BaseModel
from psycopg2.extensions import cursor as Psycopg2Cursor

from app.core.controllers.db_controller import db_pool
from app.features.discovery.models.match_canidate_model import build_candidate_model
from app.core.swipe_exceptions import get_swipes_remaining

class MatchUserModel(BaseModel):
    id: int
    username: str
    university_id: int
    already_interacted: Optional[List[int]] = None
    preferences: Optional[dict] = None
    existing_matches: Optional[List[int]] = None


def get_matches(user_id: int, refresh: bool = False) -> MatchUserModel:
    conn = db_pool.getconn()
    try:
        cursor = conn.cursor()
        # Query 1: user info
        cursor.execute("SELECT id, username, university_id FROM users WHERE id = %s", (user_id,))
        user_row = cursor.fetchone()
        if not user_row:
            return None

        user_id, username, university_id = user_row

        # Query 2: preferences
        cursor.execute("SELECT key, value FROM user_preferences WHERE user_id = %s", (user_id,))
        preferences = {key: value for key, value in cursor.fetchall()}


        # Query 3: already_interacted and match_queue
        cursor.execute("""
            SELECT already_interacted, match_queue
            FROM user_discovery_pool
            WHERE user_id = %s
        """, (user_id,))
        row = cursor.fetchone()

        already_interacted = row[0] if row else []

        if refresh:
            # Discard the stale, not-yet-swiped queue so a fresh one gets
            # generated against the user's just-updated preferences.
            cursor.execute("UPDATE user_discovery_pool SET match_queue = '{}' WHERE user_id = %s", (user_id,))
            existing_matches = []
        else:
            existing_matches = row[1] if row else []

        user = MatchUserModel(
            id=user_id,
            username=username,
            university_id=university_id,
            already_interacted=already_interacted,
            preferences=preferences,
            existing_matches=existing_matches
        )

        return {
            "matches" : get_matches_by_preference(
                user = user,
                cursor = cursor,
                limit = 10 - len(user.existing_matches)
            ),
            "preferences_set": True if len(user.preferences.keys()) > 1 else False,
            "swipes_remaining": get_swipes_remaining(user_id, cursor),
        }
    finally:
        if 'cursor' in locals():
            cursor.close()
        db_pool.putconn(conn)

def get_matches_by_preference(user: MatchUserModel, limit: int = 10, cursor: Psycopg2Cursor = None):
    university_id = user.university_id
    interested_gender = (user.preferences or {}).get("interested_gender")
    user_id = user.id
    already_interacted = user.already_interacted or []

    exclusion_list = already_interacted + [user_id] + user.existing_matches
    exclusion_tuple = tuple(exclusion_list) if exclusion_list else (-1,)

    user_existing_matches = user.existing_matches or []
    user_existing_matches_tuple = tuple(user_existing_matches) if user_existing_matches else (-1,)

    preferences = user.preferences.copy() if user.preferences else {}
    preferences.pop("interested_gender", None)

    matched_users = []

    query = f"""
    SELECT DISTINCT users.id, users.username, users.gender, users.university_id, users.profile_picture::text
    FROM users
        where users.id IN %s
          AND users.is_deleted = FALSE
          AND users.is_profile_complete = TRUE
    """

    params = [user_existing_matches_tuple]
    cursor.execute(query, params)

    matched_users += cursor.fetchall()

    # Widen the candidate pool beyond `limit` so there's something to score/rank
    # by preference match + exposure before trimming down. Preferences are no
    # longer hard AND-filters (small user base would starve the queue), they're
    # a soft ranking signal instead.
    pool_size = max(limit * 5, 30)

    query = """
        SELECT DISTINCT users.id, users.username, users.gender, users.university_id,
               users.profile_picture::text, users.times_queued
        FROM users
        WHERE users.university_id = %s
          AND users.gender = %s
          AND users.id NOT IN %s
          AND users.is_deleted = FALSE
          AND users.is_profile_complete = TRUE
        LIMIT %s;
    """
    params = [university_id, interested_gender, exclusion_tuple, pool_size]

    cursor.execute(query, params)
    candidate_rows = cursor.fetchall()

    if not candidate_rows and not matched_users:
        print("No matches found")
        return []

    candidate_ids = tuple(row[0] for row in candidate_rows) if candidate_rows else (-1,)
    metadata_lookup_ids = candidate_ids if len(candidate_ids) > 1 else (candidate_ids[0], candidate_ids[0])

    metadata_query = """
        SELECT user_id, key, value
        FROM user_metadata
        WHERE user_id IN %s
    """
    cursor.execute(metadata_query, (metadata_lookup_ids,))
    all_metadata = cursor.fetchall()

    metadata_map = {}
    for user_id_, key, value in all_metadata:
        metadata_map.setdefault(user_id_, {})[key] = value

    def preference_score(user_id_: int) -> int:
        user_meta = metadata_map.get(user_id_, {})
        return sum(1 for key, value in preferences.items() if user_meta.get(key) == value)

    # Rank by: preference match score desc, exposure (times_queued) asc, then
    # a random tiebreak so equally-ranked candidates don't always order the same way.
    ranked_rows = sorted(
        candidate_rows,
        key=lambda row: (-preference_score(row[0]), row[5], random.random()),
    )
    new_candidate_rows = ranked_rows[:limit]

    matched_users += [row[:5] for row in new_candidate_rows]

    if not matched_users:
        print("No matches found")
        return []

    matched_user_ids = tuple([u[0] for u in matched_users])
    if len(matched_user_ids) == 1:
        matched_user_ids = (matched_user_ids[0], matched_user_ids[0])

    # Re-fetch metadata to also cover the `existing_matches` rows fetched earlier
    # (those weren't part of the candidate_rows metadata lookup above).
    cursor.execute(metadata_query, (matched_user_ids,))
    all_metadata = cursor.fetchall()

    metadata_map = {}
    for user_id_, key, value in all_metadata:
        metadata_map.setdefault(user_id_, {})[key] = value

    results = []
    for user_data in matched_users:
        user_id_ = user_data[0]
        user_meta = metadata_map.get(user_id_, {})
        try:
            candidate = build_candidate_model(user_meta, user_data)
            results.append(candidate.model_dump())
        except Exception as e:
            # Skip this one malformed candidate rather than failing the whole
            # matches list for the requesting user.
            print(f"Skipping candidate {user_id_}, failed to build model: {e}")
            continue

    # Exposure balancing: only count users newly added to a queue this call,
    # not ones re-fetched from an existing queue (avoids double-counting).
    if new_candidate_rows:
        new_candidate_ids = tuple(row[0] for row in new_candidate_rows)
        cursor.execute(
            "UPDATE users SET times_queued = times_queued + 1 WHERE id IN %s;",
            (new_candidate_ids,),
        )

    # Fetch existing match_queue, merge, and limit to 10 unique
    cursor.execute("SELECT match_queue FROM user_discovery_pool WHERE user_id = %s", (user_id,))
    row = cursor.fetchone()
    existing_queue = row[0] if row else []

    merged_queue = list(dict.fromkeys(existing_queue + list(matched_user_ids)))[:10]

    upsert_query = """
        INSERT INTO user_discovery_pool (user_id, match_queue)
        VALUES (%s, %s)
        ON CONFLICT (user_id) DO UPDATE
        SET match_queue = EXCLUDED.match_queue
    """
    cursor.execute(upsert_query, (user_id, merged_queue))

    cursor.connection.commit()
    random.shuffle(results)

    return results