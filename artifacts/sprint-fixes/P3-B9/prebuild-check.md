# Prebuild Info.plist Verdict — P3-B9

**Verdict: SUSPECT** (version OK, duplicate URL scheme WILL reproduce)

## 1) CFBundleShortVersionString = 1.0.9  →  PASS

- `apps/mobile-rn/app.config.ts:89` sets `version: '1.0.9'`.
- Expo built-in `withVersion` (`@expo/config-plugins/build/ios/Version.js:27-34`) maps `config.ios?.version || config.version || '1.0.0'` → `CFBundleShortVersionString`. No `ios.version` override exists, so `1.0.9` wins.
- `eas.json` has `"appVersionSource": "remote"` but that property **only governs `CFBundleVersion`** (build number / `autoIncrement`). Short version string is NOT managed remotely. Confirmed by `withBuildNumber` being the only plugin touching `CFBundleVersion`.
- Local `ios/app/Info.plist` showing `1.0.8` is stale (`ios/` is gitignored, last prebuild was before the bump).

## 2) Duplicate `com.beyond.fortune` URL scheme  →  SUSPECT (will reproduce)

**Root cause found in Expo core, not in any third-party plugin.**

`@expo/config-plugins/build/ios/Scheme.js:35-49` (`setScheme`):
```js
const scheme = [...getScheme(config), ...getScheme(config.ios ?? {})];
if (config.ios?.bundleIdentifier) {
  scheme.push(config.ios.bundleIdentifier);   // <-- auto-appends bundle id
}
return { ...infoPlist, CFBundleURLTypes: [{ CFBundleURLSchemes: scheme }] };
```

Our config:
- `scheme: 'com.beyond.fortune'` (app.config.ts:92)
- `ios.bundleIdentifier: 'com.beyond.fortune'` (app.config.ts:102)

Because scheme **equals** the bundle id, Expo emits `CFBundleURLSchemes: ['com.beyond.fortune', 'com.beyond.fortune']` — a single URL type with a duplicated string. That reproduces exactly on every fresh `expo prebuild`. Not a plugin bug — it is Expo's "for parity with Turtle v1" convenience logic, which does not de-dupe.

### Third-party plugins cleared (no CFBundleURLTypes writes)

| Plugin | Verdict |
|--------|---------|
| `expo-apple-authentication` | only sets `CFBundleAllowMixedLocalizations` + `com.apple.developer.applesignin` entitlement. No URL types. |
| `expo-router` | no CFBundleURL writes |
| `expo-web-browser` | no CFBundleURL writes |
| `expo-iap` | writes CFBundleURLTypes **only when `enableOnside` is true** (via `modules.onside` / `ios.onside.enabled`). Our entry is a bare `'expo-iap'` with no options → `includeOnside = false` (`node_modules/expo-iap/plugin/build/withIAP.js:366-384`). Safe. |
| `@sentry/react-native`, `expo-notifications`, `expo-image-picker`, `expo-speech-recognition`, `llama.rn` | grepped — no CFBundleURL / URLSchemes / URLTypes references. |
| `plugins/with-ios-prebuilt-react-native.js` | `withPodfileProperties` only (sets `ios.buildReactNativeFromSource=false`). Does NOT touch Info.plist. |

## Recommended fix (to stop the duplicate on next prebuild)

Either:
1. Change `scheme` to something other than the bundle id (e.g. `scheme: 'ondo'` or `scheme: 'fortune'`). The bundle id will still be auto-appended by Expo, so deep links via `com.beyond.fortune://` keep working while the listed scheme becomes distinct. OR
2. Drop the `scheme` field entirely and rely solely on the auto-appended bundle id scheme. OR
3. Post-process via a tiny config plugin (`withInfoPlist`) that de-dupes `CFBundleURLTypes[].CFBundleURLSchemes` — most robust if you want to keep the current declaration.

Option (1) or (2) is simplest and removes the root cause.

## Files that must stay synced

- `apps/mobile-rn/app.config.ts` — sole source of truth for `version`, `scheme`, `ios.bundleIdentifier`, plugin list
- `apps/mobile-rn/eas.json` — `appVersionSource: remote` (affects build number only)
- `apps/mobile-rn/plugins/with-ios-prebuilt-react-native.js` — Podfile only, no Info.plist impact
- `apps/mobile-rn/ios/app/Info.plist` — **gitignored, regenerated**; never hand-edit expecting it to persist across prebuilds

## Summary

- Version 1.0.9 will appear correctly on fresh prebuild — **PASS**.
- Duplicate `com.beyond.fortune` URL scheme **will reproduce** because `scheme === ios.bundleIdentifier` and Expo's `setScheme` concatenates both without de-duplication. Fix at the config level (change or remove `scheme`), not at the Info.plist level.
