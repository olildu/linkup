import asyncio
from fastapi import APIRouter, Depends
from app.constants.global_constants import oauth2_scheme
from app.routes.matches.connections_websocket_endpoints import DataModel, send_event_to_user_connection
from app.utilities.common.common_utilites import get_signed_imagekit
from app.utilities.exception.swipe.swipe_exceptions import assert_in_match_queue, handle_db_errors
from app.utilities.swipe.swipe_utilities import handle_post_action, update_discovery_and_post_action
from app.utilities.token.token_utilities import decode_token
from app.controllers.db_controller import db_pool
from app.controllers.logger_controller import logger_controller
from app.models.swipe_request_model import SwipeRequest

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

            cursor.execute("""
                SELECT users.id, users.username, users.profile_picture
                FROM likes
                JOIN users ON users.id = likes.liker_id
                WHERE likes.liker_id = %s AND likes.liked_id = %s AND likes.liked = TRUE;
            """, (liked_id, liker_id))
            match_user = cursor.fetchone()

            if match_user:
                cursor.execute("""
                    DELETE FROM likes 
                    WHERE liker_id = %s AND liked_id = %s AND liked = TRUE;
                """, (liked_id, liker_id))

                cursor.execute("""
                    INSERT INTO matches (user1_id, user2_id)
                    VALUES (%s, %s); 
                """, (liker_id, liked_id))

                conn.commit()
                logger_controller.info(f"Match found between {liker_id} and {liked_id}, deleted reciprocal like record")

                # Update discovery pool for both users
                handle_post_action(liker_id, liked_id, conn)
                handle_post_action(liked_id, liker_id, conn)

                pairs = [
                    (liked_id, liker_id),
                    (liker_id, liked_id),
                ]

                await asyncio.gather(*[
                    send_event_to_user_connection(
                        DataModel(
                            to=to,
                            from_=from_,
                            type="connections-reload",
                            sub_type="match",
                        )
                    )
                    for from_, to in pairs
                ])

                return {
                    "match": True,
                    "message": "It's a match!",
                    "matched_user": {
                        "id": match_user[0],
                        "username": match_user[1],
                        "profile_picture": get_signed_imagekit(match_user[2])
                    }
                }

            cursor.execute("""
                INSERT INTO likes (liker_id, liked_id, liked)
                VALUES (%s, %s, %s);
            """, (liker_id, liked_id, True))
            conn.commit()

        update_discovery_and_post_action(liker_id, liked_id, conn)

        logger_controller.info(f"User {liker_id} liked user {liked_id}")

        return {
            "match": False,
            "message": "Like recorded"
        }
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
                VALUES (%s, %s, %s);
            """, (liker_id, liked_id, False))
            conn.commit()

        update_discovery_and_post_action(liker_id, liked_id, conn)

        logger_controller.info(f"User {liker_id} disliked user {liked_id}")

        return {"message": "Dislike recorded"}
    finally:
        db_pool.putconn(conn)