# UI 디자인 시스템 가이드

> 최종 업데이트: 2026.04.17

Ondo의 현재 UI 소스 오브 트루스는 RN(React Native + Expo) 스택 위에 올라간 Paper 정렬형 다크 우선 디자인 시스템입니다. Flutter 레이어는 제거되었으며, 이 문서는 실제 `packages/design-tokens/` 공유 토큰 패키지, `apps/mobile-rn/src/lib/theme.ts`, `apps/mobile-rn/src/components/app-text.tsx`, 그리고 `fortuneTheme.*` API를 기준으로 정리합니다.

## 디자인 시스템 구조

```text
packages/design-tokens/
└── src/
    └── index.ts                      # fortuneColors / fortuneSpacing / fortuneRadius
                                      # / fortuneTypography / fortuneShadows / createFortuneTheme

apps/mobile-rn/src/
├── lib/
│   └── theme.ts                      # fortuneTheme 인스턴스 + navigationTheme + romanceTintBackground
├── components/
│   ├── app-text.tsx                  # <AppText variant="..."> 타이포 컴포넌트
│   ├── screen.tsx                    # 페이지 shell
│   └── (도메인 카드/칩/리스트 컴포넌트)
└── features/
    └── fortune-results/              # 결과 화면 조립 레이어
```

## Source Of Truth

| 영역 | 기준 파일 |
|------|-----------|
| 공유 토큰 패키지 | `packages/design-tokens/src/index.ts` |
| 런타임 테마 인스턴스 | `apps/mobile-rn/src/lib/theme.ts` |
| 타이포 컴포넌트 | `apps/mobile-rn/src/components/app-text.tsx` |
| 페이지 shell | `apps/mobile-rn/src/components/screen.tsx` |
| 네비게이션 테마 | `apps/mobile-rn/src/lib/theme.ts` (`navigationTheme`) |
| 결과 카드 shell | `apps/mobile-rn/src/features/fortune-results/` |

`packages/design-tokens`는 TypeScript 워크스페이스 패키지로, `@fortune/design-tokens`를 통해 앱에서 import됩니다. 새 토큰은 반드시 이 패키지에 먼저 추가한 뒤 앱에서 사용합니다.

## 색상 시스템

현재 색상 철학은 다음과 같습니다.

- 다크 모드 우선 (기본 `createFortuneTheme('dark')`)
- deep navy-black background
- cool white text
- blue-gray secondary text
- purple CTA
- warm amber highlight

### 핵심 토큰 (`fortuneTheme.colors.*`, 다크 모드)

| 용도 | 토큰 | 값 |
|------|------|----|
| 페이지 배경 | `background` | `#0B0B10` |
| 보조 배경 | `backgroundSecondary` | `#1A1A1A` |
| 3차 배경 | `backgroundTertiary` | `#151821` |
| 카드 표면 | `surface` | `#1A1A1A` |
| 중첩 표면 | `surfaceSecondary` | `#23232B` |
| 상승 표면 | `surfaceElevated` | `#17171D` |
| 주 텍스트 | `textPrimary` | `#F5F6FB` |
| 보조 텍스트 | `textSecondary` | `#9198AA` |
| 3차 텍스트 | `textTertiary` | `#9EA3B3` |
| 경계선 | `border` | `rgba(255,255,255,0.08)` |
| 불투명 경계 | `borderOpaque` | `#2C2C2E` |
| CTA 배경 | `ctaBackground` | `#8B7BE8` |
| CTA 텍스트 | `ctaForeground` | `#F5F6FB` |
| 정보 accent | `accentSecondary` | `#8FB8FF` |
| 하이라이트 accent | `accentTertiary` | `#E0A76B` |
| 성공 | `success` | `#34C759` |
| 경고 | `warning` | `#FFCC00` |
| 에러 | `error` | `#FF3B30` |

라이트 모드는 `fortuneColors.light` 맵으로 역상 대응되며, 배경/텍스트는 반전되고 `ctaBackground`는 동일하게 유지됩니다.

### 다크 모드 규칙

- 앱 기본은 다크 모드입니다. `theme.ts`에서 `createFortuneTheme('dark')`를 내보내고, `navigationTheme`는 `@react-navigation/native`의 `DarkTheme`를 확장합니다.
- 시스템 테마 추적이 필요한 화면은 `Appearance.getColorScheme()` 또는 `useColorScheme()` 훅을 읽은 뒤 `createFortuneTheme('light' | 'dark')`로 새 인스턴스를 구성합니다. 개별 컴포넌트가 `isDarkMode` 플래그를 직접 붙이지 않습니다.
- StatusBar/Navigation chrome 색은 `navigationTheme`에서 파생되므로 화면 별로 재정의하지 않습니다.

### 사용 원칙

```tsx
import { fortuneTheme } from '@/lib/theme';

// 권장
<View style={{ backgroundColor: fortuneTheme.colors.background }} />
<Text style={{ color: fortuneTheme.colors.textPrimary }} />

// 허용 (도메인 색상 직접 참조)
<View style={{ backgroundColor: fortuneTheme.colors.ctaBackground }} />

// 금지 (hex 리터럴 / 예약어 색상)
<View style={{ backgroundColor: '#8B7BE8' }} />
<View style={{ backgroundColor: 'black' }} />
```

