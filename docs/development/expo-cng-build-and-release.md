# Ondo Expo CNG local build and release policy

Ondo mobile is an Expo app using Continuous Native Generation (CNG). Expo remains the native-project generator and module ecosystem; **the default iOS binary path is local Xcode Archive → App Store Connect/TestFlight, not EAS Cloud Build**.

## Source of truth

- App config: `apps/mobile-rn/app.config.js`
- Legacy emergency EAS config: `apps/mobile-rn/eas.json`
- iOS extension targets: `apps/mobile-rn/targets/*/expo-target.config.json`
- Native config plugins: `apps/mobile-rn/plugins/*`
- Push server payload: `supabase/functions/_shared/notification_push.ts`

`eas.json`, Expo project IDs, and Expo push/update metadata may remain because existing installs, push tokens, or an explicitly approved emergency path can still depend on them. Their presence does not make EAS Cloud Build the normal release path.

## Do not rely on checked-in native folders

`apps/mobile-rn/.gitignore` ignores `/ios` and `/android`; `git ls-files apps/mobile-rn/ios` and `git ls-files apps/mobile-rn/android` should both stay at `0`.

Express native changes through Expo config, a config plugin, or an Expo target, then regenerate locally:

```bash
pnpm install
pnpm rn:native:prepare
pnpm rn:native:doctor
```

## Default build and release rule

- Local development and simulator QA: `pnpm rn:native:build` or `pnpm rn:ios:local`.
- Physical-iPhone development QA: `pnpm rn:native:device:run`.
- Any release-bound JS/TS/UI or native change: create a new local iOS archive and upload that archive to App Store Connect/TestFlight.
- Native capability, entitlement, extension, notification service, app icon, plist, pods, or dependency changes require a new binary. They cannot be delivered by OTA alone.
- `deploy:native` and `deploy:ota` are legacy compatibility commands. Do not run them unless the user explicitly requests and approves the specific EAS Cloud Build or EAS Update operation.

EAS Update is not the same as EAS Cloud Build, but it is also not Ondo's default release path. A change being OTA-compatible does not authorize an OTA publish.

## Local Xcode Archive → TestFlight

1. Start from a clean, frozen release SHA and make sure the version/build number in `app.config.js` is correct.
2. Generate the native project and pods locally:

   ```bash
   pnpm install
   pnpm rn:native:prepare
   pnpm rn:native:doctor
   ```

3. Open the generated workspace:

   ```bash
   pnpm rn:ios:xcode
   ```

4. In Xcode, select the Ondo app scheme and `Any iOS Device (arm64)` or a connected release device.
5. Confirm the Apple team, bundle ID `com.beyond.fortune`, signing, entitlements, app extensions, version, and build number.
6. Choose **Product → Archive**.
7. In Organizer, validate the archive, then choose **Distribute App → App Store Connect → Upload**.
8. Wait for App Store Connect processing and verify that the exact uploaded build appears in TestFlight.
9. Install that build on a real iPhone and run the release-specific smoke checks before claiming phone application.

TestFlight is the distribution channel, not the builder. There is no TestFlight per-upload build fee, but Apple Developer Program membership remains separate from Expo pricing.

## Verification before claiming fixed or released

1. `npx expo config --type introspect --json` confirms the generated config includes the expected bundle ID and entitlements.
2. `pnpm rn:native:build` succeeds for a local simulator build when applicable.
3. Xcode Organizer shows a successful local archive with the exact release SHA/version/build metadata.
4. App Store Connect finishes processing the uploaded archive and exposes the exact build in TestFlight.
5. A real iPhone installs that build and passes the affected runtime checks.
6. For push/avatar changes, a real push payload includes the expected character ID/image and the Notification Service Extension behavior is observed on device.

Do not report “TestFlight complete” from an archive alone, and do not report “applied to the physical phone” from an upload alone.

## Push avatar implementation

Ondo uses Expo Push API plus an iOS Notification Service Extension generated through `@bacons/apple-targets`:

1. Client stores Expo push tokens through `expo-notifications`.
2. Supabase Edge Functions send Expo push payloads with `richContent.image`, `mutableContent: true`, and character metadata.
3. `targets/notification-service/NotificationService.swift` attaches the character image and applies iOS Communication Notification metadata.
4. iOS still shows the app icon as the app source icon. The character face can appear as sender/avatar/rich attachment where iOS permits it.

## Important limitation

"Fully Expo" here means Expo CNG-generated native projects, not Expo Go and not mandatory EAS Cloud Build. Ondo depends on native modules and targets (`expo-dev-client`, IAP, ads, `llama.rn`, notification service extension, widgets), so Expo Go cannot represent production behavior.

## Historical documents

Dated files under `docs/audits/`, `docs/deployment/review/`, and `artifacts/` may record EAS builds that actually happened. Keep those facts as evidence, but do not use their old imperative commands as the current release procedure. This document and `CLAUDE.md` are the current operational source of truth.
