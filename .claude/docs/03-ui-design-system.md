# UI 디자인 시스템 가이드

> 최종 업데이트: 2025.02.07

## 개요

Fortune App은 **ChatGPT 스타일의 미니멀 디자인**을 채택합니다.
- 모노크롬 기반 (흰/검 + iOS 시스템 컬러)
- 깔끔하고 콘텐츠 중심적인 UI
- DSColors 단일 색상 시스템 사용

---

## 디자인 시스템 구조 (lib/core/design_system/)

```
lib/core/design_system/
├── design_system.dart           # 통합 export
├── tokens/                      # 디자인 토큰
│   ├── ds_colors.dart          # 색상 시스템 (ChatGPT 스타일)
│   ├── ds_typography.dart      # 타이포그래피
│   ├── ds_spacing.dart         # 간격 토큰
│   ├── ds_radius.dart          # 보더 레이더스
│   ├── ds_shadows.dart         # 그림자 효과
│   ├── ds_animation.dart       # 애니메이션 곡선
│   └── ds_saju_colors.dart     # 사주 오행 시각화용 (semantic)
├── theme/                       # 테마 시스템
│   ├── ds_theme.dart           # Material3 기반 통합 테마
│   └── ds_extensions.dart      # BuildContext 확장
├── components/                  # UI 컴포넌트
│   ├── ds_button.dart          # 버튼
│   ├── ds_card.dart            # 카드
│   ├── ds_chip.dart            # 칩
│   ├── ds_text_field.dart      # 입력 필드
│   ├── ds_modal.dart           # 모달
│   ├── ds_bottom_sheet.dart    # 바텀시트
│   ├── ds_toast.dart           # 토스트
│   ├── ds_loading.dart         # 로딩 표시자
│   ├── ds_badge.dart           # 뱃지
│   ├── ds_toggle.dart          # 토글
│   ├── ds_list_tile.dart       # 리스트 타일
│   └── ds_section_header.dart  # 섹션 헤더
└── utils/
    └── ds_haptics.dart         # 햅틱 피드백
```

### 핵심 파일
- `lib/core/design_system/tokens/ds_colors.dart` - ChatGPT 스타일 색상 시스템
- `lib/core/theme/typography_unified.dart` - 타이포그래피

---

## 색상 시스템 (DSColors)

### 디자인 철학
- **다크 모드 우선**: 기본값이 다크 모드
- **모노크롬 기반**: 흰/검 + 최소한의 accent
- **iOS 시스템 컬러**: success, warning, error

### 색상 사용법

```dart
import 'package:fortune/core/design_system/design_system.dart';

// Context extension 사용 (권장)
Container(
  color: context.colors.background,
  child: Text(
    '텍스트',
    style: TextStyle(color: context.colors.textPrimary),
  ),
)

// 정적 색상 (테마 무관)
Container(color: DSColors.success)
```

### 주요 색상

| 용도 | Light Mode | Dark Mode | 사용법 |
|------|------------|-----------|--------|
| 배경 | White `#FFFFFF` | Black `#000000` | `context.colors.background` |
| 표면 | Gray `#F7F7F8` | Gray `#1A1A1A` | `context.colors.surface` |
| 텍스트 (주) | Black `#000000` | White `#FFFFFF` | `context.colors.textPrimary` |
| 텍스트 (부) | Gray `#6B7280` | Gray `#9CA3AF` | `context.colors.textSecondary` |
| 구분선 | Gray `#E5E7EB` | Gray `#374151` | `context.colors.divider` |

### Semantic 색상

| 용도 | 색상 | Hex | 사용법 |
|------|------|-----|--------|
| 성공/건강 | Green | `#10B981` | `DSColors.success` |
| 경고/토큰 | Amber | `#F59E0B` | `DSColors.warning` |
| 에러/위험 | Red | `#EF4444` | `DSColors.error` |
| 정보 | Blue | `#3B82F6` | `DSColors.info` |
| Accent | Purple | `#8B5CF6` | `DSColors.accentSecondary` |

---

## 타이포그래피

### Context Extension 사용 (필수)

```dart
// ✅ 올바른 사용
Text('제목', style: context.heading1)
Text('본문', style: context.body1)
Text('캡션', style: context.caption)

// ❌ 금지
Text('제목', style: TextStyle(fontSize: 24))
```

### 스타일 매핑

