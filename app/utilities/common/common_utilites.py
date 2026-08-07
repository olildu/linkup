from app.controllers.imagekit_controller import imagekit
from app.utilities.media.imgproxy_utilities import build_signed_url

def get_signed_imagekit(image_metadata : dict, expire_seconds : int = 7200):
    file_key = image_metadata['file_key']

    if file_key.startswith("sw/"):
        image_metadata['url'] = build_signed_url(file_key, expire_seconds=expire_seconds)
        return image_metadata

    image_metadata['url'] = imagekit.url({
        "path": file_key,
        "signed": True,
        "expire_seconds": expire_seconds
    })
    return image_metadata