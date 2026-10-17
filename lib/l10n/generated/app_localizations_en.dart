// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ShopSphere';

  @override
  String get retry => 'Try again';

  @override
  String get goBack => 'Go back';

  @override
  String get cancel => 'Cancel';

  @override
  String get undo => 'Undo';

  @override
  String get errorNetworkTitle => 'You\'re offline';

  @override
  String get errorNetworkMessage => 'Check your connection, then try again.';

  @override
  String get errorTimeoutTitle => 'That took too long';

  @override
  String get errorTimeoutMessage =>
      'The store didn\'t answer in time. Try again in a moment.';

  @override
  String get errorServerTitle => 'The store hit a snag';

  @override
  String get errorServerMessage =>
      'Something went wrong on the server. Try again in a moment.';

  @override
  String get errorNotFoundTitle => 'Nothing here';

  @override
  String get errorNotFoundMessage =>
      'We couldn\'t find what you were looking for.';

  @override
  String get errorBadRequestTitle => 'Request not accepted';

  @override
  String get errorBadRequestMessage =>
      'The store couldn\'t process that request.';

  @override
  String get errorSessionTitle => 'Session ended';

  @override
  String get errorSessionMessage => 'Sign in again to keep shopping.';

  @override
  String get errorParseTitle => 'Unexpected response';

  @override
  String get errorParseMessage =>
      'The store sent something the app couldn\'t read.';

  @override
  String get errorCacheTitle => 'Storage problem';

  @override
  String get errorCacheMessage =>
      'The app couldn\'t read or save data on this device.';

  @override
  String get errorUnknownTitle => 'Something went wrong';

  @override
  String get errorUnknownMessage => 'An unexpected error occurred. Try again.';

  @override
  String get invalidCredentials => 'Invalid username or password';

  @override
  String get loading => 'Loading';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get quantity => 'Quantity';

  @override
  String get inStock => 'In stock';

  @override
  String lowStock(int count) {
    return 'Only $count left';
  }

  @override
  String get outOfStock => 'Out of stock';

  @override
  String discountOff(int percent) {
    return '$percent% off';
  }

  @override
  String ratingOutOf(String rating) {
    return 'Rated $rating out of 5';
  }
}
