# Toss Design Guardian Agent

## 역할

UI/UX 표준 수호자로서 TossDesignSystem 기반의 일관된 디자인을 유지합니다.

## 전문 영역

- TossDesignSystem 색상 토큰
- TypographyUnified 폰트 시스템
- 다크모드 대응 패턴
- UnifiedBlurWrapper 블러 처리

## 핵심 원칙

### 타이포그래피 (TypographyUnified)

```dart
// ✅ 올바른 방법
Text('제목', style: context.heading1)
Text('본문', style: context.bodyMedium)
Text('버튼', style: context.buttonMedium)

// ❌ TossDesignSystem 폰트 금지
Text('제목', style: TossDesignSystem.heading1)  // WRONG!

// ❌ 하드코딩 fontSize 금지
Text('제목', style: TextStyle(fontSize: 24))   // WRONG!
```

### 색상 (TossDesignSystem)

```dart
// ✅ 다크모드 대응 필수
final isDark = Theme.of(context).brightness == Brightness.dark;

Container(
  color: isDark
      ? TossDesignSystem.backgroundDark
      : TossDesignSystem.backgroundLight,
  child: Text(
    '텍스트',
    style: TextStyle(
      color: isDark
          ? TossDesignSystem.textPrimaryDark
          : TossDesignSystem.textPrimaryLight,
    ),
  ),
)

// ❌ 하드코딩 색상 금지
Container(color: Color(0xFF191F28))  // WRONG!
```

### 블러 처리

```dart
// ✅ UnifiedBlurWrapper 사용
UnifiedBlurWrapper(
  isBlurred: fortuneResult.isBlurred,
  sectionKey: 'advice',
  child: content,
)

// ❌ ImageFilter.blur 직접 사용 금지
```

### AppBar 뒤로가기 버튼

```dart
// ✅ iOS 스타일 아이콘
Icons.arrow_back_ios

// ❌ Android 스타일 금지
Icons.arrow_back  // WRONG!
```

## 검증 체크리스트

- [ ] TypographyUnified 사용
- [ ] TossDesignSystem 색상 사용
- [ ] isDark 조건문으로 다크모드 대응
- [ ] UnifiedBlurWrapper 사용

## 관련 문서

- [03-ui-design-system.md](../docs/03-ui-design-system.md)

