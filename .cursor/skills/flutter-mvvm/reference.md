# Flutter MVVM templates

Replace `Auth` / `auth` with the feature name. Package imports use the `name` in `pubspec.yaml` (`arana360` for this app).

## `lib/core/services/api_exception.dart`

```dart
import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    var message = error.message ?? 'Request failed';
    if (data is Map && data['message'] is String) {
      message = data['message'] as String;
    }
    return ApiException(message, statusCode: error.response?.statusCode);
  }

  @override
  String toString() => message;
}
```

## `lib/core/services/api_result.dart`

```dart
import 'package:dio/dio.dart';

import 'api_exception.dart';

sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isError => this is ApiError<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiError<T> error) failure,
  });
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data, {this.statusCode});

  final T data;
  final int? statusCode;
}

final class ApiError<T> extends ApiResult<T> {
  const ApiError({
    required this.message,
    this.statusCode,
    this.error,
    this.errors,
  });

  final String message;
  final int? statusCode;
  final Object? error;
  final Map<String, dynamic>? errors;

  factory ApiError.fromDio(DioException exception) { /* map response */ }
}
```

## `lib/core/services/token_store.dart`

```dart
class TokenStore {
  String? accessToken;
}
```

## `lib/core/services/app_interceptor.dart`

```dart
import 'package:dio/dio.dart';

import 'locator.dart';
import 'token_store.dart';

class AppInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (getIt.isRegistered<TokenStore>()) {
      final token = getIt<TokenStore>().accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
```

## `lib/core/services/dio_service.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../consts/api_endpoints.dart';
import 'app_interceptor.dart';

class DioService {
  const DioService._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    dio.interceptors.add(AppInterceptor());
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }
    return dio;
  }
}
```

## `lib/core/services/locator.dart`

```dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/cubit/auth_client.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/cubit/auth_repository.dart';
import 'dio_service.dart';
import 'token_store.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt
    ..registerLazySingleton<TokenStore>(TokenStore.new)
    ..registerLazySingleton<Dio>(DioService.create);

  getIt.registerLazySingleton<AuthClient>(() => AuthClient(getIt<Dio>()));
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<AuthClient>()),
  );
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
}
```

Register each new feature in that same order: client, repository, then cubit factory.

## `lib/core/config/app_config.dart`

```dart
class AppConfig {
  AppConfig._();

  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'production',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com/',
  );

  static bool get isDevelopment => flavor == 'development';
  static bool get isProduction => flavor == 'production';
}
```

## `lib/core/consts/api_endpoints.dart`

```dart
import 'package:arana360/core/config/app_config.dart';

class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = AppConfig.apiBaseUrl;
  static const String login = 'auth/login';
}
```

Keep paths relative and without a leading slash. The host lives only in `config.development.json` and `config.production.json`, and it ends with `/`.

## `lib/main.dart`

```dart
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/services/locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('Flavor=${AppConfig.flavor} API=${AppConfig.apiBaseUrl}');
  setupLocator();
  runApp(const App());
}
```

## Model

`lib/features/auth/model/user_model.dart`

```dart
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({required this.id, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  final String id;
  final String email;

  Map<String, dynamic> toJson() => {'id': id, 'email': email};

  @override
  List<Object?> get props => [id, email];
}
```

## Client

`lib/features/auth/cubit/auth_client.dart`

```dart
import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../model/user_model.dart';

class AuthClient {
  const AuthClient(this._dio);

  final Dio _dio;

  Future<ApiResult<UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      if (data is! Map) {
        return const ApiError(message: 'Unexpected response');
      }
      return ApiSuccess(
        UserModel.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }
}
```

## Repository

`lib/features/auth/cubit/auth_repository.dart`

```dart
import '../../../core/services/api_result.dart';
import '../model/user_model.dart';
import 'auth_client.dart';

class AuthRepository {
  const AuthRepository(this._client);

  final AuthClient _client;

  Future<ApiResult<UserModel>> login({
    required String email,
    required String password,
  }) {
    return _client.login(email: email, password: password);
  }
}
```

## State and cubit

`lib/features/auth/cubit/auth_state.dart`

```dart
import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../model/user_model.dart';

class AuthState extends Equatable {
  const AuthState({
    this.status = AppLoading.initial,
    this.user,
    this.errorMessage = '',
  });

  final AppLoading status;
  final UserModel? user;
  final String errorMessage;

  AuthState copyWith({
    AppLoading? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
```

`lib/features/auth/cubit/auth_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import 'auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.login(email: email, password: password);
    if (isClosed) return;
    result.when(
      success: (user) {
        emit(state.copyWith(status: AppLoading.success, user: user));
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }
}
```

## View

Provide the cubit at the route. The view only builds UI.

```dart
BlocProvider(
  create: (_) => getIt<AuthCubit>(),
  child: const AuthView(),
)
```

```dart
class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return AppLoadingHandler(
            status: state.status,
            errorMessage: state.errorMessage,
            onRetry: () => context.read<AuthCubit>().login(
              email: email,
              password: password,
            ),
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .stretch,
              children: [
                const Text('Sign in').paddingSymmetric(horizontal: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

Call `context.read<AuthCubit>().login(...)` from the feature widget. Do not construct `AuthCubit()` in the widget.

## Extensions

`lib/core/extensions/widget_extensions.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension WidgetPaddingX on Widget {
  Widget paddingAll(double value) {
    return Padding(padding: EdgeInsets.all(value), child: this);
  }

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }
}

extension WidgetFlexX on Widget {
  Widget expand({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }

  Widget flexible({int flex = 1, FlexFit fit = .loose}) {
    return Flexible(flex: flex, fit: fit, child: this);
  }
}

extension WidgetTapX on Widget {
  Widget onTap(VoidCallback? action) {
    return GestureDetector(
      onTap: action,
      behavior: .opaque,
      child: this,
    );
  }
}

extension WidgetSafeAreaX on Widget {
  Widget safeArea({
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
    EdgeInsets minimum = EdgeInsets.zero,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimum,
      child: this,
    );
  }
}

extension WidgetAnnotatedRegionX on Widget {
  Widget annotatedRegion(SystemUiOverlayStyle style) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style,
      child: this,
    );
  }
}

extension WidgetAlignX on Widget {
  Widget align({
    Alignment alignment = .center,
    double? widthFactor,
    double? heightFactor,
  }) {
    return Align(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: this,
    );
  }

  Widget center({double? widthFactor, double? heightFactor}) {
    return Center(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: this,
    );
  }
}
```

`lib/core/extensions/spacing_extensions.dart`

```dart
import 'package:flutter/widgets.dart';

extension NumSpacingX on num {
  Widget get w => SizedBox(width: toDouble());
  Widget get h => SizedBox(height: toDouble());
}
```

`lib/core/extensions/context_extensions.dart`

```dart
import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  Size get screenSize => MediaQuery.sizeOf(this);

  void hideKeyboard() => FocusScope.of(this).unfocus();
}
```

`lib/core/extensions/extensions.dart`

```dart
export 'context_extensions.dart';
export 'spacing_extensions.dart';
export 'widget_extensions.dart';
```

Feature files import `package:arana360/core/extensions/extensions.dart`.
