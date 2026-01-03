# UI 디자인 시스템 가이드

> 최종 업데이트: 2025.01.03

## 개요

Fortune App은 **한국 전통 미학**을 기반으로 일관된 UI를 구현합니다.
Toss Design System은 현대적 UI 패턴의 보조 참조로만 사용합니다.

---

## 디자인 시스템 구조 (lib/core/design_system/)

```
lib/core/design_system/
├── design_system.dart           # 통합 export
├── tokens/                      # 디자인 토큰
│   ├── ds_colors.dart          # 색상 시스템 (오방색 기반)
│   ├── ds_typography.dart      # 타이포그래피 (나눔명조)
│   ├── ds_spacing.dart         # 간격 토큰
│   ├── ds_radius.dart          # 보더 레이더스
│   ├── ds_shadows.dart         # 먹 번짐 효과
│   ├── ds_animation.dart       # 애니메이션 곡선
│   ├── ds_fortune_colors.dart  # 운세별 색상
│   ├── ds_love_colors.dart     # 연애운 색상
│   ├── ds_luck_colors.dart     # 행운 색상
│   └── ds_biorhythm_colors.dart # 바이오리듬 색상
├── theme/                       # 테마 시스템
│   ├── ds_theme.dart           # Material3 기반 통합 테마
│   └── ds_extensions.dart      # BuildContext 확장
├── components/                  # UI 컴포넌트
│   ├── ds_button.dart          # 버튼
│   ├── ds_card.dart            # 카드 (5가지 스타일)
│   ├── ds_chip.dart            # 칩
│   ├── ds_text_field.dart      # 입력 필드
│   ├── ds_modal.dart           # 모달
│   ├── ds_bottom_sheet.dart    # 바텀시트
│   ├── ds_toast.dart           # 토스트
│   ├── ds_loading.dart         # 로딩 표시자
│   ├── ds_badge.dart           # 뱃지
│   ├── ds_toggle.dart          # 토글
│   ├── ds_list_tile.dart       # 리스트 타일
│   ├── ds_section_header.dart  # 섹션 헤더
│   ├── hanji_background.dart   # 한지 배경
│   └── traditional/            # 전통 스타일 컴포넌트
│       ├── hanji_card.dart     # 한지 카드
│       ├── seal_stamp_widget.dart # 낙관 (도장)
│       ├── fortune_header.dart # 운세 헤더
│       └── traditional_button.dart # 전통 버튼
└── utils/
    └── ds_haptics.dart         # 햅틱 피드백
```

### 핵심 파일
- `lib/core/design_system/tokens/ds_colors.dart` - 오방색 색상 시스템 (PRIMARY)
- `lib/core/design_system/components/traditional/hanji_card.dart` - 한지 카드
- `lib/core/theme/obangseok_colors.dart` - 레거시 오방색 (호환용)
- `lib/core/theme/typography_unified.dart` - 타이포그래피

**전체 디자인 철학**: [docs/design/DESIGN_SYSTEM.md](/docs/design/DESIGN_SYSTEM.md)

---

## 한국 전통 디자인 시스템 (PRIMARY)

### 핵심 컴포넌트

#### HanjiCard - 한지 카드

**파일**: `lib/core/design_system/components/traditional/hanji_card.dart`

모든 운세 결과 표시에 사용하는 한지 질감 카드.

```dart
import 'package:fortune/core/design_system/components/traditional/hanji_card.dart';

// 기본 사용
HanjiCard(
  child: FortuneContent(),
)

// 두루마리 스타일 + 낙관 (사주 결과)
HanjiCard(
  style: HanjiCardStyle.scroll,
  colorScheme: HanjiColorScheme.fortune,
  showSealStamp: true,
  sealText: '運',
  child: SajuResult(),
)

// 족자 스타일 (총평, 조언)
HanjiCard(
  style: HanjiCardStyle.hanging,
  showCornerDecorations: true,
  child: FortuneAdvice(),
)
```

**스타일 옵션 (HanjiCardStyle):**
| 스타일 | 용도 |
|--------|------|
| `standard` | 일반 콘텐츠 |
| `scroll` | 사주 명식, 긴 콘텐츠 (두루마리) |
| `hanging` | 총평, 조언 (족자) |
| `elevated` | 강조 카드 |
| `minimal` | 서브 콘텐츠 |

