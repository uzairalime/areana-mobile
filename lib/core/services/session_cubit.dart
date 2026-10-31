import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/model/auth_session.dart';
import '../../features/auth/model/user_model.dart';
import 'session_state.dart';
import 'session_store.dart';

/// App-wide auth/user mirror of [SessionStore]. Listen anywhere with
/// `context.watch<SessionCubit>()` / `BlocBuilder`.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._store) : super(_stateFrom(_store));

  final SessionStore _store;

  void hydrate() => emit(_stateFrom(_store));

  Future<void> restore() async {
    await _store.restore();
    if (isClosed) {
      return;
    }
    emit(_stateFrom(_store));
  }

  Future<void> applySession(AuthSession session) async {
    await _store.save(session);
    if (isClosed) {
      return;
    }
    emit(_stateFrom(_store));
  }

  Future<void> applyUser(UserModel user) async {
    await _store.saveUser(user);
    if (isClosed) {
      return;
    }
    emit(_stateFrom(_store));
  }

  Future<void> clear() async {
    await _store.clear();
    if (isClosed) {
      return;
    }
    emit(const SessionState());
  }

  static SessionState _stateFrom(SessionStore store) {
    return SessionState(accessToken: store.accessToken, user: store.user);
  }
}
