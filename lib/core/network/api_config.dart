/// Static configuration for talking to the DummyJSON API.
abstract final class ApiConfig {
  static const String baseUrl = 'https://dummyjson.com';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Page size for the product list, as the brief specifies.
  static const int pageSize = 20;

  /// How long a session lasts when signing in or refreshing, in minutes.
  static const int tokenLifetimeMinutes = 30;
}

/// Every endpoint the app calls, in one place.
abstract final class Endpoints {
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String refresh = '/auth/refresh';

  static const String products = '/products';
  static const String productSearch = '/products/search';
  static const String categories = '/products/categories';
  static String product(int id) => '/products/$id';
  static String productsInCategory(String slug) => '/products/category/$slug';

  static const String addCart = '/carts/add';

  // Used only by the developer tools to prove the error handling.
  static const String http500 = '/http/500';
  static const String http404 = '/http/404';
}
