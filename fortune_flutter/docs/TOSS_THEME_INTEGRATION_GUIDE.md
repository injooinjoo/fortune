# 🎨 TOSS Theme Integration Guide

Fortune Flutter 앱에 TOSS 디자인 시스템을 통합하는 가이드입니다.

## 📋 목차

1. [개요](#개요)
2. [테마 시스템 구조](#테마-시스템-구조)
3. [설정 방법](#설정-방법)
4. [컴포넌트 사용법](#컴포넌트-사용법)
5. [마이그레이션 가이드](#마이그레이션-가이드)
6. [모범 사례](#모범-사례)

---

## 🎯 개요

TOSS 테마 시스템은 문서화된 UI/UX 정책을 실제 Flutter 코드로 구현한 것입니다. 
모든 디자인 결정이 코드로 구현되어 있어, 일관되고 아름다운 UI를 쉽게 만들 수 있습니다.

### 주요 특징
- ✅ 완전한 다크모드 지원
- ✅ 플랫폼별 최적화 (iOS/Android)
- ✅ 접근성 기본 지원
- ✅ 성능 최적화된 애니메이션
- ✅ 햅틱 피드백 통합

---

## 🏗️ 테마 시스템 구조

```
lib/core/
├── theme/
│   ├── toss_theme_extensions.dart    # 테마 확장 정의
│   ├── toss_theme_provider.dart      # 테마 상태 관리
│   ├── app_colors.dart               # 색상 정의
│   ├── app_typography.dart           # 타이포그래피
│   └── app_animations.dart           # 애니메이션 상수
└── components/
    ├── toss_button.dart              # 버튼 컴포넌트
    ├── toss_card.dart                # 카드 컴포넌트
    ├── toss_loading.dart             # 로딩 컴포넌트
    ├── toss_input.dart               # 입력 필드
    ├── toss_bottom_sheet.dart        # 바텀 시트
    ├── toss_dialog.dart              # 다이얼로그
    └── toss_toast.dart               # 토스트 메시지
```

---

## 🚀 설정 방법

### 1. main.dart 설정

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/toss_theme_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'Fortune',
      themeMode: themeMode,
      theme: TossTheme.light(),
      darkTheme: TossTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
```

### 2. pubspec.yaml 의존성 추가

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_animate: ^4.3.0
  flutter_riverpod: ^2.4.9
  shared_preferences: ^2.2.2
```

---

## 🎨 컴포넌트 사용법

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
  onPressed: () {},
);

// 아이콘 포함 버튼
TossButton(
  text: '공유하기',
  leadingIcon: Icon(Icons.share),
  onPressed: () {},
);

// 로딩 상태
TossButton(
  text: '저장 중...',
  isLoading: true,
  onPressed: null,
);
```

### 카드 (TossCard)

```dart
// 기본 카드
TossCard(
  child: Text('카드 내용'),
  onTap: () {
    // 탭 액션
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

// Glass 카드
TossGlassCard(
  blurAmount: 20,
  child: Text('블러 효과가 있는 카드'),
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

// 전화번호 입력
TossPhoneTextField(
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

// 프로그레스 바
TossProgressIndicator(
  value: 0.7, // 70%
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
    print('선택: $value');
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

// 스크린샷 감지 토스트
TossScreenshotToast.show(
  context: context,
  onShare: () {
    // 공유 로직
  },
);
```

---

## 🔄 마이그레이션 가이드

### 1. 기존 버튼 마이그레이션

**Before:**
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('확인'),
)
```

**After:**
```dart
TossButton(
  text: '확인',
  onPressed: () {},
)
```

### 2. 기존 카드 마이그레이션

**Before:**
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('내용'),
  ),
)
```

**After:**
```dart
TossCard(
  child: Text('내용'),
)
```

### 3. 기존 TextField 마이그레이션

**Before:**
```dart
TextField(
  decoration: InputDecoration(
    labelText: '이름',
    hintText: '이름을 입력하세요',
  ),
)
```

**After:**
```dart
TossTextField(
  labelText: '이름',
  hintText: '이름을 입력하세요',
)
```

### 4. 테마 색상 사용

**Before:**
```dart
Container(
  color: Color(0xFF000000),
)
```

**After:**
```dart
Container(
  color: context.theme.primaryColor,
)

// 또는 Extension 사용
Container(
  color: context.isDarkMode ? Colors.white : Colors.black,
)
```

### 5. 애니메이션 적용

```dart
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

---

## 💡 모범 사례

### 1. 일관된 간격 사용

```dart
// 좋은 예
SizedBox(height: 16), // 8의 배수 사용
Padding(
  padding: EdgeInsets.all(24),
),

// 나쁜 예
SizedBox(height: 17), // 임의의 값
```

### 2. 테마 Extension 활용

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

### 3. 햅틱 피드백 고려

```dart
// 버튼, 카드 등의 상호작용에는 기본적으로 햅틱이 활성화됨
// 필요시 비활성화 가능
TossButton(
  text: '조용한 버튼',
  enableHaptic: false, // 햅틱 비활성화
  onPressed: () {},
);
```

### 4. 플랫폼별 분기

```dart
// 플랫폼별 다른 동작이 필요한 경우
if (Theme.of(context).platform == TargetPlatform.iOS) {
  // iOS 전용 처리
} else {
  // Android 전용 처리
}
```

### 5. 성능 최적화

```dart
// const 생성자 활용
const TossCard(
  child: Text('정적 콘텐츠'),
);

// 무거운 위젯은 필요할 때만 로드
if (isVisible) {
  FortuneLoadingAnimation();
}
```

---

## 🎯 체크리스트

마이그레이션 시 확인해야 할 사항들:

- [ ] `main.dart`에 TossTheme 적용
- [ ] 모든 ElevatedButton → TossButton 변경
- [ ] 모든 Card → TossCard 변경
- [ ] 모든 TextField → TossTextField 변경
- [ ] showModalBottomSheet → TossBottomSheet 변경
- [ ] showDialog → TossDialog 변경
- [ ] SnackBar → TossToast 변경
- [ ] 하드코딩된 색상 → 테마 색상 사용
- [ ] 임의의 간격 → 8px 그리드 시스템
- [ ] 다크모드 테스트
- [ ] iOS/Android 플랫폼 테스트

---

## 📚 추가 리소스

- [UI/UX Master Policy](./UI_UX_MASTER_POLICY.md)
- [Design System](./DESIGN_SYSTEM.md)
- [Component Gallery](#) (준비 중)

질문이나 제안사항이 있으시면 언제든 문의해주세요! 🚀