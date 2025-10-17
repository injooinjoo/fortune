# 타이포그래피 마이그레이션 가이드

## 📚 개요

Fortune 앱의 폰트 시스템이 통합되었습니다. 이제 모든 텍스트 스타일은 `TypographyTheme`을 통해 관리되며, 사용자가 폰트 크기를 조절할 수 있습니다.

## 🎯 주요 변경사항

### 1. **기존 방식 (Deprecated)**
```dart
Text(
  '제목',
  style: TossDesignSystem.heading2.copyWith(
    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
  ),
)
```

### 2. **새 방식 (Recommended)**
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(typographyThemeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      '제목',
      style: typography.headingLarge.copyWith(
        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
      ),
    );
  }
}
```

## 📖 스타일 매핑 테이블

### Display Styles (특대 제목)
| 기존 | 새로운 | 사용처 |
|-----|-------|--------|
| `display1` | `displayLarge` | 히어로 섹션, 스플래시 (48px) |
| `display2` | `displayMedium` | 메인 제목 (40px) |
| `heading1` | `displaySmall` | 큰 섹션 제목 (32px) |

### Heading Styles (제목)
| 기존 | 새로운 | 사용처 |
|-----|-------|--------|
| `heading2` | `headingLarge` | 페이지 제목 (28px) |
| `heading3` | `headingMedium` | 섹션 제목 (24px) |
| `heading4` | `headingSmall` | 카드 제목, 서브 섹션 (20px) |

### Title Styles (타이틀)
| 기존 | 새로운 | 사용처 |
|-----|-------|--------|
| N/A | `titleLarge` | 리스트 아이템 제목 (18px) |
| N/A | `titleMedium` | 카드 타이틀 (17px) |
| N/A | `titleSmall` | 작은 카드 타이틀 (16px) |

### Body Styles (본문)
| 기존 | 새로운 | 사용처 |
|-----|-------|--------|
| `body1` | `bodyLarge` | 메인 본문, 중요한 설명 (17px) |
| `body2` | `bodyMedium` | 일반 본문 (15px) |
| `body3` | `bodySmall` | 보조 설명, 작은 텍스트 (14px) |

### Label Styles (라벨)
| 기존 | 새로운 | 사용처 |
|-----|-------|--------|
| `button` | `labelLarge` | 버튼 텍스트, 중요한 라벨 (16px) |
| `caption`, `caption1` | `labelMedium` | 태그, 배지, 작은 버튼 (13px) |
| `small` | `labelSmall` | 캡션, 힌트, 타임스탬프 (12px) |

### Number Styles (숫자)
| 기존 | 새로운 | 사용처 |
|-----|-------|--------|
| `amountLarge` | `numberLarge` | 금액, 중요한 수치 (32px) |
| `amountMedium` | `numberMedium` | 일반 숫자 표시 (24px) |
| N/A | `numberSmall` | 작은 수치, 통계 (15px) |

## 🔄 마이그레이션 단계별 가이드

### Step 1: StatelessWidget → ConsumerWidget 변환

**Before:**
```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

**After:**
```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(typographyThemeProvider);
    // ...
  }
}
```

### Step 2: 텍스트 스타일 변경

**Before:**
```dart
Text(
  '오늘의 타로',
  style: TossDesignSystem.heading2.copyWith(
    color: TossDesignSystem.gray900,
  ),
)
```

**After:**
```dart
Text(
  '오늘의 타로',
  style: typography.headingLarge.copyWith(
    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
  ),
)
```

### Step 3: 반복되는 패턴 추출

여러 텍스트에서 같은 색상을 사용한다면:

```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(typographyThemeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 자주 사용하는 색상을 변수로 추출
    final primaryColor = isDark
        ? TossDesignSystem.textPrimaryDark
        : TossDesignSystem.textPrimaryLight;
    final secondaryColor = isDark
        ? TossDesignSystem.textSecondaryDark
        : TossDesignSystem.textSecondaryLight;

    return Column(
      children: [
        Text('제목', style: typography.headingLarge.copyWith(color: primaryColor)),
        Text('설명', style: typography.bodyMedium.copyWith(color: secondaryColor)),
      ],
    );
  }
}
```

## 💡 사용 예시

### 예시 1: 간단한 페이지

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/providers/user_settings_provider.dart';

