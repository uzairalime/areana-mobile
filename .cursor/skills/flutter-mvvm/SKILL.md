---
name: flutter-mvvm
description: >-
  Builds Flutter features with MVVM clean architecture using Cubit, Equatable,
  GetIt, Dio (one interceptor plus debug logs), and flutter_flavorizr
  development/production flavors. Use when creating or editing Flutter
  screens, features, widgets, API clients, repositories, cubits, dependency
  injection, flavors, dart-define config, go_router, core folders (config, widgets,
  utils, consts, extensions, services, router), or extensions such as padding,
  expand, flexible, onTap, align, and center.
---

# Flutter MVVM

Use this for every Flutter change in this app. UI talks to a Cubit. The Cubit talks to a repository. The repository talks to a client. Only the client uses Dio.

Do not add Provider, Riverpod, GetX, Bloc events, or a second HTTP client.

Add packages with:

```bash
flutter pub add flutter_bloc equatable get_it dio
flutter pub add --dev flutter_flavorizr
```

Imports:

- `package:flutter_bloc/flutter_bloc.dart` for `Cubit`, `BlocProvider`, `BlocBuilder`, `BlocListener`, `BlocConsumer`
- `package:equatable/equatable.dart`
- `package:get_it/get_it.dart`
- `package:dio/dio.dart`

## Dart & Flutter Coding Standards

- Always use valid, modern Dart and Flutter syntax.
- Always use the correct enum type and its exact, case-sensitive values.
- Never guess, abbreviate, or misspell enum values.
- Use `MainAxisAlignment.spaceBetween`, not `MainAxis.spacebetnh` or other invalid variations.
- Use `CrossAxisAlignment.center`, `MainAxisAlignment.center`, and other enum values from their correct classes.
- Verify Flutter and Dart API names before using unfamiliar properties, methods, or enum values.
- Follow official Dart and Flutter conventions for naming, formatting, null safety, and code structure.
- Before finishing, check the code for invalid enum values, typos, deprecated APIs, and syntax errors.
- Prefer clean, readable, maintainable code that follows current Flutter best practices.

When the parameter type is already known, write the real enum value with dot shorthand: `.spaceBetween`, `.center`, `.start`, `.stretch`, `.loose`, `.opaque`, `.w600`. That is `MainAxisAlignment.spaceBetween`, `CrossAxisAlignment.center`, `FlexFit.loose`, and `HitTestBehavior.opaque`. Do not invent a type or a case.

## Folder layout

```
lib/
  main.dart
  app.dart
  core/
    config/
    consts/
    extensions/
    router/
    services/
    utils/
    widgets/
  features/
    <feature>/
      screen/
      widgets/
      model/
      cubit/
        <feature>_cubit.dart
        <feature>_state.dart
        <feature>_repository.dart
        <feature>_client.dart
```

| Folder | Holds | Does not hold |
| --- | --- | --- |
| `core/config` | `AppConfig` from `config.*.json` | hardcoded API hosts |
| `core/consts` | colors, strings, sizes, `ApiEndpoints` | a second base URL |
| `core/extensions` | padding, expand, flexible, onTap, align, center, spacing, context helpers | feature UI |
| `core/router` | `GoRouter`, `AppRoutes`, fade and slide page transitions | feature cubit logic |
| `core/services` | GetIt locator, Dio, interceptor, `ApiResult`, `SessionStore`, token store | feature cubits |
| `core/mock` | delayed mock payloads while `USE_MOCK_API` is true | production networking |
| `core/utils` | pure helpers (validators, formatters) | `BuildContext`, Dio, widgets |
| `core/widgets` | widgets reused by more than one feature | one-feature widgets |
| `features/<feature>/screen` | the screen (`*Screen`) | API calls |
| `features/<feature>/widgets` | widgets used only by that feature | shared widgets |
| `features/<feature>/model` | Equatable request and response models | cubit logic |
| `features/<feature>/cubit` | cubit, state, repository, client | widgets |

Name files and folders in `snake_case`. Name types in `PascalCase`.

## Layer rules

