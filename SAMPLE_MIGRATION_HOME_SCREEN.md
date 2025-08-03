# Sample Migration: HomeScreen Typography Update

This document shows a step-by-step example of migrating the HomeScreen to use the new typography system.

## Original Code Analysis

Looking at `/lib/screens/home/home_screen.dart`, we found several instances that need migration:

### 1. SnackBar Text (Line 62)
**Before:**
```dart
SnackBar(
  content: Text('환영합니다! 오늘의 운세를 확인해보세요 ✨'),
  backgroundColor: Colors.green,
  duration: Duration(seconds: 3),
),
```

**After:**
```dart
SnackBar(
  content: AppBodyText.medium('환영합니다! 오늘의 운세를 확인해보세요 ✨'),
  backgroundColor: AppColors.success,
  duration: Duration(seconds: 3),
),
```

### 2. Add Required Imports
Add these imports at the top of the file:
```dart
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/typography/app_text.dart';
```

### 3. Common Patterns to Look For

When migrating home_screen.dart, look for:
- AppBar title styling
- Section headers
- Card titles
- Button text
- Empty state messages
- Loading text
- Error messages

### 4. Full Migration Steps

1. **Add imports** for typography system
2. **Search for TextStyle** instances
3. **Replace hardcoded colors** (like Colors.green → AppColors.success)
4. **Update spacing values** to use AppTheme constants
5. **Test in both light and dark modes**

### 5. Expected Changes Throughout the File

Based on typical home screen patterns, you'll likely need to update:

```dart
// Section headers
Text(
  'Recent Fortunes',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
)
// Becomes:
AppHeadlineText.medium('Recent Fortunes')

// Card titles
Text(
  fortuneTitle,
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
)
// Becomes:
AppTitleText.medium(fortuneTitle)

// Empty state text
Text(
  'No fortunes yet',
  style: TextStyle(
    fontSize: 14,
    color: Colors.grey,
  ),
)
// Becomes:
AppBodyText.small(
  'No fortunes yet',
  color: AppColors.textSecondary,
)

// Loading text
Text(
  'Loading...',
  style: TextStyle(fontSize: 16),
)
// Becomes:
AppBodyText.large('Loading...')
```

## Migration Checklist for HomeScreen

- [ ] Add typography imports
- [ ] Update SnackBar styling
- [ ] Replace any AppBar title styling
- [ ] Update section headers
- [ ] Fix card content typography
- [ ] Update button text styles
- [ ] Replace hardcoded colors
- [ ] Update spacing constants
- [ ] Test empty states
- [ ] Test loading states
- [ ] Verify dark mode support
- [ ] Check responsive behavior

## Testing After Migration

1. Run the app and navigate to HomeScreen
2. Check all text is visible and properly styled
3. Toggle dark mode and verify contrast
4. Test on different screen sizes
5. Verify no text overflow issues
6. Check that the visual hierarchy is maintained

## Common Issues and Solutions

### Issue: Text color not changing in dark mode
**Solution:** Use AppText components which handle dark mode automatically, or use theme-aware colors

### Issue: Font weight looks different
**Solution:** Check the mapping guide - some weights may have changed slightly for better consistency

### Issue: Spacing looks off
**Solution:** Replace magic numbers with AppTheme spacing constants for consistency

## Next Steps

After migrating HomeScreen:
1. Commit the changes
2. Run visual regression tests
3. Get design team approval if needed
4. Move to the next screen in the migration plan