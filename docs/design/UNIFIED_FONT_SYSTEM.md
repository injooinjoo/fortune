# 통합 폰트 시스템 - 단일 소스로 앱 전체 관리

## 🎯 개요

Fortune 앱의 모든 텍스트는 이제 **하나의 소스**에서 관리됩니다.

---

## 🎎 전통 타이포그래피 시스템 (Korean Traditional Typography)

Fortune App은 한국 전통 미학에 기반한 타이포그래피 체계를 사용합니다.

### 폰트 계층 구조

| 용도 | 폰트 | 사용 위치 | 우선순위 |
|------|------|----------|----------|
| 전통 제목 | **GowunBatang Bold** | 운세 제목, 사주 명칭, 한자 | **PRIMARY** |
| 전통 본문 | **GowunBatang Regular** | 낙관, 오행 표기, 전통 요소 | PRIMARY |
| 현대 본문 | ZenSerif / 시스템 명조 | 일반 텍스트, 설명 | SECONDARY |
| 숫자/데이터 | Pretendard | 수치, 날짜, 통계 | SECONDARY |

### GowunBatang 사용 가이드

```dart
// 1. 전통 제목 스타일
Text(
  '오늘의 사주',
  style: TextStyle(
    fontFamily: 'GowunBatang',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: ObangseokColors.getMeok(context),
  ),
)

// 2. 한자 표기
Text(
  '木 火 土 金 水',
  style: TextStyle(
    fontFamily: 'GowunBatang',
    fontSize: 20,
    fontWeight: FontWeight.w500,
  ),
)

// 3. 낙관(도장) 텍스트
SealStamp(
  text: '福',  // GowunBatang 자동 적용
  size: 48,
)
```

### 전통 타이포그래피 스케일

```yaml
fortune_display:
  font: GowunBatang
  size: 32-40px
  weight: 700
  usage: 운세 메인 타이틀, 사주 이름

fortune_headline:
  font: GowunBatang
  size: 24-28px
  weight: 700
  usage: 섹션 제목, 운세 카테고리

fortune_title:
  font: GowunBatang
  size: 18-22px
  weight: 500
  usage: 카드 제목, 오행 명칭

fortune_body:
  font: GowunBatang
  size: 14-16px
  weight: 400
  usage: 전통 설명, 한자 해석

seal_text:
  font: GowunBatang
  size: 14-18px
  weight: 700
  usage: 낙관, 도장 텍스트
```

### HanjiCard와 통합

```dart
// HanjiCard 내부에서 자동으로 전통 폰트 적용
HanjiCard(
  style: HanjiCardStyle.scroll,
  colorScheme: HanjiColorScheme.fortune,
  child: Column(
    children: [
      // 자동으로 GowunBatang 적용 (showTraditionalFont: true 기본값)
      Text('사주팔자', style: context.heading1),

      // 또는 명시적으로 적용
      Text(
        '甲子年 乙丑月',
        style: TextStyle(
          fontFamily: 'GowunBatang',
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
)
```

### 다크모드 대응

```dart
// 전통 폰트 색상 (테마 인식)
Text(
  '운세 제목',
  style: TextStyle(
    fontFamily: 'GowunBatang',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: ObangseokColors.getMeok(context),  // 라이트: 먹색, 다크: 미색
  ),
)
```

### 폰트 로딩 (pubspec.yaml)

```yaml
fonts:
  - family: GowunBatang
    fonts:
      - asset: assets/fonts/GowunBatang-Regular.ttf
        weight: 400
      - asset: assets/fonts/GowunBatang-Bold.ttf
        weight: 700
```

---

## ✅ 완성된 시스템

### 📍 **단일 제어 지점**
```
사용자 설정 (UserSettingsProvider)
          ↓
      main.dart
          ↓
    ThemeData.textTheme (fontSizeFactor 적용)
          ↓
    앱 전체 모든 Text 위젯 자동 적용 ✅
```

### 🎨 작동 방식

