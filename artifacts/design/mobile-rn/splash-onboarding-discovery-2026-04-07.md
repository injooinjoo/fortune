# Discovery Report

## 1. Goal
- Requested change:
  - RN 스플래시 이미지를 개선하고, 온보딩이 실제 입력/저장 흐름으로 적용되도록 보강한 뒤 iPhone 17에서 검증
- Work type: Page / Provider / Asset
- Scope:
  - `apps/mobile-rn`의 splash asset, `/splash`, `/onboarding`, onboarding persistence

## 2. Search Strategy
- Keywords:
  - `splash`, `onboarding`, `birthCompleted`, `interestCompleted`, `firstRunHandoffSeen`
- Commands:
  - `rg -n "splash|onboarding|LaunchScreen|expo-splash-screen" apps/mobile-rn apps/mobile-rn/src ios`
  - `sed -n '1,220p' apps/mobile-rn/src/screens/splash-screen.tsx`
  - `sed -n '1,220p' apps/mobile-rn/src/screens/onboarding-screen.tsx`
  - `sed -n '1,260p' apps/mobile-rn/src/providers/app-bootstrap-provider.tsx`
  - `sed -n '1,260p' apps/mobile-rn/src/providers/mobile-app-state-provider.tsx`
  - `sed -n '1,260p' apps/mobile-rn/src/lib/mobile-app-state.ts`
  - `sed -n '1,260p' apps/mobile-rn/src/lib/user-profile-remote.ts`
  - `sed -n '1,220p' lib/screens/onboarding/onboarding_page.dart`

## 3. Similar Code Findings
- Reusable:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-edit-screen.tsx` - RN에서 birth/profile 입력을 다루는 가장 가까운 reference
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/mobile-app-state-provider.tsx` - local profile 저장 + remote profile sync 진입점
  3. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/app-bootstrap-provider.tsx` - onboarding gate source of truth
- Reference only:
  1. `/Users/jacobmac/Desktop/Dev/fortune/lib/screens/onboarding/onboarding_page.dart` - Flutter 3-step 원본 구조
  2. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/character/presentation/utils/onboarding_interest_catalog.dart` - interest option source
  3. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/ios/Fortune/SplashScreen.storyboard` - 실제 launch splash wiring

## 4. Reuse Decision
- Reuse as-is:
  - bootstrap gate 계산
  - mobile app profile persistence
- Extend existing code:
  - `OnboardingScreen`을 checklist에서 실제 3-step 입력형으로 확장
  - `MobileProfileState`와 remote sync에 onboarding interest persistence 추가
  - `SplashScreen` route를 branded surface로 확장
- New code required:
  - RN용 onboarding interest catalog
  - splash asset refresh
  - dev-only onboarding debug step params
- Duplicate prevention notes:
  - Flutter 전체 onboarding을 그대로 포팅하지 않고 RN 저장 구조에 맞는 최소 step만 구현

## 5. Planned Changes
- Files to edit:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/splash-screen.tsx`
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/onboarding-screen.tsx`
  3. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/mobile-app-state-provider.tsx`
  4. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/mobile-app-state.ts`
  5. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/user-profile-remote.ts`
- Files to create:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/onboarding-interest-catalog.ts`
  2. `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/mobile-rn/splash-onboarding-discovery-2026-04-07.md`
  3. `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/mobile-rn/splash-onboarding-rca-2026-04-07.md`

## 6. Validation Plan
- Static checks:
  - `npm run rn:typecheck`
  - `npm run rn:test`
  - `flutter analyze`
  - `git diff --check`
- Runtime checks:
  - iPhone 17에서 `/splash`
  - iPhone 17에서 `/onboarding?debugStep=birth`
  - iPhone 17에서 `/onboarding?debugStep=interest`
  - iPhone 17에서 `/onboarding?debugStep=handoff`
- Test cases:
  - splash route가 새 자산과 함께 branded layout으로 렌더되는지
  - onboarding 각 step이 실제 입력/선택 UI를 가지는지
  - `returnTo`가 signup round-trip에서 보존되는지
