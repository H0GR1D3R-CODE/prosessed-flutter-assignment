import 'package:shopsphere/core/error/guard.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/api_config.dart';
import 'package:shopsphere/core/network/session.dart';
import 'package:shopsphere/features/dev_tools/domain/error_lab.dart';

/// Runs each scenario through the same network stack the rest of the app uses, so what the lab
/// shows is what a shopper would meet.
class ErrorLabRepositoryImpl implements ErrorLabRepository {
  const ErrorLabRepositoryImpl({required this._client, required this._tokens});

  final ApiClient _client;
  final TokenStore _tokens;

  @override
  Future<LabOutcome> run(LabScenario scenario) async {
    final stopwatch = Stopwatch()..start();
    final result = await guard(() => _request(scenario));
    stopwatch.stop();

    return result.fold(
      onFailure: LabFailed.new,
      onSuccess: (_) => switch (scenario) {
        LabScenario.slowNetwork => LabArrived(stopwatch.elapsed),
        LabScenario.expiredToken => const LabRecovered(),
        // These can only succeed if the server unexpectedly behaved.
        _ => const LabRecovered(),
      },
    );
  }

  Future<void> _request(LabScenario scenario) async {
    switch (scenario) {
      case LabScenario.serverError:
        await _client.getMap(Endpoints.http500);
      case LabScenario.notFound:
        await _client.getMap(Endpoints.product(9999));
      case LabScenario.slowNetwork:
        await _client.getMap(
          Endpoints.products,
          query: {'limit': 1, 'select': 'id', 'delay': 3000},
        );
      case LabScenario.timeout:
        // The API waits five seconds; the client gives up after two.
        await _client.getMap(
          Endpoints.products,
          query: {'limit': 1, 'select': 'id', 'delay': 5000},
          receiveTimeout: const Duration(seconds: 2),
        );
      case LabScenario.expiredToken:
        // Keep the real refresh token, spoil the access token: the first call gets a 401, the
        // interceptor refreshes, and the retried call succeeds.
        await _tokens.saveTokens(
          accessToken: 'expired.access.token',
          refreshToken: await _tokens.readRefreshToken() ?? 'missing',
        );
        await _client.getMap(Endpoints.me, authenticated: true);
      case LabScenario.rejectedRefresh:
        // Spoil both: the 401 triggers a refresh, the refresh is refused with 403, and the
        // session ends.
        await _tokens.saveTokens(
          accessToken: 'expired.access.token',
          refreshToken: 'rejected.refresh.token',
        );
        await _client.getMap(Endpoints.me, authenticated: true);
    }
  }
}
