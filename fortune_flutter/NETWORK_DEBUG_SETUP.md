# Flutter iOS Network Debugging Setup

## Steps to Complete Network Configuration

### 1. Grant Local Network Permissions on macOS

1. Open **System Settings** > **Privacy & Security** > **Local Network**
2. Enable permissions for:
   - **Terminal** (or iTerm2 if you use it)
   - **VS Code** (if you use it)
   - **Xcode**
   - Any other IDE or terminal you use to run Flutter

### 2. Network Configuration Checklist

- [ ] Ensure Mac and iPhone are on the **same WiFi network**
- [ ] Disable any **VPN connections** on both devices
- [ ] Make sure iPhone is **unlocked** and has **trusted this computer**
- [ ] Check that no firewall is blocking port 5353 (mDNS)

### 3. Clean Build and Run

```bash
# Clean previous builds
flutter clean
cd ios && pod install && cd ..

# Run with verbose output to see connection details
flutter run -v
```

### 4. Alternative: Use Cable Connection

If wireless debugging continues to fail, use a cable connection:
```bash
# Run with cable connected
flutter run
```

### 5. Troubleshooting

If you still see connection errors:

1. **Reset Network Settings on iPhone**:
   - Settings > General > Transfer or Reset iPhone > Reset > Reset Network Settings

2. **Check Router Settings**:
   - Ensure multicast/mDNS is not blocked
   - Port 5353 should be open for local network

3. **Try with Hotspot**:
   - Create a hotspot from your Mac
   - Connect iPhone to Mac's hotspot
   - Run Flutter again

## Configuration Added

The following has been configured for your project:

1. **Info.plist**: Added NSBonjourServices with `_dartobservatory._tcp`
2. **Debug.xcconfig**: Added `DART_DEBUG_BONJOUR_SERVICE` for debug-only configuration
3. **NSLocalNetworkUsageDescription**: Added description for local network permission dialog

This configuration ensures that:
- Debug builds can use Bonjour for Flutter debugging
- Release builds won't include the Bonjour service (App Store compliant)
- Users will see a permission dialog for local network access when debugging