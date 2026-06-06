# Design System & Motion Reviewer QA Report

## Verdict
- **조건부 GO**: 현재 TypeScript 정적 검증은 통과하지만, 디자인 시스템/모션 체크리스트 관점에서는 **P1 2건, P2 4건, P3 2건**을 먼저 정리해야 App Store/프리미엄 전환 화면의 신뢰도를 안정적으로 유지할 수 있다.
- 핵심 리스크: `fortuneTheme`/`AppText`/reduced-motion/haptic 정책이 존재하지만, 주요 첫 경험·결과·채팅·프리미엄 경로에 raw 색상/폰트/루프 모션이 넓게 남아 있어 화면별 체감 품질이 흔들린다.

## Scope & Method
- 체크리스트: `docs/audits/2026-06-ondo-full-audit/checklists/09-design-system-motion.md:53-100`
- 레포 상태 고정:
  - `git status --short --branch` 결과: `## master...origin/master`, dirty/untracked 존재
  - 변경/미추적: `CLAUDE.md`, `apps/mobile-rn/package.json`, `package.json`, `pnpm-lock.yaml`, `.githooks/`, `apps/mobile-rn/scripts/`, `docs/audits/`, `docs/development/local-native-ios-testing.md`, `scripts/verify-rn-native-patch.sh`
  - `git log --oneline origin/master..HEAD`: ahead commit 없음
- 수행한 검증/조사:
  - 체크리스트/AGENTS/CLAUDE.md 확인
  - `rg` 기반 정적 감사: typography, colors, motion, haptics, routes, premium/token, assets
  - `pnpm --dir apps/mobile-rn exec tsc --noEmit` 실행: **exit 0**, stdout 없음
- 미수행/제약:
  - 코드 수정 없음.
  - DB row는 이 체크리스트 범위(디자인 시스템/모션)에서 직접 관련 테이블이 없어 조회하지 않음.
  - 실기기/시뮬레이터 시각 캡처는 수행하지 않았으므로, 아래 재현 경로는 코드 근거 기반의 UX 검증 경로다. 체크리스트 원칙상 시뮬레이터 성공은 실기기 성공으로 간주하면 안 된다.

## P0
- 없음.

## P1

