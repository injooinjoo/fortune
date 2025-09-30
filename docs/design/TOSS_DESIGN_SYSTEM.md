# 🎨 TOSS Design System - Complete Guide

Fortune Flutter 앱의 통합 TOSS 디자인 시스템 완전 가이드

## 📋 목차

1. [개요](#개요)
2. [통합 현황](#통합-현황)
3. [디자인 철학](#디자인-철학)
4. [테마 시스템 구조](#테마-시스템-구조)
5. [색상 시스템](#색상-시스템)
6. [타이포그래피](#타이포그래피)
7. [간격 및 크기](#간격-및-크기)
8. [테마 접근 방법](#테마-접근-방법)
9. [컴포넌트 라이브러리](#컴포넌트-라이브러리)
10. [마이그레이션 가이드](#마이그레이션-가이드)
11. [모범 사례](#모범-사례)

---

## 🎯 개요

Fortune 앱은 토스의 디자인 철학을 완벽하게 구현한 통합 테마 시스템을 사용합니다.
TOSS 디자인 시스템이 Fortune의 기존 테마 시스템에 완전히 통합되어,
하나의 통합된 테마 시스템을 통해 일관되고 아름다운 UI를 구현할 수 있습니다.

### 핵심 특징
- ✅ 완전한 다크모드 지원
- ✅ Fortune 테마와 TOSS 스타일의 완벽한 조화
- ✅ 플랫폼별 최적화 (iOS/Android)
- ✅ 접근성 기본 지원
- ✅ 성능 최적화된 애니메이션
- ✅ 햅틱 피드백 통합
- ✅ 간편한 접근을 위한 Extension 메서드

---

## ✅ 통합 현황

### 완료된 작업

#### 1. 테마 시스템 통합
- **`app_theme_extensions.dart` 수정**
  - 기존 `FortuneThemeExtension`에 TOSS 디자인 시스템 통합
  - MicroInteractions, AnimationDurations, AnimationCurves 등 11개 클래스 추가
  - Light/Dark 테마 모두 지원
  - `context.toss` 및 `context.fortuneTheme`로 접근 가능

#### 2. 중복 파일 제거
- **삭제된 파일**:
  - `toss_theme_extensions.dart` (중복)
  - `toss_theme_provider.dart` (중복)
- **이유**: 기존 테마 시스템에 통합하여 단일 테마 시스템 유지

#### 3. TOSS 컴포넌트 라이브러리
- **업데이트된 컴포넌트** (8개):
  - `toss_button.dart` - 버튼 컴포넌트
  - `toss_card.dart` - 카드 컴포넌트
  - `toss_loading.dart` - 로딩 상태
  - `toss_input.dart` - 입력 필드
  - `toss_bottom_sheet.dart` - 바텀 시트
  - `toss_dialog.dart` - 다이얼로그
  - `toss_toast.dart` - 토스트 메시지
  - `toss_components.dart` - 통합 export 파일

#### 4. 메인 앱 통합
- **`main.dart` 업데이트**:
  - `AppTheme.lightTheme()` / `AppTheme.darkTheme()` 사용
  - 불필요한 import 제거
  - 통합된 테마 시스템 적용

---

## 🎨 디자인 철학

Fortune은 **현대적이고 미니멀한 디자인 철학**을 따릅니다. TOSS의 간결한 미학과 Instagram의 직관적인 인터페이스에서 영감을 받았습니다.

### 핵심 원칙

1. **명확성 (Clarity)**: 정보는 즉시 이해 가능해야 함
2. **일관성 (Consistency)**: 모든 요소가 동일한 디자인 언어를 따름
3. **우아함 (Elegance)**: 단순하고 세련되며 사려 깊은 디자인 선택
4. **접근성 (Accessibility)**: 모든 사용자가 읽고 사용할 수 있어야 함

### TOSS 디자인 원칙

1. **단순하고 명확한 색상 시스템**
   - Primary Brand Color: Toss Blue (#3182F6) - 신뢰와 안정성
   - 제한된 색상 팔레트: 의미에 집중
   - 명확한 시맨틱 색상: 각 색상은 특정 목적을 가짐

2. **일관된 색상 사용**
   - 같은 의미 = 같은 색상: 앱 전체의 일관성
   - 명확한 텍스트 계층: 세밀한 그레이 스케일
   - 상태 기반 색상: 성공, 경고, 에러의 명확한 구분

3. **접근성 우선**
   - 높은 대비: 가독성 보장
   - 색맹 친화적: 색상 외의 패턴 활용
   - 다크모드 지원: 완전한 테마 지원

---

## 🏗️ 테마 시스템 구조

### 파일 구조

```
lib/core/
├── theme/
│   ├── app_theme.dart                # 메인 테마 정의
│   ├── app_theme_extensions.dart     # 통합된 테마 확장 (Fortune + TOSS)
│   ├── app_colors.dart               # 색상 정의
│   ├── app_typography.dart           # 타이포그래피
│   ├── app_spacing.dart              # 간격 시스템
│   └── app_dimensions.dart           # 크기 상수
└── components/
    ├── toss_button.dart              # TOSS 스타일 버튼
    ├── toss_card.dart                # TOSS 스타일 카드
    ├── toss_loading.dart             # TOSS 스타일 로딩
    ├── toss_input.dart               # TOSS 스타일 입력
    ├── toss_bottom_sheet.dart        # TOSS 스타일 바텀시트
    ├── toss_dialog.dart              # TOSS 스타일 다이얼로그
    ├── toss_toast.dart               # TOSS 스타일 토스트
    └── toss_components.dart          # 통합 export 파일
```

### 통합 테마 확장

```dart
class FortuneThemeExtension extends ThemeExtension<FortuneThemeExtension> {
  // 기존 Fortune 색상
  final Color scoreExcellent;
  final Color scoreGood;
  final Color scoreFair;
  final Color scorePoor;
  final Color scoreBad;

  // TOSS 디자인 시스템
  final MicroInteractions microInteractions;
  final AnimationDurations animationDurations;
  final AnimationCurves animationCurves;
  final LoadingStates loadingStates;
  final ErrorStates errorStates;
  final HapticPatterns hapticPatterns;
  final FormStyles formStyles;
  final BottomSheetStyles bottomSheetStyles;
  final DataVisualization dataVisualization;
  final SocialSharingStyles socialSharing;

  // ... 생성자 및 메서드
}
```

---

## 🎨 색상 시스템

### Primary Colors

```dart
// 메인 브랜드 색상
TossDesignSystem.tossBlue    // #3182F6 - 토스 블루
TossDesignSystem.white        // #FFFFFF - 흰색
TossDesignSystem.black        // #000000 - 검정

// Semantic Colors
TossDesignSystem.successGreen   // #10B981 - 성공
TossDesignSystem.errorRed       // #EF4444 - 에러
TossDesignSystem.warningOrange  // #F59E0B - 경고
```

### Grayscale (10단계)

```dart
TossDesignSystem.gray50   // #FAFAFA - 가장 밝음
TossDesignSystem.gray100  // #F5F5F5
TossDesignSystem.gray200  // #E5E5E5
TossDesignSystem.gray300  // #D4D4D4
TossDesignSystem.gray400  // #A3A3A3
TossDesignSystem.gray500  // #737373
TossDesignSystem.gray600  // #525252
TossDesignSystem.gray700  // #404040
TossDesignSystem.gray800  // #262626
TossDesignSystem.gray900  // #171717 - 가장 어두움
```

### AppColors (Core Theme)

```dart
// Toss Blue - Primary brand color
tossBlue: #0064FF
tossBlueDark: #0050CC
tossBlueLight: #3384FF
tossBlueBackground: #E6F1FF

// Gray Scale (50-900)
gray50: #F9FAFB → gray900: #111827

// Semantic Colors
positive: #00D67A (success)
negative: #FF3B30 (error/danger)
caution: #FFB800 (warning)
informative: #0064FF (info)
```

### FortuneColors (Domain-Specific)

```dart
// Category Colors with Clear Meanings
love: #FF3B57 (warm, emotional)
mystical: #9333EA (spiritual, mysterious)
career: tossBlue (trust, professional)
wealth: #FFB800 (prosperity, gold)
health: #00D67A (fresh, natural)
daily: gray700 (neutral, everyday)

// Intensity Levels
excellent: positive (90-100%)
good: #00D67A (70-89%)
moderate: caution (50-69%)
careful: #FF9500 (30-49%)
challenging: negative (0-29%)
```

### 색상 사용 예시

```dart
Container(
  color: TossDesignSystem.gray50,  // 배경색
  child: Text(
    '토스 디자인',
    style: TextStyle(color: TossDesignSystem.gray900),
  ),
)

// Theme-aware color getters
FortuneColors.getFortuneTypeColor(context, type)
AppColors.getGray(context, shade)
AppColors.getTossBlue(context)
```

### Dark Mode Colors

```dart
// Background Dark
TossDesignSystem.backgroundDark: #0A0A0A
TossDesignSystem.surfaceDark: #1A1A1A
TossDesignSystem.cardBackgroundDark: #141414

// Text Colors Dark
TossDesignSystem.textPrimaryDark: #F9FAFB
TossDesignSystem.textSecondaryDark: #D1D5DB
```

---

## ✏️ 타이포그래피

### 폰트 패밀리

```dart
// 한글 폰트
TossDesignSystem.fontFamilyKorean  // 'Pretendard'

// 숫자 폰트
TossDesignSystem.fontFamilyNumber  // 'Toss Product Sans'
```

### Text Styles

#### Display & Headings

```dart
TossDesignSystem.display   // 48px, 700, -0.02em, Line Height 1.2
TossDesignSystem.heading1  // 32px, 700, -0.01em, Line Height 1.25
TossDesignSystem.heading2  // 28px, 700, -0.01em, Line Height 1.3
TossDesignSystem.heading3  // 24px, 700, -0.01em, Line Height 1.35
TossDesignSystem.heading4  // 20px, 600, -0.01em, Line Height 1.4
TossDesignSystem.heading5  // 18px, 600, -0.01em, Line Height 1.4
```

#### Body Text

```dart
TossDesignSystem.body1     // 18px, 500, Line Height 1.5
TossDesignSystem.body2     // 16px, 400, Line Height 1.5
TossDesignSystem.body3     // 14px, 400, Line Height 1.55
```

#### Captions

```dart
TossDesignSystem.caption1  // 12px, 400, Line Height 1.5
TossDesignSystem.caption2  // 11px, 400, Line Height 1.45
```

#### Special Styles

```dart
// Button Text
AppTypography.button       // 16px, SemiBold (600)
AppTypography.buttonSmall  // 14px, SemiBold (600)

// Overline
AppTypography.overline     // 12px, SemiBold (600), Letter Spacing 0.04

// Numbers (Uses tabular figures for alignment)
TossDesignSystem.fontFamilyNumber
```

### 타이포그래피 사용 예시

```dart
Text(
  '안녕하세요',
  style: TossDesignSystem.heading1,
)

Text(
  '₩1,234,567',
  style: TossDesignSystem.body1.copyWith(
    fontFamily: TossDesignSystem.fontFamilyNumber,
  ),
)

// Context extension 사용
Text(
  'Hello World',
  style: context.headlineMedium,
)
```

### Text Styles by Usage

- **Page Title**: `displaySmall` or `headlineLarge`
- **Section Header**: `headlineMedium`
- **Card Title**: `titleLarge`
- **Body Text**: `bodyMedium`
- **Button Text**: `AppTypography.button`
- **Caption**: `captionMedium`
- **Input Label**: `labelMedium`

---

## 📐 간격 및 크기

### Spacing System (4px 기반)

```dart
TossDesignSystem.spacing1   // 4px
TossDesignSystem.spacing2   // 8px
TossDesignSystem.spacing3   // 12px
TossDesignSystem.spacing4   // 16px
TossDesignSystem.spacing5   // 20px
TossDesignSystem.spacing6   // 24px
TossDesignSystem.spacing7   // 28px
TossDesignSystem.spacing8   // 32px
TossDesignSystem.spacing9   // 36px
TossDesignSystem.spacing10  // 40px
TossDesignSystem.spacing12  // 48px
TossDesignSystem.spacing16  // 64px
```

### Border Radius

```dart
TossDesignSystem.radius1  // 4px  - 작은 요소
TossDesignSystem.radius2  // 8px  - 버튼, 입력
TossDesignSystem.radius3  // 12px - 카드
TossDesignSystem.radius4  // 16px - 모달
TossDesignSystem.radius5  // 20px - 바텀시트
TossDesignSystem.radiusFull // 9999px - 원형
```

### 간격 사용 예시

```dart
Container(
  padding: EdgeInsets.all(TossDesignSystem.spacing4),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(TossDesignSystem.radius3),
    color: TossDesignSystem.white,
  ),
)

// 일관된 간격 사용
SizedBox(height: TossDesignSystem.spacing4), // Good ✅
SizedBox(height: 15), // Bad ❌ - 임의의 값
```

### Button Sizes

```dart
TossDesignSystem.buttonHeightLarge   // 56px
TossDesignSystem.buttonHeightMedium  // 48px
TossDesignSystem.buttonHeightSmall   // 40px

TossDesignSystem.inputHeight         // 52px
```

---

## 🎨 테마 접근 방법

### 1. Fortune 테마 접근

```dart
// 기본 Fortune 테마 접근
final fortuneTheme = context.fortuneTheme;

// Fortune 색상
final scoreColor = fortuneTheme.scoreExcellent;
final gradientStart = fortuneTheme.fortuneGradientStart;
```

### 2. TOSS 디자인 시스템 접근

```dart
// TOSS 테마 접근 (fortuneTheme과 동일한 객체)
final toss = context.toss;

// Micro-interactions
final buttonScale = toss.microInteractions.buttonPressScale;

// Animation durations
final shortDuration = toss.animationDurations.short;

// Animation curves
final emphasizeCurve = toss.animationCurves.emphasize;

// Form styles
final inputHeight = toss.formStyles.inputHeight;
```

### 3. 다크모드 체크

```dart
// 다크모드 여부 확인
final isDark = context.isDarkMode;

// 조건부 스타일
final bgColor = isDark ? Colors.black : Colors.white;

// 자동 다크모드 대응
Container(
  color: isDark ? TossDesignSystem.gray900 : TossDesignSystem.white,
  child: Text(
    '자동 대응',
    style: TossDesignSystem.body1.copyWith(
      color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
    ),
  ),
)
```

### 4. Extension 메서드 활용

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Extension 메서드 사용
    final toss = context.toss;
    final isDark = context.isDarkMode;

    return Container(
      height: toss.formStyles.inputHeight,
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(
          toss.formStyles.inputBorderRadius,
        ),
      ),
    );
  }
}
```

---

## 🧩 컴포넌트 라이브러리

### 버튼 (TossButton)

```dart
// Primary 버튼
TossButton(
  text: '확인',
  onPressed: () {
    // 액션
  },
  style: TossButtonStyle.primary,
  size: TossButtonSize.large,
);

// Secondary 버튼
TossButton(
  text: '취소',
  style: TossButtonStyle.secondary,
  size: TossButtonSize.medium,
  onPressed: () {},
);

// 아이콘 포함 버튼
TossButton(
  text: '공유하기',
  leadingIcon: Icon(Icons.share),
  enableHaptic: true, // 햅틱 피드백
  onPressed: () {},
);

// 로딩 상태
TossButton(
  text: '저장 중...',
  isLoading: true,
  onPressed: null,
);

// 전체 너비 버튼
TossButton(
  text: '시작하기',
  onPressed: _startOnboarding,
  width: double.infinity,
);
```

### 버튼 스타일 (직접 구현)

```dart
// Primary Button
Container(
  height: TossDesignSystem.buttonHeightLarge,  // 56px
  decoration: BoxDecoration(
    color: TossDesignSystem.tossBlue,
    borderRadius: BorderRadius.circular(TossDesignSystem.radius3),
  ),
  child: Center(
    child: Text(
      '확인',
      style: TossDesignSystem.body1.copyWith(
        color: TossDesignSystem.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
)

// Secondary Button
Container(
  height: TossDesignSystem.buttonHeightMedium,  // 48px
  decoration: BoxDecoration(
    border: Border.all(color: TossDesignSystem.gray300),
    borderRadius: BorderRadius.circular(TossDesignSystem.radius2),
  ),
)
```

### 카드 (TossCard)

```dart
// 기본 카드
TossCard(
  child: Text('카드 내용'),
  onTap: () {
    print('카드 탭됨');
  },
);

// Section 카드
TossSectionCard(
  title: '오늘의 운세',
  subtitle: '2024년 1월 29일',
  action: IconButton(
    icon: Icon(Icons.refresh),
    onPressed: () {},
  ),
  child: Text('운세 내용...'),
);

// Glass 카드 (블러 효과)
TossGlassCard(
  blurAmount: 20,
  child: Column(
    children: [
      Text('운세 결과'),
      // ...
    ],
  ),
);

// 카드 스타일 (직접 구현)
Container(
  padding: EdgeInsets.all(TossDesignSystem.spacing4),
  decoration: BoxDecoration(
    color: TossDesignSystem.white,
    borderRadius: BorderRadius.circular(TossDesignSystem.radius3),
    boxShadow: TossDesignSystem.shadowSmall,
  ),
  child: // 카드 내용
)
```

### 입력 필드 (TossTextField)

```dart
// 기본 텍스트 필드
TossTextField(
  labelText: '이름',
  hintText: '이름을 입력하세요',
  onChanged: (value) {
    // 값 변경 처리
  },
);

// 전화번호 입력 (자동 포맷팅)
TossPhoneTextField(
  controller: _phoneController,
  onChanged: (value) {
    print(value); // 010-1234-5678 형식
  },
);

// 금액 입력
TossAmountTextField(
  onChanged: (value) {
    print(value); // 1,000,000 형식
  },
);

// 입력 필드 스타일 (직접 구현)
Container(
  height: TossDesignSystem.inputHeight,  // 52px
  padding: EdgeInsets.symmetric(
    horizontal: TossDesignSystem.spacing4,
  ),
  decoration: BoxDecoration(
    border: Border.all(color: TossDesignSystem.gray200),
    borderRadius: BorderRadius.circular(TossDesignSystem.radius2),
  ),
  child: TextField(
    style: TossDesignSystem.body2,
    decoration: InputDecoration(
      hintText: '입력하세요',
      hintStyle: TossDesignSystem.body2.copyWith(
        color: TossDesignSystem.gray400,
      ),
      border: InputBorder.none,
    ),
  ),
)
```

### 로딩 상태 (TossLoading)

```dart
// 스켈레톤 로딩
Column(
  children: [
    TossSkeleton.text(width: 200),
    SizedBox(height: 8),
    TossSkeleton.rectangle(
      width: double.infinity,
      height: 100,
    ),
    SizedBox(height: 8),
    TossSkeleton.circle(size: 60),
  ],
);

// 프로그레스 바
TossProgressIndicator(
  value: 0.7, // 70%
);

// Fortune 로딩 애니메이션
FortuneLoadingAnimation();

// 로딩 상태 처리
if (isLoading) {
  return Column(
    children: [
      TossSkeleton.text(width: 200),
      SizedBox(height: 16),
      TossSkeleton.rectangle(
        width: double.infinity,
        height: 100,
      ),
    ],
  );
}
```

### 바텀 시트 (TossBottomSheet)

```dart
// 기본 바텀 시트
TossBottomSheet.show(
  context: context,
  builder: (context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 핸들은 자동으로 추가됨
      // 내용만 작성
    ],
  ),
);

// 선택 바텀 시트
TossBottomSheet.showSelection<String>(
  context: context,
  title: '성별을 선택하세요',
  options: [
    TossBottomSheetOption(
      title: '남성',
      value: 'male',
      icon: Icons.male,
    ),
    TossBottomSheetOption(
      title: '여성',
      value: 'female',
      icon: Icons.female,
    ),
  ],
).then((value) {
  if (value != null) {
    print('선택됨: $value');
  }
});

// 확인 바텀 시트
TossBottomSheet.showConfirmation(
  context: context,
  title: '정말 삭제하시겠습니까?',
  message: '삭제한 데이터는 복구할 수 없습니다.',
  confirmText: '삭제',
  cancelText: '취소',
  isDanger: true,
).then((confirmed) {
  if (confirmed == true) {
    // 삭제 처리
  }
});
```

### 다이얼로그 (TossDialog)

```dart
// 성공 다이얼로그
TossDialog.showSuccess(
  context: context,
  title: '저장 완료!',
  message: '운세가 성공적으로 저장되었습니다.',
  autoCloseDuration: Duration(seconds: 2),
);

// 에러 다이얼로그
TossDialog.showError(
  context: context,
  title: '오류 발생',
  message: '네트워크 연결을 확인해주세요.',
);

// 로딩 다이얼로그
TossDialog.showLoading(
  context: context,
  message: '운세를 불러오는 중...',
);

// 로딩 다이얼로그 닫기
TossDialog.hideLoading(context);

// 확인 다이얼로그
TossDialog.showConfirmation(
  context: context,
  title: '정말로 삭제하시겠습니까?',
  message: '삭제한 데이터는 복구할 수 없습니다.',
  confirmText: '삭제',
  cancelText: '취소',
  isDanger: true,
).then((confirmed) {
  if (confirmed == true) {
    _deleteItem();
  }
});
```

### 토스트 (TossToast)

```dart
// 성공 토스트
TossToast.success(
  context: context,
  message: '복사되었습니다',
);

// 에러 토스트
TossToast.error(
  context: context,
  message: '오류가 발생했습니다',
  actionText: '다시 시도',
  onAction: () {
    // 재시도 로직
  },
);

// 정보 토스트
TossToast.info(
  context: context,
  message: '새로운 업데이트가 있습니다',
);

// 스크린샷 감지 토스트
TossScreenshotToast.show(
  context: context,
  onShare: () {
    // 공유 로직
  },
);
```

### 애니메이션

```dart
// 토스 애니메이션 표준
AnimatedContainer(
  duration: TossDesignSystem.animationNormal,  // 250ms
  curve: TossDesignSystem.animationCurveSpring,
  // ...
)

// TOSS 스타일 애니메이션
widget
  .animate()
  .fadeIn(duration: context.toss.animationDurations.short)
  .slideY(
    begin: 0.1,
    end: 0,
    curve: context.toss.animationCurves.decelerate,
  );
```

### 그림자 효과

```dart
Container(
  decoration: BoxDecoration(
    boxShadow: TossDesignSystem.shadowMedium,
  ),
)

// 사용 가능한 그림자
TossDesignSystem.shadowSmall
TossDesignSystem.shadowMedium
TossDesignSystem.shadowLarge
TossDesignSystem.shadowXLarge
```

---

## 🔄 마이그레이션 가이드

### Import 변경

```dart
// Before
import 'lib/core/theme/toss_theme_extensions.dart';
import 'lib/core/theme/toss_theme_provider.dart';
import 'lib/core/theme/toss_theme.dart';
import 'lib/core/theme/app_colors.dart';
import 'lib/core/theme/app_typography.dart';

// After
import 'lib/core/theme/app_theme_extensions.dart';
import 'lib/core/components/toss_components.dart'; // 모든 TOSS 컴포넌트
```

### 테마 적용 변경

```dart
// Before
theme: TossTheme.light(),
darkTheme: TossTheme.dark(),

// After
theme: AppTheme.lightTheme(),
darkTheme: AppTheme.darkTheme(),
```

### 색상 변경

```dart
// Before
TossTheme.primaryBlue
AppColors.primary
Color(0xFF7C3AED) // 하드코딩된 색상

// After
TossDesignSystem.tossBlue
AppColors.getTossBlue(context)
FortuneColors.mystical // 시맨틱 색상
```

### 타이포그래피 변경

```dart
// Before
TossTheme.heading1
AppTypography.headline1
TextStyle(fontSize: 32, fontWeight: FontWeight.bold)

// After
TossDesignSystem.heading1
context.headlineLarge
```

### 간격 변경

```dart
// Before
TossTheme.spacingM
AppTheme.spacingMedium
EdgeInsets.all(15) // 임의의 값

// After
TossDesignSystem.spacing4
EdgeInsets.all(TossDesignSystem.spacing4)
```

### 버튼 마이그레이션

```dart
// Before
ElevatedButton(
  onPressed: _startOnboarding,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    ),
  ),
  child: Text('시작하기'),
)

// After
TossButton(
  text: '시작하기',
  onPressed: _startOnboarding,
  style: TossButtonStyle.primary,
  size: TossButtonSize.large,
)
```

### 카드 마이그레이션

```dart
// Before
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text('오늘의 운세'),
        // ...
      ],
    ),
  ),
)

// After
TossCard(
  onTap: () {
    // 카드 탭 액션
  },
  child: Column(
    children: [
      Text('오늘의 운세'),
      // ...
    ],
  ),
)
```

### TextField 마이그레이션

```dart
// Before
TextField(
  controller: _nameController,
  decoration: InputDecoration(
    labelText: '이름',
    hintText: '이름을 입력하세요',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    filled: true,
    fillColor: Colors.grey[100],
  ),
  onChanged: (value) {
    setState(() {
      _name = value;
    });
  },
)

// After
TossTextField(
  controller: _nameController,
  labelText: '이름',
  hintText: '이름을 입력하세요',
  onChanged: (value) {
    setState(() {
      _name = value;
    });
  },
)
```

### Bottom Sheet 마이그레이션

```dart
// Before
showModalBottomSheet(
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(20),
    ),
  ),
  builder: (context) => Container(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 복잡한 핸들 UI 구현
        // ...
      ],
    ),
  ),
);

// After
TossBottomSheet.show(
  context: context,
  builder: (context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 핸들은 자동으로 추가됨
      // 내용만 작성
    ],
  ),
);
```

### Dialog 마이그레이션

```dart
// Before
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('확인'),
    content: Text('정말로 삭제하시겠습니까?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('취소'),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          _deleteItem();
        },
        child: Text('삭제'),
      ),
    ],
  ),
);

