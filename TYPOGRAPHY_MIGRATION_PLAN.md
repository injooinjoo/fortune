# Typography Migration Plan - Fortune Flutter App

## Overview
This document outlines a systematic approach to migrate all Flutter screens from hardcoded text styles to the new Toss Product Sans typography system.

## Migration Goals
1. Replace all hardcoded TextStyle with AppTypography or context extensions
2. Replace hardcoded colors with theme colors
3. Ensure dark mode support
4. Apply consistent spacing using AppTheme constants
5. Update button styles to use new typography
6. Verify text hierarchy is maintained

## New Typography System Components
- **Typography System**: `/lib/core/theme/app_typography.dart`
- **Text Components**: `/lib/shared/widgets/typography/app_text.dart`
- **Theme Guidelines**: `/lib/core/theme/THEME_GUIDELINES.md`

## Migration Phases

### Phase 1: Core Screens (Priority: High)
Update the most frequently used screens first.

#### 1.1 Authentication Screens
- [ ] `/lib/screens/auth/signup_screen.dart`
- [ ] `/lib/screens/auth/callback_page.dart`
- [ ] `/lib/screens/auth/native_auth_callback_handler.dart`

#### 1.2 Main Navigation Screens
- [ ] `/lib/screens/home/home_screen.dart`
- [ ] `/lib/screens/home/home_screen_updated.dart`
- [ ] `/lib/screens/profile/profile_screen.dart`
- [ ] `/lib/screens/settings/settings_screen.dart`
- [ ] `/lib/screens/landing_page.dart`
- [ ] `/lib/screens/splash_screen.dart`

#### 1.3 Onboarding Flow
- [ ] `/lib/screens/onboarding/onboarding_screen.dart`
- [ ] `/lib/screens/onboarding/onboarding_page.dart`
- [ ] `/lib/screens/onboarding/onboarding_page_v2.dart`
- [ ] `/lib/screens/onboarding/onboarding_flow_page.dart`
- [ ] `/lib/screens/onboarding/enhanced_onboarding_flow.dart`
- [ ] All onboarding steps in `/lib/screens/onboarding/steps/`
- [ ] All onboarding widgets in `/lib/screens/onboarding/widgets/`

### Phase 2: Fortune Feature Pages (Priority: High)
Update all fortune-related pages that users interact with frequently.

#### 2.1 Main Fortune Pages
- [ ] `/lib/features/fortune/presentation/pages/base_fortune_page.dart`
- [ ] `/lib/features/fortune/presentation/pages/daily_fortune_page.dart`
- [ ] `/lib/features/fortune/presentation/pages/today_fortune_page.dart`
- [ ] `/lib/features/fortune/presentation/pages/tomorrow_fortune_page.dart`
- [ ] `/lib/features/fortune/presentation/pages/monthly_fortune_page.dart`

#### 2.2 Tarot Pages
- [ ] `/lib/features/fortune/presentation/pages/tarot_main_page.dart`
- [ ] `/lib/features/fortune/presentation/pages/tarot_deck_selection_page.dart`

#### 2.3 Enhanced Fortune Pages
- [ ] All pages ending with `_enhanced_page.dart`
- [ ] All pages ending with `_unified_page.dart`

### Phase 3: Secondary Features (Priority: Medium)
Update less frequently used but still important screens.

#### 3.1 Profile & Settings
- [ ] `/lib/screens/profile/profile_edit_page.dart`
- [ ] `/lib/screens/settings/phone_management_screen.dart`
- [ ] `/lib/screens/settings/social_accounts_screen.dart`
- [ ] `/lib/screens/settings/screenshot_settings_page.dart`
- [ ] `/lib/screens/settings/native_features_settings_page.dart`

#### 3.2 Payment & Subscription
- [ ] `/lib/screens/payment/payment_confirmation_dialog.dart`
- [ ] `/lib/screens/payment/token_history_page.dart`
- [ ] `/lib/screens/subscription/subscription_page.dart`
- [ ] `/lib/screens/premium/premium_screen.dart`

#### 3.3 Special Fortune Pages
- [ ] All remaining fortune pages in `/lib/features/fortune/presentation/pages/`

### Phase 4: Shared Components (Priority: High)
Update reusable components that affect multiple screens.

#### 4.1 Core Widgets
- [ ] `/lib/presentation/widgets/fortune_loading_widget.dart`
- [ ] `/lib/presentation/widgets/fortune_card.dart`
- [ ] `/lib/presentation/widgets/daily_fortune_card.dart`
- [ ] `/lib/presentation/widgets/user_info_card.dart`