### P1-1. Reduced Motion 적용이 첫 경험/녹음/결과 리빌 경로에 일관되지 않음
- **영향**: iOS 접근성 “동작 줄이기” 사용자가 앱 진입 직후 splash/welcome, 녹음 composer pulse, 일부 결과 리빌에서 반복/자동 모션을 그대로 받는다. 체크리스트 `Motion/Animation / Haptics`의 `reduced motion 대응` 항목 미충족.
- **증거**:
  - reduced-motion 커버리지 검색 결과는 55건이지만 `story-chat-animations`, `chat-surface` hero overlay, `sentence-reading-player`에 집중되어 있다. `splash-screen.tsx`/`welcome-screen.tsx`/`survey-composer.tsx`/composer pulse에는 reduced-motion 분기 없음.
  - `apps/mobile-rn/src/screens/splash-screen.tsx:30-70`: `entry`, `float` `Animated.Value`와 `Animated.loop`가 mount 시 항상 시작됨. `AccessibilityInfo.isReduceMotionEnabled` 없음.
  - `apps/mobile-rn/src/screens/welcome-screen.tsx:377-416`: Brand reveal에서 `onboardingBrandReveal()` haptic과 `Animated.spring`, `Animated.loop`가 항상 실행됨. reduced-motion 분기 없음.
  - `apps/mobile-rn/src/screens/welcome-screen.tsx:518-568`: Thermometer scene에서 `Animated.loop`와 `requestAnimationFrame` count-up이 항상 실행됨. reduced-motion 분기 없음.
  - `apps/mobile-rn/src/components/survey-composer.tsx:48-70`: 녹음 상태에서 `Animated.loop(...).start()`를 호출하고 stop은 `isRecording=false`일 때만 처리. reduced-motion 분기 없음.
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:1974-1998`: active chat composer mic pulse도 동일하게 reduced-motion 분기 없음.
  - 대비되는 정상 패턴: `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:120-135`는 `AccessibilityInfo.isReduceMotionEnabled()`와 `reduceMotionChanged` listener를 사용하고, `:155-166`에서 reduced-motion 시 짧은 fade/전체 텍스트 표시로 대체한다.
  - 대비되는 정상 패턴: `apps/mobile-rn/src/features/fortune-results/fullscreen/sentence-reading-player.tsx:32-40`, `:57-65`는 reduced-motion에서 opacity/translate를 정적으로 두고 timeout으로만 진행한다.
- **화면 경로/재현 단계**:
  1. iOS 설정 → 손쉬운 사용 → 동작 → 동작 줄이기 ON.
  2. 앱 fresh start → `/splash` → `/welcome` 경로 진입.
  3. brand aura/thermometer scene의 float/count-up이 계속 재생되는지 확인.
  4. `/chat`에서 음성 입력/음성 메시지 녹음을 시작해 pulse가 계속 반복되는지 확인.
  5. 운세 결과 fullscreen reading player는 reduced-motion이 반영되는지 비교한다.
- **수정 방향**:
  - 공용 `useReducedMotion()` hook을 만들고 `splash-screen`, `welcome-screen`, `survey-composer`, `ActiveChatComposer`, result reveal primitives에 적용.
  - reduced-motion ON이면 `Animated.loop`, spring bounce, count-up RAF를 생략하고 최종 정적 상태 또는 단일 fade로 대체.
  - `AccessibilityInfo.addEventListener('reduceMotionChanged', ...)`까지 포함해 런타임 설정 변경 반영.
- **검증 방법**:
  - iOS Simulator/실기기에서 Reduce Motion ON/OFF 각각 `/splash`, `/welcome`, `/chat` 녹음, `/result/[resultKind]` fullscreen reading 비교 녹화.
  - `pnpm --dir apps/mobile-rn exec tsc --noEmit`.
  - 가능하면 reduced-motion hook unit test: mock `AccessibilityInfo.isReduceMotionEnabled()` true/false.

### P1-2. 다크 모드 토큰은 존재하지만 앱 런타임은 강제 dark theme로 고정되어 theme token 정책과 실제 설정 대응이 어긋남
- **영향**: 체크리스트 `Colors`의 `theme token 사용`, `dark mode 대응` 기준에서 “토큰은 있음”과 “사용자/시스템 scheme 대응”이 분리되어 있다. App Store 접근성/사용자 기대 관점에서 light/dark 전환 품질을 검증할 수 없다.
- **증거**:
  - `packages/design-tokens/src/index.ts:1-90`: `fortuneColors.dark`/`fortuneColors.light` 둘 다 정의됨.
  - `packages/design-tokens/src/index.ts:179-187`: `createFortuneTheme(mode: FortuneColorMode = 'dark')`는 mode 인자를 받도록 설계됨.
  - `apps/mobile-rn/src/lib/theme.ts:4`: `export const fortuneTheme = createFortuneTheme('dark');`로 고정.
  - `apps/mobile-rn/src/lib/theme.ts:56-68`: React Navigation도 `DarkTheme` + `dark: true`로 고정.
  - `rg "Appearance|useColorScheme|colorScheme" apps/mobile-rn/app apps/mobile-rn/src` 결과에서 theme mode 전환 연결 근거 없음.
- **화면 경로/재현 단계**:
  1. iOS 시스템 appearance를 Light로 설정.
  2. 앱 실행 후 `/chat`, `/premium`, `/profile`, `/result/[resultKind]` 이동.
  3. Navigation/background/text가 계속 dark palette로 유지되는지 확인.
- **수정 방향**:
  - 제품 전략상 dark-only가 의도라면 `09-design-system-motion` 보고서/릴리즈 문서에 명시하고 light token은 “future token”으로 분리.
  - 시스템 대응이 목표라면 `useColorScheme()`/Appearance provider를 통해 `createFortuneTheme(scheme)`를 앱 전역 context로 공급하고, `fortuneTheme` singleton 직접 import를 점진적으로 제거.
  - 스크린샷/QA 매트릭스에 Light/Dark 최소 2개 경로(`/chat`, `/premium`) 포함.
- **검증 방법**:
  - iOS Light/Dark 전환 후 `/chat`, `/welcome`, `/premium`, `/result/[resultKind]` screenshot diff.
  - token snapshot test: `createFortuneTheme('light')` 사용 시 navigation/card/text 색이 light palette로 내려오는지 확인.

## P2

### P2-1. raw `Text`, raw typography, raw color가 핵심 화면에 넓게 남아 AppText/fortuneTheme 정책을 약화함
- **영향**: 체크리스트 `Typography`, `Colors` 전반. `AppText`와 token system은 존재하지만 화면별 임의 값이 많아 한국어 line-height, weight, contrast, dynamic type 대응이 화면마다 달라질 수 있다.
- **정량 증거**:
  - `rg -n "<Text\b" apps/mobile-rn/app apps/mobile-rn/src -g "*.tsx"`: **143건**
    - `fortune-results`: 84건
    - `story-chat-animations`: 35건
    - `screens`: 17건
    - `components`: 7건
  - `rg -n "fontSize\s*:|fontWeight\s*:|fontFamily\s*:|lineHeight\s*:" ...`: **466건**
    - `fortune-results`: 216건
    - `screens`: 82건
    - `story-chat-animations`: 81건
    - `components`: 20건
    - `app-routes`: 12건
  - `rg -n "#[0-9A-Fa-f]{3,8}|rgba?\(" ...`: **433건**
    - `fortune-results`: 248건
    - `screens`: 62건
    - `components`: 21건
    - `app-routes`: 11건
- **파일/라인 증거**:
  - 정상 시스템: `apps/mobile-rn/src/components/app-text.tsx:22-43`가 `fortuneTheme.typography[variant]`와 `fortuneTheme.colors.textPrimary`를 중앙 적용.
  - token 정의: `packages/design-tokens/src/index.ts:126-160`에 display/heading/body/label/caption/oracle/emoji variants 존재.
  - 위반 예시: `apps/mobile-rn/src/screens/splash-screen.tsx:192-237`는 `Text` + `fontFamily/fontSize/lineHeight/color/fontWeight` 직접 지정.
  - 위반 예시: `apps/mobile-rn/src/screens/welcome-screen.tsx:475-502`, `:629-687`는 raw `Text`, raw hex/rgba, raw font scale을 사용.
  - 위반 예시: `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:1740-1756`, `:1770-1786`는 email/phone button에서 `#FFFFFF`, `#111111` 직접 사용.
