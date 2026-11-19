case "$CONFIGURATION" in
  *-development)
    cp Runner/development/GoogleService-Info.plist Runner/GoogleService-Info.plist
    ;;
  *-production)
    cp Runner/production/GoogleService-Info.plist Runner/GoogleService-Info.plist
    ;;
esac
