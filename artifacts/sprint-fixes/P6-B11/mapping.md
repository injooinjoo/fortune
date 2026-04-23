# Privacy Manifest Mapping — Ondo (온도) iOS

## Findings

- Existing `PrivacyInfo.xcprivacy` (at `apps/mobile-rn/ios/app/PrivacyInfo.xcprivacy`) has 4 Accessed API categories (FileTimestamp C617.1/0A2A.1/3B52.1, UserDefaults CA92.1, SystemBootTime 35F9.1, DiskSpace E174.1/85F4.1). `NSPrivacyCollectedDataTypes` is currently empty `<array/>`. Preserved verbatim below.
- `crash-reporting.ts`: `Sentry.setUser({ id: user.id })` is called — email explicitly stripped, but crashes ARE linked to user id. => Crash / Performance / Diagnostic data: `Linked: true`.
- `social-auth.ts` + Supabase: email, uid, display name persisted per user => all linked.
- Birth data: Apple's "Sensitive Info" does NOT include DOB (reserved for race/religion/orientation/biometric/health). Use `OtherUserContent`.
- Face photo: sent to Gemini (leaves device) — must declare `PhotosorVideos` even if not server-persisted.
- Speech-to-text audio: transmitted to edge function — declare `AudioData`.
- No tracking (no IDFA / no cross-site/app linkage) => `NSPrivacyTracking: false`, `NSPrivacyCollectedDataTypeTracking: false` on every entry.

## TypeScript object for `app.config.ts` → `ios.privacyManifests`

```ts
privacyManifests: {
  NSPrivacyTracking: false,
  NSPrivacyAccessedAPITypes: [
    {
      NSPrivacyAccessedAPIType: 'NSPrivacyAccessedAPICategoryFileTimestamp',
      NSPrivacyAccessedAPITypeReasons: ['C617.1', '0A2A.1', '3B52.1'],
    },
    {
      NSPrivacyAccessedAPIType: 'NSPrivacyAccessedAPICategoryUserDefaults',
      NSPrivacyAccessedAPITypeReasons: ['CA92.1'],
    },
    {
      NSPrivacyAccessedAPIType: 'NSPrivacyAccessedAPICategorySystemBootTime',
      NSPrivacyAccessedAPITypeReasons: ['35F9.1'],
    },
    {
      NSPrivacyAccessedAPIType: 'NSPrivacyAccessedAPICategoryDiskSpace',
      NSPrivacyAccessedAPITypeReasons: ['E174.1', '85F4.1'],
    },
  ],
  NSPrivacyCollectedDataTypes: [
    {
      NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeEmailAddress',
      NSPrivacyCollectedDataTypeLinked: true,
      NSPrivacyCollectedDataTypeTracking: false,
      NSPrivacyCollectedDataTypePurposes: [
        'NSPrivacyCollectedDataTypePurposeAppFunctionality',
      ],
    },
    {
      NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeName',
      NSPrivacyCollectedDataTypeLinked: true,
      NSPrivacyCollectedDataTypeTracking: false,
      NSPrivacyCollectedDataTypePurposes: [
        'NSPrivacyCollectedDataTypePurposeAppFunctionality',
        'NSPrivacyCollectedDataTypePurposeProductPersonalization',
      ],
    },
    {
      NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeUserID',
      NSPrivacyCollectedDataTypeLinked: true,
      NSPrivacyCollectedDataTypeTracking: false,
      NSPrivacyCollectedDataTypePurposes: [
        'NSPrivacyCollectedDataTypePurposeAppFunctionality',
      ],
    },
    {
      NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeDeviceID',
      NSPrivacyCollectedDataTypeLinked: true,
      NSPrivacyCollectedDataTypeTracking: false,
      NSPrivacyCollectedDataTypePurposes: [
        'NSPrivacyCollectedDataTypePurposeAppFunctionality',
        'NSPrivacyCollectedDataTypePurposeAnalytics',
      ],
    },
    {
      NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeCrashData',
      NSPrivacyCollectedDataTypeLinked: true,
      NSPrivacyCollectedDataTypeTracking: false,
      NSPrivacyCollectedDataTypePurposes: [
        'NSPrivacyCollectedDataTypePurposeAppFunctionality',
      ],
    },
    {
      NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypePerformanceData',
      NSPrivacyCollectedDataTypeLinked: true,
      NSPrivacyCollectedDataTypeTracking: false,
      NSPrivacyCollectedDataTypePurposes: [
        'NSPrivacyCollectedDataTypePurposeAnalytics',
      ],
    },
    {
      NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeOtherDiagnosticData',
      NSPrivacyCollectedDataTypeLinked: true,
      NSPrivacyCollectedDataTypeTracking: false,
      NSPrivacyCollectedDataTypePurposes: [
        'NSPrivacyCollectedDataTypePurposeAppFunctionality',
        'NSPrivacyCollectedDataTypePurposeAnalytics',
      ],
    },
    {
      NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypePhotosorVideos',
      NSPrivacyCollectedDataTypeLinked: true,
      NSPrivacyCollectedDataTypeTracking: false,
      NSPrivacyCollectedDataTypePurposes: [
        'NSPrivacyCollectedDataTypePurposeAppFunctionality',
      ],
    },
    {
      NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeAudioData',
      NSPrivacyCollectedDataTypeLinked: true,
      NSPrivacyCollectedDataTypeTracking: false,
      NSPrivacyCollectedDataTypePurposes: [
        'NSPrivacyCollectedDataTypePurposeAppFunctionality',
      ],
    },
    {
      NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeOtherUserContent',
      NSPrivacyCollectedDataTypeLinked: true,
      NSPrivacyCollectedDataTypeTracking: false,
      NSPrivacyCollectedDataTypePurposes: [
        'NSPrivacyCollectedDataTypePurposeAppFunctionality',
        'NSPrivacyCollectedDataTypePurposeProductPersonalization',
      ],
    },
    {
      NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypePurchaseHistory',
      NSPrivacyCollectedDataTypeLinked: true,
      NSPrivacyCollectedDataTypeTracking: false,
      NSPrivacyCollectedDataTypePurposes: [
        'NSPrivacyCollectedDataTypePurposeAppFunctionality',
      ],
    },
  ],
}
```