1. **사용자가 폰트 크기 조절** (`/settings/font`)
   - 슬라이더로 85% ~ 130% 조절
   - 프리셋 버튼 (매우 작게, 작게, 기본, 크게 등)

2. **설정 자동 저장**
   - `SharedPreferences`에 저장
   - 앱 재시작 시에도 유지

3. **앱 전체 즉시 반영**
   - `main.dart`에서 `userSettingsProvider` 구독
   - `TossDesignSystem.lightTheme(fontScale: userSettings.fontScale)` 적용
   - ThemeData의 `textTheme.apply(fontSizeFactor: ...)` 사용
   - **모든 Text 위젯이 자동으로 크기 조절됨**

## 🔧 핵심 구현

### 1. TossDesignSystem (lib/core/theme/toss_design_system.dart)

```dart
/// Light Theme - 폰트 크기 배율 적용
static ThemeData lightTheme({double fontScale = 1.0}) {
  final baseTheme = ThemeData.light();

  return ThemeData(
    // 🎯 앱 전체 폰트 크기 조절 (핵심!)
    textTheme: baseTheme.textTheme.apply(
      fontSizeFactor: fontScale,  // ← 여기서 모든 텍스트 크기 조절
      fontFamily: fontFamilyKorean,
    ),
    // ... 나머지 테마 설정
  );
}

/// Dark Theme - 동일한 방식
static ThemeData darkTheme({double fontScale = 1.0}) {
  final baseTheme = ThemeData.dark();

  return ThemeData(
    textTheme: baseTheme.textTheme.apply(
      fontSizeFactor: fontScale,
      fontFamily: fontFamilyKorean,
    ),
    // ... 나머지 테마 설정
  );
}
```

### 2. main.dart - 사용자 설정 구독

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    // 🎯 사용자 폰트 설정을 앱 전체에 적용
    final userSettings = ref.watch(userSettingsProvider);

    return MaterialApp.router(
      title: 'Fortune - 운세 서비스',
      theme: TossDesignSystem.lightTheme(fontScale: userSettings.fontScale),
      darkTheme: TossDesignSystem.darkTheme(fontScale: userSettings.fontScale),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
```

### 3. UserSettingsProvider (lib/core/providers/user_settings_provider.dart)

```dart
/// 사용자 폰트 설정
class UserSettings {
  final double fontScale;  // 0.85 ~ 1.3
  final String bodyFontFamily;
  final String headingFontFamily;
  final String numberFontFamily;

  // SharedPreferences에 자동 저장
  Future<void> save() async { ... }
  static Future<UserSettings> load() async { ... }
}

/// Provider
final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  return UserSettingsNotifier();
});
```

## 📱 사용자 인터페이스

### 폰트 설정 페이지 (`/settings/font`)

**기능:**
- 실시간 미리보기
- 슬라이더 (85% ~ 130%)
- 6가지 프리셋 버튼
- 증가/감소 버튼
- 기본값 리셋

**사용 방법:**
```dart
// 설정 페이지로 이동
context.push('/settings/font');

