from fastapi import APIRouter, Depends, HTTPException

from app.core.constants.global_constants import oauth2_scheme
from app.core.swipe_exceptions import handle_db_errors
from app.core.token_utilities import decode_token
from app.features.discovery.matches_utilities import get_matches

matches_router = APIRouter(prefix="/matches")

@matches_router.get("/get-matches")
@handle_db_errors
async def return_matches(refresh: bool = False, token: str = Depends(oauth2_scheme)):
    """
    Get matches for the user.
    """

    id = decode_token(token)

    try:
        return get_matches(user_id=id, refresh=refresh)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
