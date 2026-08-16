from app.constants.global_constants import APPLICATION_KEY, APPLICATION_KEY_ID, BUCKET_NAME
from b2sdk.v2 import InMemoryAccountInfo, B2Api

info = InMemoryAccountInfo()
b2_api = B2Api(info)
b2_api.authorize_account("production", APPLICATION_KEY_ID, APPLICATION_KEY)
bucket = b2_api.get_bucket_by_name(BUCKET_NAME)