| 스타일 | 크기 | Weight | 용도 |
|--------|------|--------|------|
| `heading1` | 30pt | Bold | 페이지 메인 제목 |
| `heading2` | 26pt | SemiBold | 섹션 제목 |
| `heading3` | 22pt | SemiBold | AppBar, 서브섹션 |
| `heading4` | 20pt | Medium | 카드 제목 |
| `body1` / `bodyMedium` | 17pt | Regular | 일반 본문 |
| `body2` | 15pt | Regular | 보조 본문 |
| `bodySmall` | 14pt | Regular | 작은 본문 |
| `caption` / `labelSmall` | 12pt | Regular | 캡션, 힌트 |

---

## 컴포넌트

### DSCard

```dart
// 기본 카드
DSCard(
  child: content,
)

// Elevated 카드
DSCard.elevated(
  child: content,
)

// Outlined 카드
DSCard.outlined(
  child: content,
)
```

### DSButton

```dart
// Primary 버튼
DSButton.primary(
  text: '확인',
  onPressed: () {},
)

// Secondary 버튼
DSButton.secondary(
  text: '취소',
  onPressed: () {},
)

// Text 버튼
DSButton.text(
  text: '더보기',
  onPressed: () {},
)
```

### DSChip

```dart
DSChip(
  label: '태그',
  selected: true,
  onTap: () {},
)
```

---

## 다크모드 지원

### 자동 테마 적용
```dart
// context.colors는 자동으로 다크/라이트 모드 감지
Container(
  color: context.colors.background, // 자동 전환
)
```

### 수동 테마 확인
```dart
final isDark = context.isDark;
if (isDark) {
  // 다크모드 전용 로직
}
```

---

## 금지 사항

| 금지 | 대안 |
|------|------|
| `Color(0xFF...)` 하드코딩 | `DSColors.xxx` 또는 `context.colors.xxx` |
| `fontSize: 숫자` 직접 사용 | `context.heading1`, `context.body1` 등 |
| `Colors.white/black` | `context.colors.background/textPrimary` |
| 레거시 색상 시스템 (DSFortuneColors, ObangseokColors 등) | DSColors만 사용 |

---

## 사주 오행 시각화 (예외)

사주 차트의 오행 구분에는 `SajuColors` 사용 허용:
- 목(木): Green
- 화(火): Red
- 토(土): Amber
- 금(金): Gray
- 수(水): Blue

```dart
import 'package:fortune/core/design_system/design_system.dart';

// 오행 색상 가져오기
final color = SajuColors.getElementColor('목', context.isDark);
```

---

## 표준 AppBar 패턴

```dart
AppBar(
  backgroundColor: context.colors.background,
  elevation: 0,
  scrolledUnderElevation: 0,
  leading: IconButton(
    icon: Icon(
      Icons.arrow_back_ios,
      color: context.colors.textPrimary,
    ),
    onPressed: () => context.pop(),
  ),
  title: Text(
    '페이지 제목',
    style: context.heading3.copyWith(
      color: context.colors.textPrimary,
    ),
  ),
  centerTitle: true,
)
```

---

## 디자인 토큰 시스템

### 간격 (DSSpacing)

```dart
DSSpacing.xxs   // 2px
DSSpacing.xs    // 4px
DSSpacing.sm    // 8px
DSSpacing.md    // 16px
DSSpacing.lg    // 24px
DSSpacing.xl    // 32px
DSSpacing.xxl   // 48px
```

### 반경 (DSRadius)

```dart
DSRadius.xs     // 4px
DSRadius.sm     // 8px
DSRadius.md     // 12px
DSRadius.lg     // 16px
DSRadius.xl     // 24px
DSRadius.card   // 16px (카드 기본)
DSRadius.button // 12px (버튼 기본)
```

### 그림자 (DSShadows)

```dart
DSShadows.sm        // 작은 그림자
DSShadows.md        // 중간 그림자
DSShadows.lg        // 큰 그림자
DSShadows.card      // 카드용 그림자
DSShadows.elevated  // 강조 그림자
```

---

## 검증 체크리스트

### 새 위젯 작성 시
- [ ] DSCard 사용 (카드)
- [ ] DSColors / context.colors 사용 (색상)
- [ ] context.heading1, context.body1 등 사용 (텍스트)
- [ ] 다크모드 지원 (context.colors 자동 대응)
- [ ] AppBar에 iOS 스타일 뒤로가기 버튼

---

## 관련 문서

- [18-chat-first-architecture.md](18-chat-first-architecture.md) - Chat-First 아키텍처
- [16-typography-policy.md](16-typography-policy.md) - 타이포그래피 정책
