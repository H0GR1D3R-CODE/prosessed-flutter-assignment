import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/auth_interceptor.dart';
import 'package:shopsphere/core/network/dio_factory.dart';
import 'package:shopsphere/core/network/session.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shopsphere/features/auth/data/sign_in_preference_repository_impl.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/sign_in_preference.dart';
import 'package:shopsphere/features/auth/domain/usecases/auth_usecases.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/bloc/login_cubit.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_data_sources.dart';
import 'package:shopsphere/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopsphere/features/cart/domain/usecases/cart_usecases.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/bloc/checkout_cubit.dart';
import 'package:shopsphere/features/dev_tools/data/error_lab_repository_impl.dart';
import 'package:shopsphere/features/dev_tools/domain/error_lab.dart';
import 'package:shopsphere/features/dev_tools/presentation/bloc/error_lab_cubit.dart';
import 'package:shopsphere/features/discover/data/discover_repositories.dart';
import 'package:shopsphere/features/discover/domain/discover.dart';
import 'package:shopsphere/features/discover/presentation/bloc/discover_cubits.dart';
import 'package:shopsphere/features/orders/data/orders_repository_impl.dart';
import 'package:shopsphere/features/orders/domain/orders.dart';
import 'package:shopsphere/features/orders/presentation/bloc/orders_cubit.dart';
import 'package:shopsphere/features/products/data/datasources/product_local_data_source.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/data/repositories/product_repository_impl.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';
import 'package:shopsphere/features/products/domain/usecases/product_usecases.dart';
import 'package:shopsphere/features/products/presentation/bloc/categories_cubit.dart';
import 'package:shopsphere/features/products/presentation/bloc/product_details_cubit.dart';
import 'package:shopsphere/features/products/presentation/bloc/product_list_cubit.dart';
import 'package:shopsphere/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:shopsphere/features/settings/data/settings_repository_impl.dart';
import 'package:shopsphere/features/settings/domain/settings.dart';
import 'package:shopsphere/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:shopsphere/features/wishlist/data/wishlist_repository_impl.dart';
import 'package:shopsphere/features/wishlist/domain/wishlist.dart';
import 'package:shopsphere/features/wishlist/presentation/bloc/wishlist_cubit.dart';

/// The service locator. Widgets and cubits ask it for collaborators; they never construct them.
final GetIt sl = GetIt.instance;

/// Name of the HTTP client that has no auth interceptor (used for the token refresh itself).
const String plainClientName = 'plain';

/// Registers everything the app needs. Tests pass fakes for the storage backends and for the
/// network ([httpAdapter] stands in for the real connection on every client).
Future<void> configureDependencies({
  SharedPreferences? preferences,
  FlutterSecureStorage? secureStorage,
  HttpClientAdapter? httpAdapter,
  bool logRequests = kDebugMode,
}) async {
  await sl.reset();

  // Platform storage.
  sl.registerSingleton<SharedPreferences>(
    preferences ?? await SharedPreferences.getInstance(),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => secureStorage ?? const FlutterSecureStorage(),
  );

  // Network.
  sl.registerLazySingleton<SessionEvents>(
    SessionEvents.new,
    dispose: (events) => events.dispose(),
  );
  Dio newDio() {
    final dio = DioFactory.create();
    if (httpAdapter != null) dio.httpClientAdapter = httpAdapter;
    return dio;
  }

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      newDio()
        ..interceptors.addAll([
          if (logRequests) DebugLogInterceptor(),
          AuthInterceptor(
            store: sl<TokenStore>(),
            refresh: (token) => sl<AuthRemoteDataSource>().refresh(token),
            events: sl<SessionEvents>(),
            replay: newDio(),
          ),
        ]),
    ),
  );
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      newDio()..interceptors.addAll([if (logRequests) DebugLogInterceptor()]),
    ),
    instanceName: plainClientName,
  );

  _registerAuth();
  _registerProducts();
  _registerCart();
  _registerOrders();
  _registerDiscover();
  _registerWishlist();
  _registerSettings();
  _registerProfile();
  _registerDevTools();
}

