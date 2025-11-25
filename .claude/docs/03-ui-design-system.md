# UI 디자인 시스템 가이드

## 개요

Fortune App은 **TossDesignSystem**을 기반으로 일관된 UI를 구현합니다.

### 핵심 파일
- `lib/core/theme/toss_design_system.dart` (917줄) - 색상, 간격, 반경
- `lib/core/theme/typography_unified.dart` (420줄) - 타이포그래피

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
Text('제목', style: context.heading1.copyWith(color: Colors.blue))
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

| 카테고리 | 스타일 | 크기 | 용도 |
|---------|--------|------|------|
| **Display** | displayLarge | 48pt | 스플래시, 온보딩 |
| | displayMedium | 40pt | 큰 헤드라인 |
| | displaySmall | 32pt | 중간 헤드라인 |
| **Heading** | heading1 | 28pt | 메인 페이지 제목 |
| | heading2 | 24pt | 섹션 제목 |
| | heading3 | 20pt | 서브 섹션 제목 |
| | heading4 | 18pt | 작은 섹션 제목 |
| **Body** | bodyLarge | 17pt | 큰 본문 |
| | bodyMedium | 15pt | 기본 본문 |
| | bodySmall | 14pt | 작은 본문 |
| **Label** | labelLarge | 13pt | 큰 라벨 |
| | labelMedium | 12pt | 기본 라벨 |
| | labelSmall | 11pt | 작은 라벨 |
| | labelTiny | 10pt | 배지, NEW 표시 |
| **Button** | buttonLarge | 17pt | 큰 버튼 |
| | buttonMedium | 16pt | 기본 버튼 |
| | buttonSmall | 15pt | 작은 버튼 |
| | buttonTiny | 14pt | 매우 작은 버튼 |
| **Number** | numberXLarge | 40pt | 매우 큰 숫자 (TossFace) |
| | numberLarge | 32pt | 큰 숫자 |
| | numberMedium | 24pt | 중간 숫자 |
| | numberSmall | 18pt | 작은 숫자 |

### 핵심 원칙
1. **사용자 설정 반영**: FontSizeSystem 기반으로 사용자 폰트 크기 자동 반영
2. **일관성**: 모든 화면에서 동일한 타이포그래피
3. **접근성**: 시각 장애인을 위한 큰 글씨 모드 지원

---

## 색상 시스템 (TossDesignSystem)

### 다크모드 지원 필수

**모든 색상은 다크모드 대응 패턴을 따릅니다:**

```dart
// 올바른 방법: isDark 조건문 사용
final isDark = Theme.of(context).brightness == Brightness.dark;

Container(
  color: isDark
      ? TossDesignSystem.backgroundDark
      : TossDesignSystem.backgroundLight,
  child: Text(
    '텍스트',
    style: TextStyle(
      color: isDark
          ? TossDesignSystem.textPrimaryDark
          : TossDesignSystem.textPrimaryLight,
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

### 주요 색상 토큰

| 용도 | Light | Dark |
|-----|-------|------|
| **배경** | backgroundLight | backgroundDark |
| **카드 배경** | cardBackgroundLight | cardBackgroundDark |
| **텍스트 (주)** | textPrimaryLight | textPrimaryDark |
| **텍스트 (부)** | textSecondaryLight | textSecondaryDark |
| **테두리** | borderLight | borderDark |
| **구분선** | dividerLight | dividerDark |

### 브랜드 색상

```dart
TossDesignSystem.tossBlue      // 메인 브랜드 색상
TossDesignSystem.tossBlueLight // 밝은 버전
TossDesignSystem.success       // 성공 (녹색)
TossDesignSystem.warning       // 경고 (노랑)
TossDesignSystem.error         // 에러 (빨강)
```

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
  child: TossCard(
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

### 블러 디자인 표준
- **Blur**: `ImageFilter.blur(sigmaX: 10, sigmaY: 10)`
- **그라디언트**: 0.3 → 0.8 alpha
- **아이콘**: 40px 자물쇠, 중앙 배치, shimmer 애니메이션
- **버튼 텍스트**: "광고 보고 전체 내용 보기"

### 섹션 키 네이밍 규칙
- 영문 소문자 + 언더스코어
- 예: `advice`, `future_outlook`, `luck_items`, `warnings`

---

## 표준 AppBar 패턴

**모든 페이지의 뒤로가기 버튼은 이 패턴을 따릅니다:**

```dart
// 참조: lib/features/fortune/presentation/pages/tarot_renewed_page.dart:123-129
AppBar(
  backgroundColor: isDark
      ? TossDesignSystem.backgroundDark
      : TossDesignSystem.backgroundLight,
  elevation: 0,
  scrolledUnderElevation: 0,
  leading: IconButton(
    icon: Icon(
      Icons.arrow_back_ios,  // iOS 스타일 < 아이콘
      color: isDark
          ? TossDesignSystem.textPrimaryDark
          : TossDesignSystem.textPrimaryLight,
    ),
    onPressed: () => context.pop(),  // go_router의 pop 사용
  ),
  title: Text(
    '페이지 제목',
    style: TextStyle(
      color: isDark
          ? TossDesignSystem.textPrimaryDark
          : TossDesignSystem.textPrimaryLight,
      fontSize: 18,
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
- **배경색**: 다크모드 대응 필수

---

## 표준 위젯 컴포넌트

### TossCard
```dart
TossCard(
  padding: EdgeInsets.all(TossDesignSystem.spacingM),
  borderRadius: TossDesignSystem.radiusM,
  child: Column(...),
)
```

### TossButton
```dart
TossButton(
  text: '버튼 텍스트',
  onPressed: () {},
  type: TossButtonType.primary,  // primary, secondary, text
)
```

### TossInput
```dart
TossInput(
  label: '라벨',
  hint: '힌트 텍스트',
  controller: _controller,
  validator: (value) => value?.isEmpty ?? true ? '필수 입력' : null,
)
```

---

## 간격 및 반경

### 간격 (Spacing)
```dart
TossDesignSystem.spacingXS   // 4
TossDesignSystem.spacingS    // 8
TossDesignSystem.spacingM    // 16
TossDesignSystem.spacingL    // 24
TossDesignSystem.spacingXL   // 32
TossDesignSystem.spacingXXL  // 48
```

### 반경 (Radius)
```dart
TossDesignSystem.radiusS     // 8
TossDesignSystem.radiusM     // 12
TossDesignSystem.radiusL     // 16
TossDesignSystem.radiusXL    // 24
TossDesignSystem.radiusFull  // 9999 (완전 둥근)
```

---

## 검증 체크리스트

### 새 위젯 작성 시
- [ ] TypographyUnified 사용 (TossDesignSystem 폰트 금지)
- [ ] TossDesignSystem 색상 사용 (하드코딩 금지)
- [ ] 다크모드 지원 (`isDark` 조건문)
- [ ] 블러 처리 시 UnifiedBlurWrapper 사용
- [ ] AppBar에 iOS 스타일 뒤로가기 버튼

---

## 관련 문서

- [docs/design/BLUR_SYSTEM_GUIDE.md](/docs/design/BLUR_SYSTEM_GUIDE.md) - 블러 시스템 상세
- [docs/design/TOSS_DESIGN_SYSTEM.md](/docs/design/TOSS_DESIGN_SYSTEM.md) - 전체 디자인 시스템
