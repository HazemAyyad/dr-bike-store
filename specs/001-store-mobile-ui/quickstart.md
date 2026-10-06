# Validation Quickstart: Doctor Bike Store Mobile UI

This is a post-implementation validation guide. It does not authorize backend changes, production
mutation, app-store release, APK creation, or interruption of an existing device session.

## Prerequisites

- Work from `F:/flutter_projects/doctorbike_store` on `feat/store-mobile-ui`.
- Use the repository's pinned dependency lockfile and a compatible Flutter stable toolchain.
- Keep a non-production Store account for authenticated journeys.
- Use a disposable/non-production order environment before running checkout/cancellation scenarios.
- Ensure all eight files under `docs/design-reference/` are locally available.
- Select reference devices/viewports for Android and iOS and record text scale, pixel ratio, locale,
  theme, OS, app version/build, and API environment.

## 1. Scope and Artifact Checks

```bash
git branch --show-current
git status --short
git diff --name-only origin/feat/store-mobile-ui...HEAD
```

Expected: current branch remains `feat/store-mobile-ui`; no Laravel or Flutter Admin path appears.

Verify reference coverage:

```bash
find docs/design-reference -maxdepth 1 -type f -name '*.png' | sort
grep -c '^| SCR-' specs/001-store-mobile-ui/screen-inventory.md
```

Expected: 8 reference PNGs and 44 screen inventory entries.

## 2. Dependency and Static Checks

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
```

For a phase PR, also run targeted analysis on changed Dart files and record whether broad analysis
contains unrelated pre-existing findings. Static success is not live/API/device proof.

## 3. Automated Tests

Always preserve the secure Store baseline:

```bash
flutter test test/t140_secure_store_client_test.dart
```

Then run phase-specific contract, controller, widget, and journey tests, followed by the full suite:

```bash
flutter test test/contracts
flutter test test/controllers
flutter test test/widgets
flutter test test/journeys
flutter test
```

Directories that do not yet exist are implementation outputs and should be invoked only after their
phase adds them. Replace the stale counter template test before treating the full suite as evidence.

## 4. Safe Live API Contract Checks

Use read-only calls or the app's non-production environment to verify:

1. store settings/startup policy;
2. inventory sections and published listing payload types;
3. product detail/media/options/listing identity;
4. search and filter/sort capabilities;
5. profile/account roles and Shiply city/village/fee data;
6. orders, status logs, tracking, notifications, and reviews;
7. capability gaps recorded in [api-mapping.md](api-mapping.md).

Do not submit checkout, cancel orders, delete accounts, or create reviews against production-like
data merely to satisfy this guide. Those mutations require an explicitly disposable test context.

## 5. Device Journey Matrix

Run on both a supported Android device/emulator and iOS device/simulator where available:

- first launch -> animated splash -> onboarding -> guest home;
- returning guest and authenticated return;
- offline launch, refresh failure, store closed, required upgrade;
- login, registration, recovery, OTP, reset, logout;
- Home -> Categories/Search -> Listing -> Product detail -> media variants;
- favorite behavior according to confirmed capability;
- cart restore -> quantity/remove/coupon -> checkout steps;
- duplicate checkout tap and uncertain retry with same request identity in a disposable environment;
- order list -> detail -> tracking -> authorized actions;
- notifications/read behavior, reviews, profile/account, addresses/payment gates, language/settings;
- background/foreground, keyboard, safe areas, small screen, and supported text scaling.

Record API environment and distinguish a UI-only check from confirmed server behavior.

## 6. Visual Fidelity Pass

For each phase:

1. Set Arabic, RTL, light theme, agreed viewport, and normal text scale.
2. Seed only safe deterministic test data matching the state being compared.
3. Capture every mapped screen and meaningful state.
4. Compare against [design-reference-mapping.md](design-reference-mapping.md) using the criteria in
   [visual-fidelity-contract.md](contracts/visual-fidelity-contract.md).
5. Resolve blocking/high differences; tune shared calibration tokens for smaller differences.
6. Recheck representative previously accepted screens after shared-token changes.
7. Record any technically necessary deviation and approval.

## 7. Release Gate

Release readiness requires all of the following, reported separately:

- targeted and full static-analysis result;
- focused and full automated-test result;
- live API contract result and environment;
- Android/iOS device journey result;
- visual comparison coverage and unresolved differences;
- accessibility/RTL result;
- backend gap status and disabled/omitted capability behavior;
- staged diff proving no Laravel/Admin changes;
- checkout safety evidence for listing IDs, role choice, and idempotency.

A passing analyzer or HTTP 200 is never sufficient by itself.
