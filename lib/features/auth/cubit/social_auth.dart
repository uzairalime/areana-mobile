import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/config/app_config.dart';

class SocialCredential {
  const SocialCredential({
    required this.provider,
    required this.idToken,
    this.name,
  });

  final String provider;
  final String idToken;
  final String? name;
}

class SocialAuthException implements Exception {
  const SocialAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class SocialAuth {
  bool get googleAvailable;
  bool get appleAvailable;

  Future<SocialCredential?> signInGoogle();
  Future<SocialCredential?> signInApple();
}

/// Native Google / Apple sheets. Android shows Google only; iOS both.
class DeviceSocialAuth implements SocialAuth {
  bool _googleReady = false;

  @override
  bool get googleAvailable => true;

  @override
  bool get appleAvailable =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<SocialCredential?> signInGoogle() async {
    if (!AppConfig.isGoogleSignInConfigured) {
      throw const SocialAuthException(
        'Google Sign-In is not configured yet.',
      );
    }
    await _ensureGoogle();
    try {
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const SocialAuthException(
          'Google did not return an ID token. Check the server client ID.',
        );
      }
      return SocialCredential(
        provider: 'google',
        idToken: idToken,
        name: account.displayName,
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      throw SocialAuthException(
        error.description?.trim().isNotEmpty == true
            ? error.description!
            : 'Google Sign-In failed. Please try again.',
      );
    } finally {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
  }

  @override
  Future<SocialCredential?> signInApple() async {
    if (!appleAvailable) {
      throw const SocialAuthException(
        'Apple Sign-In is available on iPhone and iPad only.',
      );
    }
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw const SocialAuthException(
          'Apple did not return an identity token. Please try again.',
        );
      }
      final name = [
        credential.givenName,
        credential.familyName,
      ].whereType<String>().map((part) => part.trim()).where((part) => part.isNotEmpty).join(' ');
      return SocialCredential(
        provider: 'apple',
        idToken: idToken,
        name: name.isEmpty ? null : name,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) return null;
      throw SocialAuthException(
        error.message.trim().isEmpty
            ? 'Apple Sign-In failed. Please try again.'
            : error.message,
      );
    }
  }

  Future<void> _ensureGoogle() async {
    if (_googleReady) return;
    final ios = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final iosClientId = AppConfig.googleIosClientId.trim();
    final webClientId = AppConfig.googleServerClientId.trim();
    final androidClientId = AppConfig.googleAndroidClientId.trim();
    // No Web client yet: iOS tokens `aud` the iOS ID; Android needs
    // serverClientId to mint an ID token, so it uses the Android ID.
    await GoogleSignIn.instance.initialize(
      clientId: ios && iosClientId.isNotEmpty ? iosClientId : null,
      serverClientId: webClientId.isNotEmpty
          ? webClientId
          : (!ios && androidClientId.isNotEmpty ? androidClientId : null),
    );
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw const SocialAuthException(
        'Google Sign-In is not available on this device.',
      );
    }
    _googleReady = true;
  }
}