- **화면 경로/재현 단계**:
  1. `/splash` → `/welcome` → `/chat?showList=1` → `/premium` → `/result/[resultKind]` 이동.
  2. 각 화면에서 텍스트 크기/line-height/letter-spacing/버튼 contrast가 AppText variants와 일치하는지 비교.
  3. iOS Dynamic Type를 크게 설정하고 clipping/overflow 확인.
- **수정 방향**:
  - 모든 raw `Text`를 일괄 치환하지 말고, UX 핵심 경로 우선순위로 `AppText` variant mapping 표를 만든다.
  - `splash/welcome`, `premium`, `chat auth CTA`, `fortune-results/heroes`를 1차 정리 대상으로 분리.
  - 특별한 숫자/온도/emoji 표현은 `emojiDisplay`, `displayLarge`, `kicker`, `oracle*`처럼 이미 있는 variants를 확장하거나 명명된 token으로 추가.
- **검증 방법**:
  - raw usage budget을 CI 검사로 추가: 신규 raw `Text`/hex/fontSize 증가 시 fail 또는 warning.
  - Dynamic Type 1.0x/1.5x, iPhone SE/16 Pro Max/iPad 시각 QA.

### P2-2. haptic 중앙 서비스는 있으나 사용자 설정/전역 opt-out 경계가 채팅 외 경로에 명확하지 않음
- **영향**: 체크리스트 `선택/전송/성공/실패 haptic이 적절한가?` 항목. 채팅 haptic 토글은 있으나 onboarding/result/purchase 등 핵심 경로는 `haptics.ts` 함수 호출 시 설정을 검사하지 않는다.
- **증거**:
  - 중앙 서비스: `apps/mobile-rn/src/lib/haptics.ts:1-18`는 4-tier hierarchy를 정의하고 platform guard만 수행.
  - `apps/mobile-rn/src/lib/haptics.ts:19-22`: `safe()`는 iOS/Android 여부만 검사하고 사용자 설정은 모름.
  - `apps/mobile-rn/src/lib/haptics.ts:63-69`: `chatTypingTick()` 주석에 “호출자가 chatHapticsEnabled 설정을 게이팅해야 한다”라고 명시.
  - 채팅 설정 존재: `apps/mobile-rn/src/lib/mobile-app-state.ts:65`, `:137`, `:258-260`에 `chatHapticsEnabled` 저장.
  - 설정 UI 존재: `apps/mobile-rn/src/screens/profile-screen.tsx:599-606`에서 “켜짐/꺼짐” 토글.
  - 채팅 정상 게이트: `apps/mobile-rn/src/screens/chat-screen.tsx:1498-1502`는 `mobileAppState.settings.chatHapticsEnabled` 확인 후 `scoreReveal(90)` 호출.
  - 그러나 welcome은 `apps/mobile-rn/src/screens/welcome-screen.tsx:377-379`, `:518-520`에서 설정 확인 없이 `onboardingBrandReveal()`/`onboardingTemperatureReveal()` 호출.
