from pathlib import Path
from minio import Minio
from minio.error import S3Error

client = Minio(
    "localhost:9000",
    access_key="minioadmin",
    secret_key="minioadmin",
    secure=False,
)

BUCKET_NAME = "bronze"
LOCAL_ROOT = Path("data/minio_bucket/bronze")


def ensure_bucket():
    if not client.bucket_exists(BUCKET_NAME):
        client.make_bucket(BUCKET_NAME)
        print(f"Created bucket: {BUCKET_NAME}")
    else:
        print(f"Bucket already exists: {BUCKET_NAME}")


def upload_all():
    count = 0
    for orc_file in LOCAL_ROOT.rglob("*.orc"):
        relative_path = orc_file.relative_to(LOCAL_ROOT)
        object_name = str(relative_path).replace("\\", "/")
        client.fput_object(BUCKET_NAME, object_name, str(orc_file))
        count += 1
    print(f"Uploaded {count} files to bucket '{BUCKET_NAME}'.")


if __name__ == "__main__":
    ensure_bucket()
    upload_all()