### Notes on each entry
- `OtherUserContent` covers: chat messages, birthdate, birth time, birth location, saju inputs (not Sensitive per Apple spec).
- `PhotosorVideos` covers face-reading photos (transmitted even if not persisted).
- `AudioData` covers STT microphone captures.
- `DeviceID` covers Expo push token + Sentry installation id.
- Sentry's Pod ships its own `PrivacyInfo.xcprivacy` for its SDK-internal API access; our manifest only declares what WE (the app) collect via Sentry — no duplication conflict.
- Sign-in email/name collected via Apple, Google, Kakao all map to the same Email+Name entries (no separate "Third-party Advertising" purpose — none of these providers are used for ads here).

## ASC "App Privacy" Answer Sheet (must match 1:1)

Tracking: **No** (no data used to track).

Data types collected (all "Linked to You", none used for Tracking):

| Category | Type | Linked | Purposes |
|---|---|---|---|
| Contact Info | Email Address | Yes | App Functionality |
| Contact Info | Name | Yes | App Functionality, Product Personalization |
| Identifiers | User ID | Yes | App Functionality |
| Identifiers | Device ID | Yes | App Functionality, Analytics |
| Diagnostics | Crash Data | Yes | App Functionality |
| Diagnostics | Performance Data | Yes | Analytics |
| Diagnostics | Other Diagnostic Data | Yes | App Functionality, Analytics |
| User Content | Photos or Videos | Yes | App Functionality |
| User Content | Audio Data | Yes | App Functionality |
| User Content | Other User Content | Yes | App Functionality, Product Personalization |
| Purchases | Purchase History | Yes | App Functionality |

Explicitly answer "No" for: Health & Fitness, Financial Info, Precise/Coarse Location, Sensitive Info, Contacts, Browsing History, Search History, Gameplay Content, Customer Support, Other Data Types, Advertising Data, and all Tracking questions.

## File preservation warning
The on-disk `ios/app/PrivacyInfo.xcprivacy` is regenerated by `@expo/config-plugins` on `expo prebuild`. The 4 Accessed API entries above MUST be emitted via `app.config.ts` (same structure) or they will be lost. Both blocks ship together in `ios.privacyManifests`.
