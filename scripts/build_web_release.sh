#!/bin/bash
# Flutter Web Release Build Script
#
# IconData tree-shaking 에러 해결:
# fortune_category.dart에서 Remote Config를 위해 IconData를 런타임에 동적 생성하므로
# --no-tree-shake-icons 플래그가 필수입니다.

set -e

echo "🌐 Flutter Web Release Build Starting..."

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web with no tree-shake-icons
# (필수: fortune_category.dart의 동적 IconData 생성 때문)
echo "🔨 Building web release..."
flutter build web --release --no-tree-shake-icons

echo "✅ Web build complete!"
echo "📁 Output: build/web/"
echo ""
echo "To serve locally:"
echo "  cd build/web && python3 -m http.server 8080"
