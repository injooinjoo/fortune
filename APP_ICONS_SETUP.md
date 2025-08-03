# Fortune Flutter - App Icons & Splash Screen Setup Guide

This guide explains how to set up and customize app icons and splash screens for the Fortune Flutter application.

## Prerequisites

1. **ImageMagick** - Required for converting SVG to PNG
   ```bash
   # macOS
   brew install imagemagick
   
   # Ubuntu/Debian
   sudo apt-get install imagemagick
   
   # Windows
   # Download from https://imagemagick.org/script/download.php
   ```

2. **librsvg** (Optional but recommended for better SVG conversion)
   ```bash
   # macOS
   brew install librsvg
   
   # Ubuntu/Debian
   sudo apt-get install librsvg2-bin
   ```

## File Structure

```
fortune_flutter/
├── assets/
│   ├── icons/
│   │   ├── app_icon.svg              # Main app icon (source)
│   │   ├── app_icon.png              # Generated 1024x1024 PNG
│   │   ├── app_icon_foreground.svg   # Android adaptive icon foreground
│   │   └── app_icon_foreground.png   # Generated foreground PNG
│   └── images/
│       ├── splash_logo.svg           # Light mode splash logo
│       ├── splash_logo.png           # Generated light mode PNG
│       ├── splash_logo_dark.svg      # Dark mode splash logo
│       └── splash_logo_dark.png      # Generated dark mode PNG
├── pubspec.yaml                      # Flutter configuration with icon settings
└── scripts/
    └── generate_app_icons.sh         # Icon generation script
```

## Configuration

### App Icon Settings (in `pubspec.yaml`)

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#FFD700"  # Gold color
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/icons/app_icon.png"
  windows:
    generate: true
    image_path: "assets/icons/app_icon.png"
  macos:
    generate: true
    image_path: "assets/icons/app_icon.png"
```

### Splash Screen Settings (in `pubspec.yaml`)

```yaml
flutter_native_splash:
  color: "#FFD700"  # Gold background
  image: assets/images/splash_logo.png
  color_dark: "#1A1A1A"  # Dark mode background
  image_dark: assets/images/splash_logo_dark.png
  
  # Android 12+ specific
  android_12:
    image: assets/images/splash_logo.png
    image_dark: assets/images/splash_logo_dark.png
    color: "#FFD700"
    color_dark: "#1A1A1A"
    
  android: true
  ios: true
  web: true
  ios_content_mode: center
  fullscreen: true
  android_gravity: center
```

## Usage

### 1. Install Flutter Dependencies

```bash
cd fortune_flutter
flutter pub get
```

### 2. Generate Icons and Splash Screens

Run the provided script:

```bash
./scripts/generate_app_icons.sh
```

This script will:
- Convert SVG files to PNG format
- Generate platform-specific app icons
- Create splash screens for all platforms
- Generate additional web favicons

### 3. Manual Generation (Alternative)

If you prefer to run commands manually:

```bash
# Convert SVGs to PNGs (requires ImageMagick)
convert -background none -resize 1024x1024 assets/icons/app_icon.svg assets/icons/app_icon.png
convert -background none -resize 1024x1024 assets/icons/app_icon_foreground.svg assets/icons/app_icon_foreground.png
convert -background none -resize 400x400 assets/images/splash_logo.svg assets/images/splash_logo.png
convert -background none -resize 400x400 assets/images/splash_logo_dark.svg assets/images/splash_logo_dark.png

# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screens
flutter pub run flutter_native_splash:create
```

### 4. Build and Test

After generating icons and splash screens:

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run on iOS
flutter run -d ios

# Run on Android
flutter run -d android

# Build for release
flutter build ios
flutter build apk
```

## Customization

### Changing App Icon

1. Replace `assets/icons/app_icon.svg` with your new icon design
2. For Android adaptive icons, also update `app_icon_foreground.svg`
3. Run `./scripts/generate_app_icons.sh`

### Changing Splash Screen

1. Replace `assets/images/splash_logo.svg` (light mode)
2. Replace `assets/images/splash_logo_dark.svg` (dark mode)
3. Update colors in `pubspec.yaml` if needed
4. Run `./scripts/generate_app_icons.sh`

### Color Scheme

The Fortune app uses a gold theme:
- Primary Gold: `#FFD700`
- Dark Background: `#1A1A1A`
- Brown Accent: `#8B4513`

## Platform-Specific Notes

### iOS
- Icons are generated in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Splash screen uses `LaunchScreen.storyboard`
- Supports iOS 12.0+

### Android
- Icons are generated in `android/app/src/main/res/`
- Adaptive icons supported for Android 8.0+
- Splash screen supports Android 12+ splash screen API

### Web
- Favicons are generated in `web/icons/`
- Includes various sizes for different devices

## Troubleshooting

### SVG Conversion Issues

If SVG conversion fails:
1. Ensure ImageMagick is properly installed
2. Install librsvg for better SVG support
3. Check SVG file for complex gradients or filters

### Build Errors After Icon Generation

If you encounter build errors:
1. Run `flutter clean`
2. Delete `ios/Pods` and run `pod install`
3. Clean Android build: `cd android && ./gradlew clean`

### Icons Not Updating

If icons don't update:
1. Uninstall the app from device/simulator
2. Clean build folders
3. Rebuild and reinstall

## Design Guidelines

### Icon Design
- Use simple, recognizable shapes
- Ensure good contrast
- Test on both light and dark backgrounds
- Follow platform-specific guidelines

### Splash Screen Design
- Keep it simple and fast-loading
- Use brand colors consistently
- Center important elements
- Test on various screen sizes

## Resources

- [Flutter Launcher Icons](https://pub.dev/packages/flutter_launcher_icons)
- [Flutter Native Splash](https://pub.dev/packages/flutter_native_splash)
- [Android Adaptive Icons](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios/icons-and-images/app-icon/)