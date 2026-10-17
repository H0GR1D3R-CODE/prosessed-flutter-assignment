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
}
