/// App-wide font configuration - Central management
///
/// Neon Dark Theme - GmarketSans Font Family
///
/// Usage:
/// ```dart
/// // Font family reference
/// fontFamily: FontConfig.primary
///
/// // Font size reference
/// fontSize: FontConfig.displayLarge
/// ```
class FontConfig {
  FontConfig._();

  // ═══════════════════════════════════════════════════════
  // FONT FAMILIES - GmarketSans (Neon Dark Theme)
  // ═══════════════════════════════════════════════════════

  /// Primary font family - GmarketSans for bold, modern look
  static const String primary = 'GmarketSans';

  /// Korean font - GmarketSans
  static const String korean = 'GmarketSans';

  /// English font - GmarketSans
  static const String english = 'GmarketSans';

  /// Number font - GmarketSans
  static const String number = 'GmarketSans';

  /// Legacy calligraphy font (kept for specific traditional content)
  static const String calligraphy = 'NanumMyeongjo';

  /// Font family fallback list
  static const List<String> fontFamilyFallback = [
    'GmarketSans',
    'Apple SD Gothic Neo',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
  ];

  // ═══════════════════════════════════════════════════════
  // FONT SIZES
  // ═══════════════════════════════════════════════════════

  // Display Sizes (Large Headlines)
  static const double displayLarge = 36.0;   // Increased from 32
  static const double displayMedium = 32.0;  // Increased from 28
  static const double displaySmall = 28.0;   // Increased from 24

  // Heading Sizes (Section Titles)
  static const double heading1 = 28.0;   // Increased from 24
  static const double heading2 = 24.0;   // Increased from 20
  static const double heading3 = 20.0;   // Increased from 18
  static const double heading4 = 18.0;

  // Body Sizes (Body Text)
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 13.0;

  // Label Sizes (Labels, Captions)
  static const double labelLarge = 14.0;
  static const double labelMedium = 13.0;
  static const double labelSmall = 12.0;
  static const double labelTiny = 11.0;

  // Caption/Badge Sizes (Very Small Text)
  static const double captionLarge = 11.0;
  static const double captionSmall = 10.0;
  static const double badgeText = 9.0;

  // Button Sizes (Button Text)
  static const double buttonLarge = 16.0;
  static const double buttonMedium = 15.0;
  static const double buttonSmall = 14.0;
  static const double buttonTiny = 13.0;

  // Number Sizes (Numbers Only)
  static const double numberXLarge = 36.0;
  static const double numberLarge = 28.0;
  static const double numberMedium = 22.0;
  static const double numberSmall = 18.0;

  // Emoji/Icon Display Sizes
  static const double emojiXLarge = 64.0;
  static const double emojiLarge = 48.0;
  static const double emojiMedium = 40.0;
  static const double emojiSmall = 32.0;

  // Score Display Sizes
  static const double scoreXLarge = 48.0;
  static const double scoreLarge = 36.0;
  static const double scoreMedium = 28.0;

  // ═══════════════════════════════════════════════════════
  // FONT INFO
  // ═══════════════════════════════════════════════════════

  /// Whether using Google Fonts package (false = use local fonts)
  static const bool useGoogleFonts = false;

  /// Google Fonts method name (not used when useGoogleFonts = false)
  static const String googleFontsMethod = 'gmarketSans';
}
