/// Google OAuth clients for the player app.
///
/// Android Sign-In matches package `com.zorixsolutions.arana` + SHA-1.
/// iOS Sign-In uses [iosClientId] and the reversed URL scheme in Info.plist.
/// The API accepts both IDs as ID-token `aud` values (`GOOGLE_CLIENT_IDS`).
abstract final class GoogleOAuth {
  static const androidClientId =
      '777093148678-7e8rtcsr5p29ne8vbsbp2h57opmq79p2.apps.googleusercontent.com';

  static const iosClientId =
      '777093148678-morcmf0fm6lbhotqq1mo4n5op1nvdo46.apps.googleusercontent.com';

  static const iosReversedClientId =
      'com.googleusercontent.apps.777093148678-morcmf0fm6lbhotqq1mo4n5op1nvdo46';

  static const audienceList = '$androidClientId,$iosClientId';
}
