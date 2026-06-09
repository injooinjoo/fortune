# Ondo local native iOS testing

Use this path when you want to test Ondo without Expo Go, Expo tunnel, EAS build, or EAS OTA spend.

## What this is

- Local native iOS testing via Xcode / iOS Simulator / physical iPhone.
- Uses the generated `apps/mobile-rn/ios/` project.
- Uses React Native Community CLI for local `run-ios`.

## What this is not

- It does not publish an EAS OTA update.
- It does not create a cloud EAS native build.
- It does not remove every Expo module from the app code. Ondo still uses Expo Router and Expo native modules, so `expo prebuild` remains the local native-project generator.

## First-time setup

From the repo root:

```bash
pnpm install
pnpm rn:native:prepare
```

`pnpm rn:native:prepare` does three things:

1. Generates `apps/mobile-rn/ios/` locally if it does not exist.
2. Runs CocoaPods locally.
3. Prints a doctor report with the discovered workspace and schemes.

```bash
pnpm rn:native:build
```

This runs local `xcodebuild` against the generated workspace/scheme and an available iPhone Simulator. It disables Sentry sourcemap auto-upload for the local build so missing release credentials do not block simulator verification.

## Run in Xcode

```bash
pnpm rn:ios:xcode
```

Then in Xcode:

1. Select an iOS Simulator or a connected iPhone.
2. Ensure the signing team is set if using a physical iPhone.
3. Press Run.

## Run from CLI

In one terminal:

```bash
pnpm rn:start:native
```

In another terminal:

```bash
pnpm rn:ios:local
```

The local helper discovers the generated `.xcworkspace` and the app scheme automatically, so it does not rely on a hard-coded workspace name.

## Remote wireless testing from another network/region

Use this when the iPhone is not on the same Wi-Fi/LAN as this Mac. This is still the local native Debug app path: no Expo Go, no Expo tunnel, no EAS build, and no EAS OTA.

### One-time phone install

The phone needs a Debug native build that includes the remote-bundle handler:

```bash
pnpm rn:native:device:run
```

This install step still requires the iPhone to be connected/trusted at least once, because it is a local Xcode/CoreDevice development build. After it is installed, the JS bundle can be switched remotely with the deep link below while the tunnel is running.

### Start the public Metro tunnel

```bash
pnpm rn:start:remote-native
```

The command starts React Native Metro on `127.0.0.1:8081`, exposes it with `cloudflared tunnel`, and prints an iPhone link like:

```text
com.beyond.fortune://dev-bundle?url=https%3A%2F%2F...trycloudflare.com%2F.expo%2F.virtual-metro-entry.bundle%3Fplatform%3Dios%26dev%3Dtrue%26minify%3Dfalse
```

Send/open that link on the installed iPhone, then fully quit and reopen Ondo. The Debug app stores the bundle URL in `UserDefaults` and loads JavaScript from the Cloudflare tunnel on launch.

Keep the terminal running while testing. When the tunnel stops, the remote bundle URL becomes unreachable; start the command again and open the new printed link.

### Reset back to normal local Metro

If the app keeps trying an old tunnel URL, reinstall the Debug app or clear app data. A fresh Debug install falls back to the normal local Metro bundle root.

## Health check

```bash
pnpm rn:native:doctor
```

Expected after preparation:

- `iosDirectoryExists: true`
- `podfileExists: true`
- `workspace` points to an `.xcworkspace`
- `pnpm rn:native:build` succeeds for a local Debug simulator build

## Physical iPhone check

```bash
pnpm rn:native:device:build
pnpm rn:native:device:install
pnpm rn:native:device:launch
# or all together:
pnpm rn:native:device:run
```

The device build uses local `xcodebuild -destination generic/platform=iOS -allowProvisioningUpdates`, so Xcode can create local development provisioning profiles for `com.beyond.fortune` and the app extensions when the Apple Development account is configured.

For install/launch, the iPhone must be connected and available to CoreDevice/devicectl:

- paired/trusted with this Mac
- unlocked
- Developer Mode enabled
- `devicectl` device tunnel connected, not `tunnelState=unavailable`

If the phone is paired but the tunnel is unavailable, the helper fails early with a clear message instead of claiming the real-phone run succeeded.

## Existing Expo commands

The old commands still exist for compatibility:

- `pnpm --filter @fortune/mobile-rn start`
- `pnpm --filter @fortune/mobile-rn ios`
- `pnpm --filter @fortune/mobile-rn deploy:ota`
- `pnpm --filter @fortune/mobile-rn deploy:native`

Do not use `deploy:ota` or `deploy:native` unless the user explicitly approves EAS spend/deployment.
