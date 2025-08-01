# Typography Migration Examples - Common Patterns

## Import Statements Required

Add these imports to every file being migrated:

```dart
import 'package:fortune_flutter/core/theme/app_typography.dart';
import 'package:fortune_flutter/core/theme/app_colors.dart';
import 'package:fortune_flutter/core/theme/app_theme.dart';
import 'package:fortune_flutter/shared/widgets/typography/app_text.dart';
```

## Common Migration Patterns

### 1. App Bar Titles

**Before:**
```dart
AppBar(
  title: Text(
    '운세',
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  ),
)
```

**After:**
```dart
AppBar(
  title: Text(
    '운세',
    style: context.headlineMedium,
  ),
)

// Or using AppText:
AppBar(
  title: AppHeadlineText.medium('운세'),
)
```

### 2. Page Titles

**Before:**
```dart
Text(
  '오늘의 운세',
  style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1F2937),
  ),
)
```

**After:**
```dart
Text(
  '오늘의 운세',
  style: context.displaySmall,
)

// Or using AppText:
AppDisplayText.small('오늘의 운세')
```

### 3. Card Headers

**Before:**
```dart
Container(
  child: Text(
    '금전운',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  ),
)
```

**After:**
```dart
Container(
  child: Text(
    '금전운',
    style: context.titleLarge,
  ),
)

// Or using AppText:
Container(
  child: AppTitleText.large('금전운'),
)
```

### 4. Body Text with Dark Mode

**Before:**
```dart
Text(
  description,
  style: TextStyle(
    fontSize: 14,
    color: isDarkMode ? Colors.white70 : Colors.black87,
    height: 1.5,
  ),
)
```

**After:**
```dart
Text(
  description,
  style: context.bodySmall,
)

// Or using AppText (handles dark mode automatically):
AppBodyText.small(description)
```

### 5. Buttons

**Before:**
```dart
ElevatedButton(
  onPressed: () {},
  child: Text(
    '확인',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
)
```

**After:**
```dart
ElevatedButton(
  onPressed: () {},
  child: Text(
    '확인',
    style: AppTypography.button,
  ),
)

// Or using AppButtonText:
ElevatedButton(
  onPressed: () {},
  child: AppButtonText('확인'),
)
```

### 6. Form Labels

**Before:**
```dart
TextField(
  decoration: InputDecoration(
    labelText: '이름',
    labelStyle: TextStyle(
      fontSize: 14,
      color: Colors.grey[600],
    ),
  ),
)
```

**After:**
```dart
TextField(
  decoration: InputDecoration(
    labelText: '이름',
    labelStyle: context.labelMedium.copyWith(
      color: AppColors.textSecondary,
    ),
  ),
)
```

### 7. Error Messages

**Before:**
```dart
Text(
  errorMessage,
  style: TextStyle(
    fontSize: 12,
    color: Colors.red,
  ),
)
```

**After:**
```dart
Text(
  errorMessage,
  style: context.captionMedium.copyWith(
    color: AppColors.error,
  ),
)

// Or using AppText:
AppCaptionText.medium(
  errorMessage,
  color: AppColors.error,
)
```

### 8. List Items

**Before:**
```dart
ListTile(
  title: Text(
    item.title,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
  ),
  subtitle: Text(
    item.subtitle,
    style: TextStyle(
      fontSize: 14,
      color: Colors.grey,
    ),
  ),
)
```

**After:**
```dart
ListTile(
  title: Text(
    item.title,
    style: context.titleMedium,
  ),
  subtitle: Text(
    item.subtitle,
    style: context.bodySmall.copyWith(
      color: AppColors.textSecondary,
    ),
  ),
)

// Or using AppText:
ListTile(
  title: AppTitleText.medium(item.title),
  subtitle: AppBodyText.small(
    item.subtitle,
    color: AppColors.textSecondary,
  ),
)
```

### 9. Numbers and Statistics

**Before:**
```dart
Text(
  '₩${price.toStringAsFixed(0)}',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.green,
    fontFeatures: [FontFeature.tabularFigures()],
  ),
)
```

**After:**
```dart
Text(
  '₩${price.toStringAsFixed(0)}',
  style: AppTypography.numberMedium.copyWith(
    color: AppColors.success,
  ),
)

// Or using AppNumberText:
AppNumberText.medium(
  '₩${price.toStringAsFixed(0)}',
  color: AppColors.success,
)
```

