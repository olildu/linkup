import os
from imagekitio import ImageKit
import psycopg2
from dotenv import load_dotenv
from imagekitio.models.ListAndSearchFileRequestOptions import ListAndSearchFileRequestOptions

load_dotenv()

DB_HOST = os.environ.get("DATABASE_HOST")
DB_NAME = os.environ.get("DATABASE_NAME")
DB_USER = os.environ.get("DATABASE_USER")
DB_PASSWORD = os.environ.get("DATABASE_PASSWORD")
DB_PORT = os.environ.get("DATABASE_PORT")

# ImageKit config
imagekit = ImageKit(
    public_key='***REMOVED***',
    private_key='***REMOVED***',
    url_endpoint='https://ik.imagekit.io/linkup'
)

def get_imagekit_files(prefix):
    all_files = {}
    skip = 0
    limit = 100

    while True:
        options = ListAndSearchFileRequestOptions(
            path=prefix,
            skip=skip,
            limit=limit
        )
        result = imagekit.list_files(options)
        for f in result.list:
            if f.file_path.startswith(prefix):
                all_files[f.file_path] = f.file_id
        if len(result.list) < limit:
            break
        skip += limit

    return all_files

def get_db_profile_pictures():
    conn = psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        port=DB_PORT
    )
    cursor = conn.cursor()
    cursor.execute("SELECT profile_picture FROM users WHERE profile_picture IS NOT NULL")
    rows = cursor.fetchall()
    conn.close()
    return set(str(row[0]) for row in rows if row[0])

def get_db_media_files():
    conn = psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        port=DB_PORT
    )
    cursor = conn.cursor()
    cursor.execute("SELECT value FROM user_metadata WHERE key = 'photos'")
    rows = cursor.fetchall()
    conn.close()

    media_paths = set()
    for row in rows:
        value = row[0]
        if value:
            try:
                import json
                decoded = json.loads(value)
                if isinstance(decoded, list):
                    for media in decoded:
                        if isinstance(media, dict) and 'file_key' in media:
                            media_paths.add(media['file_key'].lstrip("/"))  # match with file_path
            except Exception:
                pass
    return media_paths

def compare_and_delete():
    # Fetch all profile pictures and media files from ImageKit
    pfp_files = get_imagekit_files("profile_pictures/")
    media_files = get_imagekit_files("media/")

    # Get all file paths in DB
    db_pfps = get_db_profile_pictures()
    db_media = get_db_media_files()

    unused_pfps = set(pfp_files.keys()) - db_pfps
    unused_media = set(media_files.keys()) - db_media

    print("Deleting unused profile pictures:")
    for path in unused_pfps:
        try:
            imagekit.delete_file(pfp_files[path])
            print(f"✅ Deleted: {path}")
        except Exception as e:
            print(f"❌ Failed to delete {path}: {e}")

    print("Deleting unused media files:")
    for path in unused_media:
        try:
            imagekit.delete_file(media_files[path])
            print(f"✅ Deleted: {path}")
        except Exception as e:
            print(f"❌ Failed to delete {path}: {e}")

if __name__ == "__main__":
    compare_and_delete()
