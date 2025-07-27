# Dark Mode Migration Guide

이 문서는 Fortune 앱의 모든 페이지를 다크 모드를 지원하도록 업데이트하는 방법을 설명합니다.

## 1. Import 추가

모든 페이지에 다음 import를 추가합니다:

```dart
import '../../core/theme/app_theme_extensions.dart';
import '../../core/utils/theme_utils.dart';
```

## 2. 색상 교체 규칙

### 2.1 하드코딩된 색상 교체

#### 배경 색상
```dart
// 변경 전
backgroundColor: Colors.white
backgroundColor: AppColors.background
backgroundColor: Color(0xFFF5F5F5)

// 변경 후
backgroundColor: AppColors.getSurface(context)
backgroundColor: AppColors.getBackground(context)
backgroundColor: context.fortuneTheme.cardBackground
```

#### 텍스트 색상
```dart
// 변경 전
color: Colors.black
color: AppColors.textPrimary
color: Color(0xFF262626)

// 변경 후
color: AppColors.getTextPrimary(context)
color: context.fortuneTheme.primaryText
```

#### 보조 텍스트
```dart
// 변경 전
color: Colors.grey
color: AppColors.textSecondary
color: Color(0xFF8E8E8E)

// 변경 후
color: AppColors.getTextSecondary(context)
color: context.fortuneTheme.secondaryText
color: context.fortuneTheme.subtitleText
```

#### Divider 색상
```dart
// 변경 전
color: AppColors.divider
color: Colors.grey[300]

// 변경 후
color: AppColors.getDivider(context)
color: context.fortuneTheme.dividerColor
```

### 2.2 특정 색상 교체

#### Purple 색상 (mystical 테마)
```dart
// 변경 전
Colors.purple
Color(0xFF9C27B0)
AppColors.mysticalPurple

// 변경 후
ThemeUtils.getThemedPurple(context)
ThemeUtils.getThemedPurple(context, opacity: 0.5)
```

#### 상태 색상
```dart
// 변경 전
AppColors.success
AppColors.error
AppColors.warning

// 변경 후
ThemeUtils.getStatusColor(context, StatusType.success)
ThemeUtils.getStatusColor(context, StatusType.error)
ThemeUtils.getStatusColor(context, StatusType.warning)
```

## 3. 위젯별 업데이트 예시

### 3.1 Container/Card
```dart
// 변경 전
Container(
  color: Colors.white,
  decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 10,
      ),
    ],
  ),
)

// 변경 후
Container(
  color: context.fortuneTheme.cardSurface,
  decoration: BoxDecoration(
    color: context.fortuneTheme.cardSurface,
    boxShadow: ThemeUtils.getCardShadow(context),
  ),
)
```

### 3.2 Gradient
```dart
// 변경 전
LinearGradient(
  colors: [
    Colors.purple,
    Colors.indigo,
  ],
)

// 변경 후
ThemeUtils.getMysticalGradient(context)
// 또는
ThemeUtils.getPrimaryGradient(context)
```

### 3.3 Glass Container
```dart
// Glass container는 이미 다크 모드를 지원하므로 특별한 변경 불필요
// 단, 필요시 ThemeUtils.getGlassColors(context) 사용
```

## 4. 실제 페이지 업데이트 예시

### 변경 전
```dart
class FortuneExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        color: Colors.white,
        child: Text(
          '운세',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
```

### 변경 후
```dart
class FortuneExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fortuneTheme = context.fortuneTheme;
    
    return Scaffold(
      backgroundColor: AppColors.getCardBackground(context),
      body: Container(
        color: fortuneTheme.cardSurface,
        child: Text(
          '운세',
          style: TextStyle(
            color: fortuneTheme.primaryText,
          ),
        ),
      ),
    );
  }
}
```

## 5. 주의사항

1. **BuildContext 필요**: 모든 theme-aware 색상은 context가 필요합니다
2. **fortuneTheme 캐싱**: Widget build 메서드 시작 부분에서 `final fortuneTheme = context.fortuneTheme;`로 캐싱
3. **Colors 직접 사용 금지**: `Colors.white`, `Colors.black` 등 직접 사용하지 않기
4. **테스트**: 변경 후 라이트/다크 모드 모두에서 테스트 필수

## 6. 페이지 업데이트 체크리스트

각 페이지를 업데이트할 때 다음 항목들을 확인하세요:

- [ ] Import 추가 완료
- [ ] 배경색 theme-aware로 변경
- [ ] 텍스트 색상 theme-aware로 변경
- [ ] Shadow/Border 색상 변경
- [ ] Gradient 변경
- [ ] 하드코딩된 색상 모두 제거
- [ ] 라이트 모드에서 테스트
- [ ] 다크 모드에서 테스트

## 7. 유틸리티 함수 활용

`ThemeUtils` 클래스의 다양한 헬퍼 함수를 활용하세요:

- `isDarkMode(context)`: 현재 다크 모드인지 확인
- `getCardShadow(context)`: 테마별 그림자
- `getCardBorder(context)`: 테마별 테두리
- `getShimmerColors(context)`: Shimmer 효과 색상