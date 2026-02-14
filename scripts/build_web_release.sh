#!/bin/bash
# Flutter Web Release Build Script

set -e

echo "🌐 Flutter Web Release Build Starting..."

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

echo "📦 Syncing .well-known assets for universal/app links..."
mkdir -p web/.well-known
cp docs/deployment/well-known/apple-app-site-association web/.well-known/apple-app-site-association
cp docs/deployment/well-known/assetlinks.json web/.well-known/assetlinks.json

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo "🔨 Building web release..."
flutter build web --release

echo "✅ Web build complete!"
echo "📁 Output: build/web/"
echo ""
echo "To serve locally:"
echo "  cd build/web && python3 -m http.server 8080"