- **화면 경로/재현 단계**:
  1. `/profile`에서 채팅 햅틱을 꺼짐으로 설정.
  2. QA toggle 또는 fresh install로 `/welcome` 재생.
  3. brand/thermometer scene에서 haptic이 발생하는지 실기기에서 확인.
  4. `/result/[resultKind]`, purchase success 경로도 동일하게 확인.
- **수정 방향**:
  - 설정명을 `hapticsEnabled` 전역 + `chatWordHapticsEnabled` 세부 옵션으로 재정의하거나, 현재 `chatHapticsEnabled`의 범위를 UI에 “채팅 답장 효과”로 명확히 표시.
  - `haptics.ts`에 전역 setting provider를 직접 import하지 말고, 호출부에서 명시 gate하는 패턴을 lint/test로 강제.
- **검증 방법**:
  - 실기기에서 haptic toggle ON/OFF로 welcome/result/chat/purchase 경로 비교.
  - unit test: haptic 호출 wrapper에 setting false 전달 시 `expo-haptics` mock 호출 0회.

### P2-3. 반복 애니메이션 정리/JS thread 부담 관리가 화면별로 흩어져 있고 일부 loop는 handle을 보관하지 않음
- **영향**: 체크리스트 `animation cleanup`, `JS thread 부담`. 대부분 native driver를 쓰지만, loop lifecycle/reduced-motion/RAF count-up이 화면별 수동 구현이라 누락 위험이 높다.
- **증거**:
  - `rg -n "Animated\.loop" ...`: **14개 loop site**.
  - 좋은 정리 예시: `apps/mobile-rn/src/screens/splash-screen.tsx:48-70`은 `floatLoop.stop()`과 `clearTimeout`을 cleanup.
  - 좋은 정리 예시: `apps/mobile-rn/src/screens/welcome-screen.tsx:536-568`은 `floatLoop.stop()`과 `cancelAnimationFrame` cleanup.
  - 위험 예시: `apps/mobile-rn/src/components/survey-composer.tsx:48-70`는 `Animated.loop(...).start()`의 반환 loop handle을 저장하지 않고 `pulseAnim.stopAnimation()`만 호출한다. 컴포넌트 unmount 시 cleanup 함수가 별도로 없어 recording 중 unmount 케이스를 코드상 보장하기 어렵다.
  - 위험 예시: `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:1976-1998`도 loop handle을 저장하지 않고 `micPulseAnim.stopAnimation()`만 호출.
  - JS RAF 예시: `apps/mobile-rn/src/features/fortune-results/primitives/use-reveal-progress.ts:20-35`는 every frame마다 `setProgress(next)`를 수행한다. 결과 카드 전체에서 하위 atom이 많으면 JS render churn이 생길 수 있다.
- **화면 경로/재현 단계**:
  1. `/chat`에서 녹음 시작 → 즉시 뒤로가기/캐릭터 전환/탭 전환.
  2. console warning, lingering pulse, JS FPS drop 여부 확인.
  3. `/result/[resultKind]`에서 긴 결과/hero chart 리빌 시 FPS와 JS frame time 확인.
- **수정 방향**:
  - `useLoopedPulse({ enabled, reduceMotion, min, max, duration })` hook으로 loop handle cleanup 표준화.
  - 결과 카드 리빌은 가능하면 Reanimated shared value 또는 Animated.Value + native driver로 하위 컴포넌트 render churn 줄이기. JS progress가 필요한 곳은 throttling/segment 단위로 제한.
- **검증 방법**:
  - React Native performance monitor/Flipper로 JS FPS 확인.
  - 녹음 중 unmount 테스트: 컴포넌트 unmount 후 `stopAnimation`/loop cleanup 호출 검증.

