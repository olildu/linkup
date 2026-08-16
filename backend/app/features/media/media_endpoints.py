import asyncio
import tempfile
import cv2
from fastapi import APIRouter, Depends, File, Form, UploadFile, HTTPException, BackgroundTasks
from enum import Enum
import uuid
from io import BytesIO
from PIL import Image
import time

import requests

from app.core.constants.global_constants import oauth2_scheme
from app.features.media.media_utilities import generate_blurhash
from app.features.media.imgproxy_utilities import build_signed_url
from app.features.media.url_safety import is_safe_url
from app.core.token_utilities import decode_token
from app.core.controllers import seaweedfs_controller
from app.core.controllers.logger_controller import logger_controller

common_router = APIRouter(prefix="/upload")

class MediaTypeEnum(str, Enum):
    IMAGE = "image"
    VOICE = "voice"

MAX_FILE_SIZE_MB = 5
MAX_FILE_SIZE_BYTES = MAX_FILE_SIZE_MB * 1024 * 1024  # 5 MB

async def upload_file_async_chat(webp_content: bytes, file_key: str):
    loop = asyncio.get_event_loop()
    await loop.run_in_executor(None, seaweedfs_controller.upload_bytes, webp_content, file_key)

async def upload_file_async_user(file_path: str, file_key: str) -> tuple[str, str]:
    loop = asyncio.get_event_loop()
    await loop.run_in_executor(None, seaweedfs_controller.upload_file, file_path, file_key)

    return file_key, build_signed_url(file_key)

def process_image_half_and_convert_webp(content: bytes) -> tuple[bytes, int, int]:
    image = Image.open(BytesIO(content))
    original_width, original_height = image.size
    width, height = original_width // 2, original_height // 2
    image = image.resize((width, height), Image.Resampling.LANCZOS)

    webp_buffer = BytesIO()
    image.save(webp_buffer, format="WEBP", quality=75)
    return webp_buffer.getvalue(), width, height

def process_image_to_webp_file(content: bytes) -> tuple[str, bytes, int, int]:
    image = Image.open(BytesIO(content))
    original_width, original_height = image.size
    width, height = original_width // 2, original_height // 2
    image = image.resize((width, height), Image.Resampling.LANCZOS)

    with tempfile.NamedTemporaryFile(suffix=".webp", delete=False) as temp_file:
        image.save(temp_file, format="WEBP", quality=75)
        temp_file_path = temp_file.name

    with open(temp_file_path, "rb") as f:
        webp_content = f.read()

    return temp_file_path, webp_content, width, height

def extract_face(image_path, save_path, PADDING = 50):
    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
    
    # Read image
    img = cv2.imread(image_path)
    if img is None:
        print("Image not found.")
        return False
    
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Detect faces
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5)
    
    if len(faces) == 0:
        print("No face detected.")
        return False
    
    # Take first face only
    x, y, w, h = faces[0]
    
    # Apply padding and ensure bounds
    x1 = max(0, x - PADDING)
    y1 = max(0, y - PADDING)
    x2 = min(img.shape[1], x + w + PADDING)
    y2 = min(img.shape[0], y + h + PADDING)
    
    # Crop and save
    face_img = img[y1:y2, x1:x2]
    pil_image = Image.fromarray(cv2.cvtColor(face_img, cv2.COLOR_BGR2RGB))
    pil_image.save(save_path)
    
    return True


@common_router.post("/media")
async def upload_media(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    media_type: MediaTypeEnum = Form(...),
    token: str = Depends(oauth2_scheme),
):
    try:
        user_id = decode_token(token)
        content = await file.read()

        if len(content) > MAX_FILE_SIZE_BYTES:
            raise HTTPException(status_code=413, detail=f"File too large. Max {MAX_FILE_SIZE_MB}MB")

        loop = asyncio.get_event_loop()
        webp_content, width, height = await loop.run_in_executor(None, process_image_half_and_convert_webp, content)

        if len(webp_content) > MAX_FILE_SIZE_BYTES:
            raise HTTPException(status_code=413, detail="Converted file too large.")

        file_key = f"sw/media/{user_id}/{uuid.uuid4()}.webp"
        blurhash = generate_blurhash(webp_content)

        start_time = time.time()
        await upload_file_async_chat(webp_content, file_key)
        logger_controller.info(f"Upload time for {file_key}: {time.time() - start_time:.2f} sec")

        signed_url = build_signed_url(file_key, expire_seconds=600)

        return {
            "file_key": file_key,
            "media_type": media_type,
            "metadata": {
                "file_url": signed_url,
                "width": float(width),
                "height": float(height),
                "blurhash": blurhash,
                "format": "webp",
                "size_bytes": len(webp_content),
            },
        }

    except HTTPException as e:
        logger_controller.warning(f"Exception in uploading file {e}")
        raise
    except Exception as e:
        logger_controller.warning(f"Exception in uploading file {e}")
        raise HTTPException(status_code=500, detail=str(e))

