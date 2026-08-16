from imagekitio import ImageKit
from imagekitio.models.UploadFileRequestOptions import UploadFileRequestOptions

# ImageKit config
imagekit = ImageKit(
    public_key='***REMOVED***',
    private_key='***REMOVED***',
    url_endpoint='https://ik.imagekit.io/linkup'
)

expire_seconds = 600  # 10 minutes

options = UploadFileRequestOptions(folder='test', is_private_file=True)

upload = imagekit.upload(
    file=open('test/face.webp', "rb"), file_name='face.webp', options=options
)

# # Generate signed URL
# signed_url = imagekit.url({
#     "path": file_path,
#     "signed": True,
#     "expire_seconds": expire_seconds
# })

# print(f"[SIGNED URL] {signed_url}")
