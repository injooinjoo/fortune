# Ondo Expo CNG build/release policy

Ondo mobile is an Expo app using Continuous Native Generation (CNG). The repository should treat `apps/mobile-rn/ios` and `apps/mobile-rn/android` as generated output, not source of truth.

## Source of truth

- App config: `apps/mobile-rn/app.config.js`
- EAS config: `apps/mobile-rn/eas.json`
- iOS extension targets: `apps/mobile-rn/targets/*/expo-target.config.json`
- Native config plugins: `apps/mobile-rn/plugins/*`
- Push server payload: `supabase/functions/_shared/notification_push.ts`

## Do not rely on checked-in native folders

`apps/mobile-rn/.gitignore` ignores `/ios` and `/android`; `git ls-files apps/mobile-rn/ios` and `git ls-files apps/mobile-rn/android` should both stay at `0`.

If a native change is needed, express it through Expo config, a config plugin, or an Expo target, then regenerate via Expo/EAS.

## Build/update rule

- JS/TS/UI-only changes with unchanged native runtime: use `npm run deploy:ota --workspace @fortune/mobile-rn`.
- Native capability, entitlement, extension, notification service, app icon, plist, pods, or native dependency changes: use EAS native build.
- iOS notification sender/avatar behavior is native. It cannot be fixed by OTA alone; users need a new TestFlight/App Store build containing the Notification Service Extension and entitlements.

## Push avatar implementation

Ondo uses Expo Push API plus an iOS Notification Service Extension generated through `@bacons/apple-targets`:

1. Client stores Expo push tokens through `expo-notifications`.
2. Supabase Edge Functions send Expo push payloads with `richContent.image`, `mutableContent: true`, and character metadata.
3. `targets/notification-service/NotificationService.swift` attaches the character image and applies iOS Communication Notification metadata.
4. iOS still shows the app icon as the app source icon. The character face can appear as sender/avatar/rich attachment where iOS permits it.

## Verification before claiming fixed

1. `npx expo config --type introspect --json` confirms generated config includes:
   - `ios.bundleIdentifier = com.beyond.fortune`
   - `ios.entitlements.aps-environment = production`
   - `ios.entitlements.com.apple.developer.usernotifications.communication = true`
   - `updates.url = https://u.expo.dev/f7a724ea-b46e-494a-b83c-94e7a6fec02a`
2. EAS build finishes with `distribution = STORE`.
3. Build is processed and available in TestFlight/App Store Connect.
4. A real device installs the new build and receives a real push payload that includes a character id and image.

## Important limitation

"Fully Expo" here means Expo CNG/EAS-managed native generation, not Expo Go. Ondo depends on native modules and native targets (`expo-dev-client`, IAP, ads, llama.rn, notification service extension, widgets), so Expo Go cannot represent production behavior.
