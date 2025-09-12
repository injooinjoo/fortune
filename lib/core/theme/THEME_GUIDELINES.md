# Fortune App Theme Guidelines

## 🎨 Design Philosophy

Fortune follows a **modern, minimalist design philosophy** inspired by Toss's clean aesthetic and Instagram's intuitive interface. Our design prioritizes:

- **Clarity**: Information should be immediately understandable
- **Consistency**: Every element follows the same design language
- **Elegance**: Simple, refined, and thoughtful design choices
- **Accessibility**: Readable, usable, and inclusive for all users

## 🔤 Typography System

### Font Family
**Primary**: Toss Product Sans
- Web: Loaded via CDN
- Mobile: Falls back to system fonts with similar characteristics

### Type Scale

#### Display Text (Hero Content)
- **Display Large**: 48px, Bold (700), Line Height 1.2
  - Usage: Landing page heroes, major announcements
- **Display Medium**: 36px, Bold (700), Line Height 1.25
  - Usage: Page titles, feature headers
- **Display Small**: 28px, SemiBold (600), Line Height 1.3
  - Usage: Section headers, modal titles

#### Headlines (Section Headers)
- **Headline Large**: 24px, SemiBold (600), Line Height 1.35
  - Usage: Main content headers
- **Headline Medium**: 20px, SemiBold (600), Line Height 1.4
  - Usage: Subsection headers
- **Headline Small**: 18px, Medium (500), Line Height 1.4
  - Usage: Card titles, list headers

#### Title Text (UI Elements)
- **Title Large**: 17px, SemiBold (600), Line Height 1.45
  - Usage: Navigation items, prominent labels
- **Title Medium**: 16px, Medium (500), Line Height 1.5
  - Usage: Card titles, list items
- **Title Small**: 15px, Medium (500), Line Height 1.5
  - Usage: Secondary titles, tabs

#### Body Text (Content)
- **Body Large**: 16px, Regular (400), Line Height 1.6
  - Usage: Main content, articles
- **Body Medium**: 15px, Regular (400), Line Height 1.6
  - Usage: Standard body text
- **Body Small**: 14px, Regular (400), Line Height 1.55
  - Usage: Secondary content, descriptions

#### Supporting Text
- **Label Large**: 15px, Medium (500), Line Height 1.4
  - Usage: Button text, form labels
- **Label Medium**: 14px, Medium (500), Line Height 1.4
  - Usage: Input labels, tags
- **Label Small**: 13px, Medium (500), Line Height 1.4
  - Usage: Helper text, badges

- **Caption Large**: 13px, Regular (400), Line Height 1.5
  - Usage: Timestamps, metadata
- **Caption Medium**: 12px, Regular (400), Line Height 1.5
  - Usage: Helper text, hints
- **Caption Small**: 11px, Regular (400), Line Height 1.45
  - Usage: Legal text, disclaimers

#### Special Styles
- **Button**: 16px, SemiBold (600)
- **Button Small**: 14px, SemiBold (600)
- **Overline**: 12px, SemiBold (600), Letter Spacing 0.04
- **Numbers**: Uses tabular figures for alignment

## 🎨 Color System

### Core Palette

#### Primary Colors
- **Primary**: `#6366F1` - Indigo (Main brand color)
- **Primary Light**: `#818CF8` - Light indigo
- **Primary Dark**: `#4F46E5` - Dark indigo

#### Neutral Colors
- **Background**: `#FAFAFA` - Off-white
- **Surface**: `#FFFFFF` - Pure white
- **Card Background**: `#F9FAFB` - Light gray
- **Border**: `#E5E7EB` - Light gray border
- **Divider**: `#F3F4F6` - Subtle divider

#### Text Colors
- **Text Primary**: `#111827` - Almost black
- **Text Secondary**: `#6B7280` - Medium gray
- **Text Tertiary**: `#9CA3AF` - Light gray

#### Semantic Colors
- **Success**: `#10B981` - Green
- **Warning**: `#F59E0B` - Amber
- **Error**: `#EF4444` - Red
- **Info**: `#3B82F6` - Blue

### Dark Mode Colors
- **Background Dark**: `#0A0A0A`
- **Surface Dark**: `#1A1A1A`
- **Card Background Dark**: `#141414`
- **Text Primary Dark**: `#F9FAFB`
- **Text Secondary Dark**: `#D1D5DB`

