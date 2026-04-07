# KAN-300 RCA Report

## 1. Symptom
- Error message: 없음
- Repro steps:
  1. RN 앱에서 `/premium` 같은 서브페이지를 연다.
  2. 화면 상단을 본다.
- Observed behavior:
  - 일부 서브페이지에 즉시 보이는 top back affordance가 없다.
  - 하단 CTA나 다른 메뉴를 눌러야만 복귀가 가능하다.
- Expected behavior:
  - 루트 탭이 아닌 서브페이지는 상단에 바로 보이는 back affordance가 있어야 한다.

## 2. WHY (Root Cause)
- Direct cause:
  - 루트 stack이 `headerShown: false`인데 각 서브페이지가 자체 top back UI를 일관되게 렌더하지 않았다.
- Root cause:
  - back affordance가 screen마다 개별 버튼/하단 CTA로 흩어져 있고 공통 route header가 없었다.
- Data/control flow:
  - `app/_layout.tsx`에서 글로벌 네이티브 헤더 비활성화
  - 각 `src/screens/*`가 `Screen`으로 직접 렌더
  - 일부 화면은 하단 “돌아가기”만 제공
  - direct deep link나 subpage 진입 시 top back 부재 발생

## 3. WHERE
- Primary location: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/app/_layout.tsx`
- Related call sites:
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/premium-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/legal-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/account-deletion-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-edit-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-notifications-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-relationships-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-saju-summary-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/character-profile-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/signup-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/onboarding-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/auth-callback-screen.tsx`

## 4. WHERE ELSE (Global Search)
- Search patterns used:
  - `rg -n "router\\.back\\(|뒤로 가기|이전 화면으로 돌아가기|header=" apps/mobile-rn/src apps/mobile-rn/app -S`
  - `rg --files apps/mobile-rn/app | sort`
- Findings:
  1. `apps/mobile-rn/src/screens/friend-creation-screen.tsx` - safe, 자체 상단 back scaffold 있음
  2. `apps/mobile-rn/src/features/fortune-results/primitives.tsx` - safe, 결과 preview route에는 상단 back 있음
  3. 위 listed subpages - issue, top back 부재 또는 하단 버튼만 존재

## 5. HOW (Correct Pattern)
- Reference implementation: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx`
- Before:
```tsx
<Screen>
  <AppText variant="displaySmall">프리미엄</AppText>
```
- After:
```tsx
<Screen header={<RouteBackHeader fallbackHref="/profile" />}>
  <AppText variant="displaySmall">프리미엄</AppText>
```
- Why this fix is correct:
  - `Screen.header`는 scroll 바깥 고정 영역이라 top back을 일관되게 노출할 수 있다.
  - `router.canGoBack()` + fallback route를 함께 쓰면 deep link/direct open에서도 복귀 경로가 생긴다.

## 6. Fix Plan
- Files to change:
  1. `apps/mobile-rn/src/components/route-back-header.tsx` - 공통 back header 추가
  2. 서브페이지 screen 파일들 - `Screen.header`에 공통 back header 연결
- Risk assessment:
  - low. root tabs는 건드리지 않고 subpages만 수정
- Validation plan:
  - static checks + iPhone 17 runtime route audit
