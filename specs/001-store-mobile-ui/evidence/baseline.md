# Phase 1 Implementation Baseline

**Captured**: 2026-10-05
**Repository**: `F:/flutter_projects/doctorbike_store`
**Branch**: `feat/store-mobile-ui`
**Approved planning revision**: `6201d86f8fbf6b492837c9f7f90496ba837008a4`

## Worktree and Scope

- `git status --porcelain=v1` returned no paths before implementation began.
- Local `HEAD` matched `origin/feat/store-mobile-ui` at the approved planning revision.
- This implementation is limited to Store Flutter T001-T023. Laravel, Flutter Admin, and
  screen-specific Phase 3+ work are excluded.
- `.gitignore` already covers Dart/Flutter build output, IDE metadata, logs, temporary files,
  Android build output, and iOS generated build identifiers. No additional ignore file was needed.

## Toolchain and Platform Targets

| Boundary | Captured value | Evidence source |
|----------|----------------|-----------------|
| Flutter | 3.41.1 stable, revision `582a0e7c55` | `flutter --version` |
| Dart | 3.11.0 stable, Windows x64 | `dart --version` |
| Package SDK constraint | `^3.7.0` | `pubspec.yaml` |
| Android compile SDK | 36 | `android/app/build.gradle.kts` |
| Android minimum SDK | 26 | `android/app/build.gradle.kts` |
| iOS CocoaPods target | 15.0 | `ios/Podfile` |
| iOS Xcode project values | 13.0 | `ios/Runner.xcodeproj/project.pbxproj` |

The iOS target mismatch is recorded for later platform alignment. It is not changed in T001-T023.

## Protected Continuity Contracts

| Contract | Current authority | Compatibility rule for this phase |
|----------|-------------------|-----------------------------------|
| Session | `SharedPreferences` and `AppConstants` keys | Key strings and guest/auth continuity remain unchanged |
| Locale | `doctorBikeLanguage_code` and `doctorBikeCountry_code` | Arabic/English/Hebrew retention remains unchanged |
| Roles | `accountRoles` parsed by auth/profile models | Only `customer` and `seller` grant checkout eligibility |
| Cart | GetStorage key `cart` and `Item.toJson/fromJson2` | Preserve listing, option, quantity, and presentation snapshot fields |
| Checkout identity | `listingId`, never product ID fallback | Missing listing identity continues to block submission |
| Recovery | Opaque `resetProof` | Reset never substitutes `userId`; secrets remain redacted |
| Checkout retry | `CheckoutAttempt.client_request_id` | Coalesce in-flight taps and reuse identity until authoritative success |

## Pre-Change Automated Baseline

- `flutter test test/t140_secure_store_client_test.dart`: **PASS**, 19 tests.
- `flutter test test/t140_secure_store_client_test.dart test/widget_test.dart`: **FAIL**, because
  the stale counter template pumps `MyApp` without registering `LocalizationController`, then
  asserts nonexistent counter UI. This is the expected T002 replacement target.
- No device, live API, or rendered screenshot verification was performed for this baseline.
