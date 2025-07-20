# Dynamic Fortune Page Migration Guide

This guide explains how we migrated from 90+ individual fortune pages to a single dynamic page system.

## Overview

The Fortune app originally had over 90 individual fortune page files, each implementing similar functionality with slight variations. This led to:
- Massive code duplication
- Difficult maintenance
- Inconsistent UI/UX
- Large bundle size

## Solution: Dynamic Fortune Page

We created a unified system with:
1. **FortuneType enum**: Defines all fortune types
2. **FortuneMetadata**: Contains UI and configuration for each type
3. **DynamicFortunePage**: Single page that handles all fortune types
4. **Simplified routing**: One route pattern for all fortunes

## Implementation Details

### 1. Fortune Type Definition

```dart
enum FortuneType {
  daily('daily', '오늘의 운세'),
  tomorrow('tomorrow', '내일의 운세'),
  weekly('weekly', '주간 운세'),
  // ... 80+ more types
}
```

### 2. Fortune Metadata

Each fortune type has associated metadata:

```dart
class FortuneMetadata {
  final FortuneType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final int tokenCost;
  final List<String> inputFields;
  final bool requiresBirthInfo;
  final bool requiresPartnerInfo;
  final String description;
}
```

### 3. Dynamic Page

The `DynamicFortunePage` widget:
- Takes a `FortuneType` parameter
- Loads metadata for that type
- Renders appropriate UI based on metadata
- Handles all fortune generation logic

### 4. Simplified Routing

Before:
```dart
GoRoute(path: '/fortune/daily', builder: (_, __) => DailyFortunePage()),
GoRoute(path: '/fortune/tomorrow', builder: (_, __) => TomorrowFortunePage()),
GoRoute(path: '/fortune/weekly', builder: (_, __) => WeeklyFortunePage()),
// ... 90+ routes
```

After:
```dart
GoRoute(
  path: ':fortuneType',
  builder: (context, state) {
    final type = FortuneType.fromKey(state.pathParameters['fortuneType']!);
    return DynamicFortunePage(fortuneType: type);
  },
)
```

## Migration Steps

### Phase 1: Setup Infrastructure
1. Create FortuneType enum
2. Create FortuneMetadata class
3. Build metadata repository
4. Create DynamicFortunePage

### Phase 2: Migrate Fortune Types
1. Add all fortune types to enum
2. Define metadata for each type
3. Test dynamic page with sample types

### Phase 3: Update Routing
1. Replace individual routes with dynamic route
2. Update navigation calls throughout app
3. Test all fortune types

### Phase 4: Remove Old Code
1. Delete individual fortune page files
2. Clean up imports
3. Update tests

## Benefits Achieved

### Code Reduction
- **Before**: 90+ files, ~15,000 lines of code
- **After**: 3 files, ~1,000 lines of code
- **Reduction**: 93% less code

### Maintenance
- **Before**: Update 90+ files for UI changes
- **After**: Update 1 file
- **Improvement**: 90x faster

### Consistency
- All fortune pages now have identical structure
- Unified animations and transitions
- Consistent error handling

### Performance
- Smaller bundle size
- Faster navigation
- Better caching

## Adding New Fortune Types

To add a new fortune type:

1. Add to FortuneType enum:
```dart
newType('new-type', '새로운 운세'),
```

2. Add metadata:
```dart
FortuneType.newType: FortuneMetadata(
  type: FortuneType.newType,
  title: '새로운 운세',
  subtitle: '새로운 운세를 확인하세요',
  icon: Icons.star,
  primaryColor: Color(0xFF123456),
  secondaryColor: Color(0xFF234567),
  tokenCost: 2,
  description: '새로운 운세에 대한 설명',
),
```

3. That's it! The fortune is now available at `/fortune-list/new-type`

## Customization

For fortune types that need special UI:

1. Check fortune type in DynamicFortunePage
2. Render custom widgets conditionally
3. Keep common structure intact

Example:
```dart
if (widget.fortuneType == FortuneType.compatibility) {
  // Show partner input fields
}
```

## Testing

Test coverage improved:
- Single page to test instead of 90+
- Parameterized tests for all fortune types
- Easier to maintain test consistency

## Future Improvements

1. **Dynamic Loading**: Load metadata from server
2. **A/B Testing**: Easy to test different UIs
3. **Personalization**: User-specific fortune recommendations
4. **Analytics**: Unified tracking implementation

## Conclusion

The dynamic fortune page migration:
- Reduced code by 93%
- Improved maintainability
- Enhanced consistency
- Simplified testing
- Made adding new fortunes trivial

This architectural change demonstrates the power of proper abstraction and the DRY (Don't Repeat Yourself) principle in action.