- **Screen:** `StatelessWidget` named `*Screen`. Render state and call cubit methods. No Dio, no repository, no JSON, no `setState` for server data. Wrap each form in `Form` using the cubit's `formKey`. Pass `AppValidators` through `AppTextField.validator`. Submit methods call `formKey.currentState.validate()` before the request. Navigate with `context.push` and `context.go` from `go_router`. Do not wrap a screen in a keyboard unfocus detector. `App` already wraps the navigator with `AppUnfocus`.
- **Cubit:** emit Equatable state and call the repository. No widgets, no `BuildContext`, no Dio, no JSON parsing. Handle `ApiResult` with `when(success:, failure:)`.
- **Repository:** call the client and return `ApiResult<T>`. No widgets and no `Dio` construction.
- **Client:** the only feature file that imports `dio`. Map JSON to models. Return `ApiResult<T>`. On `DioException`, return `ApiError.fromDio(error)`.
- **Model:** `Equatable`, `fromJson`, and `toJson` when the request has a body. Parsing stays in the model.

After every `await` in a cubit, return if `isClosed` before `emit`.

## Feature workflow

1. Add `model/`, `cubit/`, `screen/`, and `widgets/` under `lib/features/<feature>/`.
2. Add the model, client, repository, state, and cubit. Copy the shape in [reference.md](reference.md).
3. Register the client and repository as `registerLazySingleton`. Register the cubit as `registerFactory`.
4. Add the screen to `lib/core/router/app_router.dart` and open it with `context.push(AppRoutes.name)` or `context.go(AppRoutes.name)`. Provide the cubit in that route with `BlocProvider(create: (_) => getIt<FeatureCubit>(), child: const FeatureScreen())`.
5. Put feature-only widgets in `features/<feature>/widgets/`. Put controls reused across the app, such as `AppTextField` and `AppButton`, in `core/widgets/`.

Use `AppLoading` from `lib/core/enums/app_loading.dart` on every API state: `initial`, `loading`, `error`, `success`. Do not declare a second status enum. Emit `AppLoading.loading` before the call, then `AppLoading.success` or `AppLoading.error`. Wrap every form submit screen with `AppFormListener`. It shows `AppLoader` with title and `Please wait...` while loading, and `showAppErrorDialog` when the request fails. Keep field errors on the fields. Do not render the submit error under the button. Use `AppLoadingHandler` only for a screen that loads its whole body.

## Project rules added Nov 1, 2026 (do / don't)

These rules sit on top of the MVVM rules above and apply to every change
in this app, including the Areana API rewrite. Do not weaken them to make
a single screen easier.

### Theme — do not change it

- The theme stays exactly as already in the app: `AppTheme.light` in
  `lib/core/theme/app_theme.dart`, with `AppColors`, `AppSizes`, and
  `AppIcons` in `lib/core/consts/`.
- Do not introduce a second theme, a dark theme, a new color system, or
  a new font system unless the user explicitly asks for one.
- New UI must use the existing theme (`context.theme`, `colorScheme`,
  `textTheme`, `AppColors`, `AppSizes`). Do not hardcode colors, radii,
  or text styles that the theme already defines.

### Common widgets — one folder only

- `lib/core/widgets/` **is** the common widgets folder. Every reusable
  button, box/card, input, dialog, loader, chip, avatar, and scaffold
  lives there, named `App*` (for example `AppButton`, `AppTextField`,
  `AppScaffold`, `AppLoader`).
- Do not create a second common folder (for example `lib/common/`).
  Do not create a generic button, card/box, input, dialog, or loader
  inside a feature folder.
- A widget moves to `lib/core/widgets/` as soon as a second feature
  needs it. Feature folders (`lib/features/<feature>/widgets/`) hold
  only widgets used by that one feature (for example a venue card or a
  booking summary card).
- Common widgets are `StatelessWidget`s, theme-driven, and take their
  data through parameters. They do not call a Cubit, a repository, or
  Dio directly.

### Screen size — max 500 lines per screen

