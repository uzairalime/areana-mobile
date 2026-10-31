#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

usage() {
  cat <<'USAGE'
Usage:
  ./script.sh setup
  ./script.sh run [development|production] [Flutter run options...]
  ./script.sh build [apk|appbundle|ios|ipa|web] [development|production] [--debug|--release]
  ./script.sh pods

Examples:
  ./script.sh setup
  ./script.sh run development
  ./script.sh run production -d <device-id>
  ./script.sh build apk development --debug
  ./script.sh build apk production --release
  ./script.sh build appbundle production --release
  ./script.sh build ipa production --release
  ./script.sh build web development --release
  ./script.sh pods

Flutter is selected through the project FVM configuration. Android and iOS
commands use the matching flavor and config.*.json file.
USAGE
}

valid_flavor() {
  [[ "$1" == "development" || "$1" == "production" ]]
}

config_for() {
  printf 'config.%s.json' "$1"
}

if [[ $# -eq 0 || "$1" == "help" || "$1" == "--help" || "$1" == "-h" ]]; then
  usage
  exit 0
fi

ACTION="$1"
case "$ACTION" in
  setup)
    fvm flutter pub get
    ;;
  run)
    FLAVOR="${2:-development}"
    if ! valid_flavor "$FLAVOR"; then
      echo "Invalid flavor: $FLAVOR (use development or production)." >&2
      exit 2
    fi
    shift "$(( $# >= 2 ? 2 : $# ))"
    fvm flutter run --flavor "$FLAVOR" -t lib/main.dart \
      --dart-define-from-file="$(config_for "$FLAVOR")" "$@"
    ;;
  build)
    TYPE="${2:-apk}"
    FLAVOR="${3:-development}"
    MODE="${4:---release}"
    if ! valid_flavor "$FLAVOR"; then
      echo "Invalid flavor: $FLAVOR (use development or production)." >&2
      exit 2
    fi
    if [[ "$MODE" != "--debug" && "$MODE" != "--release" ]]; then
      echo "Invalid build mode: $MODE (use --debug or --release)." >&2
      exit 2
    fi
    CONFIG="$(config_for "$FLAVOR")"
    case "$TYPE" in
      apk)
        fvm flutter build apk --flavor "$FLAVOR" "$MODE" -t lib/main.dart \
          --dart-define-from-file="$CONFIG"
        ;;
      appbundle)
        fvm flutter build appbundle --flavor "$FLAVOR" "$MODE" -t lib/main.dart \
          --dart-define-from-file="$CONFIG"
        ;;
      ios)
        fvm flutter build ios --flavor "$FLAVOR" "$MODE" -t lib/main.dart \
          --dart-define-from-file="$CONFIG"
        ;;
      ipa)
        fvm flutter build ipa --flavor "$FLAVOR" "$MODE" -t lib/main.dart \
          --dart-define-from-file="$CONFIG"
        ;;
      web)
        fvm flutter build web "$MODE" -t lib/main.dart \
          --dart-define-from-file="$CONFIG"
        ;;
      *)
        echo "Invalid build type: $TYPE (use apk, appbundle, ios, ipa, or web)." >&2
        exit 2
        ;;
    esac
    ;;
  pods)
    (cd ios && pod install)
    ;;
  *)
    echo "Invalid action: $ACTION" >&2
    usage >&2
    exit 2
    ;;
esac
