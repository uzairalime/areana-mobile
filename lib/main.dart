import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

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
  runApp(_withClarity(const App()));
}

Widget _withClarity(Widget app) {
  if (!AppConfig.isClarityEnabled) return app;
  return ClarityWidget(
    app: app,
    clarityConfig: ClarityConfig(
      projectId: AppConfig.clarityProjectId,
      logLevel: kDebugMode ? LogLevel.Info : LogLevel.None,
    ),
  );
}
