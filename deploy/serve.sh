#!/usr/bin/env bash
# Dựng web server phục vụ site (clean URL .do) bằng Caddy — KHÔNG cần Docker.
# Chạy 1 lần trên máy build. Yêu cầu: đã cài caddy (brew install caddy).
# Cách dùng:  bash deploy/serve.sh    (đổi port: HOST_PORT=8095 bash deploy/serve.sh)
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

HOST_PORT="${HOST_PORT:-8090}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"      # thư mục gốc repo
CADDYFILE="$ROOT/deploy/Caddyfile"

if ! command -v caddy >/dev/null 2>&1; then
  echo "!! Chưa có caddy. Cài bằng:  brew install caddy" >&2
  exit 1
fi

echo ">> Serve $ROOT tại port $HOST_PORT (Caddy)"

# Dừng caddy cũ (nếu có) rồi start lại nền. try_files đọc file live từ disk,
# nên sau này chỉ cần git pull là site cập nhật, không phải restart.
caddy stop 2>/dev/null || true
SITE_ROOT="$ROOT" HOST_PORT="$HOST_PORT" \
  caddy start --config "$CADDYFILE" --adapter caddyfile

echo ">> Xong. Truy cập: http://10.0.4.85:${HOST_PORT}/  (vd /keiba/SpRaceInfo.do)"
