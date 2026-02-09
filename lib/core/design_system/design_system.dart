// Modern AI Chat Design System for Fortune App
//
// Design Philosophy: Minimalist, neutral, content-focused
// Inspired by Claude and ChatGPT interfaces.
//
// A comprehensive design system providing clean, modern styling
// across the entire application.
//
// ## Quick Start
//
// ```dart
// import 'package:fortune/core/design_system/design_system.dart';
//
// // Clean background (no texture)
// Scaffold(backgroundColor: context.colors.background)
//
// // Access colors via context (neutral palette)
// Container(color: context.colors.surface)
//
// // Access typography (Inter font)
// Text('Title', style: context.typography.headingLarge)
//
// // Modern button
// DSButton.primary(text: 'Continue', onPressed: () {})
//
// // Clean elevated card
// DSCard.elevated(child: content)
// ```
//
// ## File Structure
//
// ```
// design_system/
// ├── design_system.dart    <- You are here (barrel export)
// ├── tokens/               <- Design tokens
// │   ├── ds_colors.dart
// │   ├── ds_spacing.dart
// │   ├── ds_radius.dart
// │   ├── ds_shadows.dart
// │   ├── ds_typography.dart
// │   └── ds_animation.dart
// ├── components/           <- UI components
// │   ├── ds_button.dart
// │   ├── ds_toggle.dart
// │   ├── ds_card.dart
// │   └── ...
// ├── theme/                <- Theme configuration
// │   ├── ds_theme.dart
// │   └── ds_extensions.dart
// └── utils/                <- Utilities
//     └── ds_haptics.dart
// ```
library;

// ============================================
// TOKENS
// ============================================

export 'tokens/ds_colors.dart';
export 'tokens/ds_spacing.dart';
export 'tokens/ds_radius.dart';
export 'tokens/ds_shadows.dart';
export 'tokens/ds_typography.dart';
export 'tokens/ds_animation.dart';
export 'tokens/ds_saju_colors.dart'; // 사주 오행 데이터 시각화용 (semantic coloring)

// Typography extensions for context.labelMedium, context.bodySmall, etc.
// Note: Using typography_unified.dart instead of app_typography.dart to avoid
// ambiguous extension member conflicts with DSContextExtensions.typography
export '../theme/typography_unified.dart';

// ============================================
// THEME
// ============================================

export 'theme/ds_theme.dart';
export 'theme/ds_extensions.dart';

// ============================================
// UTILITIES
// ============================================

export 'utils/ds_haptics.dart';

// ============================================
// COMPONENTS
// Korean Traditional styled components
// ============================================

export 'components/ds_button.dart';
export 'components/ds_toggle.dart';
export 'components/ds_card.dart';
export 'components/ds_list_tile.dart';
export 'components/ds_section_header.dart';
export 'components/ds_text_field.dart';
export 'components/ds_modal.dart';
export 'components/ds_bottom_sheet.dart';
export 'components/ds_chip.dart';
export 'components/ds_badge.dart';
export 'components/ds_loading.dart';
export 'components/ds_toast.dart';
export 'components/hanji_background.dart';

// ============================================
// TRADITIONAL COMPONENTS
// Korean Traditional styled decorative components
// ============================================

export 'components/traditional/cloud_bubble.dart';
export 'components/traditional/cloud_bubble_painter.dart';
export 'components/traditional/traditional_knot_indicator.dart';
