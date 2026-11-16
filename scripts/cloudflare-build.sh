#!/usr/bin/env bash
set -euo pipefail

echo "=== [Isyaratify] Memulai build Flutter Web untuk Cloudflare ==="

FLUTTER_VERSION="3.38.6"
FLUTTER_DIR="$HOME/flutter-sdk-$FLUTTER_VERSION"

if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -d "$FLUTTER_DIR" ]; then
    echo "Mengunduh Flutter SDK $FLUTTER_VERSION (stable)..."
    git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
  fi
  export PATH="$FLUTTER_DIR/bin:$PATH"
fi

flutter --version
flutter config --no-analytics --enable-web

cd frontend
flutter pub get

flutter build web --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="${SUPABASE_PUBLISHABLE_KEY:-}"

echo "=== [Isyaratify] Build Flutter Web selesai di frontend/build/web ==="
