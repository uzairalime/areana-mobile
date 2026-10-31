import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/services/locator.dart';
import 'core/services/session_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint(
    'Flavor=${AppConfig.flavor} API=${AppConfig.apiBaseUrl} '
    'mock=${AppConfig.useMockApi}',
  );
  setupLocator();
  await getIt<SessionCubit>().restore();
  runApp(const App());
}