**색상 스킴 (HanjiColorScheme):**
| 스킴 | 용도 |
|------|------|
| `fortune` | 일반 운세 (자주+금) |
| `love` | 연애운, 궁합 (연지색) |
| `luck` | 재물운, 행운 (황금색) |
| `biorhythm` | 바이오리듬 (오방색) |
| `health` | 건강운 (청록색) |

#### SealStamp - 낙관 (도장)

```dart
SealStamp(
  text: '福',
  color: ObangseokColors.inju,
  size: 32,
)
```

#### HanjiSectionCard - 섹션 카드

```dart
HanjiSectionCard(
  title: '오늘의 조언',
  subtitle: 'Today\'s Advice',
  hanja: '言',
  colorScheme: HanjiColorScheme.fortune,
  child: AdviceContent(),
)
```

---

### 오방색 색상 시스템 (ObangseokColors)

**파일**: `lib/core/theme/obangseok_colors.dart`

#### 올바른 사용법

```dart
import 'package:fortune/core/theme/obangseok_colors.dart';

// 오방색 직접 사용
Container(color: ObangseokColors.cheong)   // 목(木) - 청색
Container(color: ObangseokColors.jeok)     // 화(火) - 적색
Container(color: ObangseokColors.hwang)    // 토(土) - 황색
Container(color: ObangseokColors.baek)     // 금(金) - 백색
Container(color: ObangseokColors.heuk)     // 수(水) - 흑색

// 특수 색상
Container(color: ObangseokColors.inju)     // 인주 (도장 색)
Container(color: ObangseokColors.meok)     // 먹색
Container(color: ObangseokColors.misaek)   // 미색 (한지 배경)

// 도메인별 자동 매핑
ObangseokColors.getDomainColor('love')     // 연애 → jeokMuted
ObangseokColors.getDomainColor('career')   // 직업 → cheongMuted
ObangseokColors.getDomainColor('money')    // 재물 → hwang
ObangseokColors.getDomainColor('health')   // 건강 → baekDark

// 오행별 매핑
ObangseokColors.getElementColor('목')      // cheong
ObangseokColors.getElementColor('화')      // jeok

// 다크모드 대응
ObangseokColors.getHanjiBackground(context)
ObangseokColors.getMisaek(context)
ObangseokColors.getMeok(context)
ObangseokColors.getInju(context)
```

#### 색상 표

| 오행 | 기본 | Muted | Light | Dark |
|------|------|-------|-------|------|
| 목(木) 청 | `#1E3A5F` | `#3D5A73` | `#2D5A87` | `#0F1F33` |
| 화(火) 적 | `#B91C1C` | `#9B4D4D` | `#DC2626` | `#7F1D1D` |
| 토(土) 황 | `#B8860B` | `#A39171` | `#D4A017` | `#8B6914` |
| 금(金) 백 | `#F5F5DC` | `#D4D0BB` | `#FFFFF0` | `#E8E4C9` |
| 수(水) 흑 | `#1C1C1C` | `#404040` | `#2D2D2D` | `#0A0A0A` |

| 특수 | 기본 | Light | Dark |
|------|------|-------|------|
| 인주 | `#DC2626` | `#EF4444` | `#B91C1C` |
| 먹 | `#1A1A1A` | `#333333` | `#0D0D0D` |
| 미색 | `#F7F3E9` | `#FAF8F2` | `#EDE8DA` |

---

## 타이포그래피 (TypographyUnified)

**모든 텍스트는 반드시 TypographyUnified를 사용합니다!**

### 올바른 사용법

```dart
import 'package:fortune/core/theme/typography_unified.dart';

// 방법 1: BuildContext extension 사용 (권장)
Text('제목', style: context.heading1)
Text('본문', style: context.bodyMedium)
Text('버튼', style: context.buttonMedium)
Text('라벨', style: context.labelMedium)

// 방법 2: 직접 사용
Text('제목', style: TypographyUnified.heading1)
Text('본문', style: TypographyUnified.bodyMedium)

// 색상 적용
Text('제목', style: context.heading1.copyWith(color: ObangseokColors.inju))
```

