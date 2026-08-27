#!/usr/bin/env bash
# Quick test helper for Quick Look providers (use after building/running host app)
if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/sample.xd"
  exit 1
fi
FILE="$1"

echo "Clearing Quick Look caches..."
qlmanage -r
qlmanage -r cache

echo "Debug preview for $FILE"
qlmanage -d 4 -p "$FILE"
