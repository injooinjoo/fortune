# iOS Simulator & Real-device Readiness Reviewer QA Report

## Verdict
- **NO-GO**
- 핵심 리스크: **로컬 시뮬레이터 빌드는 성공하지만 clean install/CLI dev-server/실기기 빌드 경로가 막혀, 체크리스트의 iOS E2E와 실제 iPhone 전용 항목을 아직 릴리스 근거로 삼을 수 없다.**

## Scope & Method
- 체크리스트: `docs/audits/2026-06-ondo-full-audit/checklists/12-ios-simulator-real-device.md`
- 코드 수정: **하지 않음**. 증거 파일/보고서만 생성.
- 실행/조사한 항목:
  - `pnpm rn:native:doctor`
  - `pnpm rn:typecheck`
  - `pnpm rn:native:build`
  - Simulator clean uninstall/install/launch via `xcrun simctl`
  - `pnpm rn:start:native`
  - `pnpm --filter @fortune/mobile-rn exec expo start --dev-client --port 8082/8086 --localhost --non-interactive`
  - `pnpm rn:native:device:build`
  - `xcrun devicectl list devices --json-output ...`
  - 관련 코드/문서/설정 조사: `package.json`, `apps/mobile-rn/package.json`, `apps/mobile-rn/scripts/local-ios.mjs`, `apps/mobile-rn/app.config.js`, `apps/mobile-rn/eas.json`, `apps/mobile-rn/src/lib/push-notifications.ts`, `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx`, `apps/mobile-rn/src/lib/social-auth.ts`, `docs/development/local-native-ios-testing.md`

## P0
- 없음.
  - 현재 확인된 이슈는 릴리스/QA readiness 차단에 해당하지만, 이 감사 범위에서 결제/토큰 손실, 보안/개인정보 누출, 앱 전면 사용 불가의 실제 프로덕션 재현 증거는 확보되지 않았다.

## P1

### P1-1. Physical iPhone local build가 provisioning profile 부재로 실패하여 실기기 필수 항목 전체가 미검증 상태
- **영향**: 체크리스트의 real-device 필수 항목(push, foreground/background push, push click deep link, App Store IAP sandbox, Sign in with Apple, camera/photo, microphone, audio playback, haptics, TestFlight runtime compatibility, iPad/manual review evidence)을 실제 iPhone에서 검증할 수 없다.
- **재현 단계**:
  1. repo root에서 `pnpm rn:native:device:build` 실행.
  2. iPhoneOS generic destination build가 code signing 단계에서 실패.
- **증거**:
  - 로그: `docs/audits/2026-06-ondo-full-audit/evidence/logs/12-native-device-build.log`
  - 핵심 로그:
    - `No profiles for 'com.beyond.fortune.notification-service' were found ... Automatic signing is disabled ... (in target 'OndoNotificationService')`
    - `No profiles for 'com.beyond.fortune.widgets' were found ... (in target 'OndoWidgets')`
    - `No profiles for 'com.beyond.fortune' were found ... (in target 'app')`
    - `** BUILD FAILED **`, `Exit status 65`
  - 설정/코드:
    - `apps/mobile-rn/app.config.js:116-123` — bundle id `com.beyond.fortune`, `appleTeamId: '5F7CN7Y54D'`, `usesAppleSignIn: true`.
    - `apps/mobile-rn/app.config.js:145-155` — main app entitlement에 `aps-environment: production`, App Group `group.com.beyond.fortune.widgets`.
    - `apps/mobile-rn/ios/app/app.entitlements:5-13` — `aps-environment`, Apple sign-in, app group entitlement 존재.
  - 물리 기기 발견 상태:
    - `xcrun devicectl list devices` 결과: `Jacob’s iPhone 16 Pro`, identifier `F3F698CE-AD0B-5697-84D6-52CFC5477DCF`, iOS `26.5`, `developerModeStatus=enabled`, `pairingState=paired`, but `tunnelState=unavailable`.