### 전통 폰트 사용 (NanumMyeongjo)

전통적 느낌이 필요한 제목, 한자, 낙관에 사용:

```dart
// 전통 제목
Text(
  '오늘의 운세',
  style: TextStyle(
    fontFamily: 'NanumMyeongjo',
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: ObangseokColors.meok,
  ),
)

// 한자 요소
Text(
  '運',
  style: TextStyle(
    fontFamily: 'NanumMyeongjo',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: ObangseokColors.inju,
  ),
)
```

### 잘못된 사용법 (금지!)

```dart
// TossDesignSystem의 deprecated TextStyle 사용 금지
Text('제목', style: TossDesignSystem.heading1)  // WRONG!
Text('본문', style: TossDesignSystem.body2)     // WRONG!

// 하드코딩된 fontSize 사용 금지
Text('제목', style: TextStyle(fontSize: 24))   // WRONG!
```

### 스타일 가이드

**모든 텍스트는 NanumMyeongjo (나눔명조) 폰트를 사용합니다.**

| 카테고리 | 스타일 | 크기 | 용도 |
|---------|--------|------|------|
| **Display** | displayLarge | 50pt | 스플래시, 온보딩 |
| | displayMedium | 42pt | 큰 헤드라인 |
| | displaySmall | 34pt | 중간 헤드라인 |
| **Heading** | heading1 | 30pt | 메인 페이지 제목 |
| | heading2 | 26pt | 섹션 제목 |
| | heading3 | 22pt | 서브 섹션 제목 |
| | heading4 | 20pt | 작은 섹션 제목 |
| **Body** | bodyLarge | 19pt | 큰 본문 |
| | bodyMedium | 17pt | 기본 본문 |
| | bodySmall | 16pt | 작은 본문 |
| **Label** | labelLarge | 15pt | 큰 라벨 |
| | labelMedium | 14pt | 기본 라벨 |
| | labelSmall | 13pt | 작은 라벨 |
| | labelTiny | 12pt | 배지, NEW 표시 |
| **Button** | buttonLarge | 19pt | 큰 버튼 |
| | buttonMedium | 18pt | 기본 버튼 |
| | buttonSmall | 17pt | 작은 버튼 |
| | buttonTiny | 16pt | 매우 작은 버튼 |
| **Number** | numberXLarge | 42pt | 매우 큰 숫자 |
| | numberLarge | 34pt | 큰 숫자 |
| | numberMedium | 26pt | 중간 숫자 |
| | numberSmall | 20pt | 작은 숫자 |

---

## 색상 시스템 - 다크모드 지원

### 다크모드 지원 필수

**모든 색상은 다크모드 대응 패턴을 따릅니다:**

```dart
// 올바른 방법: isDark 조건문 사용
final isDark = Theme.of(context).brightness == Brightness.dark;

Container(
  color: isDark
      ? ObangseokColors.hanjiBackgroundDark
      : ObangseokColors.hanjiBackground,
  child: Text(
    '텍스트',
    style: TextStyle(
      color: ObangseokColors.getMeok(context),
    ),
  ),
)
```

```dart
// 잘못된 방법: 하드코딩 색상 금지
Container(
  color: Color(0xFF191F28),  // WRONG!
  child: Text('텍스트', style: TextStyle(color: Colors.white)),  // WRONG!
)
```

### 주요 색상 토큰 (다크모드)

| 용도 | Light | Dark |
|-----|-------|------|
| **한지 배경** | `hanjiBackground` #FAF8F5 | `hanjiBackgroundDark` #1E1E1E |
| **미색 배경** | `misaek` #F7F3E9 | `heukLight` #2D2D2D |
| **텍스트 (주)** | `meok` #1A1A1A | `baekDark` #E8E4C9 |
| **강조** | `inju` #DC2626 | `injuLight` #EF4444 |
| **테두리** | `meok` 15% | `baek` 15% |

### 보조 참조: TossDesignSystem 색상

> **Note**: 아래는 보조 참조입니다. 가능하면 ObangseokColors를 우선 사용하세요.

