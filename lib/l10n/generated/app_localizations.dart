import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ShopSphere'**
  String get appName;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @errorNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get errorNetworkTitle;

  /// No description provided for @errorNetworkMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection, then try again.'**
  String get errorNetworkMessage;

  /// No description provided for @errorTimeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'That took too long'**
  String get errorTimeoutTitle;

  /// No description provided for @errorTimeoutMessage.
  ///
  /// In en, this message translates to:
  /// **'The store didn\'t answer in time. Try again in a moment.'**
  String get errorTimeoutMessage;

  /// No description provided for @errorServerTitle.
  ///
  /// In en, this message translates to:
  /// **'The store hit a snag'**
  String get errorServerTitle;

  /// No description provided for @errorServerMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on the server. Try again in a moment.'**
  String get errorServerMessage;

  /// No description provided for @errorNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get errorNotFoundTitle;

  /// No description provided for @errorNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get errorNotFoundMessage;

  /// No description provided for @errorBadRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request not accepted'**
  String get errorBadRequestTitle;

  /// No description provided for @errorBadRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'The store couldn\'t process that request.'**
  String get errorBadRequestMessage;

  /// No description provided for @errorSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session ended'**
  String get errorSessionTitle;

  /// No description provided for @errorSessionMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to keep shopping.'**
  String get errorSessionMessage;

  /// No description provided for @errorParseTitle.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response'**
  String get errorParseTitle;

  /// No description provided for @errorParseMessage.
  ///
  /// In en, this message translates to:
  /// **'The store sent something the app couldn\'t read.'**
  String get errorParseMessage;

  /// No description provided for @errorCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage problem'**
  String get errorCacheTitle;

  /// No description provided for @errorCacheMessage.
  ///
  /// In en, this message translates to:
  /// **'The app couldn\'t read or save data on this device.'**
  String get errorCacheMessage;

  /// No description provided for @errorUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorUnknownTitle;

  /// No description provided for @errorUnknownMessage.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Try again.'**
  String get errorUnknownMessage;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get invalidCredentials;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @decreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decreaseQuantity;

  /// No description provided for @increaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increaseQuantity;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Only {count} left'**
  String lowStock(int count);

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @discountOff.
  ///
  /// In en, this message translates to:
  /// **'{percent}% off'**
  String discountOff(int percent);

  /// No description provided for @ratingOutOf.
  ///
  /// In en, this message translates to:
  /// **'Rated {rating} out of 5'**
  String ratingOutOf(String rating);

  /// No description provided for @loginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginHeadline;

  /// No description provided for @loginSubhead.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see what\'s new in the store.'**
  String get loginSubhead;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of ShopSphere?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Your cart stays on this device for next time.'**
  String get signOutConfirmMessage;

  /// No description provided for @usernameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get usernameEmpty;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username needs at least {min} characters'**
  String usernameTooShort(int min);

  /// No description provided for @passwordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordEmpty;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password needs at least {min} characters'**
  String passwordTooShort(int min);

  /// No description provided for @useDemoAccount.
  ///
  /// In en, this message translates to:
  /// **'Use the demo account'**
  String get useDemoAccount;

  /// No description provided for @demoAccountNote.
  ///
  /// In en, this message translates to:
  /// **'Test login: emilys / emilyspass'**
  String get demoAccountNote;

  /// No description provided for @sessionEndedNotice.
  ///
  /// In en, this message translates to:
  /// **'Your session ended. Sign in again to continue.'**
  String get sessionEndedNotice;

  /// No description provided for @navShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navProfile;

  /// No description provided for @shopGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String shopGreeting(String name);

  /// No description provided for @themeToggleToDark.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get themeToggleToDark;

  /// No description provided for @themeToggleToLight.
  ///
  /// In en, this message translates to:
  /// **'Switch to light theme'**
  String get themeToggleToLight;

  /// No description provided for @shopSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get shopSearchHint;

  /// No description provided for @shopClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get shopClearSearch;

  /// No description provided for @shopResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 product} other{{count} products}}'**
  String shopResultsCount(int count);

  /// No description provided for @shopSortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get shopSortLabel;

  /// No description provided for @sortSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortSheetTitle;

  /// No description provided for @sortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get sortRelevance;

  /// No description provided for @sortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get sortPriceHigh;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get sortRating;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Name: A to Z'**
  String get sortTitle;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoriesFailed.
  ///
  /// In en, this message translates to:
  /// **'Categories didn’t load'**
  String get categoriesFailed;

  /// No description provided for @shopOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'You’re offline. Showing the products from your last visit.'**
  String get shopOfflineBanner;

  /// No description provided for @shopEmptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches for “{query}”'**
  String shopEmptySearchTitle(String query);

  /// No description provided for @shopEmptySearchMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a shorter word, or browse a category.'**
  String get shopEmptySearchMessage;

  /// No description provided for @shopEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show'**
  String get shopEmptyTitle;

  /// No description provided for @shopEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another category or sort order.'**
  String get shopEmptyMessage;

  /// No description provided for @shopLoadMoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load more products'**
  String get shopLoadMoreFailed;

  /// No description provided for @shopEndOfList.
  ///
  /// In en, this message translates to:
  /// **'You’ve seen all {total} products'**
  String shopEndOfList(int total);

  /// No description provided for @shopRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t refresh. Showing what you already have.'**
  String get shopRefreshFailed;

  /// No description provided for @wishlistAdd.
  ///
  /// In en, this message translates to:
  /// **'Save {title}'**
  String wishlistAdd(String title);

  /// No description provided for @wishlistRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from saved'**
  String wishlistRemove(String title);

  /// No description provided for @productReviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reviews} =1{1 review} other{{count} reviews}}'**
  String productReviewsCount(int count);

  /// No description provided for @productYouSave.
  ///
  /// In en, this message translates to:
  /// **'You save {amount}'**
  String productYouSave(String amount);

  /// No description provided for @productAbout.
  ///
  /// In en, this message translates to:
  /// **'About this product'**
  String get productAbout;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get productDetails;

  /// No description provided for @specBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get specBrand;

  /// No description provided for @specSku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get specSku;

  /// No description provided for @specCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get specCategory;

  /// No description provided for @specWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get specWeight;

  /// No description provided for @specWarranty.
  ///
  /// In en, this message translates to:
  /// **'Warranty'**
  String get specWarranty;

  /// No description provided for @specShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get specShipping;

  /// No description provided for @specReturns.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get specReturns;

  /// No description provided for @specMinOrder.
  ///
  /// In en, this message translates to:
  /// **'Minimum order'**
  String get specMinOrder;

  /// No description provided for @productReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get productReviewsTitle;

  /// No description provided for @productNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get productNoReviews;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @addToCartWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Add to cart · {price}'**
  String addToCartWithPrice(String price);

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'{quantity, plural, =1{Added {title}} other{Added {quantity} × {title}}}'**
  String addedToCart(int quantity, String title);

  /// No description provided for @cartLimitReached.
  ///
  /// In en, this message translates to:
  /// **'That’s all we have: {limit} of {title} are in your cart.'**
  String cartLimitReached(int limit, String title);

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewCart;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart'**
  String get cartTitle;

  /// No description provided for @cartItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String cartItemCount(int count);

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add something you like and it will wait for you here.'**
  String get cartEmptyMessage;

  /// No description provided for @cartStartShopping.
  ///
  /// In en, this message translates to:
  /// **'Start shopping'**
  String get cartStartShopping;

  /// No description provided for @cartRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {title}'**
  String cartRemove(String title);

  /// No description provided for @cartRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed {title}'**
  String cartRemoved(String title);

  /// No description provided for @cartSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartSubtotal;

  /// No description provided for @cartDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get cartDiscount;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartTotal;

  /// No description provided for @cartCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get cartCheckout;

  /// No description provided for @cartSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save your cart on this device'**
  String get cartSaveFailed;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutDeliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get checkoutDeliverTo;

  /// No description provided for @checkoutNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No address on file'**
  String get checkoutNoAddress;

  /// No description provided for @checkoutPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get checkoutPayment;

  /// No description provided for @checkoutPaymentNote.
  ///
  /// In en, this message translates to:
  /// **'This is a demo order. Nothing is charged and nothing is shipped.'**
  String get checkoutPaymentNote;

  /// No description provided for @checkoutSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get checkoutSummary;

  /// No description provided for @checkoutPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get checkoutPlaceOrder;

  /// No description provided for @checkoutPlaceOrderWithTotal.
  ///
  /// In en, this message translates to:
  /// **'Place order · {total}'**
  String checkoutPlaceOrderWithTotal(String total);

  /// No description provided for @checkoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Order not placed'**
  String get checkoutFailed;

  /// No description provided for @orderPlacedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get orderPlacedTitle;

  /// No description provided for @orderPlacedMessage.
  ///
  /// In en, this message translates to:
  /// **'Order #{id} is confirmed.'**
  String orderPlacedMessage(int id);

  /// No description provided for @orderPlacedDetail.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}} · {total}'**
  String orderPlacedDetail(int count, String total);

  /// No description provided for @orderPlacedDemoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo order: DummyJSON confirms it but doesn’t store it.'**
  String get orderPlacedDemoNote;

  /// No description provided for @orderContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue shopping'**
  String get orderContinue;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTitle;

  /// No description provided for @savedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get savedEmptyTitle;

  /// No description provided for @savedEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a product to keep it here.'**
  String get savedEmptyMessage;

  /// No description provided for @savedBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse products'**
  String get savedBrowse;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get profileTitle;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profileAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profileAddress;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// No description provided for @profileDevTools.
  ///
  /// In en, this message translates to:
  /// **'Developer tools'**
  String get profileDevTools;

  /// No description provided for @profileDevToolsNote.
  ///
  /// In en, this message translates to:
  /// **'Try the error scenarios'**
  String get profileDevToolsNote;

  /// No description provided for @labTitle.
  ///
  /// In en, this message translates to:
  /// **'Error lab'**
  String get labTitle;

  /// No description provided for @labIntro.
  ///
  /// In en, this message translates to:
  /// **'Trigger the failures this app is built to survive. Every button runs a real request.'**
  String get labIntro;

  /// No description provided for @labServerError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get labServerError;

  /// No description provided for @labServerErrorNote.
  ///
  /// In en, this message translates to:
  /// **'GET /http/500'**
  String get labServerErrorNote;

  /// No description provided for @labNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get labNotFound;

  /// No description provided for @labNotFoundNote.
  ///
  /// In en, this message translates to:
  /// **'GET /products/9999'**
  String get labNotFoundNote;

  /// No description provided for @labSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow network'**
  String get labSlow;

  /// No description provided for @labSlowNote.
  ///
  /// In en, this message translates to:
  /// **'GET /products?delay=3000. The loader stays until the answer arrives.'**
  String get labSlowNote;

  /// No description provided for @labTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timeout'**
  String get labTimeout;

  /// No description provided for @labTimeoutNote.
  ///
  /// In en, this message translates to:
  /// **'A 5 s delay against a 2 s limit.'**
  String get labTimeoutNote;

  /// No description provided for @labExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired access token'**
  String get labExpired;

  /// No description provided for @labExpiredNote.
  ///
  /// In en, this message translates to:
  /// **'Spoils the access token, then calls /auth/me. The app refreshes it and retries.'**
  String get labExpiredNote;

  /// No description provided for @labRejectedRefresh.
  ///
  /// In en, this message translates to:
  /// **'Rejected refresh token'**
  String get labRejectedRefresh;

  /// No description provided for @labRejectedRefreshNote.
  ///
  /// In en, this message translates to:
  /// **'Spoils both tokens. The refresh is refused with 403 and you are signed out.'**
  String get labRejectedRefreshNote;

  /// No description provided for @labOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet: switch on airplane mode, then pull down to refresh on the Shop tab.'**
  String get labOffline;

  /// No description provided for @labRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get labRun;

  /// No description provided for @labRunning.
  ///
  /// In en, this message translates to:
  /// **'Running…'**
  String get labRunning;

  /// No description provided for @labRecovered.
  ///
  /// In en, this message translates to:
  /// **'Recovered: /auth/me answered after an automatic token refresh.'**
  String get labRecovered;

  /// No description provided for @labSlowDone.
  ///
  /// In en, this message translates to:
  /// **'The slow response arrived after {seconds} s.'**
  String labSlowDone(String seconds);

  /// No description provided for @labHandled.
  ///
  /// In en, this message translates to:
  /// **'Handled: the app turned that into a friendly state.'**
  String get labHandled;

  /// No description provided for @labClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get labClose;

  /// No description provided for @shopPrompt.
  ///
  /// In en, this message translates to:
  /// **'What are you shopping for?'**
  String get shopPrompt;

  /// No description provided for @shopSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a product'**
  String get shopSelectTitle;

  /// No description provided for @shopSelectMessage.
  ///
  /// In en, this message translates to:
  /// **'Its photos, price and reviews open here.'**
  String get shopSelectMessage;

  /// No description provided for @photoReload.
  ///
  /// In en, this message translates to:
  /// **'Tap to reload this photo'**
  String get photoReload;

  /// No description provided for @panelHide.
  ///
  /// In en, this message translates to:
  /// **'Hide the details panel'**
  String get panelHide;

  /// No description provided for @panelShow.
  ///
  /// In en, this message translates to:
  /// **'Show the details panel'**
  String get panelShow;

  /// No description provided for @panelResize.
  ///
  /// In en, this message translates to:
  /// **'Drag to resize the panel'**
  String get panelResize;

  /// No description provided for @summaryHide.
  ///
  /// In en, this message translates to:
  /// **'Hide the order summary'**
  String get summaryHide;

  /// No description provided for @summaryShow.
  ///
  /// In en, this message translates to:
  /// **'Show the order summary'**
  String get summaryShow;

  /// No description provided for @brandHome.
  ///
  /// In en, this message translates to:
  /// **'ShopSphere home'**
  String get brandHome;

  /// No description provided for @shopWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get shopWelcome;

  /// No description provided for @productGallery.
  ///
  /// In en, this message translates to:
  /// **'Photo {current} of {total}'**
  String productGallery(int current, int total);

  /// No description provided for @errorGoHome.
  ///
  /// In en, this message translates to:
  /// **'Back to the shop'**
  String get errorGoHome;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Your orders'**
  String get ordersTitle;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Orders you place will be listed here.'**
  String get ordersEmptyMessage;

  /// No description provided for @ordersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 order} other{{count} orders}}'**
  String ordersCount(int count);

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderNumber(int id);

  /// No description provided for @orderPlacedOn.
  ///
  /// In en, this message translates to:
  /// **'Placed {date}'**
  String orderPlacedOn(String date);

  /// No description provided for @orderShowItems.
  ///
  /// In en, this message translates to:
  /// **'Show items'**
  String get orderShowItems;

  /// No description provided for @orderHideItems.
  ///
  /// In en, this message translates to:
  /// **'Hide items'**
  String get orderHideItems;

  /// No description provided for @profileOrders.
  ///
  /// In en, this message translates to:
  /// **'Your orders'**
  String get profileOrders;

  /// No description provided for @profileOrdersNote.
  ///
  /// In en, this message translates to:
  /// **'See what you have ordered'**
  String get profileOrdersNote;

  /// No description provided for @orderViewOrders.
  ///
  /// In en, this message translates to:
  /// **'View my orders'**
  String get orderViewOrders;

  /// No description provided for @searchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecent;

  /// No description provided for @searchClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get searchClearAll;

  /// No description provided for @searchForget.
  ///
  /// In en, this message translates to:
  /// **'Remove {term} from recent searches'**
  String searchForget(String term);

  /// No description provided for @searchCategorySuggestion.
  ///
  /// In en, this message translates to:
  /// **'In {category}'**
  String searchCategorySuggestion(String category);

  /// No description provided for @viewedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recently viewed'**
  String get viewedTitle;

  /// No description provided for @viewedClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get viewedClear;

  /// No description provided for @searchShortcutHint.
  ///
  /// In en, this message translates to:
  /// **'Press / to search'**
  String get searchShortcutHint;

  /// No description provided for @searchFor.
  ///
  /// In en, this message translates to:
  /// **'Search for “{query}”'**
  String searchFor(String query);

  /// No description provided for @themeHintSystemLight.
  ///
  /// In en, this message translates to:
  /// **'Follows your device. It is light right now.'**
  String get themeHintSystemLight;

  /// No description provided for @themeHintSystemDark.
  ///
  /// In en, this message translates to:
  /// **'Follows your device. It is dark right now.'**
  String get themeHintSystemDark;

  /// No description provided for @themeHintLight.
  ///
  /// In en, this message translates to:
  /// **'Always light, whatever your device does.'**
  String get themeHintLight;

  /// No description provided for @themeHintDark.
  ///
  /// In en, this message translates to:
  /// **'Always dark, whatever your device does.'**
  String get themeHintDark;

  /// No description provided for @languageHintSystem.
  ///
  /// In en, this message translates to:
  /// **'Follows your device language.'**
  String get languageHintSystem;

  /// No description provided for @languageHintEnglish.
  ///
  /// In en, this message translates to:
  /// **'Always English.'**
  String get languageHintEnglish;

  /// No description provided for @languageHintHindi.
  ///
  /// In en, this message translates to:
  /// **'Always Hindi.'**
  String get languageHintHindi;

  /// No description provided for @homeDealTag.
  ///
  /// In en, this message translates to:
  /// **'Deal of the day'**
  String get homeDealTag;

  /// No description provided for @homeDealCta.
  ///
  /// In en, this message translates to:
  /// **'Shop now'**
  String get homeDealCta;

  /// No description provided for @homeCouponTag.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get homeCouponTag;

  /// No description provided for @homeCouponTitle.
  ///
  /// In en, this message translates to:
  /// **'10% off your first order'**
  String get homeCouponTitle;

  /// No description provided for @homeCouponBody.
  ///
  /// In en, this message translates to:
  /// **'Use code {code} at checkout.'**
  String homeCouponBody(String code);

  /// No description provided for @homeCouponCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get homeCouponCopy;

  /// No description provided for @homeCouponCopied.
  ///
  /// In en, this message translates to:
  /// **'Code {code} copied'**
  String homeCouponCopied(String code);

  /// No description provided for @homeGiveTag.
  ///
  /// In en, this message translates to:
  /// **'Feel good'**
  String get homeGiveTag;

  /// No description provided for @homeGiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Round up for good'**
  String get homeGiveTitle;

  /// No description provided for @homeGiveBody.
  ///
  /// In en, this message translates to:
  /// **'Donate the change from your order when you check out.'**
  String get homeGiveBody;

  /// No description provided for @homeSlideLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer {page} of {count}'**
  String homeSlideLabel(int page, int count);

  /// No description provided for @shelfDealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deals worth grabbing'**
  String get shelfDealsTitle;

  /// No description provided for @shelfDealsNote.
  ///
  /// In en, this message translates to:
  /// **'Biggest discounts first'**
  String get shelfDealsNote;

  /// No description provided for @shelfTopTitle.
  ///
  /// In en, this message translates to:
  /// **'Loved by shoppers'**
  String get shelfTopTitle;

  /// No description provided for @shelfTopNote.
  ///
  /// In en, this message translates to:
  /// **'Rated 4.0 and above'**
  String get shelfTopNote;

  /// No description provided for @shelfAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything in orbit'**
  String get shelfAllTitle;

  /// No description provided for @couponTitle.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get couponTitle;

  /// No description provided for @couponHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a code'**
  String get couponHint;

  /// No description provided for @couponApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get couponApply;

  /// No description provided for @couponApplied.
  ///
  /// In en, this message translates to:
  /// **'{code} applied'**
  String couponApplied(String code);

  /// No description provided for @couponRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove code'**
  String get couponRemove;

  /// No description provided for @couponUnknown.
  ///
  /// In en, this message translates to:
  /// **'That code isn\'t valid. Try one below.'**
  String get couponUnknown;

  /// No description provided for @couponTooSmall.
  ///
  /// In en, this message translates to:
  /// **'{code} needs {amount} more in your cart.'**
  String couponTooSmall(String code, String amount);

  /// No description provided for @couponAvailable.
  ///
  /// In en, this message translates to:
  /// **'Codes you can use'**
  String get couponAvailable;

  /// No description provided for @couponWelcomeNote.
  ///
  /// In en, this message translates to:
  /// **'10% off everything'**
  String get couponWelcomeNote;

  /// No description provided for @couponSave5Note.
  ///
  /// In en, this message translates to:
  /// **'\$5 off orders over \$25'**
  String get couponSave5Note;

  /// No description provided for @couponOrbit20Note.
  ///
  /// In en, this message translates to:
  /// **'20% off orders over \$100, up to \$40'**
  String get couponOrbit20Note;

  /// No description provided for @couponLine.
  ///
  /// In en, this message translates to:
  /// **'Code {code}'**
  String couponLine(String code);

  /// No description provided for @giveTitle.
  ///
  /// In en, this message translates to:
  /// **'Give a little'**
  String get giveTitle;

  /// No description provided for @giveBody.
  ///
  /// In en, this message translates to:
  /// **'Add a donation to the Orbit Trees fund. This is a demo: nothing is really charged or donated.'**
  String get giveBody;

  /// No description provided for @giveNone.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get giveNone;

  /// No description provided for @giveRoundUp.
  ///
  /// In en, this message translates to:
  /// **'Round up +{amount}'**
  String giveRoundUp(String amount);

  /// No description provided for @giveLine.
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get giveLine;

  /// No description provided for @giveThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for giving {amount}.'**
  String giveThanks(String amount);

  /// No description provided for @loginRemember.
  ///
  /// In en, this message translates to:
  /// **'Keep me signed in'**
  String get loginRemember;

  /// No description provided for @loginRememberNote.
  ///
  /// In en, this message translates to:
  /// **'Stay signed in on this device. Untick it on a shared one.'**
  String get loginRememberNote;

  /// No description provided for @loginSecureNote.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in is kept in your device\'s secure storage.'**
  String get loginSecureNote;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Everything, in orbit.'**
  String get splashTagline;

  /// No description provided for @splashStatus.
  ///
  /// In en, this message translates to:
  /// **'Warming up the shop'**
  String get splashStatus;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