- **수정 방향**:
  - 무료/공식 로컬 우선: Xcode에서 Team `5F7CN7Y54D`로 automatic signing을 켜거나 `xcodebuild -allowProvisioningUpdates`를 helper에서 선택적으로 지원한다.
  - main app뿐 아니라 extension bundle id `com.beyond.fortune.notification-service`, `com.beyond.fortune.widgets`의 Development provisioning profile/App Group capability를 함께 생성/매핑한다.
  - helper에 `DEVICE_UDID`/`DEVELOPMENT_TEAM`/`ALLOW_PROVISIONING_UPDATES=1` 같은 opt-in env를 두고, 기본값은 비용 없는 로컬 빌드 유지.
- **검증 방법**:
  1. `pnpm rn:native:device:build`가 exit 0로 성공.
  2. `pnpm rn:native:device:install`로 physical iPhone에 설치.
  3. `pnpm rn:native:device:launch` 후 실제 화면 캡처/영상 확보.
  4. real-device 항목별 DB/log row 확인: `notification_devices`, `user_notification_preferences`, purchase verification 함수 로그/transaction id, auth provider row 등.

### P1-2. 문서화된 CLI dev server 경로(`pnpm rn:start:native`)가 즉시 실패하여 local native simulator E2E 진입이 불안정
- **영향**: `docs/development/local-native-ios-testing.md`가 안내하는 “한 터미널 `pnpm rn:start:native`, 다른 터미널 `pnpm rn:ios:local`” 경로가 현재 실패한다. clean install 이후 dev client가 bundle을 받아 실제 앱 UX로 들어가는 표준 로컬 루프가 끊긴다.
- **재현 단계**:
  1. repo root에서 `pnpm rn:start:native` 실행.
  2. React Native CLI가 Metro config package를 찾지 못하고 종료.
- **증거**:
  - 실행 로그:
    - `error Cannot resolve '@react-native/metro-config'. Ensure it is listed in your project's devDependencies.`
    - `@fortune/mobile-rn@1.0.14 start:native: react-native start --port 8081`, `Exit status 1`
  - 스크립트/문서:
    - `package.json:43` — root script `rn:start:native`.
    - `apps/mobile-rn/package.json:8` — `start:native: react-native start --port 8081`.
    - `docs/development/local-native-ios-testing.md:50-64` — CLI run path로 `pnpm rn:start:native` → `pnpm rn:ios:local` 안내.
- **수정 방향**:
  - `@react-native/metro-config`를 올바른 workspace devDependency로 추가하거나, Expo dev-client 기반 명령(`expo start --dev-client`)으로 문서/스크립트를 통일한다.
  - `start:native`가 포트 충돌/Metro config 누락을 preflight로 감지하고 명확한 오류를 출력하게 한다.
- **검증 방법**:
  1. `pnpm rn:start:native` exit 0 및 Metro ready 로그 확인.
  2. clean install 앱이 dev launcher에서 앱 bundle로 진입.
  3. app restart/background-foreground 후에도 bundle reconnect 확인.

### P1-3. Simulator clean install 단독 launch가 실제 앱이 아니라 Expo Development Build/Dev Launcher로 시작되어 E2E 항목을 “앱 성공”으로 판정할 수 없음
- **영향**: 시뮬레이터 install 자체는 성공했지만, clean launch 시 앱 UX가 바로 열리지 않는다. dev server 연결/launcher 조작이 필요하고, 이는 체크리스트의 clean install, splash/welcome, guest flow, signup/login, chat, fortune generation, result reopen, token top-up, settings, restart, background/foreground, network failure simulation을 자동/반복 가능한 E2E로 검증하기 어렵게 만든다.
- **재현 단계**:
  1. `pnpm rn:native:build`로 simulator build 생성.
  2. `xcrun simctl uninstall <UDID> com.beyond.fortune`
  3. `xcrun simctl install <UDID> apps/mobile-rn/ios/build/Build/Products/Debug-iphonesimulator/app.app`
  4. `xcrun simctl launch <UDID> com.beyond.fortune`
