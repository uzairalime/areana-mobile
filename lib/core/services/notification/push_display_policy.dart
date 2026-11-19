/// Whether a remote push should present a system/local banner.
///
/// Background and terminated: the OS shows the FCM `notification` payload.
/// Foreground (app open): never present a banner — inbox/chat already live.
bool shouldPresentPushBanner({required bool appOpen}) => !appOpen;
