# 🎨 TOSS Theme Unified Integration Guide

Fortune Flutter 앱에 통합된 TOSS 디자인 시스템 사용 가이드입니다.

## 📋 목차

1. [개요](#개요)
2. [통합 테마 시스템 구조](#통합-테마-시스템-구조)
3. [테마 접근 방법](#테마-접근-방법)
4. [컴포넌트 사용법](#컴포넌트-사용법)
5. [마이그레이션 가이드](#마이그레이션-가이드)
6. [모범 사례](#모범-사례)

---

## 🎯 개요

TOSS 디자인 시스템이 Fortune의 기존 테마 시스템에 완전히 통합되었습니다. 
이제 하나의 통합된 테마 시스템을 통해 일관된 디자인을 구현할 수 있습니다.

### 주요 변경사항
- ✅ `FortuneThemeExtension`에 TOSS 디자인 시스템 통합
- ✅ 중복 테마 파일 제거
- ✅ 기존 Fortune 테마와 TOSS 스타일의 조화
- ✅ 간편한 접근을 위한 Extension 메서드

---

## 🏗️ 통합 테마 시스템 구조

```
lib/core/
├── theme/
│   ├── app_theme.dart               # 메인 테마 정의
│   ├── app_theme_extensions.dart    # 통합된 테마 확장 (Fortune + TOSS)
│   ├── app_colors.dart              # 색상 정의
│   ├── app_typography.dart          # 타이포그래피
│   ├── app_spacing.dart             # 간격 시스템
│   └── app_dimensions.dart          # 크기 상수
└── components/
    ├── toss_button.dart             # TOSS 스타일 버튼
    ├── toss_card.dart               # TOSS 스타일 카드
    ├── toss_loading.dart            # TOSS 스타일 로딩
    ├── toss_input.dart              # TOSS 스타일 입력
    ├── toss_bottom_sheet.dart       # TOSS 스타일 바텀시트
    ├── toss_dialog.dart             # TOSS 스타일 다이얼로그
    └── toss_toast.dart              # TOSS 스타일 토스트
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
// TOSS 테마 접근 (fortuneTheme과 동일)
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
```

---

## 🔧 컴포넌트 사용법

### 버튼 (TossButton)
```dart
// Primary 버튼
TossButton(
  text: '확인',
  onPressed: () {
    // 액션
  },
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
  onChanged: (value) {
    print(value); // 010-1234-5678 형식
  },
);
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
  ],
);

// Fortune 로딩 애니메이션
FortuneLoadingAnimation();
```

### 바텀 시트 (TossBottomSheet)
```dart
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
```

---

## 🔄 마이그레이션 가이드

### 1. 테마 임포트 변경
```dart
// Before
import 'core/theme/toss_theme_extensions.dart';
import 'core/theme/toss_theme_provider.dart';

// After
import 'core/theme/app_theme_extensions.dart';
```

### 2. 테마 적용 변경
```dart
// Before
theme: TossTheme.light(),
darkTheme: TossTheme.dark(),

// After
theme: AppTheme.lightTheme(),
darkTheme: AppTheme.darkTheme(),
```

### 3. 테마 접근 변경
```dart
// 모두 동일하게 작동합니다
final theme1 = context.fortuneTheme;  // Fortune 테마
final theme2 = context.toss;          // TOSS 단축키 (동일한 객체)
```

### 4. 애니메이션 적용
```dart
// TOSS 애니메이션 시스템 사용
AnimatedContainer(
  duration: context.toss.animationDurations.medium,
  curve: context.toss.animationCurves.emphasize,
  // ...
);
```

---

## 💡 모범 사례

### 1. 테마 일관성
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final toss = context.toss;
    
    return Container(
      padding: EdgeInsets.all(16), // 8의 배수
      decoration: BoxDecoration(
        color: toss.cardBackground,
        borderRadius: BorderRadius.circular(
          toss.formStyles.inputBorderRadius,
        ),
      ),
    );
  }
}
```

### 2. 햅틱 피드백 활용
```dart
// 버튼 탭 시
if (context.toss.hapticPatterns.buttonTap != null) {
  HapticFeedback.lightImpact();
}

// 성공 액션
if (context.toss.hapticPatterns.success != null) {
  HapticFeedback.mediumImpact();
}
```

### 3. 로딩 상태 처리
```dart
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
```

### 4. 에러 상태 처리
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

### 5. 다크모드 대응
```dart
// 다크모드 자동 대응
Container(
  color: context.isDarkMode 
    ? context.toss.cardBackgroundDark
    : context.toss.cardBackground,
);

// 또는 테마가 자동으로 처리
TossCard(
  child: Text('자동으로 다크모드 대응됨'),
);
```

---

## 🎯 체크리스트

통합 후 확인사항:
- [ ] 모든 `TossTheme` 참조를 `AppTheme`로 변경
- [ ] `toss_theme_extensions.dart` 임포트 제거
- [ ] `toss_theme_provider.dart` 임포트 제거  
- [ ] `context.toss` 또는 `context.fortuneTheme` 사용
- [ ] 컴포넌트가 정상 작동하는지 확인
- [ ] 다크모드에서 테스트
- [ ] 햅틱 피드백 작동 확인

---

## 📚 추가 리소스

- [UI/UX Master Policy](./UI_UX_MASTER_POLICY.md)
- [Design System](./DESIGN_SYSTEM.md)
- [Theme Guidelines](../lib/core/theme/THEME_GUIDELINES.md)

통합된 테마 시스템으로 더욱 일관되고 아름다운 UI를 만들어보세요! 🚀