- **증거**:
  - 빌드 성공 로그: `docs/audits/2026-06-ondo-full-audit/evidence/logs/12-native-simulator-build.log`
    - `** BUILD SUCCEEDED **`
  - launch 로그: `docs/audits/2026-06-ondo-full-audit/evidence/logs/12-ios-clean-install-launch.log`
    - `http://localhost:19000/status`, `http://localhost:19002/status`, `http://localhost:19001/status`, `http://localhost:8081/status`, `http://localhost:8085/status` 등 dev server 탐색.
    - 다수 `Connection refused`.
  - 스크린샷:
    - `docs/audits/2026-06-ondo-full-audit/evidence/screenshots/12-ios-clean-install-launch.png` — “온도 Development Build”, “DEVELOPMENT SERVERS”, `http://localhost:8082`, “Enter URL manually”가 보이는 Expo dev launcher 화면. Apple Account Verification prompt도 함께 노출.
  - 의존성/빌드 성격:
    - `apps/mobile-rn/package.json:40` — `expo-dev-client` 포함.
    - `apps/mobile-rn/eas.json:7-10` — development profile은 `developmentClient: true`.
- **수정 방향**:
  - QA 목적을 분리한다.
    - Simulator dev-client E2E: dev server를 명시적으로 띄우고 URL을 고정해 검증.
    - Release/TestFlight readiness: dev launcher가 없는 Release configuration 또는 EAS/TestFlight 빌드로 검증.
  - helper에 `simulator-run` 플로우를 추가해 `build → install → expo dev server ready → open URL → screenshot/log capture`를 한 명령으로 묶는다.
  - release-like simulator build가 필요한 경우 Debug dev-client와 별도 scheme/configuration을 만든다.
- **검증 방법**:
  1. clean install 후 dev-client 테스트라면 앱 bundle 진입 스크린샷 확보.
  2. release-like 테스트라면 dev launcher 없이 splash/welcome이 바로 열리는 스크린샷 확보.
  3. restart/background/foreground/network-offline 각각 로그와 화면 캡처 저장.

### P1-4. Simulator E2E가 Apple Account Verification prompt + Expo dev menu overlay에 의해 중단되어 핵심 UX 경로를 끝까지 검증하지 못함
- **영향**: Expo dev server를 별도 포트로 띄운 뒤 앱 content 일부는 보였지만, 시스템 Apple 계정 prompt와 dev menu overlay가 화면을 막아 guest/chat/fortune/top-up/settings 경로를 실제로 완료하지 못했다.
- **재현 단계**:
  1. 포트 8082는 다른 프로젝트(`word_master`, pid 49801)가 사용 중이라 `expo start --dev-client --port 8082 --localhost --non-interactive` 실패.
  2. `expo start --dev-client --port 8086 --localhost --non-interactive` 실행.
  3. `xcrun simctl openurl <UDID> "com.beyond.fortune://expo-development-client/?url=http%3A%2F%2F127.0.0.1%3A8086"`
  4. 스크린샷 확보.
- **증거**:
  - 포트 충돌 로그:
    - `Port 8082 is running word_master in another window /Users/injoo/Desktop/Dev/word_master (pid 49801)`
    - `Input is required, but 'npx expo' is in non-interactive mode. Required input: Use port 8083 instead?`
  - 스크린샷:
    - `docs/audits/2026-06-ondo-full-audit/evidence/screenshots/12-ios-app-after-expo-dev-server.png` — dev menu 설명과 `Continue` 버튼이 보이고, Apple Account Verification prompt가 전면 차단.
    - `docs/audits/2026-06-ondo-full-audit/evidence/screenshots/12-ios-app-loaded-attempt.png` — 배경에 앱 “메시지” 화면과 캐릭터 목록 일부가 보이나 Apple Account Verification prompt 및 dev menu overlay가 여전히 UX를 가림.
  - 코드 참고:
    - `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:856-866` — StoreKit init을 cold-start에서 지연하려는 주석/로직이 있으나, 테스트 환경에서는 Apple 계정 verification prompt가 여전히 노출됨. 이 prompt가 앱 코드 때문인지 시뮬레이터 계정/StoreKit 상태 때문인지는 추가 분리가 필요.