| 용도 | Light | Dark |
|-----|-------|------|
| **배경** | backgroundLight | backgroundDark |
| **카드 배경** | cardBackgroundLight | cardBackgroundDark |
| **텍스트 (주)** | textPrimaryLight | textPrimaryDark |
| **텍스트 (부)** | textSecondaryLight | textSecondaryDark |
| **테두리** | borderLight | borderDark |

---

## 블러 처리 시스템

**모든 블러 처리는 UnifiedBlurWrapper를 사용합니다!**

### 올바른 사용법

```dart
import 'package:fortune/core/widgets/unified_blur_wrapper.dart';

// 1. 블러 처리
UnifiedBlurWrapper(
  isBlurred: fortuneResult.isBlurred,
  blurredSections: fortuneResult.blurredSections,
  sectionKey: 'advice', // 섹션 고유 키
  child: HanjiCard(
    child: Text('조언 내용...'),
  ),
)

// 2. 광고 버튼 (블러 상태일 때만)
if (fortuneResult.isBlurred)
  UnifiedAdUnlockButton(
    onPressed: _showAdAndUnblur,
  )

// 3. 광고 보기 로직 (표준 구현)
bool _isShowingAd = false;

Future<void> _showAdAndUnblur() async {
  if (_isShowingAd) return; // 중복 호출 방지

  try {
    _isShowingAd = true;
    final adService = AdService();

    await adService.showRewardedAd(
      onRewarded: () {
        setState(() {
          _fortuneResult = _fortuneResult.copyWith(
            isBlurred: false,
            blurredSections: [],
          );
          _isShowingAd = false;
        });
      },
      onAdDismissed: () {
        _isShowingAd = false;
      },
    );
  } catch (e) {
    _isShowingAd = false;
  }
}
```

### 잘못된 사용법 (금지!)

```dart
// ImageFilter.blur 직접 사용 금지
ImageFiltered(
  imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  child: child,
)

// 커스텀 블러 구현 금지
Widget _buildBlurWrapper({...}) {
  return Stack(...); // 커스텀 블러 구현
}
```

### 섹션 키 네이밍 규칙
- 영문 소문자 + 언더스코어
- 예: `advice`, `future_outlook`, `luck_items`, `warnings`

---

## 표준 AppBar 패턴

**모든 페이지의 뒤로가기 버튼은 이 패턴을 따릅니다:**

```dart
AppBar(
  backgroundColor: isDark
      ? ObangseokColors.hanjiBackgroundDark
      : ObangseokColors.hanjiBackground,
  elevation: 0,
  scrolledUnderElevation: 0,
  leading: IconButton(
    icon: Icon(
      Icons.arrow_back_ios,  // iOS 스타일 < 아이콘
      color: ObangseokColors.getMeok(context),
    ),
    onPressed: () => context.pop(),  // go_router의 pop 사용
  ),
  title: Text(
    '페이지 제목',
    style: TextStyle(
      fontFamily: 'NanumMyeongjo',  // 전통 폰트
      color: ObangseokColors.getMeok(context),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  centerTitle: true,
)
```

### 핵심 원칙
- **아이콘**: `Icons.arrow_back_ios` (iOS 스타일) - `Icons.arrow_back` 금지
- **다크모드**: `isDark` 조건으로 색상 대응
- **네비게이션**: `context.pop()` (go_router 표준)
- **배경색**: 한지 배경색 사용

---

## 디자인 토큰 시스템

### Context 확장 사용법 (권장)

```dart
import 'package:fortune/core/design_system/design_system.dart';

// 색상 접근
Container(
  color: context.colors.background,
  child: Text('Hello', style: context.typography.bodyMedium),
)

// 확장 메서드
context.isDark        // 다크모드 확인
context.colors        // DSColorScheme 접근
context.typography    // DSTypographyScheme 접근
context.shadows       // DSShadowScheme 접근
context.spacing       // DSSpacing 접근
```

### 간격 (DSSpacing)

**파일**: `lib/core/design_system/tokens/ds_spacing.dart`