void _registerAuth() {
  sl
    ..registerLazySingleton<AuthLocalDataSource>(
      () => SecureAuthLocalDataSource(sl<FlutterSecureStorage>()),
    )
    ..registerLazySingleton<TokenStore>(() => sl<AuthLocalDataSource>())
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        client: sl<ApiClient>(),
        plainClient: sl<ApiClient>(instanceName: plainClientName),
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: sl<AuthRemoteDataSource>(),
        local: sl<AuthLocalDataSource>(),
      ),
    )
    ..registerFactory(() => LoginUseCase(sl<AuthRepository>()))
    ..registerFactory(() => LogoutUseCase(sl<AuthRepository>()))
    ..registerFactory(() => GetCurrentUserUseCase(sl<AuthRepository>()))
    ..registerLazySingleton<SignInPreferenceRepository>(
      () => PrefsSignInPreferenceRepository(sl<SharedPreferences>()),
    )
    ..registerFactory(
      () => LoadSignInPreferenceUseCase(sl<SignInPreferenceRepository>()),
    )
    ..registerFactory(
      () => SaveSignInPreferenceUseCase(sl<SignInPreferenceRepository>()),
    )
    ..registerFactory(
      () => RestoreSessionUseCase(
        sl<AuthRepository>(),
        sl<SignInPreferenceRepository>(),
      ),
    )
    ..registerLazySingleton<AuthCubit>(
      () => AuthCubit(
        restoreSession: sl<RestoreSessionUseCase>(),
        getCurrentUser: sl<GetCurrentUserUseCase>(),
        logout: sl<LogoutUseCase>(),
        events: sl<SessionEvents>(),
      ),
    )
    ..registerFactory(
      () => LoginCubit(
        sl<LoginUseCase>(),
        sl<LoadSignInPreferenceUseCase>(),
        sl<SaveSignInPreferenceUseCase>(),
      ),
    );
}

void _registerProducts() {
  sl
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(sl<ApiClient>()),
    )
    ..registerLazySingleton<ProductLocalDataSource>(
      () => PrefsProductLocalDataSource(sl<SharedPreferences>()),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(
        remote: sl<ProductRemoteDataSource>(),
        local: sl<ProductLocalDataSource>(),
      ),
    )
    ..registerFactory(() => GetProductsUseCase(sl<ProductRepository>()))
    ..registerFactory(() => GetCategoriesUseCase(sl<ProductRepository>()))
    ..registerFactory(() => GetProductDetailsUseCase(sl<ProductRepository>()))
    ..registerFactory(
      () => ProductListCubit(getProducts: sl<GetProductsUseCase>()),
    )
    ..registerFactory(() => CategoriesCubit(sl<GetCategoriesUseCase>()))
    ..registerFactoryParam<ProductDetailsCubit, int, void>(
      (productId, _) => ProductDetailsCubit(
        productId: productId,
        getProduct: sl<GetProductDetailsUseCase>(),
      ),
    );
}

void _registerCart() {
  sl
    ..registerLazySingleton<CartLocalDataSource>(
      () => PrefsCartLocalDataSource(sl<SharedPreferences>()),
    )
    ..registerLazySingleton<CartRemoteDataSource>(
      () => CartRemoteDataSourceImpl(sl<ApiClient>()),
    )
    ..registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(
        local: sl<CartLocalDataSource>(),
        remote: sl<CartRemoteDataSource>(),
      ),
    )
    ..registerFactory(() => LoadCartUseCase(sl<CartRepository>()))
    ..registerFactory(() => AddToCartUseCase(sl<CartRepository>()))
    ..registerFactory(() => UpdateCartQuantityUseCase(sl<CartRepository>()))
    ..registerFactory(() => RemoveFromCartUseCase(sl<CartRepository>()))
    ..registerFactory(() => RestoreCartItemUseCase(sl<CartRepository>()))
    ..registerFactory(() => ClearCartUseCase(sl<CartRepository>()))
    ..registerFactory(() => PlaceOrderUseCase(sl<CartRepository>()))
    ..registerFactory(CalculateCartTotalsUseCase.new)
    ..registerLazySingleton<CartCubit>(
      () => CartCubit(
        load: sl<LoadCartUseCase>(),
        add: sl<AddToCartUseCase>(),
        updateQuantity: sl<UpdateCartQuantityUseCase>(),
        remove: sl<RemoveFromCartUseCase>(),
        restore: sl<RestoreCartItemUseCase>(),
        clear: sl<ClearCartUseCase>(),
      ),
    )
    ..registerFactory(
      () => CheckoutCubit(
        placeOrder: sl<PlaceOrderUseCase>(),
        cartCubit: sl<CartCubit>(),
        ordersCubit: sl<OrdersCubit>(),
      ),
    );
}