## 타이포그래피

권장 API는 두 가지입니다.

1. 컴포넌트: `<AppText variant="...">` — 기본 색상 `fortuneTheme.colors.textPrimary` + system font 적용
2. 스타일 객체: `fortuneTheme.typography.*` — 커스텀 컴포넌트 내부에서 스타일 합성 시

```tsx
import { AppText } from '@/components/app-text';
import { fortuneTheme } from '@/lib/theme';

<AppText variant="heading1">타이틀</AppText>
<AppText variant="bodyMedium">본문</AppText>
<AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>라벨</AppText>

// 스타일 합성이 필요할 때
<Text style={[fortuneTheme.typography.heading2, { color: fortuneTheme.colors.accentTertiary }]} />
```

### 권장 variant (`fortuneTheme.typography`)

| variant | 용도 |
|---------|------|
| `displayLarge`, `displayMedium`, `displaySmall` | splash / hero |
| `heading1`, `heading2`, `heading3`, `heading4` | 페이지/카드/섹션 제목 |
| `bodyLarge`, `bodyMedium`, `bodySmall` | 본문/설명 |
| `labelLarge`, `labelMedium`, `labelSmall` | UI 라벨 |
| `caption` | 보조/메타 정보 |
| `calligraphyTitle`, `calligraphyBody` | 전통/서사형 콘텐츠 |

### 타이포 정책

- 모든 텍스트는 `<AppText>` 또는 `fortuneTheme.typography.*`를 경유합니다. `<Text style={{ fontSize: 16 }}>`처럼 raw 숫자 지정은 금지.
- 폰트 패밀리는 `AppText`가 기본 `System`을 지정합니다. 변경이 필요하면 `theme.ts`에서 파생하고 변형을 토큰으로 추가합니다.
- Flutter 시절의 `headlineMedium` / `titleMedium` 같은 이름은 더 이상 사용하지 않습니다. `heading1~4`, `bodyLarge~Small` 스케일로 정렬합니다.

## 공용 컴포넌트 계층

### 1. 런타임 테마 / shell

| 영역 | 위치 |
|------|------|
| 페이지 shell | `apps/mobile-rn/src/components/screen.tsx` |
| 네비게이션 테마 | `apps/mobile-rn/src/lib/theme.ts` — `navigationTheme` |
| 타이포 컴포넌트 | `apps/mobile-rn/src/components/app-text.tsx` |
| 공용 인풋/카드 | `apps/mobile-rn/src/components/` 하위 |

### 2. 도메인 컴포넌트

| 컴포넌트 | 역할 |
|----------|------|
| `recent-chat-signal-card.tsx` | 채팅 진입 카드 |
| `recent-result-card.tsx` | 최근 운세 결과 카드 |
| `survey-composer.tsx` | 서베이 입력 composer |
| `voice-text-input.tsx` | 음성+텍스트 입력 |
| `fortune-results/screens/*` | 운세 타입별 결과 화면 |

### 3. 결과 카드 shell

- `fortune-results/registry.tsx` — 결과 타입 ↔ 스크린 매핑
- `fortune-results/mapping.ts` — 스키마 ↔ view-model 변환
- `fortune-results/screens/` — batch-a / batch-c / birthstone / face-reading / naming 등

결과 화면은 공용 컴포넌트만으로 끝내지 않고, 필요 시 `screen.tsx` shell + `AppText` + 도메인 카드를 조합합니다. 구체 카탈로그는 [26-widget-component-catalog.md](26-widget-component-catalog.md)를 참조하세요 (RN 기준으로 정렬 필요).

## Preferred Layer Guide

| 상황 | 우선 사용 |
|------|-----------|
| 일반 앱 UI | `AppText` + `fortuneTheme.colors.*` + `fortuneTheme.spacing.*` |
| 페이지 chrome | `components/screen.tsx` + `navigationTheme` |
| 운세 결과 화면 | `features/fortune-results/` 공용 shell + 도메인 카드 |
| 결과 타입별 전용 조립 | `features/fortune-results/screens/*` 내부 위젯 |

## 금지 사항

| 금지 | 대안 |
|------|------|
| hex 리터럴 (`'#8B7BE8'`) 하드코딩 | `fortuneTheme.colors.ctaBackground` |
| raw `fontSize` 직접 지정 | `<AppText variant="...">`, `fortuneTheme.typography.*` |
| `'black'`, `'white'` 같은 예약어 | `fortuneTheme.colors.textPrimary` / `background` |
| Flutter 시절 네이밍(`DSColors`, `context.typography.headlineMedium`) 복원 | RN `fortuneTheme.*` 사용 |
| 도큐먼트 전역에 라이트 모드 기본 전제 | 다크 우선, 라이트는 `createFortuneTheme('light')` 파생 |

## 관련 문서

- [16-typography-policy.md](16-typography-policy.md)
- [24-page-layout-reference.md](24-page-layout-reference.md)
- [26-widget-component-catalog.md](26-widget-component-catalog.md) — RN 컴포넌트 기준 재정리 필요