### P2-4. Premium/token UI는 polished top-up과 legacy storefront가 한 화면에 공존해 신뢰감/전환 집중도가 약해질 수 있음
- **영향**: 체크리스트 `premium/token UI의 신뢰감`. 최근 top-up flow는 강화됐지만 full premium route에서는 subscription/token/lifetime/ad/selected product card가 길게 이어져 사용자가 “무엇을 사야 하는지”가 흐려질 수 있다.
- **증거**:
  - `apps/mobile-rn/src/screens/premium-screen.tsx:661-686`: “구독 플랜” card.
  - `apps/mobile-rn/src/screens/premium-screen.tsx:690-706`: “토큰 충전” card.
  - `apps/mobile-rn/src/screens/premium-screen.tsx:710-722`: “평생 소장” card.
  - `apps/mobile-rn/src/screens/premium-screen.tsx:725-760`: “광고 보고 토큰 받기” card.
  - `apps/mobile-rn/src/screens/premium-screen.tsx:763-867`: “선택된 상품” card + purchase/restore CTA.
  - 같은 파일 `apps/mobile-rn/src/screens/premium-screen.tsx:873-910` 이후에는 `TopUpPackageTile` 기반의 더 polished top-up package UI가 존재하지만, `focusTopUpOnly` 여부에 따라 다른 구조로 보인다.
- **화면 경로/재현 단계**:
  1. `/premium` 직접 진입.
  2. `focusTopUpOnly=false` 기본 화면에서 위 card들이 한 번에 노출되는지 확인.
  3. zero-token/top-up intent에서 진입한 `/premium?focus=topup`류 경로와 시각/CTA 집중도 비교.
- **수정 방향**:
  - `/premium` 기본 정보 구조를 `Hero balance → 3 package tiles → selected usage preview → trust row → sticky CTA`로 통합.
  - 구독/평생/광고는 secondary accordion 또는 separate “모든 상품 보기”로 낮춰 primary conversion path를 하나로 만든다.
  - 상품 card/token card/button primitive를 `ProductOption`/`TopUpPackageTile` 중 하나로 통합.
- **검증 방법**:
  - iPhone SE/16 Pro Max에서 fold 위 CTA 명확성 screenshot.
  - StoreKit sandbox: selected product → purchase pending/error/success/restore visual states 확인.

## P3

### P3-1. 일부 placeholder/emoji fallback이 premium visual language와 어긋남
- **영향**: 체크리스트 `code-drawn center art가 싼티 나지 않는가?`, `generated asset 품질`, `아이콘/이미지/일러스트 스타일 통일`. 주요 welcome asset은 mp4/webp로 교체되어 있지만, 생성/오류/fallback 경로에는 emoji 중심 표현이 남아 있다.
- **증거**:
  - `apps/mobile-rn/assets/onboarding/ondo-brand-aura-loop.mp4` 18,958 bytes, `ondo-thermometer-aura-loop.mp4` 28,047 bytes가 존재해 welcome hero는 영상 asset 기반.
  - `apps/mobile-rn/src/screens/welcome-screen.tsx:457-464`, `:612-619`에서 onboarding loop mp4 사용.
  - fallback 예시: `apps/mobile-rn/src/screens/friend-creation-screen.tsx:1090-1105`에서 avatar가 없으면 `😢`/`🎉`/`✨` emoji를 44px로 표시.
  - data-level emoji 예시: `apps/mobile-rn/src/lib/birthstone-data.ts:26-37` 등 birthstone 카드 데이터가 emoji/color 중심.
- **화면 경로/재현 단계**:
  1. `/friends/new/.../creating`에서 avatar 없는 saving/error/success 상태 확인.
  2. birthstone/result card 노출 경로에서 emoji fallback이 주변 generated avatar/tarot asset과 톤이 맞는지 확인.
- **수정 방향**:
  - 상태별 premium micro-illustration 또는 Lottie/mp4/webp mini asset으로 대체.
  - emoji 사용이 의도인 곳은 `AppText` `emoji*` variants만 사용하고 semantic/accessibility label 분리.
- **검증 방법**:
  - friend creation success/error screenshot compare.
  - asset budget 확인: webp/png 크기와 visual quality 검수.

