import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/session_cubit.dart';

enum SplashDestination { loading, welcome, home }

class SplashState extends Equatable {
  const SplashState({this.destination = SplashDestination.loading});

  final SplashDestination destination;

  @override
  List<Object?> get props => [destination];
}

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._session) : super(const SplashState()) {
    bootstrap();
  }

  final SessionCubit _session;

  Future<void> bootstrap() async {
    emit(const SplashState());
    await Future.wait([
      _session.restore(),
      Future<void>.delayed(const Duration(milliseconds: 900)),
    ]);
    if (isClosed) {
      return;
    }
    emit(
      SplashState(
        destination: _session.state.isAuthenticated
            ? SplashDestination.home
            : SplashDestination.welcome,
      ),
    );
  }
}
