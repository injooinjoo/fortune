# Discovery Report

## 1. Goal
- Requested change:
  - RN 전체 UI를 전수 점검하고, 감사 자체를 막는 런타임 blocker를 먼저 제거
- Work type: Provider / Screen / Route audit
- Scope:
  - `apps/mobile-rn` 전반
  - 우선 blocker는 `MobileAppStateProvider`의 IAP 초기화 경로

## 2. Search Strategy
- Keywords:
  - `expo-iap`, `purchaseUpdatedListener`, `initConnection`, `restorePurchases`, `premium`, `profile`
- Commands:
  - `rg -n "expo-iap|purchaseUpdatedListener|initConnection|requestPurchase|restorePurchases" apps/mobile-rn/src apps/mobile-rn/package.json`
  - `sed -n '1,220p' apps/mobile-rn/src/providers/mobile-app-state-provider.tsx`
  - `sed -n '220,980p' apps/mobile-rn/src/providers/mobile-app-state-provider.tsx`
  - `sed -n '1,260p' apps/mobile-rn/src/screens/premium-screen.tsx`
  - `sed -n '1,180p' apps/mobile-rn/src/screens/profile-screen.tsx`

## 3. Similar Code Findings
- Reusable:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/mobile-app-state-provider.tsx` - store status와 오류 상태를 이미 관리하고 있어 별도 provider 추가 없이 확장 가능
- Reference only:
  1. `/Users/jacobmac/Desktop/Dev/fortune/node_modules/expo-iap/build/index.js` - listener가 `getNativeModule().addListener()`를 직접 호출함
  2. `/Users/jacobmac/Desktop/Dev/fortune/node_modules/expo-iap/build/ExpoIapModule.js` - native module 부재 시 `UnavailabilityError`를 던지는 구조 확인

## 4. Reuse Decision
- Reuse as-is:
  - 기존 `storeStatus`, `storeError`, `purchaseProduct`, `restorePurchases` 흐름
- Extend existing code:
  - `MobileAppStateProvider` 내부에 runtime availability gate를 추가
- New code required:
  - native module unavailable 판별 함수
  - degraded mode 에러 메시지 상수
- Duplicate prevention notes:
  - 새 provider/새 상태 레이어를 만들지 않고 기존 provider에만 한정

## 5. Planned Changes
- Files to edit:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/mobile-app-state-provider.tsx`
- Files to create:
  1. `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/mobile-rn/ui-audit-expo-iap-rca-2026-04-07.md`
  2. `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/mobile-rn/ui-audit-discovery-2026-04-07.md`

## 6. Validation Plan
- Static checks:
  - `npm run rn:typecheck`
  - `npm run rn:test`
  - `flutter analyze`
  - `git diff --check`
- Runtime checks:
  - iPhone 17에서 `/chat`, `/profile`, `/premium`, `/signup`, `/privacy-policy`, `/friends/new/basic`, `/character/luts` 재캡처
- Test cases:
  - profile/premium/signup 진입 시 redbox가 없어야 함
  - premium은 store unavailable 메시지로 degrade 되어야 함
  - profile/premium route 자체는 정상 렌더되어 back/header 검수가 가능해야 함
