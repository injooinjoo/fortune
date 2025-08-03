# 🔄 TOSS Component Migration Examples

실제 코드에서 TOSS 컴포넌트로 마이그레이션하는 예제입니다.

## 1. Button Migration

### Before (ElevatedButton)
```dart
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
```

### After (TossButton)
```dart
import '../core/components/toss_button.dart';

TossButton(
  text: '시작하기',
  onPressed: _startOnboarding,
  style: TossButtonStyle.primary,
  size: TossButtonSize.large,
)
```

## 2. Social Login Button Migration

### Before
```dart
SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  ),
)
```

### After
```dart
TossButton(
  text: text,
  onPressed: onPressed,
  style: backgroundColor == Colors.white 
    ? TossButtonStyle.secondary 
    : TossButtonStyle.primary,
  size: TossButtonSize.large,
  leadingIcon: icon,
  width: double.infinity,
)
```

## 3. Card Migration

### Before
```dart
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
```

### After
```dart
import '../core/components/toss_card.dart';

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

## 4. TextField Migration

### Before
```dart
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
```

### After
```dart
import '../core/components/toss_input.dart';

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

## 5. Phone Number Input Migration

### Before
```dart
TextField(
  controller: _phoneController,
  keyboardType: TextInputType.phone,
  decoration: InputDecoration(
    labelText: '전화번호',
    hintText: '010-0000-0000',
    border: OutlineInputBorder(),
  ),
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    // 복잡한 포맷터 로직...
  ],
)
```

### After
```dart
TossPhoneTextField(
  controller: _phoneController,
  onChanged: (value) {
    // value는 자동으로 010-1234-5678 형식으로 포맷됨
    print(value);
  },
)
```

## 6. Bottom Sheet Migration

### Before
```dart
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
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // ...
      ],
    ),
  ),
);
```

### After
```dart
import '../core/components/toss_bottom_sheet.dart';

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

## 7. Selection Bottom Sheet Migration

### Before
```dart
// 복잡한 커스텀 선택 UI
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    child: ListView(
      children: [
        ListTile(
          leading: Icon(Icons.male),
          title: Text('남성'),
          onTap: () {
            Navigator.pop(context, 'male');
          },
        ),
        ListTile(
          leading: Icon(Icons.female),
          title: Text('여성'),
          onTap: () {
            Navigator.pop(context, 'female');
          },
        ),
      ],
    ),
  ),
);
```

### After
```dart
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

## 8. Loading State Migration

### Before
```dart
if (isLoading) {
  return Center(
    child: CircularProgressIndicator(),
  );
}
```

### After
```dart
import '../core/components/toss_loading.dart';

if (isLoading) {
  return Column(
    children: [
      TossSkeleton.text(width: 200),
      SizedBox(height: 16),
      TossSkeleton.rectangle(
        width: double.infinity,
        height: 100,
      ),
      SizedBox(height: 16),
      TossSkeleton.circle(size: 60),
    ],
  );
}

// 또는 Fortune 로딩 애니메이션
if (isLoading) {
  return Center(
    child: FortuneLoadingAnimation(),
  );
}
```

## 9. Dialog Migration

### Before
```dart
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
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
        ),
      ),
    ],
  ),
);
```

### After
```dart
import '../core/components/toss_dialog.dart';

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

## 10. Toast/SnackBar Migration

### Before
```dart
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
```

### After
```dart
import '../core/components/toss_toast.dart';

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
```

## 11. Complete Screen Example

### Landing Page 마이그레이션 예제

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
                style: context.toss.isDarkMode
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
              
              const SizedBox(height: 12),
              
              TossButton(
                text: 'Apple로 계속하기',
                onPressed: _signInWithApple,
                style: context.isDarkMode 
                  ? TossButtonStyle.primary 
                  : TossButtonStyle.secondary,
                size: TossButtonSize.large,
                leadingIcon: Icon(Icons.apple),
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

## 마이그레이션 팁

1. **점진적 마이그레이션**: 한 번에 모든 것을 바꾸지 말고 화면 단위로 진행
2. **테스트**: 각 컴포넌트 변경 후 기능 테스트 수행
3. **일관성**: 같은 화면 내에서는 모두 TOSS 컴포넌트 사용
4. **테마 활용**: 하드코딩된 색상 대신 테마 색상 사용
5. **햅틱 피드백**: 사용자 상호작용에 햅틱 피드백 추가 고려

## 성능 최적화

```dart
// const 생성자 활용
const TossButton(
  text: '확인',
  onPressed: null, // 비활성화 상태
);

// 조건부 렌더링
if (showButton) {
  TossButton(
    text: '다음',
    onPressed: _handleNext,
  );
}
```