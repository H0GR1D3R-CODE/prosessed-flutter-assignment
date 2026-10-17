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
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/auth_usecases.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/bloc/login_cubit.dart';

/// The service locator. Widgets and cubits ask it for collaborators; they never construct them.
final GetIt sl = GetIt.instance;

/// Name of the HTTP client that has no auth interceptor (used for the token refresh itself).
const String plainClientName = 'plain';

/// Registers everything the app needs. Tests pass fakes for the storage backends.
Future<void> configureDependencies({
  SharedPreferences? preferences,
  FlutterSecureStorage? secureStorage,
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
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      DioFactory.create()
        ..interceptors.addAll([
          if (logRequests) DebugLogInterceptor(),
          AuthInterceptor(
            store: sl<TokenStore>(),
            refresh: (token) => sl<AuthRemoteDataSource>().refresh(token),
            events: sl<SessionEvents>(),
            replay: DioFactory.create(),
          ),
        ]),
    ),
  );
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      DioFactory.create()
        ..interceptors.addAll([if (logRequests) DebugLogInterceptor()]),
    ),
    instanceName: plainClientName,
  );

  _registerAuth();
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
    ..registerFactory(() => RestoreSessionUseCase(sl<AuthRepository>()))
    ..registerLazySingleton<AuthCubit>(
      () => AuthCubit(
        restoreSession: sl<RestoreSessionUseCase>(),
        getCurrentUser: sl<GetCurrentUserUseCase>(),
        logout: sl<LogoutUseCase>(),
        events: sl<SessionEvents>(),
      ),
    )
    ..registerFactory(() => LoginCubit(sl<LoginUseCase>()));
}