#### 4.2 Common Components
- [ ] All widgets in `/lib/presentation/widgets/common/`
- [ ] All widgets in `/lib/shared/components/`

#### 4.3 Specialized Widgets
- [ ] All remaining widgets in `/lib/presentation/widgets/`

### Phase 5: Glassmorphism & Special Effects (Priority: Low)
Update glassmorphism components to work with new typography.

- [ ] `/lib/shared/glassmorphism/glass_container.dart`
- [ ] `/lib/shared/glassmorphism/glass_effects.dart`

## Migration Approach for Each File

### Step 1: Add Imports
```dart
import 'package:fortune_flutter/core/theme/app_typography.dart';
import 'package:fortune_flutter/core/theme/app_colors.dart';
import 'package:fortune_flutter/core/theme/app_theme.dart';
// For using text components:
import 'package:fortune_flutter/shared/widgets/typography/app_text.dart';
```

### Step 2: Replace TextStyle
```dart
// Old style
Text(
  'Title',
  style: TextStyle(
    fontFamily: 'NotoSansKR',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1F2937),
  ),
)

// New style using context extension
Text(
  'Title',
  style: context.headlineMedium,
)

// Or using AppText component
AppHeadlineText.medium('Title')
```

### Step 3: Replace Colors
```dart
// Old style
color: Color(0xFF1F2937)

// New style
color: AppColors.textPrimary

// Dark mode aware
color: Theme.of(context).brightness == Brightness.dark 
    ? AppColors.textPrimaryDark 
    : AppColors.textPrimary
```

### Step 4: Replace Spacing
```dart
// Old style
padding: EdgeInsets.all(16)
SizedBox(height: 24)

// New style
padding: EdgeInsets.all(AppTheme.spacingMedium)
SizedBox(height: AppTheme.spacingLarge)
```

### Step 5: Update Buttons
```dart
// Old style
TextButton(
  child: Text(
    'Button',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  ),
)

// New style
TextButton(
  child: Text(
    'Button',
    style: AppTypography.button,
  ),
)

// Or using AppButtonText
TextButton(
  child: AppButtonText('Button'),
)
```

## Text Style Mapping Guide

### Headers & Titles
- Page titles → `displaySmall` or `headlineLarge`
- Section headers → `headlineMedium`
- Card titles → `titleLarge`
- List item titles → `titleMedium`

### Body Text
- Main content → `bodyMedium`
- Secondary content → `bodySmall`
- Large paragraphs → `bodyLarge`

### UI Elements
- Button text → `AppTypography.button`
- Form labels → `labelMedium`
- Input text → `bodyMedium`
- Helper text → `captionMedium`
- Error text → `captionMedium` with error color

### Special Cases
- Numbers → `numberLarge`, `numberMedium`, `numberSmall`
- Overline text → `AppTypography.overline`
- Captions → `captionLarge`, `captionMedium`, `captionSmall`

## Validation Checklist

For each migrated file, ensure:
- [ ] All TextStyle instances replaced with AppTypography
- [ ] All hardcoded colors replaced with theme colors
- [ ] Dark mode support implemented
- [ ] Spacing uses AppTheme constants
- [ ] Text hierarchy maintained
- [ ] No font family hardcoded
- [ ] Buttons use proper typography
- [ ] Text is readable in both light and dark modes

## Testing Strategy

1. **Visual Regression Testing**
   - Screenshot before migration
   - Screenshot after migration
   - Compare for unintended changes

2. **Dark Mode Testing**
   - Test each screen in both light and dark modes
   - Verify text contrast and readability

3. **Responsive Testing**
   - Test on different screen sizes
   - Verify text scales appropriately

4. **Performance Testing**
   - Ensure no performance degradation
   - Check for any increase in render time

## Rollback Plan

If issues arise:
1. Each file migration should be a separate commit
2. Can revert individual file changes
3. Keep original TextStyle values documented in comments during transition

## Success Metrics

- 100% of screens using AppTypography
- 0 hardcoded font families
- 0 hardcoded text colors
- All screens support dark mode
- Consistent text hierarchy across app
- Improved maintainability for future typography changes

## Timeline Estimate

- Phase 1: 2-3 days
- Phase 2: 3-4 days
- Phase 3: 2-3 days
- Phase 4: 2-3 days
- Phase 5: 1 day
- Testing & Refinement: 2-3 days

**Total: ~2-3 weeks** for complete migration

## Next Steps

1. Start with Phase 1 core screens
2. Create a branch for typography migration
3. Migrate files systematically, one at a time
4. Test each file after migration
5. Commit each file separately for easy rollback
6. Move to next phase after completing current phase
7. Perform comprehensive testing after each phase