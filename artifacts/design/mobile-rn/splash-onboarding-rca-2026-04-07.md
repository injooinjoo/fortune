# RCA Report

## 1. Symptom
- Error message:
  - 명시적 crash는 없지만, 온보딩이 실제 입력 없이 checklist placeholder로 남아 있음
- Repro steps:
  1. RN 앱에서 `/onboarding` 진입
  2. 진행 상태와 확인 항목 카드만 보이고 실제 birth/interest 입력은 없음
  3. signup으로 이동 후 돌아오면 원래 `returnTo`가 `/onboarding`으로 고정됨
- Observed behavior:
  - onboarding gate는 birth/interest/handoff를 요구하지만 UI는 그 세 단계를 실제로 수집하지 않음
- Expected behavior:
  - RN onboarding도 최소한 birth 입력, interest 선택, handoff summary를 실제로 제공해야 함

## 2. WHY (Root Cause)
- Direct cause:
  - `OnboardingScreen`이 progress 요약과 CTA만 있는 placeholder screen으로 구현되어 있음
- Root cause:
  - Flutter 원본의 3-step onboarding state를 RN으로 이식하지 않고, gate 플래그만 먼저 연결한 채 UI는 임시 화면으로 남겨둠
- Data/control flow:
  - Step 1: bootstrap gate는 `birthCompleted`, `interestCompleted`, `firstRunHandoffSeen`를 평가
  - Step 2: `/onboarding` 화면은 실제 입력 없이 `completeOnboarding()`만 호출
  - Step 3: 결과적으로 gate와 screen semantics가 어긋나고, signup round-trip도 `returnTo`를 잃음

## 3. WHERE
- Primary location: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/onboarding-screen.tsx`
- Related call sites:
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/app-bootstrap-provider.tsx:358`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/signup-screen.tsx:124`
  - `/Users/jacobmac/Desktop/Dev/fortune/lib/screens/onboarding/onboarding_page.dart`

## 4. WHERE ELSE (Global Search)
- Search patterns used:
  - `rg -n "onboarding|birthCompleted|interestCompleted|firstRunHandoffSeen|completeOnboarding" apps/mobile-rn/src lib`
- Findings:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/splash-screen.tsx` - splash도 placeholder copy 위주
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-edit-screen.tsx` - RN birth input reference
  3. `/Users/jacobmac/Desktop/Dev/fortune/lib/features/character/presentation/utils/onboarding_interest_catalog.dart` - Flutter interest option source

## 5. HOW (Correct Pattern)
- Reference implementation: `/Users/jacobmac/Desktop/Dev/fortune/lib/screens/onboarding/onboarding_page.dart`
- Before:
```tsx
<Card>
  <AppText variant="heading4">확인할 항목</AppText>
  {onboardingSteps.map((step) => ...)}
</Card>
```
- After:
```tsx
// step 1: birth input
// step 2: interest selection
// step 3: handoff summary + completion CTA
```
- Why this fix is correct:
  - gate가 요구하는 세 단계를 UI가 직접 반영하게 되고, 저장/복구 semantics도 일치시킬 수 있음

## 6. Fix Plan
- Files to change:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/onboarding-screen.tsx`
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/mobile-app-state-provider.tsx`
  3. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/mobile-app-state.ts`
  4. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/user-profile-remote.ts`
  5. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/splash-screen.tsx`
- Risk assessment:
  - onboarding 저장 구조를 바꾸면 기존 local state normalization과 remote sync가 같이 맞아야 함
- Validation plan:
  - static checks 4종
  - iPhone 17 route screenshots for splash + onboarding steps
