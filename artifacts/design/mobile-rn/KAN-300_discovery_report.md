# KAN-300 Discovery Report

## 1. Goal
- Requested change: RN 서브페이지 전반의 back navigation affordance 점검 및 누락 보완
- Work type: UI / route audit
- Scope: `apps/mobile-rn/app`, `apps/mobile-rn/src/screens`, `apps/mobile-rn/src/components`

## 2. Search Strategy
- Keywords: `router.back`, `뒤로 가기`, `이전 화면으로 돌아가기`, `header`, `canGoBack`
- Commands:
  - `rg --files apps/mobile-rn/app | sort`
  - `rg -n "router\\.back\\(|뒤로 가기|이전 화면으로 돌아가기|header=" apps/mobile-rn/src apps/mobile-rn/app -S`
  - `rg -n "canGoBack" node_modules/expo-router -S`

## 3. Similar Code Findings
- Reusable:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/components/screen.tsx` - `header` slot exists, top-fixed back UI를 공통화하기 좋음
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/fortune-results/primitives.tsx` - 결과 화면에서 이미 상단 back affordance를 쓰는 패턴이 있음
- Reference only:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx` - fixed header를 `Screen.header`로 주입하는 패턴 참조
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/friend-creation-screen.tsx` - wizard형 화면은 이미 자체 back scaffold가 있어 이번 공통 보완 대상에서 제외

## 4. Reuse Decision
- Reuse as-is:
  - `Screen.header`
- Extend existing code:
  - route 전용 공통 back header를 `src/components`에 추가해 각 서브페이지에서 재사용
- New code required:
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/components/route-back-header.tsx`
- Duplicate prevention notes:
  - 각 screen에 개별 top back 마크업을 반복 작성하지 않고 공통 컴포넌트로 통일

## 5. Planned Changes
- Files to edit:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/premium-screen.tsx`
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/legal-screen.tsx`
  3. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/account-deletion-screen.tsx`
  4. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-saju-summary-screen.tsx`
  5. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-edit-screen.tsx`
  6. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-notifications-screen.tsx`
  7. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-relationships-screen.tsx`
  8. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/character-profile-screen.tsx`
  9. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/signup-screen.tsx`
  10. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/onboarding-screen.tsx`
  11. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/auth-callback-screen.tsx`
- Files to create:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/components/route-back-header.tsx`

## 6. Validation Plan
- Static checks:
  - `npm run rn:typecheck`
  - `npm run rn:test`
  - `flutter analyze`
  - `git diff --check`
- Runtime checks:
  - `npm run ios --workspace @fortune/mobile-rn -- --device 9ED1D212-A3D3-43F1-9E36-2F1F54367878`
  - deep link open for premium/profile/legal subpages
- Test cases:
  - premium direct open 시 상단 back 즉시 노출
  - profile subpages에서 top back 작동
  - signup/onboarding/auth callback에서 history 없을 때 fallback route로 복귀