### P3-2. raw spacing/layout 수치가 토큰과 섞여 small-screen/iPad polish 검증이 어렵다
- **영향**: 체크리스트 `Spacing/Layout`, `작은 화면/iPad에서 깨지지 않는가`. `Screen` wrapper는 safe area/keyboard/padding token을 잘 제공하지만, 개별 화면에 fixed width/height/margins가 많다.
- **증거**:
  - 공용 정상 패턴: `apps/mobile-rn/src/components/screen.tsx:63-70`, `:141-155`, `:182-190`, `:215-218`에서 safe area, keyboard, maxWidth 600, token spacing 사용.
  - fixed-size 예시: `apps/mobile-rn/src/screens/welcome-screen.tsx:449-450` brand art `342x342`, `:604-605` thermometer art `286x286`.
  - fixed footer/text spacing 예시: `apps/mobile-rn/src/screens/splash-screen.tsx:164`, `:189`, `:195-210`.
  - raw margin escape 예시: `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:1868`, `:1887`에 `marginHorizontal: -20`로 page padding 상쇄.
- **화면 경로/재현 단계**:
  1. iPhone SE, iPhone 16 Pro Max, iPad split view에서 `/welcome`, `/chat?showList=1`, `/premium`, `/result/[resultKind]` 확인.
  2. safe area, keyboard, bottom CTA, topBoundaryFade overlap 확인.
- **수정 방향**:
  - fixed art size를 `min(width * ratio, maxToken)` 기반 responsive helper로 이동.
  - negative margins는 `Screen`에 `bleedHorizontal` 같은 명시 prop을 추가해 의도화.
- **검증 방법**:
  - 3개 viewport screenshot matrix.
  - keyboard open/close 자동화: composer가 safe area와 겹치지 않는지 확인.

## Evidence
- **체크리스트/규칙**
  - `docs/audits/2026-06-ondo-full-audit/checklists/09-design-system-motion.md:61-100`: Typography, Colors, Spacing/Layout, Components/Brand, Motion/Haptics 체크 항목.
  - `AGENTS.md:176-204`: `DSColors/context.colors`, typography, raw color/font 금지, haptic 중앙 제어 규칙.
  - `CLAUDE.md:195-204`: RN 앱은 `AppText + fortuneTheme`가 핵심 패턴.
- **정적 검색 로그 요약**
  - Raw `<Text>`: 143건 (`fortune-results` 84, `story-chat-animations` 35, `screens` 17, `components` 7)
  - Raw typography: 466건 (`fortune-results` 216, `screens` 82, `story-chat-animations` 81)
  - Raw color: 433건 (`fortune-results` 248, `screens` 62)
  - Reduced-motion coverage: 55건이나 first-run `splash/welcome`과 recording composer pulse는 미포함
  - `Animated.loop`: 14개 site
- **검증 로그**
  - Command: `pnpm --dir apps/mobile-rn exec tsc --noEmit`
  - Result: exit code `0`, stdout/stderr 없음
- **DB row**
  - 해당 없음. 디자인 시스템/모션 감사는 로컬 UI 코드/asset/settings 경로 기반으로 수행했다.

## Recommended Fix Order
1. **P1 reduced-motion/haptic setting 정리**: `useReducedMotion` hook + first-run/welcome/composer/result reveal 적용, haptic global/chat setting 경계 명확화.
2. **P1/P2 token enforcement**: `fortuneTheme` singleton dark 고정 의사결정 확정 후, raw color/font/Text budget을 CI warning으로 추가하고 splash/welcome/premium/chat CTA부터 AppText/token화.
3. **P2 animation cleanup 표준화**: pulse/loop/RAF hooks로 통합, unmount 테스트 추가.
4. **P2 premium UI 구조 통합**: full storefront와 focused top-up UI를 하나의 premium conversion language로 정리.
5. **P3 asset/spacing polish**: emoji fallback과 fixed layout 수치를 responsive/token 기반으로 치환.

## Open Questions
- 온도 앱은 제품 전략상 **dark-only**인가, 아니면 시스템 Light/Dark 대응을 이번 full audit에서 요구하는가?
- `chatHapticsEnabled`는 “채팅 답장 효과만”의 설정인가, 아니면 앱 전체 haptic opt-out이어야 하는가?
- `/premium` 기본 진입은 구독 중심인가, 토큰 충전 중심인가? 현재 코드는 두 방향이 공존한다.
