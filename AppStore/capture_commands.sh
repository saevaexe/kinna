#!/bin/zsh

set -euo pipefail

DEVICE_NAME="${1:-iPhone 17 Pro Max}"
MODE="${2:-status-on}"
OUT_PATH="${3:-}"
FORCE_PREMIUM="${KINNA_SCREENSHOT_PREMIUM:-0}"

status_on() {
  xcrun simctl status_bar "$DEVICE_NAME" override \
    --time 09:41 \
    --dataNetwork wifi \
    --wifiBars 3 \
    --cellularMode active \
    --cellularBars 4 \
    --batteryState charged \
    --batteryLevel 100
}

status_off() {
  xcrun simctl status_bar "$DEVICE_NAME" clear
}

boot_and_launch() {
  xcrun simctl boot "$DEVICE_NAME" || true
  open -a Simulator
  sleep 2

  APP_PATH=$(ls -dt /Users/osmanseven/Library/Developer/Xcode/DerivedData/Kinna-*/Build/Products/Debug-iphonesimulator/Kinna.app 2>/dev/null | head -n 1)

  if [[ -z "${APP_PATH:-}" ]]; then
    echo "Kinna.app bulunamadi. Once xcodebuild build calistir."
    exit 1
  fi

  xcrun simctl install "$DEVICE_NAME" "$APP_PATH"

  if [[ "$FORCE_PREMIUM" == "1" ]]; then
    SIMCTL_CHILD_KINNA_SCREENSHOT_PREMIUM=1 \
      xcrun simctl launch "$DEVICE_NAME" com.osmanseven.kinna
  else
    xcrun simctl launch "$DEVICE_NAME" com.osmanseven.kinna
  fi
}

capture() {
  if [[ -z "$OUT_PATH" ]]; then
    echo "Capture mode icin ciktı yolu gerekli."
    echo "Ornek: ./capture_commands.sh 'iPhone 17 Pro Max' capture /Users/osmanseven/Kinna/design/AppStore_20260314/raw_tr/01_home_tr.png"
    exit 1
  fi

  mkdir -p "$(dirname "$OUT_PATH")"
  xcrun simctl io "$DEVICE_NAME" screenshot "$OUT_PATH"
  echo "Saved: $OUT_PATH"
}

case "$MODE" in
  boot)
    boot_and_launch
    ;;
  status-on)
    status_on
    ;;
  status-off)
    status_off
    ;;
  capture)
    capture
    ;;
  *)
    echo "Bilinmeyen mod: $MODE"
    echo "Kullanim:"
    echo "  ./capture_commands.sh 'iPhone 17 Pro Max' boot"
    echo "  KINNA_SCREENSHOT_PREMIUM=1 ./capture_commands.sh 'iPhone 17 Pro Max' boot"
    echo "  ./capture_commands.sh 'iPhone 17 Pro Max' status-on"
    echo "  ./capture_commands.sh 'iPhone 17 Pro Max' capture /path/to/file.png"
    echo "  ./capture_commands.sh 'iPhone 17 Pro Max' status-off"
    exit 1
    ;;
esac
