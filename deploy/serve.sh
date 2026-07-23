#!/usr/bin/env bash
# Chạy 1 lần trên máy Mac host để dựng web server phục vụ site (clean URL .do).
# Yêu cầu: Docker Desktop đang chạy. Chạy script từ thư mục gốc repo:  bash deploy/serve.sh
set -euo pipefail

APP_NAME="opapp-html"
HOST_PORT="${HOST_PORT:-8090}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"   # thư mục gốc repo

echo ">> Deploy $ROOT lên nginx tại port $HOST_PORT"

docker rm -f "$APP_NAME" 2>/dev/null || true
docker run -d --name "$APP_NAME" --restart unless-stopped \
  -p "${HOST_PORT}:80" \
  -v "$ROOT":/usr/share/nginx/html:ro \
  -v "$ROOT/deploy/nginx.conf":/etc/nginx/conf.d/default.conf:ro \
  nginx:alpine

echo ">> Xong. Truy cập: http://10.0.4.85:${HOST_PORT}/  (vd /keiba/SpRaceInfo.do)"