- **수정 방향**:
  - 시뮬레이터 테스트 전 Apple ID/Sandbox account 상태를 정리하는 preflight 문서화: Settings에서 sign-out 또는 verification 완료, StoreKit transaction queue reset 여부 확인.
  - dev menu `Continue`/launcher 자동 dismiss 또는 dev-client URL 진입 후 overlay 없는 상태를 확보하는 QA runbook 작성.
  - StoreKit 관련 prompt가 앱 cold-start에서 반복되는지 확인하려면, 구매 화면 진입 전/후 로그를 분리하고 StoreKit listener만으로 prompt가 뜨는지 regression test한다.
- **검증 방법**:
  1. Apple prompt 없는 clean simulator에서 앱 첫 화면을 캡처.
  2. guest → chat send/reply → fortune generation → result reopen → token top-up → settings → restart → background/foreground까지 각 단계 스크린샷/로그 확보.
  3. 네트워크 차단(`simctl`/Network Link Conditioner 등) 시 Supabase/API 실패 UI가 사용자를 막지 않는지 확인.

## P2

### P2-1. Push notification은 코드상 실기기-only로 분리되어 있으나, 실제 foreground/background/click deep link evidence가 없다
- **영향**: 시뮬레이터 성공을 push 성공으로 오인하지 않도록 방어는 되어 있으나, real-device proof가 없어서 TestFlight/App Store 전 push UX 신뢰도가 낮다.
- **증거**:
  - `apps/mobile-rn/src/lib/push-notifications.ts:558-572` — `expo-notifications`, `expo-device`를 로드하고 `!Device.isDevice`면 `{ skipped: true, reason: 'not a physical device' }` 반환.
  - `apps/mobile-rn/src/lib/push-notifications.ts:368-457` — tap/foreground receive listener 설치 및 payload normalization.
  - `apps/mobile-rn/src/lib/push-notifications.ts:520-538` — iOS permission request는 `promptIfNotGranted`일 때만 JIT로 요청.
  - `apps/mobile-rn/src/lib/push-notifications.ts:902-977` — character 첫 메시지 시 soft ask → OS prompt → token registration 흐름.
- **수정 방향**:
  - real-device runbook에 `notification_devices` row, Expo push token, foreground receive 로그, background tap route(`/chat?characterId=...`) 스크린샷을 필수 evidence로 지정한다.
  - iOS NSE는 로컬 푸시로 검증 불가라는 코드 주석(`push-notifications.ts:718-727`)에 맞춰 서버 원격 푸시로만 검증한다.
- **검증 방법**:
  1. 실제 iPhone에서 로그인 후 첫 캐릭터 메시지 전송.
  2. soft ask/OS prompt 승인.
  3. DB `notification_devices` row와 `user_notification_preferences` row 확인.
  4. foreground 수신, background 수신, notification tap 후 해당 채팅 진입 영상 저장.

### P2-2. IAP sandbox는 simulator/code review만 가능했고 실제 App Store sandbox 결제 evidence가 없다
- **영향**: token top-up/premium screen은 결제/매출 핵심 경로라 실제 sandbox transaction 전까지 GO 불가.
- **증거**:
  - `apps/mobile-rn/package.json:45` — `expo-iap` 사용.
  - `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:643-672` — StoreKit connection 및 consumable product fetch를 premium 화면 시점에 수행.
  - `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:753-785` — iOS receipt 확인 후 remote purchase verification 및 transaction finish.
  - `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:923-978` — `purchaseProduct`가 로그인/session과 store product 존재를 요구하고 iOS는 `apple: { sku: productId }`로 구매 요청.
  - `apps/mobile-rn/src/lib/premium-remote.ts:269-299` — `payment-verify-purchase` edge function 호출 후 `tokensAdded`, `transactionId`, `valid` 처리.
