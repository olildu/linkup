from fastapi import APIRouter, Depends

from app.core.constants.global_constants import oauth2_scheme
from app.core.controllers.db_controller import db_pool
from app.core.controllers.logger_controller import logger_controller
from app.features.likes.models.likes_you_model import LikesYouEntryModel, LikesYouResponseModel
from app.core.swipe_exceptions import (
    assert_has_liked_me,
    assert_under_daily_like_limit,
    handle_db_errors,
)
from app.features.likes.likes_utilities import (
    build_first_photo,
    build_full_profile,
    get_pending_liker_ids,
    get_pending_likes_count,
    get_unseen_likes_count,
    mark_likes_seen,
)
from app.features.discovery.swipe_utilities import process_like, update_discovery_and_post_action
from app.core.token_utilities import decode_token

likes_route = APIRouter(prefix="/likes")

PAGE_SIZE = 20


@likes_route.get("/received", response_model=LikesYouResponseModel)
@handle_db_errors
async def get_received_likes(offset: int = 0, token: str = Depends(oauth2_scheme)):
    """
    Returns the Likes-You queue, oldest-first. Only the very first entry
    (global index 0) is fully revealed; all others are photo-only teasers.
    """
    user_id = decode_token(token)

    conn = db_pool.getconn()
    try:
        with conn.cursor() as cursor:
            all_ids = get_pending_liker_ids(user_id, cursor)
            page_ids = all_ids[offset: offset + PAGE_SIZE]

            entries = []
            for position, liker_id in enumerate(page_ids, start=offset):
                if position == 0:
                    entries.append(LikesYouEntryModel(
                        id=liker_id,
                        revealed=True,
                        profile=build_full_profile(liker_id, cursor),
                    ))
                else:
                    entries.append(LikesYouEntryModel(
                        id=liker_id,
                        revealed=False,
                        first_photo=build_first_photo(liker_id, cursor),
                    ))

            mark_likes_seen(user_id, page_ids, cursor)
            unseen_count = get_unseen_likes_count(user_id, cursor)
            conn.commit()

        return LikesYouResponseModel(
            entries=entries,
            total_count=len(all_ids),
            unseen_count=unseen_count,
        )
    finally:
        db_pool.putconn(conn)


@likes_route.get("/count")
@handle_db_errors
async def get_likes_count(token: str = Depends(oauth2_scheme)):
    """
    Lightweight, count-only endpoint for badge polling — no profile
    lookups, no seen-state mutation.
    """
    user_id = decode_token(token)

    conn = db_pool.getconn()
    try:
        with conn.cursor() as cursor:
            total_count = get_pending_likes_count(user_id, cursor)
        return {"total_count": total_count}
    finally:
        db_pool.putconn(conn)


@likes_route.post("/{liker_id}/like-back")
@handle_db_errors
async def like_back(liker_id: int, token: str = Depends(oauth2_scheme)):
    current_user_id = decode_token(token)

    conn = db_pool.getconn()
    try:
        with conn.cursor() as cursor:
            assert_has_liked_me(liker_id, current_user_id, cursor)
            assert_under_daily_like_limit(current_user_id, cursor)

        result = await process_like(current_user_id, liker_id, conn)

        if not result["match"]:
            update_discovery_and_post_action(current_user_id, liker_id, conn)

        return result
    finally:
        db_pool.putconn(conn)


@likes_route.post("/{liker_id}/pass")
@handle_db_errors
async def pass_like(liker_id: int, token: str = Depends(oauth2_scheme)):
    current_user_id = decode_token(token)

    conn = db_pool.getconn()
    try:
        with conn.cursor() as cursor:
            assert_has_liked_me(liker_id, current_user_id, cursor)

            cursor.execute("""
                INSERT INTO likes (liker_id, liked_id, liked)
                VALUES (%s, %s, %s)
                ON CONFLICT (liker_id, liked_id) DO NOTHING;
            """, (current_user_id, liker_id, False))
            conn.commit()

        update_discovery_and_post_action(current_user_id, liker_id, conn)

        logger_controller.info(f"User {current_user_id} passed on likes-you candidate {liker_id}")

        return {"message": "Pass recorded"}
    finally:
        db_pool.putconn(conn)
