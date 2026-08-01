FROM python:3.12-slim

# opencv-python (face detection in app/routes/common/common_endpoints.py) needs
# libGL/libglib at runtime; tzdata is required for the Asia/Kolkata APScheduler job.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ARG APP_VERSION=dev
ENV APP_VERSION=$APP_VERSION

EXPOSE 8002

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8002"]
