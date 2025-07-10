#!/bin/bash

# Fortune Flutter App Icon & Splash Screen Generator Script
# This script converts SVG files to PNG and generates app icons and splash screens

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSETS_DIR="$PROJECT_ROOT/assets"
ICONS_DIR="$ASSETS_DIR/icons"
IMAGES_DIR="$ASSETS_DIR/images"

echo -e "${GREEN}Fortune Flutter - App Icon & Splash Screen Generator${NC}"
echo "======================================================"

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}Error: ImageMagick is not installed.${NC}"
    echo "Please install ImageMagick first:"
    echo "  macOS: brew install imagemagick"
    echo "  Ubuntu/Debian: sudo apt-get install imagemagick"
    echo "  Windows: Download from https://imagemagick.org/script/download.php"
    exit 1
fi

# Check if rsvg-convert is installed (for better SVG conversion)
if ! command -v rsvg-convert &> /dev/null; then
    echo -e "${YELLOW}Warning: rsvg-convert is not installed. Using ImageMagick for SVG conversion.${NC}"
    echo "For better results, install librsvg:"
    echo "  macOS: brew install librsvg"
    echo "  Ubuntu/Debian: sudo apt-get install librsvg2-bin"
    USE_RSVG=false
else
    USE_RSVG=true
fi

# Function to convert SVG to PNG
convert_svg_to_png() {
    local svg_file=$1
    local png_file=$2
    local size=$3
    
    if [ "$USE_RSVG" = true ]; then
        rsvg-convert -w $size -h $size "$svg_file" -o "$png_file"
    else
        convert -background none -resize ${size}x${size} "$svg_file" "$png_file"
    fi
}

# Generate app icons from SVG
echo -e "\n${YELLOW}Converting app icons from SVG to PNG...${NC}"

# Main app icon (1024x1024)
if [ -f "$ICONS_DIR/app_icon.svg" ]; then
    convert_svg_to_png "$ICONS_DIR/app_icon.svg" "$ICONS_DIR/app_icon.png" 1024
    echo -e "${GREEN}✓ Generated app_icon.png (1024x1024)${NC}"
else
    echo -e "${RED}✗ app_icon.svg not found${NC}"
fi

# Foreground icon for Android adaptive icon
if [ -f "$ICONS_DIR/app_icon_foreground.svg" ]; then
    convert_svg_to_png "$ICONS_DIR/app_icon_foreground.svg" "$ICONS_DIR/app_icon_foreground.png" 1024
    echo -e "${GREEN}✓ Generated app_icon_foreground.png (1024x1024)${NC}"
else
    echo -e "${RED}✗ app_icon_foreground.svg not found${NC}"
fi

# Generate splash screen logos
echo -e "\n${YELLOW}Converting splash logos from SVG to PNG...${NC}"

# Light mode splash logo
if [ -f "$IMAGES_DIR/splash_logo.svg" ]; then
    convert_svg_to_png "$IMAGES_DIR/splash_logo.svg" "$IMAGES_DIR/splash_logo.png" 400
    echo -e "${GREEN}✓ Generated splash_logo.png (400x400)${NC}"
else
    echo -e "${RED}✗ splash_logo.svg not found${NC}"
fi

# Dark mode splash logo
if [ -f "$IMAGES_DIR/splash_logo_dark.svg" ]; then
    convert_svg_to_png "$IMAGES_DIR/splash_logo_dark.svg" "$IMAGES_DIR/splash_logo_dark.png" 400
    echo -e "${GREEN}✓ Generated splash_logo_dark.png (400x400)${NC}"
else
    echo -e "${RED}✗ splash_logo_dark.svg not found${NC}"
fi

# Run Flutter packages get to ensure dependencies are installed
echo -e "\n${YELLOW}Installing Flutter dependencies...${NC}"
cd "$PROJECT_ROOT"
flutter pub get

# Generate app icons using flutter_launcher_icons
echo -e "\n${YELLOW}Generating platform-specific app icons...${NC}"
flutter pub run flutter_launcher_icons

# Generate splash screens using flutter_native_splash
echo -e "\n${YELLOW}Generating platform-specific splash screens...${NC}"
flutter pub run flutter_native_splash:create

echo -e "\n${GREEN}✨ App icons and splash screens generated successfully!${NC}"
echo -e "${YELLOW}Note: Make sure to rebuild your app to see the changes.${NC}"

# Additional sizes for web and other platforms (optional)
if [ -f "$ICONS_DIR/app_icon.png" ]; then
    echo -e "\n${YELLOW}Generating additional icon sizes...${NC}"
    
    # Web favicon sizes
    for size in 16 32 64 128 256 512; do
        convert "$ICONS_DIR/app_icon.png" -resize ${size}x${size} "$ICONS_DIR/icon-${size}.png"
        echo -e "${GREEN}✓ Generated icon-${size}.png${NC}"
    done
    
    # Generate favicon.ico
    convert "$ICONS_DIR/app_icon.png" -resize 16x16 -resize 32x32 -resize 48x48 -resize 64x64 "$ICONS_DIR/favicon.ico"
    echo -e "${GREEN}✓ Generated favicon.ico${NC}"
fi

echo -e "\n${GREEN}🎉 All done! Your Fortune app is ready with beautiful icons and splash screens.${NC}"