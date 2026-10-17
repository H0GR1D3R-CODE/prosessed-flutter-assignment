// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'ShopSphere';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get goBack => 'वापस जाएँ';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get undo => 'पूर्ववत करें';

  @override
  String get errorNetworkTitle => 'आप ऑफ़लाइन हैं';

  @override
  String get errorNetworkMessage =>
      'अपना कनेक्शन जाँचें, फिर दोबारा कोशिश करें।';

  @override
  String get errorTimeoutTitle => 'इसमें बहुत समय लग गया';

  @override
  String get errorTimeoutMessage =>
      'स्टोर ने समय पर जवाब नहीं दिया। थोड़ी देर बाद फिर कोशिश करें।';

  @override
  String get errorServerTitle => 'स्टोर में कुछ गड़बड़ हो गई';

  @override
  String get errorServerMessage =>
      'सर्वर पर कुछ गलत हो गया। थोड़ी देर बाद फिर कोशिश करें।';

  @override
  String get errorNotFoundTitle => 'यहाँ कुछ नहीं मिला';

  @override
  String get errorNotFoundMessage => 'आप जो खोज रहे थे, वह हमें नहीं मिला।';

  @override
  String get errorBadRequestTitle => 'अनुरोध स्वीकार नहीं हुआ';

  @override
  String get errorBadRequestMessage => 'स्टोर उस अनुरोध को पूरा नहीं कर सका।';

  @override
  String get errorSessionTitle => 'सत्र समाप्त हो गया';

  @override
  String get errorSessionMessage =>
      'खरीदारी जारी रखने के लिए दोबारा साइन इन करें।';

  @override
  String get errorParseTitle => 'अप्रत्याशित जवाब';

  @override
  String get errorParseMessage => 'स्टोर ने ऐसा कुछ भेजा जिसे ऐप पढ़ नहीं सका।';

  @override
  String get errorCacheTitle => 'स्टोरेज की समस्या';

  @override
  String get errorCacheMessage => 'ऐप इस डिवाइस पर डेटा पढ़ या सहेज नहीं सका।';

  @override
  String get errorUnknownTitle => 'कुछ गलत हो गया';

  @override
  String get errorUnknownMessage =>
      'एक अनपेक्षित त्रुटि हुई। फिर से कोशिश करें।';

  @override
  String get invalidCredentials => 'उपयोगकर्ता नाम या पासवर्ड गलत है';

  @override
  String get loading => 'लोड हो रहा है';

  @override
  String get decreaseQuantity => 'मात्रा घटाएँ';

  @override
  String get increaseQuantity => 'मात्रा बढ़ाएँ';

  @override
  String get quantity => 'मात्रा';

  @override
  String get inStock => 'स्टॉक में है';

  @override
  String lowStock(int count) {
    return 'सिर्फ़ $count बचे हैं';
  }

  @override
  String get outOfStock => 'स्टॉक में नहीं है';

  @override
  String discountOff(int percent) {
    return '$percent% की छूट';
  }

  @override
  String ratingOutOf(String rating) {
    return '5 में से $rating रेटिंग';
  }

  @override
  String get loginHeadline => 'वापसी पर स्वागत है';

  @override
  String get loginSubhead =>
      'स्टोर में नया क्या है, यह देखने के लिए साइन इन करें।';

  @override
  String get usernameLabel => 'उपयोगकर्ता नाम';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get showPassword => 'पासवर्ड दिखाएँ';

  @override
  String get hidePassword => 'पासवर्ड छिपाएँ';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get signOut => 'साइन आउट करें';

  @override
  String get signOutConfirmTitle => 'ShopSphere से साइन आउट करें?';

  @override
  String get signOutConfirmMessage =>
      'आपकी कार्ट अगली बार के लिए इस डिवाइस पर बनी रहेगी।';

  @override
  String get usernameEmpty => 'अपना उपयोगकर्ता नाम दर्ज करें';

  @override
  String usernameTooShort(int min) {
    return 'उपयोगकर्ता नाम में कम से कम $min अक्षर होने चाहिए';
  }

  @override
  String get passwordEmpty => 'अपना पासवर्ड दर्ज करें';

  @override
  String passwordTooShort(int min) {
    return 'पासवर्ड में कम से कम $min अक्षर होने चाहिए';
  }

  @override
  String get useDemoAccount => 'डेमो खाता इस्तेमाल करें';

  @override
  String get demoAccountNote => 'टेस्ट लॉगिन: emilys / emilyspass';

  @override
  String get sessionEndedNotice =>
      'आपका सत्र समाप्त हो गया। जारी रखने के लिए दोबारा साइन इन करें।';

  @override
  String get navShop => 'शॉप';

  @override
  String get navSaved => 'सेव किए';

  @override
  String get navCart => 'कार्ट';

  @override
  String get navProfile => 'मैं';

  @override
  String shopGreeting(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get themeToggleToDark => 'डार्क थीम पर जाएँ';

  @override
  String get themeToggleToLight => 'लाइट थीम पर जाएँ';

  @override
  String get shopSearchHint => 'उत्पाद खोजें';

  @override
  String get shopClearSearch => 'खोज हटाएँ';

  @override
  String shopResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count उत्पाद',
      one: '1 उत्पाद',
    );
    return '$_temp0';
  }

  @override
  String get shopSortLabel => 'क्रम';

  @override
  String get sortSheetTitle => 'इसके अनुसार क्रमबद्ध करें';

  @override
  String get sortRelevance => 'चुनिंदा';

  @override
  String get sortPriceLow => 'कीमत: कम से ज़्यादा';

  @override
  String get sortPriceHigh => 'कीमत: ज़्यादा से कम';

  @override
  String get sortRating => 'सबसे ऊँची रेटिंग';

  @override
  String get sortTitle => 'नाम: अ से ज़';

  @override
  String get categoryAll => 'सभी';

  @override
  String get categoriesFailed => 'श्रेणियाँ लोड नहीं हुईं';

  @override
  String get shopOfflineBanner =>
      'आप ऑफ़लाइन हैं। पिछली बार के उत्पाद दिखाए जा रहे हैं।';

  @override
  String shopEmptySearchTitle(String query) {
    return '“$query” के लिए कुछ नहीं मिला';
  }

  @override
  String get shopEmptySearchMessage =>
      'छोटा शब्द आज़माएँ, या कोई श्रेणी देखें।';

  @override
  String get shopEmptyTitle => 'दिखाने के लिए कुछ नहीं';

  @override
  String get shopEmptyMessage => 'कोई दूसरी श्रेणी या क्रम आज़माएँ।';

  @override
  String get shopLoadMoreFailed => 'और उत्पाद लोड नहीं हो सके';

  @override
  String shopEndOfList(int total) {
    return 'आपने सभी $total उत्पाद देख लिए';
  }

  @override
  String get shopRefreshFailed =>
      'रीफ़्रेश नहीं हो सका। जो आपके पास है वही दिखाया जा रहा है।';

  @override
  String wishlistAdd(String title) {
    return '$title सेव करें';
  }

  @override
  String wishlistRemove(String title) {
    return '$title को सेव किए हुए से हटाएँ';
  }

  @override
  String productReviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count समीक्षाएँ',
      one: '1 समीक्षा',
      zero: 'कोई समीक्षा नहीं',
    );
    return '$_temp0';
  }

  @override
  String productYouSave(String amount) {
    return 'आप $amount बचाते हैं';
  }

  @override
  String get productAbout => 'इस उत्पाद के बारे में';

  @override
  String get productDetails => 'विवरण';

  @override
  String get specBrand => 'ब्रांड';

  @override
  String get specSku => 'SKU';

  @override
  String get specCategory => 'श्रेणी';

  @override
  String get specWeight => 'वज़न';

  @override
  String get specWarranty => 'वारंटी';

  @override
  String get specShipping => 'शिपिंग';

  @override
  String get specReturns => 'वापसी';

  @override
  String get specMinOrder => 'न्यूनतम ऑर्डर';

  @override
  String get productReviewsTitle => 'समीक्षाएँ';

  @override
  String get productNoReviews => 'अभी कोई समीक्षा नहीं';

  @override
  String get addToCart => 'कार्ट में जोड़ें';

  @override
  String addToCartWithPrice(String price) {
    return 'कार्ट में जोड़ें · $price';
  }

  @override
  String addedToCart(int quantity, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      quantity,
      locale: localeName,
      other: '$quantity × $title जोड़े गए',
      one: '$title जोड़ा गया',
    );
    return '$_temp0';
  }

  @override
  String cartLimitReached(int limit, String title) {
    return 'बस इतना ही स्टॉक है: आपकी कार्ट में $title की $limit इकाइयाँ हैं।';
  }

  @override
  String get viewCart => 'कार्ट देखें';

  @override
  String get back => 'वापस';

  @override
  String get cartTitle => 'आपकी कार्ट';

  @override
  String cartItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम',
      one: '1 आइटम',
    );
    return '$_temp0';
  }

  @override
  String get cartEmptyTitle => 'आपकी कार्ट खाली है';

  @override
  String get cartEmptyMessage =>
      'जो पसंद आए उसे जोड़ें, वह यहाँ आपका इंतज़ार करेगा।';

  @override
  String get cartStartShopping => 'खरीदारी शुरू करें';

  @override
  String cartRemove(String title) {
    return '$title हटाएँ';
  }

  @override
  String cartRemoved(String title) {
    return '$title हटाया गया';
  }

  @override
  String get cartSubtotal => 'उप-योग';

  @override
  String get cartDiscount => 'छूट';

  @override
  String get cartTotal => 'कुल';

  @override
  String get cartCheckout => 'चेकआउट';

  @override
  String get cartSaveFailed => 'आपकी कार्ट इस डिवाइस पर सहेजी नहीं जा सकी';

  @override
  String get checkoutTitle => 'चेकआउट';

  @override
  String get checkoutDeliverTo => 'डिलीवरी का पता';

  @override
  String get checkoutNoAddress => 'कोई पता दर्ज नहीं है';

  @override
  String get checkoutPayment => 'भुगतान';

  @override
  String get checkoutPaymentNote =>
      'यह एक डेमो ऑर्डर है। कोई शुल्क नहीं लिया जाएगा और कुछ भेजा नहीं जाएगा।';

  @override
  String get checkoutSummary => 'ऑर्डर का सारांश';

  @override
  String get checkoutPlaceOrder => 'ऑर्डर दें';

  @override
  String checkoutPlaceOrderWithTotal(String total) {
    return 'ऑर्डर दें · $total';
  }

  @override
  String get checkoutFailed => 'ऑर्डर नहीं दिया जा सका';

  @override
  String get orderPlacedTitle => 'ऑर्डर हो गया';

  @override
  String orderPlacedMessage(int id) {
    return 'ऑर्डर #$id की पुष्टि हो गई।';
  }

  @override
  String orderPlacedDetail(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम',
      one: '1 आइटम',
    );
    return '$_temp0 · $total';
  }

  @override
  String get orderPlacedDemoNote =>
      'डेमो ऑर्डर: DummyJSON इसकी पुष्टि करता है पर इसे सहेजता नहीं।';

  @override
  String get orderContinue => 'खरीदारी जारी रखें';

  @override
  String get savedTitle => 'सेव किए हुए';

  @override
  String get savedEmptyTitle => 'अभी कुछ सेव नहीं किया';

  @override
  String get savedEmptyMessage =>
      'किसी उत्पाद पर दिल का निशान दबाएँ, वह यहाँ रखा रहेगा।';

  @override
  String get savedBrowse => 'उत्पाद देखें';

  @override
  String get profileTitle => 'आपकी प्रोफ़ाइल';

  @override
  String get profileEmail => 'ईमेल';

  @override
  String get profilePhone => 'फ़ोन';

  @override
  String get profileAddress => 'पता';

  @override
  String get profileAppearance => 'दिखावट';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get languageSystem => 'डिवाइस';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get profileDevTools => 'डेवलपर टूल्स';

  @override
  String get profileDevToolsNote => 'त्रुटि के हालात आज़माएँ';

  @override
  String get labTitle => 'एरर लैब';

  @override
  String get labIntro =>
      'वे विफलताएँ आज़माएँ जिन्हें झेलने के लिए यह ऐप बना है। हर बटन असली अनुरोध चलाता है।';

  @override
  String get labServerError => 'सर्वर त्रुटि';

  @override
  String get labServerErrorNote => 'GET /http/500';

  @override
  String get labNotFound => 'नहीं मिला';

  @override
  String get labNotFoundNote => 'GET /products/9999';

  @override
  String get labSlow => 'धीमा नेटवर्क';

  @override
  String get labSlowNote =>
      'GET /products?delay=3000। जवाब आने तक लोडर दिखता रहता है।';

  @override
  String get labTimeout => 'अनुरोध टाइमआउट';

  @override
  String get labTimeoutNote => '2 सेकंड की सीमा के सामने 5 सेकंड की देरी।';

  @override
  String get labExpired => 'एक्सपायर्ड एक्सेस टोकन';

  @override
  String get labExpiredNote =>
      'एक्सेस टोकन बिगाड़ता है, फिर /auth/me को कॉल करता है। ऐप उसे रीफ़्रेश करके दोबारा कोशिश करता है।';

  @override
  String get labRejectedRefresh => 'अस्वीकृत रीफ़्रेश टोकन';

  @override
  String get labRejectedRefreshNote =>
      'दोनों टोकन बिगाड़ता है। रीफ़्रेश 403 से अस्वीकार होता है और आप साइन आउट हो जाते हैं।';

  @override
  String get labOffline =>
      'इंटरनेट नहीं: एयरप्लेन मोड चालू करें, फिर शॉप टैब पर नीचे खींचकर रीफ़्रेश करें।';

  @override
  String get labRun => 'चलाएँ';

  @override
  String get labRunning => 'चल रहा है…';

  @override
  String get labRecovered =>
      'ठीक हो गया: ऑटोमैटिक टोकन रीफ़्रेश के बाद /auth/me ने जवाब दिया।';

  @override
  String labSlowDone(String seconds) {
    return 'धीमा जवाब $seconds सेकंड बाद आया।';
  }

  @override
  String get labHandled => 'संभाल लिया: ऐप ने इसे एक सरल स्थिति में बदल दिया।';

  @override
  String get labClose => 'बंद करें';

  @override
  String get shopPrompt => 'आज आप क्या खरीद रहे हैं?';

  @override
  String get shopWelcome => 'स्वागत है';

  @override
  String productGallery(int current, int total) {
    return '$total में से फ़ोटो $current';
  }

  @override
  String get errorGoHome => 'शॉप पर लौटें';
}