### 10. Caption and Helper Text

**Before:**
```dart
Text(
  '최근 업데이트: $date',
  style: TextStyle(
    fontSize: 12,
    color: Colors.grey[500],
  ),
)
```

**After:**
```dart
Text(
  '최근 업데이트: $date',
  style: context.captionMedium.copyWith(
    color: AppColors.textTertiary,
  ),
)

// Or using AppText:
AppCaptionText.medium(
  '최근 업데이트: $date',
  color: AppColors.textTertiary,
)
```

### 11. Rich Text

**Before:**
```dart
RichText(
  text: TextSpan(
    style: TextStyle(fontSize: 14, color: Colors.black),
    children: [
      TextSpan(text: '총 '),
      TextSpan(
        text: '${count}개',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: '의 운세'),
    ],
  ),
)
```

**After:**
```dart
RichText(
  text: TextSpan(
    style: context.bodySmall,
    children: [
      TextSpan(text: '총 '),
      TextSpan(
        text: '${count}개',
        style: context.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      TextSpan(text: '의 운세'),
    ],
  ),
)
```

### 12. Spacing Updates

**Before:**
```dart
Padding(
  padding: EdgeInsets.all(16.0),
  child: Column(
    children: [
      Text('Title'),
      SizedBox(height: 8),
      Text('Content'),
      SizedBox(height: 24),
      ElevatedButton(...),
    ],
  ),
)
```

**After:**
```dart
Padding(
  padding: EdgeInsets.all(AppTheme.spacingMedium),
  child: Column(
    children: [
      Text('Title'),
      SizedBox(height: AppTheme.spacingSmall),
      Text('Content'),
      SizedBox(height: AppTheme.spacingLarge),
      ElevatedButton(...),
    ],
  ),
)
```

### 13. Theme-Aware Colors

**Before:**
```dart
Container(
  color: isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
  child: Text(
    'Content',
    style: TextStyle(
      color: isDarkMode ? Colors.white : Colors.black,
    ),
  ),
)
```

**After:**
```dart
Container(
  color: Theme.of(context).brightness == Brightness.dark 
      ? AppColors.surfaceDark 
      : AppColors.surface,
  child: AppBodyText.medium('Content'),
)
```

### 14. Gradient Text (Special Case)

**Before:**
```dart
ShaderMask(
  shaderCallback: (bounds) => LinearGradient(
    colors: [Colors.blue, Colors.purple],
  ).createShader(bounds),
  child: Text(
    'Premium',
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
)
```

**After:**
```dart
ShaderMask(
  shaderCallback: (bounds) => LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
  ).createShader(bounds),
  child: Text(
    'Premium',
    style: context.headlineMedium.copyWith(
      color: Colors.white, // Required for ShaderMask
    ),
  ),
)
```

## Common Pitfalls to Avoid

1. **Don't mix old and new styles** in the same widget
2. **Always test dark mode** after migration
3. **Maintain text hierarchy** - don't change the visual importance
4. **Use copyWith() sparingly** - prefer using the predefined styles
5. **Test on different screen sizes** to ensure responsive behavior

## Quick Reference Cheat Sheet

| Old Pattern | New Pattern |
|-------------|-------------|
| `fontSize: 48` | `context.displayLarge` |
| `fontSize: 36` | `context.displayMedium` |
| `fontSize: 28` | `context.displaySmall` |
| `fontSize: 24` | `context.headlineLarge` |
| `fontSize: 20` | `context.headlineMedium` |
| `fontSize: 18` | `context.headlineSmall` |
| `fontSize: 17` | `context.titleLarge` |
| `fontSize: 16` | `context.titleMedium` or `context.bodyLarge` |
| `fontSize: 15` | `context.titleSmall` or `context.bodyMedium` |
| `fontSize: 14` | `context.bodySmall` or `context.labelMedium` |
| `fontSize: 13` | `context.labelSmall` or `context.captionLarge` |
| `fontSize: 12` | `context.captionMedium` |
| `fontSize: 11` | `context.captionSmall` |

## Testing After Migration

Run these checks after migrating each file:

```dart
// 1. Check text visibility in light mode
// 2. Check text visibility in dark mode
// 3. Verify text hierarchy is maintained
// 4. Test on smallest supported device
// 5. Test on tablet/large screen
// 6. Verify no text overflow issues
// 7. Check button tap areas are sufficient
```