- **수정 방향**:
  - 실기기 provisioning 해결 후 sandbox Apple ID로 token consumable 1건, subscription/non-consumable 복원 1건을 각각 검증한다.
  - 결제 성공 후 remote verification DB/function log와 token balance 증가 row를 report evidence로 남긴다.
- **검증 방법**:
  1. 실제 iPhone + Sandbox account에서 token top-up 화면 진입.
  2. 상품 가격 표시 → 구매 → Apple sandbox sheet → 영수증 verify → token balance 증가 확인.
  3. 실패/취소 시 `isPurchasePending`이 해제되고 중복 과금/중복 token add가 없는지 확인.

### P2-3. Expo/EAS 비용 절감 기준은 일부 충족하지만, “Expo Go 가능/불가능” 분리가 실제 체크리스트 evidence로 문서화되지 않음
- **영향**: QA/개발자가 Expo Go에서 안 되는 항목(push/IAP/Apple auth/native extensions 등)을 시뮬레이터 성공으로 착각할 수 있다.
- **증거**:
  - `docs/development/local-native-ios-testing.md:1-16` — EAS/Expo Go/OTA spend 없이 local native test 경로 설명.
  - `docs/development/local-native-ios-testing.md:79-88` — EAS `deploy:ota`, `deploy:native`는 명시 승인 전 사용 금지.
  - Native modules present:
    - `apps/mobile-rn/package.json:40-50` — `expo-dev-client`, `expo-haptics`, `expo-iap`, `expo-image-picker`, `expo-notifications`, `expo-secure-store` 등.
    - `apps/mobile-rn/package.json:53-61` — `expo-speech-recognition`, `llama.rn`, `react-native-google-mobile-ads`, `react-native-shared-group-preferences` 등.
  - `apps/mobile-rn/app.config.js:419-435` — production build/update secrets 누락 시 fail-fast.
- **수정 방향**:
  - audit 문서 또는 local native doc에 다음 매트릭스를 추가한다.
    - Expo Go 가능: 순수 JS UI, 일부 Supabase flow, non-native 문구/상태 변경.
    - Dev-client/local native 필요: IAP, push, Apple auth, camera/photo, microphone/speech, haptics, AdMob, widgets/NSE, on-device LLM/native modules.
    - EAS/TestFlight 필요: App Store sandbox 결제 최종, APNs/TestFlight runtime, App Review/iPad manual evidence.
  - OTA로 충분한 변경과 native rebuild 필요한 변경을 release checklist에 연결한다.
- **검증 방법**:
  - 문서 업데이트 후 각 feature PR에서 `OTA OK` / `native rebuild required` 라벨 또는 checklist를 사용한다.

## P3

### P3-1. Sentry sourcemap upload disable은 로컬 빌드에 반영되어 있으나, warning 정리가 필요
- **증거**:
  - `apps/mobile-rn/scripts/local-ios.mjs:14-18` — local native build env에서 `SENTRY_DISABLE_AUTO_UPLOAD` 기본 `true`.
  - simulator build는 성공: `docs/audits/2026-06-ondo-full-audit/evidence/logs/12-native-simulator-build.log`.
  - device build 로그에는 `Upload Debug Symbols to Sentry` run script warning이 계속 출력됨.
- **수정 방향**:
  - run script output dependencies 또는 local config 조건을 정리해 warning noise를 줄인다.
- **검증 방법**:
  - `pnpm rn:native:build` 로그에서 Sentry credential/upload failure가 없고 warning이 허용 범위인지 확인.

### P3-2. iPad/manual review evidence는 config상 준비 흔적은 있으나 실제 evidence가 없음
- **증거**:
  - `apps/mobile-rn/app.config.js:109-115` — `supportsTablet: true`, `requireFullScreen: true`.
  - `apps/mobile-rn/app.config.js:127-134` — iPad portrait orientations 제한.
