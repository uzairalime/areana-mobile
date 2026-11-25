import 'package:arana360/core/config/app_config.dart';
import 'package:arana360/core/services/clarity_service.dart';
import 'package:arana360/core/services/session_state.dart';
import 'package:arana360/features/auth/model/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _Host implements ClarityHost {
  final screens = <String>[];
  final users = <String>[];
  final tags = <String, String>{};
  var newSessions = 0;
  void Function(String sessionId)? sessionStarted;

  @override
  void setScreen(String name) => screens.add(name);

  @override
  void setUserId(String id) => users.add(id);

  @override
  void setTag(String key, String value) => tags[key] = value;

  @override
  void onSessionStarted(void Function(String sessionId) callback) {
    sessionStarted = callback;
  }

  @override
  void startNewSession(void Function(String sessionId) callback) {
    newSessions++;
    callback('session-$newSessions');
  }
}

void main() {
  test('Clarity project id is the Arena mobile project', () {
    expect(AppConfig.clarityProjectId, 'zj4sw76dfz');
    expect(AppConfig.isClarityEnabled, isTrue);
  });

  test('records a screen once until the path changes', () {
    final host = _Host();
    final clarity = ClarityService(host: host);
    clarity.recordScreen('/home');
    clarity.recordScreen('/home');
    clarity.recordScreen('/explore');
    expect(host.screens, ['/home', '/explore']);
  });

  test('tags a signed-in user id without sending email', () {
    final host = _Host();
    final clarity = ClarityService(host: host)..bind();
    host.sessionStarted?.call('s1');
    clarity.syncSession(
      const SessionState(
        accessToken: 'token',
        user: UserModel(
          id: 'player-1',
          name: 'Muhammad',
          email: 'hidden@example.com',
        ),
      ),
    );
    expect(host.users, ['player-1']);
    expect(host.tags['auth'], 'signed_in');
    expect(host.tags['flavor'], AppConfig.flavor);
    expect(host.users, isNot(contains('hidden@example.com')));
  });

  test('starts a new session when the user signs out', () {
    final host = _Host();
    final clarity = ClarityService(host: host)..bind();
    clarity.syncSession(
      const SessionState(
        accessToken: 'token',
        user: UserModel(id: 'player-1', name: 'M', email: 'a@b.com'),
      ),
    );
    clarity.syncSession(const SessionState());
    expect(host.newSessions, 1);
    expect(host.tags['auth'], 'guest');
  });
}