// After
TossDialog.showConfirmation(
  context: context,
  title: '정말로 삭제하시겠습니까?',
  message: '삭제한 데이터는 복구할 수 없습니다.',
  confirmText: '삭제',
  cancelText: '취소',
  isDanger: true,
).then((confirmed) {
  if (confirmed == true) {
    _deleteItem();
  }
});
```

### Toast/SnackBar 마이그레이션

```dart
// Before
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('복사되었습니다'),
    duration: Duration(seconds: 2),
    action: SnackBarAction(
      label: '확인',
      onPressed: () {},
    ),
  ),
);

// After
TossToast.success(
  context: context,
  message: '복사되었습니다',
);
```

### Complete Screen Example

```dart
import 'package:flutter/material.dart';
import '../core/components/toss_components.dart'; // 모든 TOSS 컴포넌트

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고
              Image.asset('assets/logo.png', height: 100),

              const SizedBox(height: 48),

              // 제목
              Text(
                'Fortune과 함께\n오늘의 운세를 확인하세요',
                style: context.isDarkMode
                  ? Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    )
                  : Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // 시작 버튼 (TOSS 스타일)
              TossButton(
                text: '시작하기',
                onPressed: () {
                  context.go('/onboarding');
                },
                style: TossButtonStyle.primary,
                size: TossButtonSize.large,
                width: double.infinity,
              ),

              const SizedBox(height: 16),

              // 소셜 로그인 버튼들
              TossButton(
                text: 'Google로 계속하기',
                onPressed: _signInWithGoogle,
                style: TossButtonStyle.secondary,
                size: TossButtonSize.large,
                leadingIcon: SvgPicture.asset(
                  'assets/icons/google.svg',
                  width: 24,
                  height: 24,
                ),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 💡 모범 사례

### 1. 일관된 색상 사용

```dart
// Good ✅
final textColor = TossDesignSystem.gray900;
final borderColor = TossDesignSystem.gray200;
FortuneColors.getFortuneTypeColor(context, type)

// Bad ❌
final textColor = Color(0xFF171717);  // 하드코딩된 색상
Color(0xFF7C3AED) // 의미 불명확
```

### 2. 타이포그래피 확장

```dart
// Good ✅
Text(
  '제목',
  style: TossDesignSystem.heading1.copyWith(
    color: TossDesignSystem.tossBlue,
  ),
)

Text(
  'Hello World',
  style: context.headlineMedium,
)

// Bad ❌
Text(
  '제목',
  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
)
```

### 3. 간격 시스템 준수

```dart
// Good ✅
padding: EdgeInsets.all(TossDesignSystem.spacing4),  // 16px
SizedBox(height: TossDesignSystem.spacing4), // 8의 배수

// Bad ❌
padding: EdgeInsets.all(15),  // 임의의 값
SizedBox(height: 17), // 임의의 값
```

### 4. 테마 Extension 활용

```dart
// Good ✅
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Extension 메서드 사용
    final toss = context.toss;
    final isDark = context.isDarkMode;

    return Container(
      height: toss.formStyles.inputHeight,
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(
          toss.formStyles.inputBorderRadius,
        ),
      ),
    );
  }
}

// Bad ❌
Container(
  color: Color(0xFF000000), // 하드코딩
)
```

### 5. 햅틱 피드백 고려

```dart
// 버튼 탭 시
if (context.toss.hapticPatterns.buttonTap != null) {
  HapticFeedback.lightImpact();
}

// 성공 액션
if (context.toss.hapticPatterns.success != null) {
  HapticFeedback.mediumImpact();
}

// 버튼, 카드 등의 상호작용에는 기본적으로 햅틱이 활성화됨
// 필요시 비활성화 가능
TossButton(
  text: '조용한 버튼',
  enableHaptic: false, // 햅틱 비활성화
  onPressed: () {},
);
```

### 6. 다크모드 대응

```dart
// Good ✅
// 자동 다크모드 대응
final isDark = Theme.of(context).brightness == Brightness.dark;

Container(
  color: isDark ? TossDesignSystem.gray900 : TossDesignSystem.white,
  child: Text(
    '자동 대응',
    style: TossDesignSystem.body1.copyWith(
      color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
    ),
  ),
)

// 또는 테마가 자동으로 처리
TossCard(
  child: Text('자동으로 다크모드 대응됨'),
)

// Bad ❌
Container(
  color: Colors.white, // 다크모드 미지원
)
```

### 7. 플랫폼별 분기

```dart
// 플랫폼별 다른 동작이 필요한 경우
if (Theme.of(context).platform == TargetPlatform.iOS) {
  // iOS 전용 처리
} else {
  // Android 전용 처리
}
```

### 8. 성능 최적화

```dart
// const 생성자 활용
const TossCard(
  child: Text('정적 콘텐츠'),
);

const TossButton(
  text: '확인',
  onPressed: null, // 비활성화 상태
);

// 무거운 위젯은 필요할 때만 로드
if (isVisible) {
  FortuneLoadingAnimation();
}

// 조건부 렌더링
if (showButton) {
  TossButton(
    text: '다음',
    onPressed: _handleNext,
  );
}
```

### 9. 로딩 상태 처리

```dart
// Good ✅
// 로딩 중 스켈레톤 표시
if (isLoading) {
  return Column(
    children: [
      TossSkeleton.text(width: 200),
      SizedBox(height: 8),
      TossSkeleton.rectangle(
        width: double.infinity,
        height: 100,
      ),
    ],
  );
}

// Bad ❌
if (isLoading) {
  return Center(
    child: CircularProgressIndicator(), // 스켈레톤이 더 나은 UX
  );
}
```

### 10. 에러 상태 처리

```dart
// 에러 UI
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: context.toss.errorStates.errorBackground,
    border: Border.all(
      color: context.toss.errorStates.errorBorder,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    children: [
      Icon(
        context.toss.errorStates.errorIcon,
        size: context.toss.errorStates.errorIconSize,
        color: context.toss.errorColor,
      ),
      SizedBox(width: 12),
      Text('오류가 발생했습니다'),
    ],
  ),
);
```

---

## 🔧 유틸리티 함수

### 금액 포맷터

```dart
String formatted = TossDesignSystem.formatAmount(1234567);
// 결과: "1,234,567원"
```

### 날짜 포맷터

```dart
String formatted = TossDesignSystem.formatDate(DateTime.now());
// 결과: "12월 31일 (월)"
```

---

## 📱 반응형 디자인

### 화면 크기별 대응

```dart
// 모바일
if (MediaQuery.of(context).size.width < 600) {
  return Padding(
    padding: EdgeInsets.all(TossDesignSystem.spacing4),
    // ...
  );
}

// 태블릿 이상
return Padding(
  padding: EdgeInsets.all(TossDesignSystem.spacing6),
  // ...
);
```

### Breakpoints

- **Mobile**: < 600px
- **Tablet**: 600px - 1200px
- **Desktop**: > 1200px

### Responsive Typography

```dart
// Use responsive font size
final fontSize = AppTypography.responsiveFontSize(context, 16);

Text(
  'Responsive Text',
  style: context.bodyMedium.copyWith(
    fontSize: fontSize,
  ),
)
```

---

## 📊 디자인 토큰 요약

| 카테고리 | 토큰 수 | 주요 값 |
|---------|---------|---------|
| Colors | 15+ | tossBlue, gray50-900, semantic colors |
| Typography | 11 | display, heading1-5, body1-3, caption1-2 |
| Spacing | 12 | 4px 단위 (spacing1-16) |
| Radius | 6 | 4px-20px, full |
| Shadows | 4 | small, medium, large, xlarge |
| Animation | 3 | fast(150ms), normal(250ms), slow(500ms) |

---

## ✅ 구현 체크리스트

마이그레이션 시 확인해야 할 사항들:

- [ ] 모든 `TossTheme` 참조를 `AppTheme`로 변경
- [ ] `toss_theme_extensions.dart` 임포트 제거
- [ ] `toss_theme_provider.dart` 임포트 제거
- [ ] `context.toss` 또는 `context.fortuneTheme` 사용
- [ ] 모든 ElevatedButton → TossButton 변경
- [ ] 모든 Card → TossCard 변경
- [ ] 모든 TextField → TossTextField 변경
- [ ] showModalBottomSheet → TossBottomSheet 변경
- [ ] showDialog → TossDialog 변경
- [ ] SnackBar → TossToast 변경
- [ ] 하드코딩된 색상 → 테마 색상 사용
- [ ] 하드코딩된 폰트 → AppTypography 사용
- [ ] 임의의 간격 → 8px 그리드 시스템
- [ ] 컴포넌트가 정상 작동하는지 확인
- [ ] 다크모드에서 테스트
- [ ] iOS/Android 플랫폼 테스트
- [ ] 햅틱 피드백 작동 확인
- [ ] 텍스트 가독성 확인 (대비 비율)
- [ ] 여러 화면 크기에서 반응형 동작 테스트
- [ ] 컴포넌트 일관성 확인

---

## 🎯 마이그레이션 팁

1. **점진적 마이그레이션**: 한 번에 모든 것을 바꾸지 말고 화면 단위로 진행
2. **테스트**: 각 컴포넌트 변경 후 기능 테스트 수행
3. **일관성**: 같은 화면 내에서는 모두 TOSS 컴포넌트 사용
4. **테마 활용**: 하드코딩된 색상/폰트 대신 테마 값 사용
5. **햅틱 피드백**: 사용자 상호작용에 햅틱 피드백 추가 고려
6. **다크모드**: 모든 변경 시 다크모드에서도 확인
7. **접근성**: 충분한 대비 비율과 명확한 타이포그래피 유지

---

## 🚀 시작하기

1. **Import**: `import 'lib/core/theme/app_theme_extensions.dart';`
2. **컴포넌트**: `import 'lib/core/components/toss_components.dart';`
3. **사용**: `context.toss` 또는 `TossDesignSystem.{property}` 형식으로 접근
4. **일관성**: 항상 디자인 시스템의 값 사용, 하드코딩 금지

---

## 🚨 주요 의사결정

1. **통합 vs 분리**: 기존 테마 시스템에 통합하여 일관성 유지
2. **호환성**: `context.toss`와 `context.fortuneTheme` 모두 지원
3. **점진적 마이그레이션**: 기존 코드를 즉시 변경하지 않고 점진적으로 적용
4. **문서화 우선**: 개발자가 쉽게 사용할 수 있도록 상세한 문서 제공

---

## 📊 성과

- **코드 중복 제거**: 2개의 중복 테마 파일 제거
- **일관성 향상**: 단일 테마 시스템으로 통합
- **개발자 경험**: 간편한 API로 생산성 향상
- **유지보수성**: 중앙화된 테마 관리
- **일관성**: 같은 의미는 같은 색상 사용
- **접근성**: 더 나은 다크모드 지원
- **명확성**: 색상이 명확한 목적을 가짐
- **전문성**: TOSS 스타일의 신뢰와 안정성

---

## 📚 추가 리소스

- [UI/UX Master Policy](./UI_UX_MASTER_POLICY.md)
- [Design System](./DESIGN_SYSTEM.md)
- [UI/UX Expansion Roadmap](./UI_UX_EXPANSION_ROADMAP.md)
- [토스 디자인 원칙](https://toss.im/design-principles)
- [Flutter 공식 문서](https://flutter.dev/docs)
- [Material Design 3](https://m3.material.io)

---

**마지막 업데이트**: 2025년 1월 30일
**버전**: 2.0.0
**작성자**: Claude Code Master Agent

통합된 테마 시스템으로 더욱 일관되고 아름다운 UI를 만들어보세요! 🚀