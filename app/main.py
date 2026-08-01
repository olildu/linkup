import asyncio
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from pytz import timezone
from contextlib import asynccontextmanager
import os

from app.controllers.db_controller import create_pool
from app.routes.chats.chats_endpoints import chats_router
from app.routes.actions.swipe_endpoint import swipe_route 
from app.routes.matches.matches_endpoint import matches_router
from app.routes.user.get_user_data import user_router
from app.routes.auth.auth_endpoints import auth_router
from app.routes.common.common_endpoints import common_router
from app.routes.cities.cities_endpoints import location_router
from app.routes.internal.status_endpoints import status_router

from app.routes.chats.chat_websocket_endpoints import chatsocket_router
from app.routes.matches.connections_websocket_endpoints import connectionsocket_router
from app.routes.matches.lobby.lobby_websocket_endpoints import lobbysocket_router, start_waiting_period

ist = timezone("Asia/Kolkata")
scheduler = BackgroundScheduler(timezone=ist)

loop = asyncio.get_event_loop()

def start_meet_at_8_sync():
    asyncio.run_coroutine_threadsafe(start_waiting_period(), loop)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create asyncpg pool
    app.state.db_pool = await create_pool()

    # Setup APScheduler job
    trigger = CronTrigger(hour=20, minute=0, timezone=ist)
    scheduler.add_job(start_meet_at_8_sync, trigger)
    scheduler.start()

    yield

    # Shutdown scheduler and close pool
    scheduler.shutdown()
    await app.state.db_pool.close()
    
app = FastAPI(lifespan=lifespan)

# --- API ROUTERS (v1) ---
# All REST API endpoints are now prefixed with /api/v1
api_v1_prefix = "/api/v1"

app.include_router(auth_router, prefix=api_v1_prefix)
app.include_router(user_router, prefix=api_v1_prefix)
app.include_router(swipe_route, prefix=api_v1_prefix)
app.include_router(matches_router, prefix=api_v1_prefix)
app.include_router(chats_router, prefix=api_v1_prefix)
app.include_router(common_router, prefix=api_v1_prefix)
app.include_router(location_router, prefix=api_v1_prefix)
app.include_router(status_router, prefix=api_v1_prefix)

# --- WEBSOCKET ROUTERS ---
app.include_router(chatsocket_router, prefix=api_v1_prefix) 
app.include_router(lobbysocket_router, prefix=api_v1_prefix)
app.include_router(connectionsocket_router, prefix=api_v1_prefix)

# --- STATIC FILES & LANDING PAGE ---
# Ensure the 'static' folder exists in your root directory
if not os.path.exists("static"):
    os.makedirs("static")

app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
async def read_index():
    return FileResponse('static/index.html')

@app.get("/terms")
async def read_terms():
    return FileResponse('static/terms.html')

@app.get("/privacy")
async def read_privacy():
    return FileResponse('static/privacy_policy.html')

@app.get("/delete-account")
async def read_delete_account():
    return FileResponse('static/delete_account.html')

@app.get("/child-safety")
async def read_delete_account():
    return FileResponse('static/child-safety.html')

@app.get("/logs")
async def read_logs():
    return FileResponse('static/logs.html')