```dart
DSSpacing.xxs   // 2px
DSSpacing.xs    // 4px
DSSpacing.sm    // 8px
DSSpacing.md    // 16px
DSSpacing.lg    // 24px
DSSpacing.xl    // 32px
DSSpacing.xxl   // 48px
DSSpacing.xxxl  // 64px
```

### 반경 (DSRadius)

**파일**: `lib/core/design_system/tokens/ds_radius.dart`

```dart
DSRadius.none   // 0px
DSRadius.xs     // 4px
DSRadius.sm     // 8px
DSRadius.md     // 12px
DSRadius.lg     // 16px
DSRadius.xl     // 24px
DSRadius.xxl    // 32px
DSRadius.full   // 9999px (완전 둥근)
DSRadius.card   // 16px (카드 기본)
DSRadius.button // 12px (버튼 기본)
```

### 그림자 (DSShadows)

**파일**: `lib/core/design_system/tokens/ds_shadows.dart`

```dart
// 먹 번짐 효과 (잉크 워시 스타일)
DSShadows.none      // 없음
DSShadows.sm        // 작은 그림자
DSShadows.md        // 중간 그림자
DSShadows.lg        // 큰 그림자
DSShadows.xl        // 매우 큰 그림자
DSShadows.card      // 카드용 그림자
DSShadows.elevated  // 강조 그림자
```

### 애니메이션 (DSAnimation)

**파일**: `lib/core/design_system/tokens/ds_animation.dart`

```dart
DSAnimation.fast      // 150ms
DSAnimation.normal    // 250ms
DSAnimation.slow      // 350ms
DSAnimation.verySlow  // 500ms

DSAnimation.curveDefault    // Curves.easeInOut
DSAnimation.curveEaseIn     // Curves.easeIn
DSAnimation.curveEaseOut    // Curves.easeOut
DSAnimation.curveBounce     // Curves.bounceOut
```

---

## 검증 체크리스트

### 새 위젯 작성 시
- [ ] HanjiCard 또는 HanjiSectionCard 사용 (운세 결과)
- [ ] ObangseokColors 우선 사용 (색상)
- [ ] TypographyUnified 사용 (텍스트)
- [ ] NanumMyeongjo 폰트 사용 (context.heading1, context.bodyMedium 등)
- [ ] 다크모드 지원 (`isDark` 조건문)
- [ ] 블러 처리 시 UnifiedBlurWrapper 사용
- [ ] AppBar에 iOS 스타일 뒤로가기 버튼

---

## 채팅 UI 표준 (Chat-First)

### 채팅 버블

**사용자 메시지**: 오른쪽 정렬, 먹색 배경
**AI 메시지**: 왼쪽 정렬, 한지 배경

```dart
// 사용자 버블
Container(
  alignment: Alignment.centerRight,
  child: Container(
    padding: EdgeInsets.all(DSSpacing.md),
    decoration: BoxDecoration(
      color: ObangseokColors.meok,
      borderRadius: BorderRadius.circular(DSRadius.lg),
    ),
    child: Text(
      message.text,
      style: context.bodyMedium.copyWith(
        color: ObangseokColors.baek,
      ),
    ),
  ),
)

// AI 버블
Container(
  alignment: Alignment.centerLeft,
  child: Container(
    padding: EdgeInsets.all(DSSpacing.md),
    decoration: BoxDecoration(
      color: isDark
          ? ObangseokColors.hanjiBackgroundDark
          : ObangseokColors.hanjiBackground,
      borderRadius: BorderRadius.circular(DSRadius.lg),
      border: Border.all(
        color: ObangseokColors.getMeok(context).withOpacity(0.15),
      ),
    ),
    child: Text(
      message.text,
      style: context.bodyMedium.copyWith(
        color: ObangseokColors.getMeok(context),
      ),
    ),
  ),
)
```

### 추천 칩 (RecommendationChip)