- **수정 방향**:
  - iPad simulator/실기기에서 welcome/chat/settings/premium 화면 4장 이상 캡처하고 App Review용 수동 evidence 폴더에 보관한다.
- **검증 방법**:
  - iPad simulator + 실제 iPad 또는 TestFlight iPad screenshot/video 확보.

## Evidence

### Build / tool logs
- `docs/audits/2026-06-ondo-full-audit/evidence/logs/12-native-simulator-build.log`
  - `pnpm rn:native:build` 결과: `** BUILD SUCCEEDED **`.
- `docs/audits/2026-06-ondo-full-audit/evidence/logs/12-native-device-build.log`
  - `pnpm rn:native:device:build` 결과: provisioning profile 없음으로 `** BUILD FAILED **`.
- `docs/audits/2026-06-ondo-full-audit/evidence/logs/12-ios-clean-install-launch.log`
  - clean install launch 후 dev server 탐색 및 `Connection refused` 로그.
- `pnpm rn:typecheck`
  - 실행 결과: exit 0.
- `pnpm rn:native:doctor`
  - 실행 결과: exit 0.
- `pnpm rn:start:native`
  - 실패: `Cannot resolve '@react-native/metro-config'`.
- `expo start --dev-client --port 8082 --localhost --non-interactive`
  - 실패: port 8082가 `/Users/injoo/Desktop/Dev/word_master` process에서 사용 중이라 non-interactive prompt 발생.

### Screenshots
- `docs/audits/2026-06-ondo-full-audit/evidence/screenshots/12-ios-clean-install-launch.png`
  - Expo Development Build launcher 화면. 실제 앱 content 아님. Apple Account Verification prompt 동시 노출.
- `docs/audits/2026-06-ondo-full-audit/evidence/screenshots/12-ios-app-after-expo-dev-server.png`
  - dev server 연결 후 dev menu overlay와 Apple Account Verification prompt가 전면 표시.
- `docs/audits/2026-06-ondo-full-audit/evidence/screenshots/12-ios-app-loaded-attempt.png`
  - 배경에 앱 “메시지” 화면/캐릭터 목록 일부가 보이나 prompt/overlay로 UX 진행 불가.

### File / line evidence
- Local native scripts:
  - `package.json:43-53`
  - `apps/mobile-rn/package.json:7-25`
  - `apps/mobile-rn/scripts/local-ios.mjs:14-18`, `308-311`
- Local testing doc:
  - `docs/development/local-native-ios-testing.md:1-16`, `32-36`, `50-64`, `66-88`
- iOS config/capabilities:
  - `apps/mobile-rn/app.config.js:84-123`, `124-155`, `419-435`
  - `apps/mobile-rn/eas.json:7-17`
  - `apps/mobile-rn/ios/app/app.entitlements:5-13`
- Push:
  - `apps/mobile-rn/src/lib/push-notifications.ts:368-457`, `520-642`, `718-727`, `902-977`
- IAP:
  - `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:236-261`, `643-672`, `753-785`, `856-866`, `923-978`
  - `apps/mobile-rn/src/lib/premium-remote.ts:269-299`
