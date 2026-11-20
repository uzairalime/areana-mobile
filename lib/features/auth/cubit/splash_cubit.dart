import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/session_cubit.dart';

enum SplashDestination { launch, welcome, home }

SplashDestination splashAfterLaunch({required bool isAuthenticated}) {
  return isAuthenticated ? SplashDestination.home : SplashDestination.welcome;
}

class SplashState extends Equatable {
  const SplashState({this.destination = SplashDestination.launch});

  final SplashDestination destination;

  @override
  List<Object?> get props => [destination];
}

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._session, {
    this.launchHold = const Duration(milliseconds: 2400),
  }) : super(const SplashState()) {
    bootstrap();
  }

  @visibleForTesting
  SplashCubit.idle(this._session)
    : launchHold = Duration.zero,
      super(const SplashState()) {
    _restoreDone = true;
  }

  final SessionCubit _session;
  final Duration launchHold;

  var _restoreDone = false;
  var _skipRequested = false;

  Future<void> bootstrap() async {
    emit(const SplashState());
    await _session.restore();
    _restoreDone = true;
    if (isClosed) {
      return;
    }
    if (_skipRequested) {
      advanceFromLaunch();
      return;
    }
    if (launchHold > Duration.zero) {
      await Future<void>.delayed(launchHold);
      if (isClosed) {
        return;
      }
    }
    advanceFromLaunch();
  }

  void advanceFromLaunch() {
    if (isClosed || state.destination != SplashDestination.launch) {
      return;
    }
    if (!_restoreDone) {
      _skipRequested = true;
      return;
    }
    emit(
      SplashState(
        destination: splashAfterLaunch(
          isAuthenticated: _session.state.isAuthenticated,
        ),
      ),
    );
  }

  @visibleForTesting
  void debugSetDestination(SplashDestination destination) {
    emit(SplashState(destination: destination));
  }
}
