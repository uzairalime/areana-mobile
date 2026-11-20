import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import 'session_state.dart';

/// Native Clarity calls. Tests inject a fake so the plugin is never touched.
abstract class ClarityHost {
  void setScreen(String name);
  void setUserId(String id);
  void setTag(String key, String value);
  void onSessionStarted(void Function(String sessionId) callback);
  void startNewSession(void Function(String sessionId) callback);
}

class MicrosoftClarityHost implements ClarityHost {
  const MicrosoftClarityHost();

  @override
  void setScreen(String name) {
    Clarity.setCurrentScreenName(name);
  }

  @override
  void setUserId(String id) {
    Clarity.setCustomUserId(id);
  }

  @override
  void setTag(String key, String value) {
    Clarity.setCustomTag(key, value);
  }

  @override
  void onSessionStarted(void Function(String sessionId) callback) {
    Clarity.setOnSessionStartedCallback(callback);
  }

  @override
  void startNewSession(void Function(String sessionId) callback) {
    Clarity.startNewSession(callback);
  }
}

/// Screen names + signed-in user id for Clarity. No email/phone/name.
class ClarityService {
  ClarityService({ClarityHost? host})
    : _host = host ?? const MicrosoftClarityHost();

  final ClarityHost _host;

  String? _lastScreen;
  String? _userId;
  void Function()? _detachRouter;
  var _bound = false;

  void bind() {
    if (_bound) return;
    _bound = true;
    _host.onSessionStarted((_) => _applyIdentity());
  }

  void attachRouter(GoRouter router) {
    _detachRouter?.call();
    void publish() {
      recordScreen(router.routeInformationProvider.value.uri.path);
    }

    router.routerDelegate.addListener(publish);
    _detachRouter = () => router.routerDelegate.removeListener(publish);
    publish();
  }

  void recordScreen(String path) {
    final name = path.trim();
    if (name.isEmpty || name == _lastScreen) return;
    _lastScreen = name;
    _host.setScreen(name);
  }

  void syncSession(SessionState session) {
    final nextId = session.isAuthenticated ? session.user!.id.trim() : '';
    final previous = _userId ?? '';
    if (nextId == previous) {
      if (_bound) _applyIdentity();
      return;
    }
    final hadUser = previous.isNotEmpty;
    _userId = nextId.isEmpty ? null : nextId;
    if (hadUser && nextId.isEmpty) {
      _host.startNewSession((_) => _applyIdentity());
      return;
    }
    _applyIdentity();
  }

  void _applyIdentity() {
    final id = _userId;
    _host.setTag('flavor', AppConfig.flavor);
    if (id == null || id.isEmpty) {
      _host.setTag('auth', 'guest');
      return;
    }
    _host.setUserId(id);
    _host.setTag('auth', 'signed_in');
  }

  void dispose() {
    _detachRouter?.call();
    _detachRouter = null;
  }
}
