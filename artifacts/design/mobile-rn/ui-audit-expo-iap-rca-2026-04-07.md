# RCA Report

## 1. Symptom
- Error message:
  - `Cannot find native module 'Expolap'`
- Repro steps:
  1. iPhone 17 시뮬레이터에서 RN 앱 실행
  2. `/profile`, `/premium`, `/signup` 같은 비루트 화면 진입
  3. 공통 provider 초기화 시 redbox overlay 발생
- Observed behavior:
  - 프로필/프리미엄/회원가입 화면이 렌더되지 않고 런타임 에러 overlay가 뜸
- Expected behavior:
  - 인앱결제 네이티브 모듈이 없는 빌드에서도 화면은 정상 렌더되고, 구매 기능만 비활성/에러 상태로 남아야 함

## 2. WHY (Root Cause)
- Direct cause:
  - `MobileAppStateProvider`가 mount 시 `purchaseUpdatedListener()`와 `purchaseErrorListener()`를 무조건 등록함
- Root cause:
  - `expo-iap` 네이티브 모듈이 빠진 빌드/런타임을 고려한 availability guard가 없음
- Data/control flow:
  - Step 1: 앱 전체가 `MobileAppStateProvider`를 mount
  - Step 2: provider effect가 `purchaseUpdatedListener()`를 즉시 호출
  - Step 3: `expo-iap` 내부 `getNativeModule().addListener()`가 네이티브 모듈을 찾지 못해 예외를 던지고 화면 전체가 깨짐

## 3. WHERE
- Primary location: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:526`
- Related call sites:
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:493`
  - `/Users/jacobmac/Desktop/Dev/fortune/node_modules/expo-iap/build/index.js:34`
  - `/Users/jacobmac/Desktop/Dev/fortune/node_modules/expo-iap/build/ExpoIapModule.js:27`

## 4. WHERE ELSE (Global Search)
- Search patterns used:
  - `rg "expo-iap|purchaseUpdatedListener|initConnection|restorePurchases" apps/mobile-rn/src apps/mobile-rn/package.json`
- Findings:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:17` - 실제 IAP 초기화/리스너 등록 위치
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/premium-screen.tsx:154` - provider API를 통해 구매 복원 호출
  3. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-screen.tsx:97` - provider API를 통해 구매 복원 호출
  4. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/package.json:18` - `expo-iap` 의존성 선언

## 5. HOW (Correct Pattern)
- Reference implementation: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/mobile-app-state-provider.tsx`
- Before:
```ts
const purchaseUpdatedSubscription = purchaseUpdatedListener((purchase) => {
  ...
});
```
- After:
```ts
try {
  purchaseUpdatedSubscription = purchaseUpdatedListener((purchase) => {
    ...
  });
} catch (error) {
  setStoreStatus('error');
  setStoreError(STORE_UNAVAILABLE_MESSAGE);
}
```
- Why this fix is correct:
  - provider 전체를 죽이지 않고 store 기능만 degraded mode로 내릴 수 있음
  - `purchaseProduct`/`restorePurchases`도 같은 availability gate를 타게 되어 dead action을 줄일 수 있음

## 6. Fix Plan
- Files to change:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/mobile-app-state-provider.tsx` - IAP native availability guard 추가
- Risk assessment:
  - 실제 IAP가 정상 탑재된 빌드에서도 리스너와 상품 fetch가 기존처럼 동작해야 함
  - degraded mode에서 화면은 살아 있어야 하고 구매 액션은 친화적 에러로 내려야 함
- Validation plan:
  - `npm run rn:typecheck`
  - `npm run rn:test`
  - `flutter analyze`
  - `git diff --check`
  - `npm run ios --workspace @fortune/mobile-rn -- --device 9ED1D212-A3D3-43F1-9E36-2F1F54367878`
