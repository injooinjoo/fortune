import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Extension to easily access localized strings via context.l10n
extension L10nExtension on BuildContext {
  /// Access AppLocalizations instance
  /// Usage: context.l10n.tokens, context.l10n.confirm, etc.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
