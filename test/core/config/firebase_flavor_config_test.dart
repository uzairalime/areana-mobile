import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/firebase_flavor_files.dart';

void main() {
  test('iOS Firebase Setup script switches plist by flavor', () {
    final script = File('ios/firebaseScript.sh').readAsStringSync();
    expect(script, contains('*-development'));
    expect(script, contains('*-production'));
    expect(script, contains('Runner/development/GoogleService-Info.plist'));
    expect(script, contains('Runner/production/GoogleService-Info.plist'));
  });

  test('flavorizr.yaml points at per-flavor Firebase configs', () {
    final yaml = File('flavorizr.yaml').readAsStringSync();
    expect(yaml, contains('google:firebase'));
    for (final flavor in FirebaseFlavorFiles.flavors) {
      expect(
        yaml,
        contains('assets/firebase/$flavor/google-services.json'),
      );
      expect(
        yaml,
        contains('assets/firebase/$flavor/GoogleService-Info.plist'),
      );
    }
  });

  test('development and production currently share the same Firebase files', () {
    final development = FirebaseFlavorFiles('development');
    final production = FirebaseFlavorFiles('production');
    expect(
      development.androidSource.readAsStringSync(),
      production.androidSource.readAsStringSync(),
    );
    expect(
      development.iosSource.readAsStringSync(),
      production.iosSource.readAsStringSync(),
    );
  });

  for (final flavor in FirebaseFlavorFiles.flavors) {
    final files = FirebaseFlavorFiles(flavor);

    test('$flavor Android JSON covers both applicationIds', () {
      expect(files.androidSource.existsSync(), isTrue);
      expect(
        files.androidPackageNames,
        containsAll([
          FirebaseFlavorFiles.productionId,
          FirebaseFlavorFiles.developmentId,
        ]),
      );
      expect(
        files.androidPackageNames,
        contains(files.expectedApplicationId),
      );
    });

    test('$flavor iOS plist is the arena Firebase iOS app', () {
      expect(files.iosSource.existsSync(), isTrue);
      expect(files.plistValue('PROJECT_ID'), FirebaseFlavorFiles.projectId);
      expect(files.plistValue('GCM_SENDER_ID'), FirebaseFlavorFiles.senderId);
      expect(
        files.plistValue('BUNDLE_ID'),
        anyOf(
          FirebaseFlavorFiles.productionId,
          FirebaseFlavorFiles.developmentId,
        ),
      );
      expect(files.plistValue('GOOGLE_APP_ID'), contains(':ios:'));
    });

    test('$flavor native copies exist for Android and iOS', () {
      expect(files.androidNative.existsSync(), isTrue);
      expect(files.iosNative.existsSync(), isTrue);
      expect(
        files.androidNative.readAsStringSync(),
        files.androidSource.readAsStringSync(),
      );
      expect(
        files.iosNative.readAsStringSync(),
        files.iosSource.readAsStringSync(),
      );
    });
  }
}
