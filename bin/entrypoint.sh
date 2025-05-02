#!/bin/bash
set -e

# 古いPIDファイルを削除
rm -f /app/tmp/pids/server.pid

# コマンド実行
exec "$@"
