#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v pnpm >/dev/null 2>&1; then
  echo "[verify-rn-native-patch] pnpm is required." >&2
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "[verify-rn-native-patch] xcodebuild is required for native iOS verification." >&2
  exit 1
fi

echo "[verify-rn-native-patch] Running RN typecheck..."
pnpm rn:typecheck

echo "[verify-rn-native-patch] Running local native iOS simulator build (no EAS/Expo cloud)..."
pnpm rn:native:build

echo "[verify-rn-native-patch] OK"
