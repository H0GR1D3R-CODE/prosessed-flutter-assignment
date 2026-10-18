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

  @override
  String get loginHeadline => 'Welcome back';

  @override
  String get loginSubhead => 'Sign in to see what\'s new in the store.';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirmTitle => 'Sign out of ShopSphere?';

  @override
  String get signOutConfirmMessage =>
      'Your cart stays on this device for next time.';

  @override
  String get usernameEmpty => 'Enter your username';

  @override
  String usernameTooShort(int min) {
    return 'Username needs at least $min characters';
  }

  @override
  String get passwordEmpty => 'Enter your password';

  @override
  String passwordTooShort(int min) {
    return 'Password needs at least $min characters';
  }

  @override
  String get useDemoAccount => 'Use the demo account';

  @override
  String get demoAccountNote => 'Test login: emilys / emilyspass';

  @override
  String get sessionEndedNotice =>
      'Your session ended. Sign in again to continue.';

  @override
  String get navShop => 'Shop';

  @override
  String get navSaved => 'Saved';

  @override
  String get navCart => 'Cart';

  @override
  String get navProfile => 'Me';

  @override
  String shopGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get themeToggleToDark => 'Switch to dark theme';

  @override
  String get themeToggleToLight => 'Switch to light theme';

  @override
  String get shopSearchHint => 'Search products';

  @override
  String get shopClearSearch => 'Clear search';

  @override
  String shopResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get shopSortLabel => 'Sort';

  @override
  String get sortSheetTitle => 'Sort by';

  @override
  String get sortRelevance => 'Featured';

  @override
  String get sortPriceLow => 'Price: low to high';

  @override
  String get sortPriceHigh => 'Price: high to low';

  @override
  String get sortRating => 'Top rated';

  @override
  String get sortTitle => 'Name: A to Z';

  @override
  String get categoryAll => 'All';

  @override
  String get categoriesFailed => 'Categories didn’t load';

  @override
  String get shopOfflineBanner =>
      'You’re offline. Showing the products from your last visit.';

  @override
  String shopEmptySearchTitle(String query) {
    return 'No matches for “$query”';
  }

  @override
  String get shopEmptySearchMessage =>
      'Try a shorter word, or browse a category.';

  @override
  String get shopEmptyTitle => 'Nothing to show';

  @override
  String get shopEmptyMessage => 'Try another category or sort order.';

  @override
  String get shopLoadMoreFailed => 'Couldn’t load more products';

  @override
  String shopEndOfList(int total) {
    return 'You’ve seen all $total products';
  }

  @override
  String get shopRefreshFailed =>
      'Couldn’t refresh. Showing what you already have.';

  @override
  String wishlistAdd(String title) {
    return 'Save $title';
  }

  @override
  String wishlistRemove(String title) {
    return 'Remove $title from saved';
  }

  @override
  String productReviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
      zero: 'No reviews',
    );
    return '$_temp0';
  }

  @override
  String productYouSave(String amount) {
    return 'You save $amount';
  }

  @override
  String get productAbout => 'About this product';

  @override
  String get productDetails => 'Details';

  @override
  String get specBrand => 'Brand';

  @override
  String get specSku => 'SKU';

  @override
  String get specCategory => 'Category';

  @override
  String get specWeight => 'Weight';

  @override
  String get specWarranty => 'Warranty';

  @override
  String get specShipping => 'Shipping';

  @override
  String get specReturns => 'Returns';

  @override
  String get specMinOrder => 'Minimum order';

  @override
  String get productReviewsTitle => 'Reviews';

  @override
  String get productNoReviews => 'No reviews yet';

  @override
  String get addToCart => 'Add to cart';

  @override
  String addToCartWithPrice(String price) {
    return 'Add to cart · $price';
  }

  @override
  String addedToCart(int quantity, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: 'Added $quantity × $title',
      one: 'Added $title',
    );
    return '$_temp0';
  }

  @override
  String cartLimitReached(int limit, String title) {
    return 'That’s all we have: $limit of $title are in your cart.';
  }

  @override
  String get viewCart => 'View cart';

  @override
  String get back => 'Back';

  @override
  String get cartTitle => 'Your cart';

  @override
  String cartItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyMessage =>
      'Add something you like and it will wait for you here.';

  @override
  String get cartStartShopping => 'Start shopping';

  @override
  String cartRemove(String title) {
    return 'Remove $title';
  }

  @override
  String cartRemoved(String title) {
    return 'Removed $title';
  }

  @override
  String get cartSubtotal => 'Subtotal';

  @override
  String get cartDiscount => 'Discount';

  @override
  String get cartTotal => 'Total';

  @override
  String get cartCheckout => 'Checkout';

  @override
  String get cartSaveFailed => 'Couldn’t save your cart on this device';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutDeliverTo => 'Deliver to';

  @override
  String get checkoutNoAddress => 'No address on file';

  @override
  String get checkoutPayment => 'Payment';

  @override
  String get checkoutPaymentNote =>
      'This is a demo order. Nothing is charged and nothing is shipped.';

  @override
  String get checkoutSummary => 'Order summary';

  @override
  String get checkoutPlaceOrder => 'Place order';

  @override
  String checkoutPlaceOrderWithTotal(String total) {
    return 'Place order · $total';
  }

  @override
  String get checkoutFailed => 'Order not placed';

  @override
  String get orderPlacedTitle => 'Order placed';

  @override
  String orderPlacedMessage(int id) {
    return 'Order #$id is confirmed.';
  }

  @override
  String orderPlacedDetail(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0 · $total';
  }

  @override
  String get orderPlacedDemoNote =>
      'Demo order: DummyJSON confirms it but doesn’t store it.';

  @override
  String get orderContinue => 'Continue shopping';

  @override
  String get savedTitle => 'Saved';

  @override
  String get savedEmptyTitle => 'Nothing saved yet';

  @override
  String get savedEmptyMessage => 'Tap the heart on a product to keep it here.';

  @override
  String get savedBrowse => 'Browse products';

  @override
  String get profileTitle => 'Your profile';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileAddress => 'Address';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get profileLanguage => 'Language';

  @override
  String get languageSystem => 'Device';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get profileDevTools => 'Developer tools';

  @override
  String get profileDevToolsNote => 'Try the error scenarios';

  @override
  String get labTitle => 'Error lab';

  @override
  String get labIntro =>
      'Trigger the failures this app is built to survive. Every button runs a real request.';

  @override
  String get labServerError => 'Server error';

  @override
  String get labServerErrorNote => 'GET /http/500';

  @override
  String get labNotFound => 'Not found';

  @override
  String get labNotFoundNote => 'GET /products/9999';

  @override
  String get labSlow => 'Slow network';

  @override
  String get labSlowNote =>
      'GET /products?delay=3000. The loader stays until the answer arrives.';

  @override
  String get labTimeout => 'Request timeout';

  @override
  String get labTimeoutNote => 'A 5 s delay against a 2 s limit.';

  @override
  String get labExpired => 'Expired access token';

  @override
  String get labExpiredNote =>
      'Spoils the access token, then calls /auth/me. The app refreshes it and retries.';

  @override
  String get labRejectedRefresh => 'Rejected refresh token';

  @override
  String get labRejectedRefreshNote =>
      'Spoils both tokens. The refresh is refused with 403 and you are signed out.';

  @override
  String get labOffline =>
      'No internet: switch on airplane mode, then pull down to refresh on the Shop tab.';

  @override
  String get labRun => 'Run';

  @override
  String get labRunning => 'Running…';

  @override
  String get labRecovered =>
      'Recovered: /auth/me answered after an automatic token refresh.';

  @override
  String labSlowDone(String seconds) {
    return 'The slow response arrived after $seconds s.';
  }

  @override
  String get labHandled =>
      'Handled: the app turned that into a friendly state.';

  @override
  String get labClose => 'Close';

  @override
  String get shopPrompt => 'What are you shopping for?';

  @override
  String get shopSelectTitle => 'Pick a product';

  @override
  String get shopSelectMessage => 'Its photos, price and reviews open here.';

  @override
  String get shopWelcome => 'Welcome';

  @override
  String productGallery(int current, int total) {
    return 'Photo $current of $total';
  }

  @override
  String get errorGoHome => 'Back to the shop';
}
