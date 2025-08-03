# Toss-Inspired Color System Migration Guide

## Overview
This document outlines the migration from hardcoded colors to a Toss-inspired semantic color system for the Fortune Flutter app.

## Design Principles (Toss-Inspired)

### 1. Simple and Clear Color System
- **Primary Brand Color**: Toss Blue (#0064FF) - Trust and reliability
- **Limited Color Palette**: Focused on semantic meaning
- **Clear Semantic Colors**: Each color has a specific purpose

### 2. Consistent Color Usage
- **Same Meaning = Same Color**: Consistency across the app
- **Clear Text Hierarchy**: Fine-grained gray scale
- **Status-based Colors**: Success, warning, error with clear distinctions

### 3. Accessibility First
- **High Contrast**: Ensuring readability
- **Color Blind Friendly**: Using patterns beyond just color
- **Dark Mode Support**: Complete theme support

## New Color Structure

### AppColors (Core Theme)
```dart
// Toss Blue - Primary brand color
tossBlue: #0064FF
tossBlueDark: #0050CC
tossBlueLight: #3384FF
tossBlueBackground: #E6F1FF

// Gray Scale (50-900)
gray50: #F9FAFB → gray900: #111827

// Semantic Colors
positive: #00D67A (success)
negative: #FF3B30 (error/danger)
caution: #FFB800 (warning)
informative: #0064FF (info)
```

### FortuneColors (Domain-Specific)
```dart
// Category Colors with Clear Meanings
love: #FF3B57 (warm, emotional)
mystical: #9333EA (spiritual, mysterious)
career: tossBlue (trust, professional)
wealth: #FFB800 (prosperity, gold)
health: #00D67A (fresh, natural)
daily: gray700 (neutral, everyday)

// Intensity Levels
excellent: positive (90-100%)
good: #00D67A (70-89%)
moderate: caution (50-69%)
careful: #FF9500 (30-49%)
challenging: negative (0-29%)
```

## Migration Changes

### 1. Removed Hardcoded Colors
- `Color(0xFF...)` → Semantic color names
- Direct color values → Theme-aware getters
- Arbitrary colors → Purpose-driven colors

### 2. Updated Components
- **career_fortune_selector.dart**: Using career/wealth/mystical colors
- **mbti_fortune_page.dart**: MBTI types mapped to semantic colors
- **lucky_job_fortune_page.dart**: Career color scheme
- **new_year_fortune_page.dart**: Love/wealth/health combination

### 3. New Helper Methods
```dart
// Theme-aware color getters
FortuneColors.getFortuneTypeColor(context, type)
AppColors.getGray(context, shade)
AppColors.getTossBlue(context)
```

## Benefits

1. **Consistency**: Same semantic meaning across the app
2. **Maintainability**: Easy to update colors globally
3. **Accessibility**: Better dark mode support
4. **Clarity**: Colors have clear purposes
5. **Professional**: Toss-inspired trust and reliability

## Migration Checklist

- [x] Extended AppColors with Toss Blue and gray scale
- [x] Restructured FortuneColors with semantic meanings
- [x] Updated hardcoded colors in widgets
- [x] Added theme-aware helper methods
- [ ] Update remaining fortune pages
- [ ] Update all widget files
- [ ] Add color usage documentation
- [ ] Create color palette visual guide

## Usage Examples

### Before (Hardcoded)
```dart
Color(0xFF7C3AED) // What does this mean?
Color(0xFFF87171) // Random color
```

### After (Semantic)
```dart
FortuneColors.mystical // Clear: spiritual/mysterious
AppColors.negative // Clear: error/danger
FortuneColors.getCareer(context) // Theme-aware
```

## Next Steps

1. Continue migrating remaining files
2. Create visual color guide
3. Update design documentation
4. Add lint rules for color usage
5. Create color tokens for design system