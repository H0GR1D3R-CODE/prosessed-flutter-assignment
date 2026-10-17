import 'package:flutter/widgets.dart';
import 'package:shopsphere/l10n/generated/app_localizations.dart';

export 'package:shopsphere/l10n/generated/app_localizations.dart';

/// `context.l10n.retry` instead of `AppLocalizations.of(context).retry`.
extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