class SimplePage extends ConsumerWidget {
  const SimplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(typographyThemeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '페이지 제목',
          style: typography.titleLarge.copyWith(
            color: isDark
                ? TossDesignSystem.textPrimaryDark
                : TossDesignSystem.textPrimaryLight,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 큰 제목
            Text(
              '오늘의 운세',
              style: typography.displayMedium.copyWith(
                color: isDark
                    ? TossDesignSystem.textPrimaryDark
                    : TossDesignSystem.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),

            // 본문
            Text(
              '오늘은 좋은 일이 가득한 하루가 될 것입니다.',
              style: typography.bodyMedium.copyWith(
                color: isDark
                    ? TossDesignSystem.textPrimaryDark
                    : TossDesignSystem.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),

            // 작은 텍스트
            Text(
              '2025년 1월 6일',
              style: typography.labelSmall.copyWith(
                color: isDark
                    ? TossDesignSystem.textSecondaryDark
                    : TossDesignSystem.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 예시 2: 카드 컴포넌트

```dart
class FortuneCard extends ConsumerWidget {
  final String title;
  final String description;
  final String date;

  const FortuneCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(typographyThemeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? TossDesignSystem.cardBackgroundDark
            : TossDesignSystem.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 제목
          Text(
            title,
            style: typography.headingSmall.copyWith(
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),

          // 설명
          Text(
            description,
            style: typography.bodySmall.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),

          // 날짜
          Text(
            date,
            style: typography.labelSmall.copyWith(
              color: isDark
                  ? TossDesignSystem.textTertiaryDark
                  : TossDesignSystem.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 예시 3: 버튼

```dart
ElevatedButton(
  onPressed: () {},
  style: TossDesignSystem.primaryButtonStyle(),
  child: Text(
    '확인',
    style: typography.labelLarge, // 버튼은 내부적으로 색상 자동 설정
  ),
)
```

## ⚙️ 사용자 설정

### 폰트 크기 조절 UI 추가

사용자가 폰트 크기를 조절할 수 있도록 설정 페이지에 링크를 추가하세요:

```dart
ListTile(
  leading: const Icon(Icons.text_fields),
  title: Text('폰트 크기', style: typography.bodyMedium),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => context.push('/settings/font'),
)
```

### 프로그래밍 방식으로 폰트 크기 변경

```dart
// 폰트 크기 증가
ref.read(userSettingsProvider.notifier).increaseFontScale();

// 폰트 크기 감소
ref.read(userSettingsProvider.notifier).decreaseFontScale();

// 특정 프리셋 적용
ref.read(userSettingsProvider.notifier).setFontScalePreset('large'); // 크게

// 직접 배율 설정 (0.85 ~ 1.3)
ref.read(userSettingsProvider.notifier).setFontScale(1.15);

// 기본값으로 리셋
ref.read(userSettingsProvider.notifier).reset();
```

## 🚨 주의사항

### 1. **StatefulWidget에서 사용 시**

ConsumerStatefulWidget을 사용하세요:

```dart
class MyPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  @override
  Widget build(BuildContext context) {
    final typography = ref.watch(typographyThemeProvider);
    // ...
  }
}
```

### 2. **하드코딩된 폰트 크기 금지**

❌ **나쁜 예:**
```dart
Text('제목', style: TextStyle(fontSize: 24))
```

✅ **좋은 예:**
```dart
Text('제목', style: typography.headingMedium)
```

### 3. **색상은 항상 다크모드 대응**

❌ **나쁜 예:**
```dart
Text('제목', style: typography.headingMedium.copyWith(color: Colors.black))
```

✅ **좋은 예:**
```dart
Text(
  '제목',
  style: typography.headingMedium.copyWith(
    color: isDark
        ? TossDesignSystem.textPrimaryDark
        : TossDesignSystem.textPrimaryLight,
  ),
)
```

## 📦 필요한 Import

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/providers/user_settings_provider.dart';
```

## 🔧 문제 해결

### Q: "Provider를 찾을 수 없다"는 에러가 발생합니다.

**A:** `main.dart`에서 `ProviderScope`로 앱을 감싸야 합니다:

```dart
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Q: 폰트 크기가 변경되지 않습니다.

**A:** 다음을 확인하세요:
1. `ConsumerWidget` 또는 `ConsumerStatefulWidget` 사용
2. `ref.watch(typographyThemeProvider)` 호출
3. `SharedPreferences` 권한 확인

### Q: 기존 코드가 너무 많아서 한 번에 마이그레이션하기 어렵습니다.

**A:** 점진적으로 마이그레이션하세요:
1. 새 페이지는 무조건 `TypographyTheme` 사용
2. 기존 페이지는 수정 시 함께 마이그레이션
3. `TossDesignSystem`의 타이포그래피 상수는 당분간 유지 (deprecated 표시)

## 📚 추가 자료

- [TypographyTheme 소스 코드](../../lib/core/theme/typography_theme.dart)
- [UserSettingsProvider 소스 코드](../../lib/core/providers/user_settings_provider.dart)
- [FontSettingsPage 예시](../../lib/features/settings/presentation/pages/font_settings_page.dart)
- [Toss Design System](./TOSS_DESIGN_SYSTEM.md)
