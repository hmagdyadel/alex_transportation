import 'package:flutter/widgets.dart';
import 'package:alex_transportation/l10n/app_localizations.dart';

/// Convenient extension on BuildContext to quickly access localized strings:
/// `context.l10n.someKey`
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
