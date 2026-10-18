import 'package:shopsphere/core/error/failures.dart';

/// The failures the error lab can provoke. Each one is a real request to the real API.
enum LabScenario {
  serverError,
  notFound,
  slowNetwork,
  timeout,
  expiredToken,
  rejectedRefresh,
}

/// How a scenario ended.
sealed class LabOutcome {
  const LabOutcome();
}

/// The app absorbed the problem and carried on (the token was refreshed behind the scenes).
final class LabRecovered extends LabOutcome {
  const LabRecovered();
}

/// A slow response that did arrive, after [elapsed].
final class LabArrived extends LabOutcome {
  const LabArrived(this.elapsed);

  final Duration elapsed;
}

/// The request failed, and this is the typed failure the screens would show.
final class LabFailed extends LabOutcome {
  const LabFailed(this.failure);

  final Failure failure;
}

abstract interface class ErrorLabRepository {
  Future<LabOutcome> run(LabScenario scenario);
}

class RunLabScenarioUseCase {
  const RunLabScenarioUseCase(this._repository);

  final ErrorLabRepository _repository;

  Future<LabOutcome> call(LabScenario scenario) => _repository.run(scenario);
}
