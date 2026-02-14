import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Extension to easily access localized strings via context.l10n
extension L10nExtension on BuildContext {
  /// Access AppLocalizations instance
  /// Usage: context.l10n.tokens, context.l10n.confirm, etc.
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    if (localizations != null) {
      return localizations;
    }

    // Fallback for transient contexts where Localizations is not yet attached.
    return lookupAppLocalizations(const Locale('ko'));
  }
}