- Apple auth:
  - `apps/mobile-rn/src/lib/social-auth.ts:94-116`
  - `apps/mobile-rn/src/components/apple-auth-button.tsx:10-24`
  - `apps/mobile-rn/src/screens/signup-screen.tsx:267-271`
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:1686-1689`

### DB row evidence
- 이번 실행에서는 실기기 push/IAP/auth flow가 완료되지 않아 DB row를 생성/확인하지 못했다.
- 다음 검증 때 필수로 남길 row/log:
  - Push: `notification_devices` row, `user_notification_preferences` row, `sync-notification-device` function log.
  - IAP: purchase verification function log, transaction id/order id, token balance 증가 row/function response.
  - Apple auth: Supabase auth identity/provider row 또는 auth event log.

### UX route coverage status
| Checklist item | Status | Evidence / reason |
|---|---:|---|
| clean install | Partial | install/launch 성공, but dev launcher로 시작. `12-ios-clean-install-launch.png` |
| splash/welcome | Not verified | dev launcher/prompt가 clean path 차단 |
| guest flow | Not verified | 앱 UX 진입 후 prompt/overlay 차단 |
| signup/login | Code reviewed only | Apple auth code/config 있음; 실제 iOS auth 미검증 |
| chat send/reply | Not verified | 메시지 화면 일부만 관찰 |
| fortune generation | Not verified | UX path 미완료 |
| fortune result reopen | Not verified | UX path 미완료 |
| premium/token top-up screen | Code reviewed only | IAP code 있음; sandbox 미검증 |
| settings | Not verified | UX path 미완료 |
| app restart | Not verified | dev launcher/prompt 상태만 확인 |
| background/foreground | Not verified | 실 UX flow 미완료 |
| network failure simulation | Not verified | dev server/port failure만 관찰, 앱 내부 offline UX는 미검증 |
| push notification | Real-device only, not verified | `Device.isDevice` guard 존재 |
| foreground/background push | Real-device only, not verified | listener code reviewed |
| push click deep link | Real-device only, not verified | route payload code reviewed |
| App Store IAP sandbox | Real-device/TestFlight required, not verified | device build fails |
| Sign in with Apple | Real-device/TestFlight required, not verified | entitlement/code reviewed |
| camera/photo permission | Not verified | Info.plist strings present in built app |
| microphone recording | Not verified | Info.plist strings present in built app |
| audio playback | Not verified | dependency/code path not exercised |
| haptics | Not verified | dependency/code path not exercised |
| TestFlight runtime compatibility | Not verified | no TestFlight build/run evidence |
| iPad/manual review evidence | Not verified | config reviewed only |

## Recommended Fix Order
1. **실기기 signing/provisioning unblock**: main app + notification-service + widgets bundle id에 development profiles/capabilities를 맞추고 `pnpm rn:native:device:build/install/launch`를 통과시킨다.
2. **local dev server command fix**: `pnpm rn:start:native`의 `@react-native/metro-config` 누락을 해결하거나 `expo start --dev-client`로 공식 로컬 경로를 통일한다.
3. **Simulator E2E runbook 자동화**: clean install → dev server ready → URL open → dev overlay dismiss → screenshot/log capture → restart/background/network-offline까지 반복 가능한 스크립트화.
4. **Apple Account/StoreKit prompt 분리**: 시뮬레이터 계정 상태 문제인지 앱 StoreKit listener 문제인지 clean simulator에서 재검증한다.
5. **Real-device 필수 항목 evidence 수집**: push/IAP/Apple auth/permissions/audio/haptics/TestFlight/iPad 순으로 영상·스크린샷·DB row를 채운다.
6. **Expo/EAS 비용 절감 matrix 문서화**: Expo Go/Dev-client/Local native/EAS-TestFlight 각각 가능한 항목을 checklist에 연결한다.

## Open Questions
- Apple Account Verification prompt가 테스트 시뮬레이터의 계정 상태 때문인지, 앱의 StoreKit/IAP listener 초기화 부작용인지 아직 분리되지 않았다.
- 현재 repo working tree에는 이미 수정/미추적 파일이 존재한다. 본 QA는 코드 수정 없이 report/evidence 작성만 수행했지만, 기존 변경의 owner/의도 확인이 필요하다.
- 실제 iPhone `Jacob’s iPhone 16 Pro`는 paired/developer mode enabled이나 `tunnelState=unavailable`이다. USB/네트워크 연결 상태를 정상화하면 install/launch까지 가능한지 재확인해야 한다.
- App Store sandbox IAP 상품이 ASC에서 active/cleared 상태인지, product id가 `@fortune/product-contracts`의 SKU와 1:1 매칭되는지 실기기 구매 전 확인이 필요하다.
