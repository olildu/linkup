from fastapi import APIRouter, Depends
from app.core.constants.global_constants import oauth2_scheme
from app.core.swipe_exceptions import assert_in_match_queue, assert_under_daily_like_limit, handle_db_errors
from app.features.discovery.swipe_utilities import process_like, update_discovery_and_post_action
from app.core.token_utilities import decode_token
from app.core.controllers.db_controller import db_pool
from app.core.controllers.logger_controller import logger_controller
from app.features.discovery.models.swipe_request_model import SwipeRequest

swipe_route = APIRouter(prefix="/swipe")

@swipe_route.post("/right")
@handle_db_errors
async def like_swipe(body: SwipeRequest, token: str = Depends(oauth2_scheme)):
    liker_id = decode_token(token)
    liked_id = body.liked_id

    conn = db_pool.getconn()
    try:
        with conn.cursor() as cursor:
            assert_in_match_queue(liker_id, liked_id, cursor)
            assert_under_daily_like_limit(liker_id, cursor)

        result = await process_like(liker_id, liked_id, conn)

        if not result["match"]:
            update_discovery_and_post_action(liker_id, liked_id, conn)

        return result
    finally:
        db_pool.putconn(conn)


@swipe_route.post("/left")
@handle_db_errors
async def dislike_swipe(body: SwipeRequest, token: str = Depends(oauth2_scheme)):
    liker_id = decode_token(token)
    liked_id = body.liked_id

    conn = db_pool.getconn()
    try:
        with conn.cursor() as cursor:
            assert_in_match_queue(liker_id, liked_id, cursor)

            cursor.execute("""
                INSERT INTO likes (liker_id, liked_id, liked)
                VALUES (%s, %s, %s)
                ON CONFLICT (liker_id, liked_id) DO NOTHING;
            """, (liker_id, liked_id, False))
            conn.commit()

        update_discovery_and_post_action(liker_id, liked_id, conn)

        logger_controller.info(f"User {liker_id} disliked user {liked_id}")

        return {"message": "Dislike recorded"}
    finally:
        db_pool.putconn(conn)