- Keep every `*Screen` file at **500 lines or fewer**.
- If a screen grows past 500 lines, split it before finishing: move
  sections into `lib/features/<feature>/widgets/` (feature-only
  widgets) and keep the screen as composition + state rendering only.
  Do not leave a 600–800 line screen and call it done.
- Current known over-limit screens to split during the API rewrite:
  `pick_slot_screen.dart` (818 lines) and `checkout_screen.dart`
  (546 lines). `booking_confirmed_screen.dart` (485 lines) is close
  to the limit — do not grow it.
- The line limit is for the screen file only. It is not an excuse to
  move server logic into a widget: layer rules still apply.

### Proper MVVM — what each layer is

- **View:** `*Screen` (`StatelessWidget`, with the narrow exceptions
  already in the codebase for purely local UI state). Renders state,
  calls Cubit methods, navigates with `go_router`. No Dio, no
  repository, no JSON, no `setState` for server data.
- **ViewModel:** the Cubit (`flutter_bloc` Cubit, never Bloc events).
  Emits Equatable state, calls the repository, handles `ApiResult`
  with `when(success:, failure:)`. No widgets, no `BuildContext`,
  no Dio, no JSON parsing. After every `await`, return if `isClosed`
  before `emit`.
- **Repository:** calls the client and returns `ApiResult<T>`. No
  widgets, no Dio construction, no mock data in production code.
- **Client:** the only feature file that imports `dio`. Maps JSON to
  models, returns `ApiResult<T>`, converts `DioException` with
  `ApiError.fromDio`.
- **Model:** `Equatable`, `fromJson`, and `toJson` when the request
  has a body. Parsing stays in the model.
- Do not skip a layer to "save time": a screen calling Dio, a Cubit
  parsing JSON, and a repository constructing Dio are all violations,
  even if the code works.

### Auth tokens and the interceptor — do not weaken these

- Tokens live in `flutter_secure_storage` via `SessionStore`, never in
  `SharedPreferences`. SharedPreferences holds only the non-secret
  user profile JSON.
- `AppInterceptor` is the only place that attaches `Authorization`
  and the only place that refreshes tokens. It must stay
  single-flight: parallel 401s share one `POST /auth/refresh` call,
  retry at most once, never refresh public auth endpoints, and clear
  the session only on a refresh 401 — never on a transient refresh
  failure (network, timeout, missing endpoint).
- On every successful refresh, discard the old access + refresh pair
  and store the new pair (`SessionCubit.applySession`). Never reuse
  a rotated refresh token.

## GetIt

One locator: `lib/core/services/locator.dart`.

```dart
final GetIt getIt = GetIt.instance;
```

Call `setupLocator()` from `main` after `WidgetsFlutterBinding.ensureInitialized()` and before `runApp`.

Registration order: `TokenStore`, `Dio`, clients, repositories, cubits. Cubits are factories so each screen gets a new instance. Do not call `GetIt.I` or `getIt` inside `build` except in `BlocProvider.create`.

## Flavors

Two flavors only: `development` and `production`. One entrypoint: `lib/main.dart`. Do not add `lib/flavors.dart`, `lib/main_development.dart`, or flavorizr sample pages.

`flutter_flavorizr` owns native ids and the display name (`flavorizr.yaml`). The API host comes from `--dart-define-from-file`, not from a second main file.

| | Development | Production |
| --- | --- | --- |
| Flavor | `development` | `production` |
| Config | `config.development.json` | `config.production.json` |
| Android applicationId | `com.example.arana360.dev` | `com.example.arana360` |
| iOS bundleId | `com.example.arana360.dev` | `com.example.arana360` |
| App name | Pitchside Dev | Pitchside |
| Xcode scheme | `development` | `production` |

Config keys are `FLAVOR` and `API_BASE_URL`. `API_BASE_URL` ends with `/`. `AppConfig` reads both with `String.fromEnvironment`. The default flavor is `production`. `ApiEndpoints.baseUrl` is `AppConfig.apiBaseUrl`. Dio uses that base URL. Do not hardcode a host in a client.

Every run and build passes both flags. Store uploads use `production` only.