void _registerOrders() {
  sl
    ..registerLazySingleton<OrdersRepository>(
      () => PrefsOrdersRepository(sl<SharedPreferences>()),
    )
    ..registerFactory(() => LoadOrdersUseCase(sl<OrdersRepository>()))
    ..registerFactory(() => RecordOrderUseCase(sl<OrdersRepository>()))
    ..registerLazySingleton<OrdersCubit>(
      () => OrdersCubit(
        load: sl<LoadOrdersUseCase>(),
        record: sl<RecordOrderUseCase>(),
      ),
    );
}

void _registerDiscover() {
  sl
    ..registerLazySingleton<SearchHistoryRepository>(
      () => PrefsSearchHistoryRepository(sl<SharedPreferences>()),
    )
    ..registerLazySingleton<RecentlyViewedRepository>(
      () => PrefsRecentlyViewedRepository(sl<SharedPreferences>()),
    )
    ..registerFactory(
      () => LoadSearchHistoryUseCase(sl<SearchHistoryRepository>()),
    )
    ..registerFactory(() => RecordSearchUseCase(sl<SearchHistoryRepository>()))
    ..registerFactory(() => ForgetSearchUseCase(sl<SearchHistoryRepository>()))
    ..registerFactory(
      () => LoadRecentlyViewedUseCase(sl<RecentlyViewedRepository>()),
    )
    ..registerFactory(() => RecordViewedUseCase(sl<RecentlyViewedRepository>()))
    ..registerFactory(
      () => ClearRecentlyViewedUseCase(sl<RecentlyViewedRepository>()),
    )
    ..registerLazySingleton<SearchHistoryCubit>(
      () => SearchHistoryCubit(
        load: sl<LoadSearchHistoryUseCase>(),
        record: sl<RecordSearchUseCase>(),
        forget: sl<ForgetSearchUseCase>(),
      ),
    )
    ..registerLazySingleton<RecentlyViewedCubit>(
      () => RecentlyViewedCubit(
        load: sl<LoadRecentlyViewedUseCase>(),
        record: sl<RecordViewedUseCase>(),
        clear: sl<ClearRecentlyViewedUseCase>(),
      ),
    );
}

void _registerWishlist() {
  sl
    ..registerLazySingleton<WishlistRepository>(
      () => WishlistRepositoryImpl(sl<SharedPreferences>()),
    )
    ..registerFactory(() => LoadWishlistUseCase(sl<WishlistRepository>()))
    ..registerFactory(() => ToggleWishlistUseCase(sl<WishlistRepository>()))
    ..registerLazySingleton<WishlistCubit>(
      () => WishlistCubit(
        load: sl<LoadWishlistUseCase>(),
        toggle: sl<ToggleWishlistUseCase>(),
      ),
    );
}

void _registerSettings() {
  sl
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl<SharedPreferences>()),
    )
    ..registerLazySingleton<SettingsCubit>(
      () => SettingsCubit(sl<SettingsRepository>()),
    );
}

void _registerProfile() {
  sl.registerFactoryParam<ProfileCubit, User?, void>(
    (knownUser, _) => ProfileCubit(
      getCurrentUser: sl<GetCurrentUserUseCase>(),
      knownUser: knownUser,
    ),
  );
}

void _registerDevTools() {
  sl
    ..registerLazySingleton<ErrorLabRepository>(
      () => ErrorLabRepositoryImpl(
        client: sl<ApiClient>(),
        tokens: sl<TokenStore>(),
      ),
    )
    ..registerFactory(() => RunLabScenarioUseCase(sl<ErrorLabRepository>()))
    ..registerFactory(() => ErrorLabCubit(sl<RunLabScenarioUseCase>()));
}