@common_router.post("/media-user")
async def upload_media_user(
    file: UploadFile = File(...),
    media_type: MediaTypeEnum = Form(...),
    token: str = Depends(oauth2_scheme),
):
    try:
        user_id = decode_token(token)
        content = await file.read()
        try:
            Image.open(BytesIO(content)).verify()
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid image file.")
        
        loop = asyncio.get_event_loop()
        temp_file_path, webp_content, width, height = await loop.run_in_executor(None, process_image_to_webp_file, content)

        if len(webp_content) > MAX_FILE_SIZE_BYTES:
            raise HTTPException(status_code=413, detail="Converted file too large.")

        blurhash = generate_blurhash(webp_content)

        file_key = f"sw/media/{user_id}/{uuid.uuid4()}.webp"
        start_time = time.time()
        file_key_remote, signed_url = await upload_file_async_user(temp_file_path, file_key)
        logger_controller.info(f"Upload time for {file_key}: {time.time() - start_time:.2f}s")

        return {
            "media_type": media_type,
            "metadata": {
                "file_key": file_key_remote, 
                "blurhash" : blurhash,
            },
        }

    except HTTPException as e:
        logger_controller.warning(f"Unhandled upload error: {e}")
        logger_controller.warning(f"Upload error: {e}")
        raise
    except Exception as e:
        logger_controller.warning(f"Unhandled upload error: {e}")
        raise HTTPException(status_code=500, detail="Something went wrong during upload.")

@common_router.post("/media-user-pfp")
async def generate_profile_picture(
    file: UploadFile = File(...),
    media_type: MediaTypeEnum = Form(...),
    token: str = Depends(oauth2_scheme),
):
    try:
        user_id = decode_token(token)
        content = await file.read()

        # Validate image
        try:
            Image.open(BytesIO(content)).verify()
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid image file.")

        # Save original image to temp file
        with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as temp_input_file:
            temp_input_file.write(content)
            input_path = temp_input_file.name

        # Upload original image
        original_file_key = f"sw/media/{user_id}/{uuid.uuid4()}.jpg"
        original_file_key_remote, original_signed_url = await upload_file_async_user(input_path, original_file_key)

        # Temp file for cropped face
        with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as temp_face_file:
            face_path = temp_face_file.name

        if not extract_face(input_path, face_path):
            raise HTTPException(status_code=422, detail="No face detected in the image.")

        # Read cropped face image bytes
        with open(face_path, "rb") as f:
            face_bytes = f.read()

        # Convert face image to webp
        loop = asyncio.get_event_loop()
        temp_file_path, webp_content, width, height = await loop.run_in_executor(
            None, process_image_to_webp_file, face_bytes
        )

        if len(webp_content) > MAX_FILE_SIZE_BYTES:
            raise HTTPException(status_code=413, detail="Converted file too large.")

        # Upload profile picture (webp)
        profile_file_key = f"sw/profile_pictures/{user_id}/pfp.webp"
        blurhash_pfp = generate_blurhash(webp_content)
        blurhash_original_image = generate_blurhash(content)

        start_time = time.time()
        profile_file_key_remote, profile_signed_url = await upload_file_async_user(temp_file_path, profile_file_key)
        logger_controller.info(f"PFP Upload time for {profile_file_key}: {time.time() - start_time:.2f}s")

        return {
            "profile_metadata" : {"file_key": profile_file_key_remote, "blurhash" : blurhash_pfp},
            "original_image_metadata" : {"file_key": original_file_key_remote, "blurhash" : blurhash_original_image},

            "original_image_url": original_signed_url,
            "profile_picture_url": profile_signed_url,
        }

    except HTTPException as e:
        logger_controller.warning(f"PFP Upload error: {e}")
        raise
    except Exception as e:
        logger_controller.warning(f"Unhandled PFP upload error: {e}")
        raise HTTPException(status_code=500, detail="Something went wrong during profile picture upload.")

@common_router.post("/media-user-pfp-from-url")
async def generate_profile_picture_from_url(
    image_url: str = Form(...),
    token: str = Depends(oauth2_scheme),
):
    try:
        user_id = decode_token(token)

        if not is_safe_url(image_url):
            raise HTTPException(status_code=400, detail="Unsafe or invalid image URL")

        # Download image from URL
        response = requests.get(image_url, timeout=10)
        if response.status_code != 200:
            raise HTTPException(status_code=400, detail="Unable to fetch image from URL")

        content = response.content

        # Validate image
        try:
            Image.open(BytesIO(content)).verify()
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid image file.")

        # Save original image to temp file
        with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as temp_input_file:
            temp_input_file.write(content)
            input_path = temp_input_file.name

        # Temp file for cropped face
        with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as temp_face_file:
            face_path = temp_face_file.name

        if not extract_face(input_path, face_path):
            raise HTTPException(status_code=422, detail="No face detected in the image.")

        # Read cropped face image bytes
        with open(face_path, "rb") as f:
            face_bytes = f.read()

        # Convert face image to webp
        loop = asyncio.get_event_loop()
        temp_file_path, webp_content, width, height = await loop.run_in_executor(
            None, process_image_to_webp_file, face_bytes
        )

        if len(webp_content) > MAX_FILE_SIZE_BYTES:
            raise HTTPException(status_code=413, detail="Converted file too large.")

        # Upload profile picture (webp)
        profile_file_key = f"sw/profile_pictures/{user_id}/pfp.webp"
        blurhash_pfp = generate_blurhash(webp_content)

        start_time = time.time()
        profile_file_key_remote, profile_signed_url = await upload_file_async_user(temp_file_path, profile_file_key)
        logger_controller.info(f"PFP Upload time from URL for {profile_file_key}: {time.time() - start_time:.2f}s")

        return {
            "profile_metadata": {
                "file_key": profile_file_key_remote,
                "blurhash": blurhash_pfp,
            },
            "profile_picture_url": profile_signed_url,
        }

    except HTTPException as e:
        logger_controller.warning(f"PFP Upload from URL error: {e}")
        raise
    except Exception as e:
        logger_controller.warning(f"Unhandled PFP upload from URL error: {e}")
        raise HTTPException(status_code=500, detail="Something went wrong while processing the image URL.")