## 📐 Spacing System

Use consistent spacing based on 4px grid:
- **XSmall**: 4px
- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px
- **XLarge**: 32px
- **XXLarge**: 48px

## 🔲 Border Radius

- **Small**: 8px (Buttons, inputs)
- **Medium**: 16px (Cards, containers)
- **Large**: 24px (Modals, sheets)
- **XLarge**: 32px (Special elements)
- **XXLarge**: 42px (Hero elements)

## 🎯 Component Guidelines

### Buttons
```dart
// Primary Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    textStyle: AppTypography.button,
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
    ),
  ),
  child: Text('확인'),
)
```

### Cards
```dart
BaseCard(
  child: Padding(
    padding: EdgeInsets.all(AppTheme.spacingMedium),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카드 제목',
          style: context.titleLarge,
        ),
        SizedBox(height: AppTheme.spacingSmall),
        Text(
          '카드 내용',
          style: context.bodyMedium,
        ),
      ],
    ),
  ),
)
```

### Input Fields
```dart
TextField(
  style: context.bodyMedium,
  decoration: InputDecoration(
    labelText: '이메일',
    labelStyle: context.labelMedium,
    hintText: 'example@email.com',
    hintStyle: context.captionMedium.copyWith(
      color: AppColors.textSecondary,
    ),
  ),
)
```

## 🌓 Dark Mode Support

All components should support both light and dark modes:

```dart
// Use theme-aware colors
final textColor = Theme.of(context).brightness == Brightness.dark
    ? AppColors.textPrimaryDark
    : AppColors.textPrimary;

// Or use FortuneThemeExtension
final fortuneTheme = Theme.of(context).extension<FortuneThemeExtension>()!;
final cardColor = fortuneTheme.cardSurface;
```

## 📱 Responsive Design

### Breakpoints
- **Mobile**: < 600px
- **Tablet**: 600px - 1200px
- **Desktop**: > 1200px

### Responsive Typography
```dart
// Use responsive font size
final fontSize = AppTypography.responsiveFontSize(context, 16);

Text(
  'Responsive Text',
  style: context.bodyMedium.copyWith(
    fontSize: fontSize,
  ),
)
```

## ✅ Implementation Checklist

When updating screens to the new theme:

1. **Replace hardcoded fonts** with `AppTypography`
2. **Use theme colors** instead of hardcoded values
3. **Apply consistent spacing** using `AppTheme.spacing*`
4. **Ensure dark mode support** with proper color switching
5. **Test on multiple screen sizes** for responsive behavior
6. **Verify text readability** with proper contrast ratios
7. **Check component consistency** across the app

## 🚀 Migration Guide

### Old Style
```dart
Text(
  'Title',
  style: TextStyle(
    fontFamily: 'NotoSansKR',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1F2937),
  ),
)
```

### New Style
```dart
Text(
  'Title',
  style: context.headlineMedium,
)
```

### With Custom Color
```dart
Text(
  'Title',
  style: context.headlineMedium.copyWith(
    color: AppColors.primary,
  ),
)
```

## 📋 Quick Reference

### Text Styles by Usage
- **Page Title**: `displaySmall` or `headlineLarge`
- **Section Header**: `headlineMedium`
- **Card Title**: `titleLarge`
- **Body Text**: `bodyMedium`
- **Button Text**: `AppTypography.button`
- **Caption**: `captionMedium`
- **Input Label**: `labelMedium`

### Common Patterns
```dart
// Import typography extension
import 'package:fortune/core/theme/app_typography.dart';

// Use in build method
@override
Widget build(BuildContext context) {
  return Text(
    'Hello World',
    style: context.headlineMedium, // Access via extension
  );
}
```

## 🎯 Best Practices

1. **Never hardcode colors or fonts** - Always use theme values
2. **Test in both light and dark modes** - Ensure readability
3. **Follow the spacing grid** - Maintain visual rhythm
4. **Use semantic color names** - Not color values
5. **Keep text hierarchy clear** - Use appropriate text styles
6. **Ensure sufficient contrast** - WCAG AA compliance
7. **Be consistent** - Same elements should look the same

---

This theme system ensures a cohesive, modern, and accessible user experience throughout the Fortune app.
