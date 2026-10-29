# Doctor Bike Store

Flutter storefront for Android APK distribution. Laravel also serves the administration app; preserve existing API contracts when changing the store.

## Local verification

Use Flutter 3.47.7 / Dart 3.13.5 and JDK 17. Android uses SDK 36 and NDK 27.0.12077973. Keep `pubspec.lock` committed.

```powershell
flutter pub get
flutter analyze --no-pub
./tool/test-store.ps1
```

The test script installs the publisher's Rive native runtime. On Windows it uses the same version's release DLL because the debug DLL requires development CRTs. It writes only build output. Review golden differences before updating references. Set `STORE_EXPORT_VISUALS=true` and run `test/widgets/store_locale_theme_test.dart` to export screenshots under `build/store-review/`.

The default API is production. For development or staging, explicitly pass `--dart-define=STORE_API_BASE_URL=https://your-staging-host`. Do not place production orders during automated tests.

## Signing and release

Keep package `com.mahm.doctor_bike` and the existing signing identity. The previous local APK has certificate SHA-256:

`292e8bc5add9e2da40a4b4a04d3634dbf827fa7ce3a9bad6ea599ab3fcbab293`

The keystore and passwords are untracked. Configure untracked `android/key.properties` or `STORE_SIGNING_STORE_FILE`, `STORE_SIGNING_KEY_ALIAS`, `STORE_SIGNING_KEY_PASSWORD`, and `STORE_SIGNING_STORE_PASSWORD`. Release builds fail if credentials are absent. Never replace the key or use debug signing for a release. Protect an independently recoverable copy of the original key and credentials. Removing files from the current Git tree does not remove older copies in history.

```powershell
flutter build apk --release
# Optional smaller APKs, one per CPU architecture:
flutter build apk --release --split-per-abi
```

Verify each APK with Android SDK `apksigner verify --print-certs`. Compare its certificate with the fingerprint above and inspect package/version with `aapt dump badging`. Install it over the old APK on a real phone without uninstalling; verify the existing cart, locale and session migration. Build success alone does not verify an upgrade on a phone.

GitHub Actions validates analysis and tests. Its manual APK job requires `STORE_SIGNING_KEYSTORE_BASE64` and the three alias/password secrets. The keystore is reconstructed only in runner temporary storage. CI artifacts do not publish the APK to customers.

## Sessions and diagnostics

Sessions migrate from preferences to verified secure storage before removing the old token. Logout revocations queue in secure storage while offline and retry on connectivity recovery or resume. Account changes clear private controller caches and reject older reads; the guest cart remains available.

Crashlytics collects sanitized error type and stack in Android/iOS release builds. Collection is disabled in debug/test and on unsupported platforms. Do not add personal data, tokens, request bodies or user identifiers. Confirm a test crash reaches the intended Firebase project on a release device before treating remote monitoring as verified.

## Rollout and rollback

Release compatible Laravel endpoints before distributing the APK. The first catalog page falls back to the legacy route when the added endpoint returns 404. Record server revision, APK hashes, build number, certificate and test evidence. Keep the previous APK and server revision, start with a pilot group, and observe authentication, shipping, checkout/replay, API duration and sanitized crash reports for 48 hours.

Smoke checks cover guest browsing/cart, login/logout online and offline, expired tokens, addresses, explicit zero shipping, unavailable shipping, coupon/stock rejection, retry and all three languages in light/dark modes. Production deployment, migrations, real device upgrade and monitoring need separate recorded evidence. Roll back compatible server code without reversing financial records or dropping data. Android normally rejects lower build numbers; prepare a higher-numbered recovery APK with the same signing key when needed.
