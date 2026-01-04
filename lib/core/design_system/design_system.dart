/// Korean Traditional "Saaju" Design System for Fortune App
///
/// Design Philosophy: "Beauty of Emptiness" (여백의 미) meets "Ink on Hanji" (한지 위의 먹)
///
/// A comprehensive design system providing authentic Korean traditional
/// styling across the entire application.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:fortune/core/design_system/design_system.dart';
///
/// // Hanji paper background
/// HanjiBackground(child: Scaffold(...))
///
/// // Access colors via context (Obangsaek palette)
/// Container(color: context.colors.background)  // Hanji paper color
///
/// // Access typography (Korean fonts)
/// Text('운세', style: context.typography.fortuneTitle)  // Gowun Batang
///
/// // Vermilion seal button (인장 스타일)
/// DSButton.primary(text: '운세 보기', onPressed: () {})
///
/// // Hanji paper card with ink-wash effect
/// DSCard.hanji(child: content)
/// ```
///
/// ## File Structure
///
/// ```
/// design_system/
/// ├── design_system.dart    <- You are here (barrel export)
/// ├── tokens/               <- Design tokens
/// │   ├── ds_colors.dart
/// │   ├── ds_spacing.dart
/// │   ├── ds_radius.dart
/// │   ├── ds_shadows.dart
/// │   ├── ds_typography.dart
/// │   └── ds_animation.dart
/// ├── components/           <- UI components
/// │   ├── ds_button.dart
/// │   ├── ds_toggle.dart
/// │   ├── ds_card.dart
/// │   └── ...
/// ├── theme/                <- Theme configuration
/// │   ├── ds_theme.dart
/// │   └── ds_extensions.dart
/// └── utils/                <- Utilities
///     └── ds_haptics.dart
/// ```
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
