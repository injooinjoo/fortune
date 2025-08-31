# 🎨 Fortune App - Toss Design System 통합 가이드

## 📋 목차
1. [개요](#개요)
2. [디자인 시스템 구조](#디자인-시스템-구조)
3. [색상 시스템](#색상-시스템)
4. [타이포그래피](#타이포그래피)
5. [간격 및 크기](#간격-및-크기)
6. [컴포넌트 사용법](#컴포넌트-사용법)
7. [마이그레이션 가이드](#마이그레이션-가이드)
8. [모범 사례](#모범-사례)

---

## 🎯 개요

Fortune 앱은 토스의 디자인 철학을 완벽하게 구현한 `TossDesignSystem`을 사용합니다. 
이 시스템은 일관성, 간결성, 그리고 사용자 친화성을 핵심으로 합니다.

### 핵심 파일
- **메인 디자인 시스템**: `lib/core/theme/toss_design_system.dart`
- **앱 테마**: `lib/core/theme/app_theme.dart`
- **테마 확장**: `lib/core/theme/app_theme_extensions.dart`

---

## 🏗️ 디자인 시스템 구조

```dart
import 'package:fortune/core/theme/toss_design_system.dart';

// 모든 디자인 요소에 직접 접근
final blue = TossDesignSystem.tossBlue;
final heading = TossDesignSystem.heading1;
final spacing = TossDesignSystem.spacing4;
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

### 사용 예시
```dart
Container(
  color: TossDesignSystem.gray50,  // 배경색
  child: Text(
    '토스 디자인',
    style: TextStyle(color: TossDesignSystem.gray900),
  ),
)
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
TossDesignSystem.display   // 48px, 700, -0.02em
TossDesignSystem.heading1  // 32px, 700, -0.01em  
TossDesignSystem.heading2  // 28px, 700, -0.01em
TossDesignSystem.heading3  // 24px, 700, -0.01em
TossDesignSystem.heading4  // 20px, 600, -0.01em
TossDesignSystem.heading5  // 18px, 600, -0.01em
```

#### Body Text
```dart
TossDesignSystem.body1     // 18px, 500, 1.5 height
TossDesignSystem.body2     // 16px, 400, 1.5 height
TossDesignSystem.body3     // 14px, 400, 1.5 height
```

#### Captions
```dart
TossDesignSystem.caption1  // 12px, 400
TossDesignSystem.caption2  // 11px, 400
```

### 사용 예시
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
```

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

### 사용 예시
```dart
Container(
  padding: EdgeInsets.all(TossDesignSystem.spacing4),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(TossDesignSystem.radius3),
    color: TossDesignSystem.white,
  ),
)
```

---

## 🧩 컴포넌트 사용법

### 버튼 스타일
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

### 카드 스타일
```dart
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

### 입력 필드
```dart
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

---

## 🔄 마이그레이션 가이드

### 1. Import 변경
```dart
// Before
import 'lib/core/theme/toss_theme.dart';
import 'lib/core/theme/app_colors.dart';
import 'lib/core/theme/app_typography.dart';

// After
import 'lib/core/theme/toss_design_system.dart';
```

### 2. 색상 변경
```dart
// Before
TossTheme.primaryBlue
AppColors.primary

// After
TossDesignSystem.tossBlue
```

### 3. 타이포그래피 변경
```dart
// Before
TossTheme.heading1
AppTypography.headline1

// After
TossDesignSystem.heading1
```

### 4. 간격 변경
```dart
// Before
TossTheme.spacingM
AppTheme.spacingMedium

// After
TossDesignSystem.spacing4
```

---

## 💡 모범 사례

### 1. 일관된 색상 사용
```dart
// Good ✅
final textColor = TossDesignSystem.gray900;
final borderColor = TossDesignSystem.gray200;

// Bad ❌
final textColor = Color(0xFF171717);  // 하드코딩된 색상
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

// Bad ❌
padding: EdgeInsets.all(15),  // 임의의 값
```

### 4. 애니메이션 사용
```dart
// 토스 애니메이션 표준
AnimatedContainer(
  duration: TossDesignSystem.animationNormal,  // 250ms
  curve: TossDesignSystem.animationCurveSpring,
  // ...
)
```

### 5. 그림자 효과
```dart
Container(
  decoration: BoxDecoration(
    boxShadow: TossDesignSystem.shadowMedium,
  ),
)
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

---

## 🌙 다크모드 지원

```dart
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

## 🚀 시작하기

1. **Import**: `import 'lib/core/theme/toss_design_system.dart';`
2. **사용**: `TossDesignSystem.{property}` 형식으로 직접 접근
3. **일관성**: 항상 디자인 시스템의 값 사용, 하드코딩 금지

---

## 📚 추가 리소스

- [토스 디자인 원칙](https://toss.im/design-principles)
- [Flutter 공식 문서](https://flutter.dev/docs)
- [Material Design 3](https://m3.material.io)

---

마지막 업데이트: 2024년 12월
버전: 2.0.0