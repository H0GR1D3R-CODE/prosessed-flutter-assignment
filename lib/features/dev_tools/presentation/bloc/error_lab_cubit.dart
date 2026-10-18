import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/features/dev_tools/domain/error_lab.dart';

sealed class ErrorLabState extends Equatable {
  const ErrorLabState();

  @override
  List<Object?> get props => [];
}

final class LabIdle extends ErrorLabState {
  const LabIdle();
}

final class LabRunning extends ErrorLabState {
  const LabRunning(this.scenario);

  final LabScenario scenario;

  @override
  List<Object?> get props => [scenario];
}

final class LabDone extends ErrorLabState {
  const LabDone(this.scenario, this.outcome);

  final LabScenario scenario;
  final LabOutcome outcome;

  @override
  List<Object?> get props => [scenario, outcome];
}

/// Runs one scenario at a time and reports how it ended.
class ErrorLabCubit extends Cubit<ErrorLabState> {
  ErrorLabCubit(this._run) : super(const LabIdle());

  final RunLabScenarioUseCase _run;

  Future<void> run(LabScenario scenario) async {
    if (state is LabRunning) return;
    emit(LabRunning(scenario));
    final outcome = await _run(scenario);
    if (!isClosed) emit(LabDone(scenario, outcome));
  }
}
