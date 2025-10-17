# TypographyTheme Deprecated 안내

⚠️ **TypographyTheme는 이제 사용하지 않습니다!**

## 대체 시스템

TypographyTheme의 기능은 다음 두 시스템으로 분리되었습니다:

1. **FontSizeSystem** - 폰트 크기 관리 및 사용자 조절
2. **TypographyUnified** - TextStyle 제공 및 다크모드 대응

## 마이그레이션 가이드

### 기본 사용

```dart
// ❌ 기존
final theme = TypographyTheme();
Text('제목', style: theme.displayLarge)

// ✅ 신규
Text('제목', style: TypographyUnified.displayLarge)
Text('제목', style: context.typo.displayLarge)
```

### 폰트 크기 조절

```dart
// ❌ 기존
final theme = TypographyTheme(fontScale: 1.15);
Text('제목', style: theme.headingLarge)

// ✅ 신규
FontSizeSystem.setScaleFactor(1.15);
Text('제목', style: TypographyUnified.headingLarge)
```

### 폰트 크기 프리셋

```dart
// ❌ 기존 프리셋
TypographyTheme.fontScalePresets = {
  'very_small': 0.85,   // 85% - 매우 작게
  'small': 0.92,        // 92% - 작게
  'normal': 1.0,        // 100% - 기본
  'large': 1.08,        // 108% - 조금 크게
  'very_large': 1.15,   // 115% - 크게
  'extra_large': 1.3,   // 130% - 매우 크게
}

// ✅ 신규 (직접 설정)
FontSizeSystem.setScaleFactor(0.85)  // 매우 작게
FontSizeSystem.setScaleFactor(0.92)  // 작게
FontSizeSystem.setScaleFactor(1.0)   // 기본
FontSizeSystem.setScaleFactor(1.08)  // 크게
FontSizeSystem.setScaleFactor(1.15)  // 매우 크게
```

### 커스텀 폰트 사용 (제거됨)

```dart
// ❌ 기존 (더 이상 지원하지 않음)
final theme = TypographyTheme(
  bodyFontFamily: 'NotoSansKR',
  headingFontFamily: 'NotoSansKR',
);

// ✅ 신규 (fontFamily는 고정값 사용)
// Pretendard (한글), TossFace (숫자)
// 커스텀 폰트가 필요한 경우 .copyWith()로 개별 적용:
Text('제목', style: TypographyUnified.heading1.copyWith(
  fontFamily: 'NotoSansKR',
))
```

## 스타일 매핑표

| TypographyTheme | TypographyUnified | FontSizeSystem |
|----------------|-------------------|----------------|
| displayLarge | displayLarge | displayLarge (48pt) |
| displayMedium | displayMedium | displayMedium (40pt) |
| displaySmall | displaySmall | displaySmall (32pt) |
| headingLarge | heading1 | heading1 (28pt) |
| headingMedium | heading2 | heading2 (24pt) |
| headingSmall | heading3 | heading3 (20pt) |
| titleLarge | heading4 | heading4 (18pt) |
| titleMedium | bodyLarge | bodyLarge (17pt) |
| titleSmall | buttonMedium | buttonMedium (16pt) |
| bodyLarge | bodyLarge | bodyLarge (17pt) |
| bodyMedium | bodyMedium | bodyMedium (15pt) |
| bodySmall | bodySmall | bodySmall (14pt) |
| labelLarge | buttonMedium | buttonMedium (16pt) |
| labelMedium | labelLarge | labelLarge (13pt) |
| labelSmall | labelMedium | labelMedium (12pt) |
| numberLarge | numberLarge | numberLarge (32pt) |
| numberMedium | numberMedium | numberMedium (24pt) |
| numberSmall | numberSmall | numberSmall (18pt) |

## 주요 변경사항

1. **폰트 크기 조절**: `fontScale` 속성 → `FontSizeSystem.setScaleFactor()` 메서드
2. **폰트 패밀리**: 동적 설정 제거, 고정값 사용 (Pretendard, TossFace)
3. **스타일 접근**: getter 대신 static 상수 사용 (성능 향상)
4. **다크모드**: `.withColor(context)` extension 추가

## 레거시 코드 유지

기존 TypographyTheme 코드는 당분간 유지되지만, 신규 개발에서는 사용하지 마세요.
점진적으로 TypographyUnified + FontSizeSystem으로 마이그레이션하세요.
