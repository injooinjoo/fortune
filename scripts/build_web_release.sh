#!/bin/bash
# Flutter web build + review asset sync for static hosting checks

set -euo pipefail

echo "🌐 Flutter Web Release Build Starting..."

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

echo "📦 Syncing review assets for universal/app links..."
mkdir -p web/.well-known
cp public/.well-known/apple-app-site-association web/.well-known/apple-app-site-association
cp public/.well-known/assetlinks.json web/.well-known/assetlinks.json

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo "🔨 Building web release..."
flutter build web --release

echo "📄 Copying public review pages into build output..."
mkdir -p build/web/.well-known
cp public/privacy.html build/web/privacy.html
cp public/terms.html build/web/terms.html
cp public/support.html build/web/support.html
cp public/.well-known/apple-app-site-association build/web/.well-known/apple-app-site-association
cp public/.well-known/assetlinks.json build/web/.well-known/assetlinks.json

echo "✅ Web build complete!"
echo "📁 Output: build/web/"
echo ""
echo "To serve locally:"
echo "  cd build/web && python3 -m http.server 8080"
