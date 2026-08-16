"""In-memory test image generation - avoids committing binary fixtures for
the format/mode/size matrix. The two real photographic fixtures that need
actual detectable faces (test-face.jpg for success, an existing subject-less
render for failure) live alongside this file and are reused as-is.
"""
import io
from pathlib import Path

from PIL import Image, ImageDraw

FIXTURES_DIR = Path(__file__).resolve().parent

FACE_IMAGE_PATH = FIXTURES_DIR / "test-face.jpg"
OVERSIZED_IMAGE_PATH = FIXTURES_DIR / "test2.jpg"  # ~10MB, 7724x5148


def make_image_bytes(
    format: str = "JPEG",
    mode: str = "RGB",
    size: tuple[int, int] = (400, 400),
    color=None,
) -> bytes:
    if color is None:
        color = {
            "RGB": (200, 100, 50),
            "RGBA": (200, 100, 50, 128),
            "L": 180,
        }.get(mode, (200, 100, 50))

    img = Image.new(mode, size, color=color)
    # Give it some non-uniform content so webp/blurhash encoding has real
    # signal instead of a flat swatch.
    draw = ImageDraw.Draw(img)
    draw.rectangle((size[0] // 4, size[1] // 4, size[0] // 2, size[1] // 2), fill=None, outline=(0, 0, 0) if mode != "L" else 0)

    buf = io.BytesIO()
    save_kwargs = {}
    if format == "JPEG" and mode == "RGBA":
        img = img.convert("RGB")
    img.save(buf, format=format, **save_kwargs)
    return buf.getvalue()


def corrupt_bytes() -> bytes:
    return b"this is definitely not an image, just plain text bytes"


def face_image_bytes() -> bytes:
    return FACE_IMAGE_PATH.read_bytes()


def no_face_image_bytes() -> bytes:
    # A synthetic gradient/shape image with no detectable face pattern.
    return make_image_bytes(format="JPEG", mode="RGB", size=(500, 500), color=(30, 60, 90))


def oversized_image_bytes() -> bytes:
    return OVERSIZED_IMAGE_PATH.read_bytes()
