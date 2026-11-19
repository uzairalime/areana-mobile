String deviceTokenKey(String userId, String token) =>
    '${userId.trim()}|${token.trim()}';

/// Upload once per signed-in user + FCM token pair.
bool shouldUploadDeviceToken({
  required bool isAuthenticated,
  required String? userId,
  required String? token,
  required String? registeredKey,
}) {
  if (!isAuthenticated) return false;
  final id = userId?.trim() ?? '';
  final value = token?.trim() ?? '';
  if (id.isEmpty || value.isEmpty) return false;
  return registeredKey != deviceTokenKey(id, value);
}