```dart
// 칩 그리드
Wrap(
  spacing: DSSpacing.sm,
  runSpacing: DSSpacing.sm,
  alignment: WrapAlignment.center,
  children: chips.map((chip) => _buildChip(chip)).toList(),
)

// 개별 칩
Widget _buildChip(RecommendationChip chip) {
  return ActionChip(
    avatar: Icon(chip.icon, size: 18, color: chip.color),
    label: Text(
      chip.label,
      style: context.labelMedium.copyWith(
        color: ObangseokColors.getMeok(context),
      ),
    ),
    backgroundColor: isDark
        ? ObangseokColors.heukLight
        : ObangseokColors.misaek,
    side: BorderSide(
      color: chip.color.withOpacity(0.3),
    ),
    onPressed: () => onChipTap(chip),
  );
}
```

### 채팅 내 운세 결과 (ChatFortuneSection)

```dart
// 채팅 내 운세 섹션
Container(
  margin: EdgeInsets.symmetric(vertical: DSSpacing.sm),
  child: HanjiCard(
    style: HanjiCardStyle.minimal,
    child: UnifiedBlurWrapper(
      isBlurred: message.isBlurred,
      sectionKey: message.sectionKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getSectionTitle(message.sectionKey),
            style: context.labelMedium.copyWith(
              color: ObangseokColors.inju,
            ),
          ),
          SizedBox(height: DSSpacing.xs),
          Text(
            message.text,
            style: context.bodyMedium,
          ),
        ],
      ),
    ),
  ),
)
```

### 타이핑 인디케이터

```dart
// 로딩 표시
Container(
  alignment: Alignment.centerLeft,
  child: Container(
    padding: EdgeInsets.all(DSSpacing.md),
    decoration: BoxDecoration(
      color: ObangseokColors.getMisaek(context),
      borderRadius: BorderRadius.circular(DSRadius.lg),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: ObangseokColors.inju,
          ),
        ),
        SizedBox(width: DSSpacing.sm),
        Text(
          '운세를 살펴보고 있어요...',
          style: context.labelMedium.copyWith(
            color: ObangseokColors.getMeok(context).withOpacity(0.7),
          ),
        ),
      ],
    ),
  ),
)
```

### 환영 화면 (WelcomeView)

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // AI 아바타
    Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ObangseokColors.inju.withOpacity(0.1),
      ),
      child: Icon(
        Icons.auto_awesome,
        size: 40,
        color: ObangseokColors.inju,
      ),
    ),
    SizedBox(height: DSSpacing.lg),

    // 환영 텍스트
    Text(
      '오늘 무엇이 궁금하세요?',
      style: context.heading2.copyWith(
        color: ObangseokColors.getMeok(context),
      ),
    ),
    SizedBox(height: DSSpacing.xl),

    // 추천 칩 그리드
    FortuneChipGrid(
      chips: defaultChips,
      onChipTap: (chip) => _handleChipTap(chip),
    ),
  ],
)
```

### 채팅 입력 영역

```dart
// UnifiedVoiceTextField 사용 (기존 컴포넌트)
Container(
  padding: EdgeInsets.all(DSSpacing.md),
  decoration: BoxDecoration(
    color: isDark
        ? ObangseokColors.hanjiBackgroundDark
        : ObangseokColors.hanjiBackground,
    border: Border(
      top: BorderSide(
        color: ObangseokColors.getMeok(context).withOpacity(0.1),
      ),
    ),
  ),
  child: UnifiedVoiceTextField(
    hintText: '무엇이든 물어보세요...',
    onSubmitted: (text) => _sendMessage(text),
    onVoiceComplete: (text) => _sendMessage(text),
  ),
)
```

---

## 관련 문서

- [docs/design/DESIGN_SYSTEM.md](/docs/design/DESIGN_SYSTEM.md) - 전체 디자인 철학
- [18-chat-first-architecture.md](18-chat-first-architecture.md) - Chat-First 아키텍처
- [docs/design/KOREAN_TALISMAN_DESIGN_GUIDE.md](/docs/design/KOREAN_TALISMAN_DESIGN_GUIDE.md) - 부적/민화 가이드
- [docs/design/BLUR_SYSTEM_GUIDE.md](/docs/design/BLUR_SYSTEM_GUIDE.md) - 블러 시스템 상세
- [docs/design/TOSS_DESIGN_SYSTEM.md](/docs/design/TOSS_DESIGN_SYSTEM.md) - Toss 보조 참조
