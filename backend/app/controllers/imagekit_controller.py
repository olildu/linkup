from imagekitio import ImageKit

from app.constants.global_constants import IMAGEKIT_ENDPOINT_URL, IMAGEKIT_PRIVATE_KEY, IMAGEKIT_PUBLIC_KEY

imagekit = ImageKit(
    public_key= IMAGEKIT_PUBLIC_KEY,
    private_key=IMAGEKIT_PRIVATE_KEY,
    url_endpoint=IMAGEKIT_ENDPOINT_URL,
)
