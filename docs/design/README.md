# Fortune App 디자인 문서 가이드

## 개요

Fortune App의 디자인 시스템은 **한국 전통 미학 (Korean Traditional Aesthetics)**을 기반으로 합니다.

> **핵심 정체성**: 한지와 수묵화의 질감, 오방색의 색상 체계, 서예와 명조의 타이포그래피로 전통의 아름다움을 현대적으로 재해석합니다.

---

## 문서 계층 구조

### Tier 1: 핵심 디자인 시스템 (PRIMARY)

| 문서 | 설명 | 우선순위 |
|------|------|----------|
| **[DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md)** | 한국 전통 미학 기반 통합 디자인 시스템 | **최우선** |

모든 UI 구현은 이 문서를 기준으로 합니다.

---

### Tier 2: 도메인 가이드

| 문서 | 설명 | 주요 내용 |
|------|------|----------|
| [KOREAN_TALISMAN_DESIGN_GUIDE.md](./KOREAN_TALISMAN_DESIGN_GUIDE.md) | 부적/민화 디자인 가이드 | 민화 에셋, 전통 문양 |
| [UI_UX_MASTER_POLICY.md](./UI_UX_MASTER_POLICY.md) | UI/UX 마스터 정책 | 인터랙션, 접근성 |
| [BLUR_SYSTEM_GUIDE.md](./BLUR_SYSTEM_GUIDE.md) | 블러 시스템 가이드 | 프리미엄 콘텐츠 처리 |

---

### Tier 3: 기술 참조 문서

| 문서 | 설명 | 참조 시점 |
|------|------|----------|
| [UNIFIED_FONT_SYSTEM.md](./UNIFIED_FONT_SYSTEM.md) | 통합 폰트 시스템 | 폰트 설정 시 |
| [WIDGET_ARCHITECTURE_DESIGN.md](./WIDGET_ARCHITECTURE_DESIGN.md) | 위젯 아키텍처 | 위젯 설계 시 |
| [FORTUNE_INPUT_ACCORDION_STANDARD.md](./FORTUNE_INPUT_ACCORDION_STANDARD.md) | 입력 아코디언 표준 | 입력 폼 구현 시 |

---

### Tier 4: 보조 참조 (SECONDARY)

| 문서 | 설명 | 주의사항 |
|------|------|----------|
| [TOSS_DESIGN_SYSTEM.md](./TOSS_DESIGN_SYSTEM.md) | Toss 디자인 시스템 참조 | **보조 참조만** |

> **중요**: Toss Design System은 보조 참조로만 사용합니다. 한국 전통 미학과 충돌 시 전통 미학이 우선입니다.

---

### 마이그레이션 문서

| 문서 | 설명 | 상태 |
|------|------|------|
| [FONT_MIGRATION_GUIDE.md](./FONT_MIGRATION_GUIDE.md) | 폰트 마이그레이션 가이드 | 참조용 |
| [FONT_MIGRATION_PLAN.md](./FONT_MIGRATION_PLAN.md) | 폰트 마이그레이션 계획 | 참조용 |
| [TYPOGRAPHY_MIGRATION_GUIDE.md](./TYPOGRAPHY_MIGRATION_GUIDE.md) | 타이포그래피 마이그레이션 | 참조용 |

---

## 핵심 디자인 원칙

### 4대 디자인 기둥

```
┌─────────────────────────────────────────────────────────────┐
│                    한국 전통 미학                              │
├──────────────┬──────────────┬──────────────┬───────────────┤
│    질감       │     색상      │   타이포그래피  │     공간      │
│   Texture    │    Color     │  Typography  │    Space     │
├──────────────┼──────────────┼──────────────┼───────────────┤
│  한지 + 먹     │    오방색     │ 서예 + 명조    │   여백의 미    │
│ Hanji + Ink  │  Five Colors │ Calligraphy  │  Empty Space │
└──────────────┴──────────────┴──────────────┴───────────────┘
```

### 핵심 색상 (오방색)

| 오행 | 색상 | Hex | 용도 |
|------|------|-----|------|
| 목(木) | 청 (Cheong) | `#1E3A5F` | 지혜, 성장 |
| 화(火) | 적 (Jeok) | `#B91C1C` | 열정, 사랑 |
| 토(土) | 황 (Hwang) | `#B8860B` | 풍요, 재물 |
| 금(金) | 백 (Baek) | `#F5F5DC` | 순수, 건강 |
| 수(水) | 흑 (Heuk) | `#1C1C1C` | 신비, 운명 |

**특수 색상**: 인주(#DC2626), 먹(#1A1A1A), 미색(#F7F3E9)

### 핵심 컴포넌트

| 컴포넌트 | 용도 | 위치 |
|----------|------|------|
| `HanjiCard` | 한지 질감 카드 | `lib/core/design_system/components/traditional/` |
| `SealStamp` | 낙관 (도장) | `lib/core/design_system/components/traditional/` |
| `ObangseokColors` | 오방색 시스템 | `lib/core/theme/obangseok_colors.dart` |

---

## 빠른 시작

### 1. 한지 카드 사용

```dart
import 'package:fortune/core/design_system/components/traditional/hanji_card.dart';

HanjiCard(
  style: HanjiCardStyle.scroll,  // 두루마리 스타일
  colorScheme: HanjiColorScheme.fortune,
  showSealStamp: true,
  child: YourContent(),
)
```

### 2. 오방색 사용

```dart
import 'package:fortune/core/theme/obangseok_colors.dart';

// 도메인별 색상
final loveColor = ObangseokColors.getDomainColor('love');  // 적색

// 테마 인식 색상
final background = ObangseokColors.getHanjiBackground(context);
```

### 3. 전통 타이포그래피

```dart
// 전통 제목 스타일
Text('사주팔자', style: context.heading1.copyWith(
  fontFamily: 'GowunBatang',
  fontWeight: FontWeight.w700,
))
```

---

## 문서 간 관계

```
DESIGN_SYSTEM.md (최상위 통합 문서)
    │
    ├── KOREAN_TALISMAN_DESIGN_GUIDE.md (민화/부적)
    │       └── assets/images/minhwa/ (30+ 에셋)
    │
    ├── UI_UX_MASTER_POLICY.md (인터랙션/접근성)
    │
    ├── UNIFIED_FONT_SYSTEM.md (폰트)
    │       └── GowunBatang, ZenSerif
    │
    └── TOSS_DESIGN_SYSTEM.md (보조 참조)
            └── 한국 전통 미학 우선
```

---

## 관련 구현 파일

| 파일 | 설명 |
|------|------|
| `lib/core/theme/obangseok_colors.dart` | 오방색 색상 시스템 |
| `lib/core/design_system/components/traditional/hanji_card.dart` | HanjiCard 컴포넌트 |
| `lib/core/design_system/tokens/ds_colors.dart` | 색상 토큰 |
| `assets/images/minhwa/` | 민화 에셋 (30+ PNG) |

---

## 업데이트 이력

| 날짜 | 변경 내용 |
|------|----------|
| 2024-12 | 한국 전통 미학 기반 디자인 시스템 v2.0 도입 |
| 2024-12 | Toss Design System → 보조 참조로 변경 |
| 2024-12 | HanjiCard, ObangseokColors 문서화 완료 |
