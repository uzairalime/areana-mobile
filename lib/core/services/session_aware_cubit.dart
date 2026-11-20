import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'session_cubit.dart';
import 'session_state.dart';

/// Skips token APIs while signed out and reloads after login.
///
/// A null [authSession] is the test seam: those cubits keep loading
/// like before (the fake HTTP adapter is the network).
mixin SessionAwareCubit<S> on Cubit<S> {
  SessionCubit? get authSession;

  StreamSubscription<SessionState>? _authSub;
  var _signedIn = true;

  bool get canUseAuthedApi => authSession?.state.isAuthenticated ?? true;

  void bindAuth({
    required void Function() onSignedIn,
    required void Function() onSignedOut,
  }) {
    final session = authSession;
    _signedIn = session?.state.isAuthenticated ?? true;
    if (_signedIn) {
      onSignedIn();
    }
    if (session == null) return;
    _authSub = session.stream.listen((state) {
      final next = state.isAuthenticated;
      if (next == _signedIn) return;
      _signedIn = next;
      if (next) {
        onSignedIn();
      } else {
        onSignedOut();
      }
    });
  }

  Future<void> unbindAuth() async {
    await _authSub?.cancel();
    _authSub = null;
  }
}