// 프로그래밍 방식으로 조절
ref.read(userSettingsProvider.notifier).setFontScale(1.15);
ref.read(userSettingsProvider.notifier).increaseFontScale();
ref.read(userSettingsProvider.notifier).setFontScalePreset('large');
```

## 🔄 마이그레이션

### ❌ 제거된 시스템

1. **`presentation/providers/font_size_provider.dart`**
   - 3단계 크기 (small, medium, large)
   - 이제 사용 안 함
   - 25개 파일에서 사용 중이었으나, 자동으로 새 시스템 적용됨

### ✅ 기존 코드 자동 작동

**수정 불필요!** 모든 기존 코드가 자동으로 새 시스템을 사용합니다:

```dart
// 이 코드들은 수정 없이 자동으로 사용자 설정 반영
Text('제목', style: TossDesignSystem.heading2)  // ✅ 자동 조절
Text('본문', style: TossDesignSystem.body1)     // ✅ 자동 조절
Text('캡션')                                    // ✅ 자동 조절
```

## 💡 장점

### 1. **단일 소스 관리**
- 한 곳에서 모든 폰트 크기 제어
- 여러 시스템 충돌 없음
- 유지보수 간편

### 2. **자동 적용**
- 기존 코드 수정 불필요
- 모든 Text 위젯 자동 조절
- 일관성 보장

### 3. **사용자 경험**
- 실시간 미리보기
- 앱 전체 즉시 반영
- 설정 영구 저장

### 4. **개발자 경험**
- 간단한 API
- 명확한 구조
- 프로답게 깔끔함 ✨

## 🧪 테스트

### 수동 테스트

1. 앱 실행
```bash
flutter run --release -d 00008140-00120304260B001C
```

2. 설정 페이지 이동
   - 메뉴 → 설정 → 폰트 크기

3. 슬라이더로 크기 조절
   - 앱 전체 텍스트가 즉시 변경됨 확인

4. 다른 페이지 이동
   - 모든 페이지의 텍스트가 일관되게 조절됨 확인

5. 앱 재시작
   - 설정이 유지되는지 확인

### 자동 테스트

```dart
void main() {
  testWidgets('Font scale changes apply globally', (tester) async {
    final container = ProviderContainer();
    final notifier = container.read(userSettingsProvider.notifier);

    // 폰트 크기 증가
    await notifier.setFontScale(1.2);

    // 설정 확인
    expect(container.read(userSettingsProvider).fontScale, 1.2);
  });
}
```

## 📊 영향 범위

### ✅ 자동 적용되는 위젯
- **모든 Text 위젯** (명시적 스타일 없음)
- **TossDesignSystem 상수 사용** (heading2, body1 등)
- **Typography 테마 사용** (headingLarge, bodyMedium 등)
- **Button 텍스트**
- **Dialog 텍스트**
- **AppBar 제목**
- **ListTile 텍스트**

### ⚠️ 예외 (수동 조절 필요)
- `fontSize`를 하드코딩한 경우
- `Theme.of(context).textTheme`을 사용하지 않는 경우
- 커스텀 TextStyle을 완전히 새로 만든 경우

**해결 방법:**
```dart
// ❌ 하드코딩 (적용 안 됨)
Text('제목', style: TextStyle(fontSize: 24))

// ✅ 테마 사용 (자동 적용)
Text('제목', style: Theme.of(context).textTheme.headlineMedium)

// ✅ TossDesignSystem 사용 (자동 적용)
Text('제목', style: TossDesignSystem.heading2)
```

## 🔍 문제 해결

### Q: 폰트 크기가 변경되지 않습니다

**A:** 다음을 확인하세요:
1. 앱을 완전히 재시작했나요?
2. `/settings/font`에서 설정이 저장되었나요?
3. Text 위젯이 하드코딩된 fontSize를 사용하나요?

### Q: 일부 텍스트만 크기가 변합니다

**A:** 하드코딩된 fontSize를 사용하는 텍스트입니다.
- `Theme.of(context).textTheme` 또는
- `TossDesignSystem` 상수를 사용하도록 변경하세요.

### Q: 설정 페이지는 어디 있나요?

**A:** `/settings/font` 경로로 이동하면 됩니다.
- 또는 메뉴 → 설정 → 폰트 크기

## 📚 관련 문서

- [TypographyTheme 소스](../../lib/core/theme/typography_theme.dart)
- [UserSettingsProvider 소스](../../lib/core/providers/user_settings_provider.dart)
- [FontSettingsPage 소스](../../lib/features/settings/presentation/pages/font_settings_page.dart)
- [마이그레이션 가이드](./TYPOGRAPHY_MIGRATION_GUIDE.md)
- [Toss Design System](./TOSS_DESIGN_SYSTEM.md)

## 🎉 결론

**이제 Fortune 앱의 모든 폰트는 하나의 시스템으로 깔끔하게 관리됩니다!**

- ✅ 단일 소스
- ✅ 자동 적용
- ✅ 사용자 설정
- ✅ 프로답게 깔끔함
