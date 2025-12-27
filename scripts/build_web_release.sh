#!/bin/bash
# Flutter Web Release Build Script

set -e

echo "🌐 Flutter Web Release Build Starting..."

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

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
