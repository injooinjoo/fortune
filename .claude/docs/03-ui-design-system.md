# UI 디자인 시스템 가이드

## 개요

Fortune App은 **한국 전통 미학**을 기반으로 일관된 UI를 구현합니다.
Toss Design System은 현대적 UI 패턴의 보조 참조로만 사용합니다.

### 핵심 파일
- `lib/core/theme/obangseok_colors.dart` - 오방색 색상 시스템 (PRIMARY)
- `lib/core/design_system/components/traditional/hanji_card.dart` - 한지 카드
- `lib/core/theme/toss_design_system.dart` - Toss 색상 참조 (SECONDARY)
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

## 간격 및 반경

### 간격 (Spacing)
```dart
DSSpacing.xs    // 4px
DSSpacing.sm    // 8px
DSSpacing.md    // 16px
DSSpacing.lg    // 24px
DSSpacing.xl    // 32px
DSSpacing.xxl   // 48px
```

### 반경 (Radius)
```dart
DSRadius.sm     // 8px
DSRadius.md     // 12px
DSRadius.lg     // 16px
DSRadius.xl     // 24px
DSRadius.full   // 9999px (완전 둥근)
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

## 관련 문서

- [docs/design/DESIGN_SYSTEM.md](/docs/design/DESIGN_SYSTEM.md) - 전체 디자인 철학
- [docs/design/KOREAN_TALISMAN_DESIGN_GUIDE.md](/docs/design/KOREAN_TALISMAN_DESIGN_GUIDE.md) - 부적/민화 가이드
- [docs/design/BLUR_SYSTEM_GUIDE.md](/docs/design/BLUR_SYSTEM_GUIDE.md) - 블러 시스템 상세
- [docs/design/TOSS_DESIGN_SYSTEM.md](/docs/design/TOSS_DESIGN_SYSTEM.md) - Toss 보조 참조
