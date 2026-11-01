# Commands — Areana mobile

Run from the project root. The app is the Areana player app (same API
and flows as user-web); the display name / package ids are still the
legacy Pitchside ones — renaming them is a separate, still-open
decision, not part of the API migration.

## Environment matrix

| | Development | Production |
|---|-------------|------------|
| Flavor | `development` | `production` |
| Config file | `config.development.json` | `config.production.json` |
| Android applicationId | `com.example.arana360.dev` | `com.example.arana360` |
| iOS bundleId | `com.example.arana360.dev` | `com.example.arana360` |
| App name | Pitchside Dev | Pitchside |
| API | `http://<Mac LAN IP>:3000/api/` | placeholder, mock on — not for live testing |
| Mock | off | on |
| Cursor / VS Code | **[Dev] Debug** / Profile / Release | **[Prod] Debug** / Profile / Release |
| Xcode scheme | `development` | `production` |

Development points at the local Areana API on the Mac (`:3000`, with the
`/api/` prefix). `localhost` on a phone means the phone itself, so the
dev base URL must be the Mac's LAN IP (find it with
`ipconfig getifaddr en0` on the Mac; it changes with the network).
The phone and the Mac must be on the same Wi-Fi, and the backend must
be running (`npm run start:dev` in `areana-api`).

Config is compiled in via `--dart-define-from-file` — editing a config
file requires a **full rebuild**. Hot reload does not pick it up.

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
./script.sh run development
```

or the long form:

```bash
flutter run --flavor development -t lib/main.dart \
  --dart-define-from-file=config.development.json
```

## Verify after a pull (no Flutter on the agent VM, so this is a Mac step)

```bash
git pull
flutter pub get
flutter analyze
```

Then a full rebuild — not hot restart — before testing, especially
after a config change.

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
| `API_BASE_URL` | Backend API base, with the `/api/` prefix and a trailing `/` |
| `USE_MOCK_API` | `true` = delayed mock data instead of Dio (auth only, after the migration); `false` = live API |

Edit `config.development.json` and `config.production.json`, then
rebuild fully.

See `docs/API.md` for the full Areana endpoint contract.