```bash
flutter run --flavor development -t lib/main.dart \
  --dart-define-from-file=config.development.json
```

```bash
flutter run --flavor production -t lib/main.dart \
  --dart-define-from-file=config.production.json
```

Cursor launch names are `[Dev] Debug`, `[Dev] Profile`, `[Dev] Release`, `[Prod] Debug`, `[Prod] Profile`, and `[Prod] Release` in `.vscode/launch.json`. Commands are in `command.md`.

Regenerate native flavors only when an id or app name changes:

```bash
dart run flutter_flavorizr -f
```

`flavorizr.yaml` allows only `ios:xcconfig`, `ios:buildTargets`, `ios:schema`, `ios:plist`, `android:androidManifest`, `android:buildGradle`, and `android:flavorizrGradle`. Do not add `flutter:flavors`, `flutter:app`, `flutter:pages`, `flutter:main`, or icon processors. Both flavors share `AppIcon`.

## Dio, interceptor, and logs

One `Dio` instance from `lib/core/services/dio_service.dart`. Clients receive it through the constructor. They never call `Dio()`.

`BaseOptions`: `baseUrl` from `ApiEndpoints`, `connectTimeout` and `receiveTimeout` of 20 seconds, `responseType: ResponseType.json`, headers `Accept` and `Content-Type` set to `application/json`.

Interceptor order:

1. `AppInterceptor` — on each request, set `Authorization: Bearer <token>` when `TokenStore.accessToken` is non-empty. Do not read the token when Dio is created.
2. `LogInterceptor` — only when `kDebugMode` is true. Enable `request`, `requestHeader`, `requestBody`, `responseBody`, and `error`. Disable `responseHeader`. Pass `logPrint: (object) => debugPrint(object.toString())`.

Full classes are in [reference.md](reference.md).

## Extensions

Create these files and export them from `lib/core/extensions/extensions.dart`:

| Extension | On | Members |
| --- | --- | --- |
| `WidgetPaddingX` | `Widget` | `paddingAll`, `paddingSymmetric`, `paddingOnly` |
| `WidgetFlexX` | `Widget` | `expand({int flex = 1})`, `flexible({int flex = 1, FlexFit fit = .loose})` |
| `WidgetTapX` | `Widget` | `onTap(VoidCallback? action)` using `GestureDetector` and `behavior: .opaque` |
| `WidgetSafeAreaX` | `Widget` | `safeArea()` |
| `WidgetAnnotatedRegionX` | `Widget` | `annotatedRegion(SystemUiOverlayStyle style)` |
| `WidgetAlignX` | `Widget` | `align({Alignment alignment = .center})`, `center()` |
| `ShimmerWidgetX` | `Widget` | `shimmer({bool enabled = true})` wrapping skeleton trees with `AppShimmer` |
| `NumSpacingX` | `num` | `w` for width, `h` for height, as `SizedBox` |
| `ContextX` | `BuildContext` | `theme`, `colorScheme`, `textTheme`, `screenSize` via `MediaQuery.sizeOf`, `hideKeyboard` via `FocusScope.of(this).unfocus()` |

Use these extensions in feature UI instead of repeating `Padding`, `Expanded`, `Flexible`, `GestureDetector`, `SafeArea`, `AnnotatedRegion`, `Align`, and `Center`. Write `16.h`, `8.w`, `child.align(alignment: .centerRight)`, and `child.center()`. For list/grid loading, build card-shaped `ShimmerBox` skeletons and call `.shimmer()` — do not use `CircularProgressIndicator` for those states. Shared avatar UI is `ProfileAvatar(username:, url:)`. Implementations are in [reference.md](reference.md).

## Before finishing

- Run `flutter analyze` and fix errors in the files you touched.
- Confirm every alignment, fit, and behavior value uses the real enum type and a real case.
- Confirm Dio appears only in `core/services` and feature clients.
- Confirm new clients, repositories, and cubits are registered in `setupLocator`.
- Confirm the screen reads state with `BlocBuilder` or `BlocConsumer`, not `setState`.
- Confirm run and build commands pass `--flavor` and the matching `--dart-define-from-file`.
