Toss 디자인 시스템 스타일의 위젯을 생성합니다.

## 입력 정보

- **위젯 유형**: $ARGUMENTS 또는 사용자에게 질문
  - card, button, input, list, dialog, bottomSheet
- **위젯 이름**: 생성할 위젯의 이름

## 생성 위치

```
lib/core/widgets/{widget_name}.dart
```

## 위젯 템플릿

### TossCard 스타일

```dart
import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';

class {WidgetName} extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const {WidgetName}({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? EdgeInsets.all(TossDesignSystem.spacingM),
        decoration: BoxDecoration(
          color: isDark
              ? TossDesignSystem.cardBackgroundDark
              : TossDesignSystem.cardBackgroundLight,
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
          border: Border.all(
            color: isDark
                ? TossDesignSystem.borderDark
                : TossDesignSystem.borderLight,
          ),
        ),
        child: child,
      ),
    );
  }
}
```

### TossButton 스타일

```dart
import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';

class {WidgetName} extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const {WidgetName}({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: TossDesignSystem.tossBlue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: TossDesignSystem.spacingL,
          vertical: TossDesignSystem.spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(text, style: context.buttonMedium),
    );
  }
}
```

### TossInput 스타일

```dart
import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';

class {WidgetName} extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const {WidgetName}({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.labelMedium),
        SizedBox(height: TossDesignSystem.spacingS),
        TextFormField(
          controller: controller,
          validator: validator,
          style: context.bodyMedium.copyWith(
            color: isDark
                ? TossDesignSystem.textPrimaryDark
                : TossDesignSystem.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.bodyMedium.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.textSecondaryLight,
            ),
            filled: true,
            fillColor: isDark
                ? TossDesignSystem.cardBackgroundDark
                : TossDesignSystem.cardBackgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
              borderSide: BorderSide(
                color: isDark
                    ? TossDesignSystem.borderDark
                    : TossDesignSystem.borderLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

## 체크리스트

- [ ] isDark 다크모드 대응
- [ ] TossDesignSystem 색상 사용
- [ ] TypographyUnified 폰트 사용
- [ ] spacing, radius 상수 사용

## 관련 Agent

- toss-design-guardian

