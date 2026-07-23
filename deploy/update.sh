#!/usr/bin/env bash
# Cập nhật site lên bản mới nhất từ Git. Nginx phục vụ live (file được mount),
# không cần restart container. Chạy tay hoặc qua cron/webhook.
set -euo pipefail

# cron có PATH tối thiểu -> khai báo rõ để tìm được git.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

before="$(git rev-parse HEAD)"
git pull --ff-only
after="$(git rev-parse HEAD)"

if [ "$before" != "$after" ]; then
  echo "$(date '+%F %T') updated $before -> $after"
else
  echo "$(date '+%F %T') no change ($after)"
fi
