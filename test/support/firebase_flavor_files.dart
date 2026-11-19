import 'dart:convert';
import 'dart:io';

/// Source + flavorizr-copied Firebase files for a named flavor.
class FirebaseFlavorFiles {
  const FirebaseFlavorFiles(this.flavor);

  static const flavors = ['development', 'production'];
  static const projectId = 'arena-b60be';
  static const senderId = '351886837361';
  static const productionId = 'com.zorixsolutions.arana';
  static const developmentId = 'com.zorixsolutions.arana.dev';

  final String flavor;

  File get androidSource =>
      File('assets/firebase/$flavor/google-services.json');
  File get iosSource =>
      File('assets/firebase/$flavor/GoogleService-Info.plist');
  File get androidNative =>
      File('android/app/src/$flavor/google-services.json');
  File get iosNative =>
      File('ios/Runner/$flavor/GoogleService-Info.plist');

  String get expectedApplicationId =>
      flavor == 'development' ? developmentId : productionId;

  List<String> get androidPackageNames {
    final json = jsonDecode(androidSource.readAsStringSync()) as Map;
    final clients = json['client'] as List<dynamic>;
    return [
      for (final client in clients)
        (client as Map)['client_info']['android_client_info']['package_name']
            as String,
    ];
  }

  String? plistValue(String key) {
    final match = RegExp(
      '<key>$key</key>\\s*<string>([^<]*)</string>',
    ).firstMatch(iosSource.readAsStringSync());
    return match?.group(1);
  }
}
