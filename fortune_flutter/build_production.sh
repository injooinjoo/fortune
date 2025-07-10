#!/bin/bash

# Fortune Flutter Production Build Script
# This script builds the Flutter app for production deployment

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_error ".env file not found!"
    print_info "Please create .env file from .env.production.example"
    exit 1
fi

# Verify environment is set to production
ENV_VALUE=$(grep "^ENVIRONMENT=" .env | cut -d '=' -f2)
if [ "$ENV_VALUE" != "production" ]; then
    print_error "ENVIRONMENT is not set to production in .env file!"
    print_info "Current value: $ENV_VALUE"
    exit 1
fi

# Clean previous builds
print_info "Cleaning previous builds..."
flutter clean
rm -rf build/
rm -rf ios/Pods
rm -rf ios/Podfile.lock
print_success "Clean completed"

# Get Flutter dependencies
print_info "Getting Flutter dependencies..."
flutter pub get
print_success "Dependencies installed"

# Run code generation if needed
print_info "Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs
print_success "Code generation completed"

# iOS Build
build_ios() {
    print_info "Starting iOS production build..."
    
    # Install iOS dependencies
    cd ios
    pod install
    cd ..
    
    # Build iOS
    flutter build ios --release --no-codesign
    
    print_success "iOS build completed"
    print_info "iOS build location: build/ios/iphoneos/"
    print_info "Next steps for iOS:"
    print_info "1. Open ios/Runner.xcworkspace in Xcode"
    print_info "2. Select 'Any iOS Device' as build target"
    print_info "3. Product → Archive"
    print_info "4. Distribute App to App Store Connect"
}

# Android Build
build_android() {
    print_info "Starting Android production build..."
    
    # Check if key.properties exists
    if [ ! -f "android/key.properties" ]; then
        print_error "android/key.properties not found!"
        print_info "Please create key.properties from key.properties.example"
        print_info "and generate your release keystore"
        return 1
    fi
    
    # Build APK
    print_info "Building APK..."
    flutter build apk --release
    print_success "APK build completed"
    print_info "APK location: build/app/outputs/flutter-apk/app-release.apk"
    
    # Build App Bundle
    print_info "Building App Bundle..."
    flutter build appbundle --release
    print_success "App Bundle build completed"
    print_info "AAB location: build/app/outputs/bundle/release/app-release.aab"
}

# Web Build (if needed)
build_web() {
    print_info "Starting web production build..."
    
    # Build for web
    flutter build web --release --web-renderer html
    
    print_success "Web build completed"
    print_info "Web build location: build/web/"
}

# Main script
echo "======================================"
echo "Fortune Flutter Production Build"
echo "======================================"

# Parse command line arguments
case "$1" in
    ios)
        build_ios
        ;;
    android)
        build_android
        ;;
    web)
        build_web
        ;;
    all)
        build_ios
        echo ""
        build_android
        echo ""
        build_web
        ;;
    *)
        echo "Usage: $0 {ios|android|web|all}"
        echo ""
        echo "Examples:"
        echo "  $0 ios      # Build for iOS only"
        echo "  $0 android  # Build for Android only"
        echo "  $0 web      # Build for web only"
        echo "  $0 all      # Build for all platforms"
        exit 1
        ;;
esac

echo ""
echo "======================================"
print_success "Production build completed!"
echo "======================================"

# Final reminders
print_info "Before deploying:"
print_info "1. Test the build thoroughly"
print_info "2. Verify all environment variables are correct"
print_info "3. Check that API endpoints are using HTTPS"
print_info "4. Ensure code signing is properly configured"