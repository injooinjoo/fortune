# Fortune 통합 폰트 시스템 가이드

## 개요

Fortune 앱의 모든 텍스트는 **단일 소스**에서 관리됩니다. 이 문서는 기존 3개 문서(UNIFIED_FONT_SYSTEM, FONT_MIGRATION_GUIDE, FONT_MIGRATION_PLAN)를 통합한 것입니다.

---

## 1. 현재 폰트 시스템

### 1.1 단일 제어 지점

```
사용자 설정 (UserSettingsProvider)
          ↓
      main.dart
          ↓
    ThemeData.textTheme (fontSizeFactor 적용)
          ↓
    앱 전체 모든 Text 위젯 자동 적용
```

### 1.2 한국 전통 타이포그래피

| 용도 | 폰트 | 사용 위치 | 우선순위 |
|------|------|----------|----------|
| 전통 제목 | **GowunBatang Bold** | 운세 제목, 사주 명칭, 한자 | **PRIMARY** |
| 전통 본문 | **GowunBatang Regular** | 낙관, 오행 표기, 전통 요소 | PRIMARY |
| 현대 본문 | NotoSansKR / 시스템 | 일반 텍스트, 설명 | SECONDARY |
| 숫자/데이터 | Pretendard | 수치, 날짜, 통계 | SECONDARY |

### 1.3 전통 타이포그래피 스케일

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
```

---

## 2. 핵심 구현

### 2.1 TossDesignSystem

```dart
// lib/core/theme/toss_design_system.dart

static ThemeData lightTheme({double fontScale = 1.0}) {
  final baseTheme = ThemeData.light();

  return ThemeData(
    // 앱 전체 폰트 크기 조절
    textTheme: baseTheme.textTheme.apply(
      fontSizeFactor: fontScale,
      fontFamily: fontFamilyKorean,
    ),
    // ... 나머지 테마 설정
  );
}
```

### 2.2 main.dart - 사용자 설정 구독

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSettings = ref.watch(userSettingsProvider);

    return MaterialApp.router(
      theme: TossDesignSystem.lightTheme(fontScale: userSettings.fontScale),
      darkTheme: TossDesignSystem.darkTheme(fontScale: userSettings.fontScale),
      // ...
    );
  }
}
```

### 2.3 사용 방법

```dart
// TypographyUnified Extension 사용 (권장)
Text('제목', style: context.heading1)
Text('본문', style: context.bodyMedium)

// 전통 폰트 직접 적용
Text(
  '사주팔자',
  style: TextStyle(
    fontFamily: 'GowunBatang',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: ObangseokColors.getMeok(context),
  ),
)

// 다크모드 대응
Text(
  '제목',
  style: context.heading4.copyWith(
    color: isDark
      ? TossDesignSystem.textPrimaryDark
      : TossDesignSystem.textPrimaryLight,
  ),
)
```

---

## 3. 폰트 크기 조절 기능

### 3.1 사용자 설정

- **경로**: `/settings/font`
- **범위**: 85% ~ 130%
- **프리셋**: 매우 작게, 작게, 기본, 크게 등

### 3.2 프로그래밍 방식

```dart
// 설정 페이지로 이동
context.push('/settings/font');

// 프로그래밍 방식으로 조절
ref.read(userSettingsProvider.notifier).setFontScale(1.15);
ref.read(userSettingsProvider.notifier).increaseFontScale();
ref.read(userSettingsProvider.notifier).setFontScalePreset('large');
```

---

## 4. 마이그레이션 가이드

### 4.1 크기별 매핑

| 기존 크기 | TypographyUnified | 용도 |
|----------|------------------|------|
| 48pt | `displayLarge` | 스플래시 |
| 32pt | `displaySmall` | 페이지 메인 제목 |
| 28pt | `heading1` | 큰 섹션 제목 |
| 24pt | `heading2` | 섹션 제목 |
| 20pt | `heading3` | 카드 제목 |
| 18pt | `heading4` | 작은 제목, 탭 |
| 16pt | `buttonMedium` | 버튼, 중요 텍스트 |
| 14pt | `bodySmall` | 기본 본문 |
| 12pt | `labelMedium` | 작은 라벨, 캡션 |
| 10pt | `labelTiny` | 배지, NEW 표시 |

### 4.2 변환 예시

**Before:**
```dart
Text('제목', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700))
```

**After:**
```dart
Text('제목', style: context.heading2)
```

### 4.3 마이그레이션 원칙

1. **기존 코드는 건드리지 않음** (작동 중이면 OK)
2. **신규 페이지/위젯만 TypographyUnified 사용**
3. **수정이 필요한 파일만 마이그레이션**

---

## 5. 자동 적용 범위

### 5.1 자동 적용되는 위젯

- 모든 Text 위젯 (명시적 스타일 없음)
- TossDesignSystem 상수 사용 (heading2, body1 등)
- Typography 테마 사용 (headingLarge, bodyMedium 등)
- Button, Dialog, AppBar, ListTile 텍스트

### 5.2 예외 (수동 조절 필요)

- `fontSize`를 하드코딩한 경우
- 커스텀 TextStyle을 완전히 새로 만든 경우

**해결 방법:**
```dart
// 하드코딩 (적용 안 됨)
Text('제목', style: TextStyle(fontSize: 24))

// 테마 사용 (자동 적용)
Text('제목', style: Theme.of(context).textTheme.headlineMedium)

// TossDesignSystem 사용 (자동 적용)
Text('제목', style: context.heading2)
```

---

## 6. 관련 파일

| 파일 | 역할 |
|------|------|
| `lib/core/theme/toss_design_system.dart` | 테마 정의 |
| `lib/core/theme/typography_unified.dart` | 타이포그래피 스케일 |
| `lib/core/providers/user_settings_provider.dart` | 사용자 설정 |
| `lib/features/settings/presentation/pages/font_settings_page.dart` | 설정 UI |

---

## 7. 문제 해결

### Q: 폰트 크기가 변경되지 않습니다
1. 앱을 완전히 재시작했나요?
2. `/settings/font`에서 설정이 저장되었나요?
3. Text 위젯이 하드코딩된 fontSize를 사용하나요?

### Q: 일부 텍스트만 크기가 변합니다
하드코딩된 fontSize를 사용하는 텍스트입니다.
→ `context.heading1` 등 Extension 사용으로 변경하세요.

---

## 변경 이력

- **2024-12**: 3개 문서 통합 (UNIFIED_FONT_SYSTEM, FONT_MIGRATION_GUIDE, FONT_MIGRATION_PLAN)
- **2024-11**: 통합 폰트 시스템 구축
- **2024-10**: GowunBatang 전통 폰트 도입
