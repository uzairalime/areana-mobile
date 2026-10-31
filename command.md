# Commands — Pitchside

Run from the project root.

## Environment matrix

| | Development | Production |
|---|-------------|------------|
| Flavor | `development` | `production` |
| Config file | `config.development.json` | `config.production.json` |
| Android applicationId | `com.example.arana360.dev` | `com.example.arana360` |
| iOS bundleId | `com.example.arana360.dev` | `com.example.arana360` |
| App name | Pitchside Dev | Pitchside |
| API | `https://api-dev.example.com/` | `https://api.example.com/` |
| Cursor / VS Code | **[Dev] Debug** / Profile / Release | **[Prod] Debug** / Profile / Release |
| Xcode scheme | `development` | `production` |

Only the API base URL changes per flavor. Replace the placeholder URLs in the config files before calling a real backend.

---

## One-time setup

```bash
flutter pub get
```

If iOS schemes are missing:

```bash
dart run flutter_flavorizr -f
cd ios && pod install && cd ..
```

Both flavors share `AppIcon`. Do not add `AppIcon-development`.

---

## Dev run

```bash
flutter run --flavor development -t lib/main.dart \
  --dart-define-from-file=config.development.json
```

## Production run

```bash
flutter run --flavor production -t lib/main.dart \
  --dart-define-from-file=config.production.json
```

**Cursor / VS Code:** Run and Debug → **[Dev] Debug** or **[Prod] Debug**.

---

## Android — APK

```bash
flutter build apk --flavor development --release -t lib/main.dart \
  --dart-define-from-file=config.development.json

flutter build apk --flavor production --release -t lib/main.dart \
  --dart-define-from-file=config.production.json
```

Outputs:

- `build/app/outputs/flutter-apk/app-development-release.apk`
- `build/app/outputs/flutter-apk/app-production-release.apk`

---

## Android — Play Store (AAB)

```bash
flutter build appbundle --flavor production --release -t lib/main.dart \
  --dart-define-from-file=config.production.json
```

Output:

- `build/app/outputs/bundle/productionRelease/app-production-release.aab`

---

## iOS

```bash
flutter build ios --flavor development --release -t lib/main.dart \
  --dart-define-from-file=config.development.json

flutter build ipa --flavor production --release -t lib/main.dart \
  --dart-define-from-file=config.production.json
```

Open `ios/Runner.xcworkspace`, pick scheme **development** or **production**, then Run / Archive.

After flavors, always pass `--flavor`. Store uploads use **production** only.

---

## Config keys

| Key | Purpose |
|-----|---------|
| `FLAVOR` | `development` or `production` |
| `API_BASE_URL` | Backend API base, with a trailing `/` |

Edit `config.development.json` and `config.production.json`.
