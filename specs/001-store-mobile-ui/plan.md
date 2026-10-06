# Implementation Plan: Doctor Bike Store Mobile UI

**Branch**: `feat/store-mobile-ui` | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-store-mobile-ui/spec.md`

## Summary

Evolve the existing Doctor Bike Store mobile application into the approved Arabic-first RTL
experience without a rewrite. Preserve proven session, repository, API, typed-model, cart,
checkout-idempotency, account-role, order, tracking, notification, and review boundaries. Build a
central Cairo-based design foundation, then refactor or add screens in reviewable phases. Every
phase maps directly to the eight approved boards, implements truthful global states, and ends with
screen-level visual comparison. Backend or Admin work is excluded; contract gaps are documented
and optional UI remains disabled or omitted until authoritative support exists.

## Technical Context

**Language/Version**: Dart SDK 3.11.0; Flutter 3.41.1 stable; package SDK constraint `^3.7.0`

**Primary Dependencies**: Flutter Material, GetX 4.6.6, flutter_screenutil 5.9.3, http 1.2.1,
GetStorage 2.1.1, SharedPreferences 2.5.3, cached_network_image 3.3.1, carousel_slider 5.0.0,
video_player 2.9.3, Firebase Core/Messaging, flutter_local_notifications, connectivity tools,
share_plus, screenshot, intl, flutter_svg

**Storage**: SharedPreferences for session/locale/first-run values; GetStorage for the local cart;
remote Laravel-backed API for authoritative commerce and identity state

**Testing**: flutter_test with focused model/repository/checkout contract tests, controller/widget
state tests added by phase, targeted `flutter analyze`, device journey checks, and reference-image
visual comparison. Existing automated baseline contains 22 secure Store client tests plus one stale
template widget test.

**Target Platform**: Android minSdk 26 and iOS 15.0 deployment target (Podfile authority; Xcode
project currently contains 13.0 values that require alignment review before implementation)

**Project Type**: Existing cross-platform mobile application; no backend source in scope

**Performance Goals**: Maintain fluid 60 fps interaction on supported phones; prevent redundant
home/search requests and duplicate checkout submissions; display immediate skeleton/state feedback
for network reads; measure final thresholds on representative devices instead of inventing them

**Constraints**: Arabic-first RTL; approved screenshots are visual authority; Cairo typography;
reuse sound architecture; backend-authoritative business state; current branch only; no Laravel or
Flutter Admin changes; planning task introduces no UI implementation

**Scale/Scope**: 44 documented screens/flows, 8 reference boards, 138 existing Dart files, four
repositories, ten controllers/services, 17 primary routed destinations, Android and iOS

## Constitution Check

*GATE: PASS before Phase 0 research; PASS again after Phase 1 design.*

| Gate | Result | Evidence / enforcement |
|------|--------|------------------------|
| Approved references govern visual output | PASS | [design-reference-mapping.md](design-reference-mapping.md) accounts for all eight boards and every implementation phase has a fidelity gate |
| Arabic RTL and Cairo are first-class | PASS | Foundation phase defines direction/type tokens before screen work; Arabic is the baseline acceptance locale |
| Sound architecture is reused | PASS | [existing-code-reuse-audit.md](existing-code-reuse-audit.md) classifies current code; no rewrite is planned |
| Backend owns business state | PASS | [api-mapping.md](api-mapping.md) separates verified contracts from gaps and safe fallbacks |
| Typed contracts and identity safety | PASS | Existing listing-ID, account-role, reset-proof, and idempotency boundaries are retained in [data-model.md](data-model.md) |
| Shared foundations precede duplication | PASS | Phase 1 implements tokens and reusable components before feature screens |
| Complete async states | PASS | UI state contract covers loading, empty, error, offline, success, refresh, and media failure |
| Session/cart continuity and security | PASS | Migration tests precede changes to startup, persistence, identity, or checkout |
| Failures remain failures | PASS | Success requires typed authoritative payloads; malformed HTTP success remains an error |
| Strict repository scope | PASS | All planned paths are Store Flutter or `specs/`; Laravel/Admin are explicitly excluded |
| Phased review and visual verification | PASS | Eleven implementation phases each have independent functional and visual acceptance |

No constitution violation or complexity exception is requested.

## Project Structure

### Documentation (this feature)

```text
specs/001-store-mobile-ui/
├── spec.md
├── plan.md
├── research.md
├── clarifications.md
├── data-model.md
├── quickstart.md
├── screen-inventory.md
├── existing-code-reuse-audit.md
├── api-mapping.md
├── design-reference-mapping.md
├── contracts/
│   ├── api-ui-contract.md
│   ├── ui-state-contract.md
│   └── visual-fidelity-contract.md
├── checklists/
│   ├── requirements.md
│   └── implementation.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── my_app.dart
├── controller/                 # Existing GetX state/orchestration
├── repository/                 # Existing API boundary by domain
├── core/
│   ├── api_client.dart
│   ├── bindings/               # Dependency registration
│   ├── constants/              # Current constants; future design tokens
│   ├── functions/              # Session, checkout, notification helpers
│   ├── helper/                 # Routes, cache, DI
│   ├── locale/                 # Arabic/English/Hebrew translations
│   ├── model/                  # Existing typed transport/domain models
│   ├── theme/                  # Current light/dark theme
│   └── widget/                 # Current shared widgets
└── features/
    ├── splash, onbarding, intro, auth
    ├── home_screen, search, category, supCategory
    ├── product, shop, order, notification
    ├── acount, lang
    └── <new feature folders only where the audit marks missing>

assets/
├── images/
├── svg/
└── font/                       # Existing Almarai; Cairo asset to be added in implementation

test/
├── t140_secure_store_client_test.dart
├── widget_test.dart            # Stale template test; replace during implementation
├── contracts/                  # Planned typed API/persistence tests
├── controllers/                # Planned state-transition tests
├── widgets/                    # Planned component/state tests
└── journeys/                   # Planned high-risk journey tests
```

**Structure Decision**: Retain the existing layered Flutter structure and migrate incrementally.
Introduce centralized design tokens and shared state/components under `lib/core/`; keep domain
controllers/repositories/models in their current boundaries unless the reuse audit identifies a
functional contract problem. Add missing feature folders such as favorites or addresses only after
their backend authority is resolved. Do not add a second state-management or networking stack.

## Phased Implementation Strategy

### Phase 0 - Contract and Baseline Lock

- Preserve current session, cart, reset-proof, listing identity, account roles, and idempotency
  behavior with focused tests.
- Capture the current route/API/persistence baseline and resolve critical backend dependencies.
- Agree on reference viewport/device matrix and visual-diff tolerance.

**Visual gate**: all eight reference boards have traceable ownership before UI changes.

### Phase 1 - Shared Design System and State Foundation

- Add Cairo assets and centralized color, type, spacing, radius, shadow, icon, and motion tokens.
- Build reusable app bar, expandable search, bottom navigation, buttons, fields, chips, product and
  category cards, media placeholders, skeletons, and global state components.
- Preserve compatibility wrappers for current widgets during migration.

**Visual gate**: components are compared directly with `08-design-system.png` in Arabic RTL.

### Phase 2 - Splash, Onboarding, and Authentication

- Implement SCR-01 through SCR-10 with startup, first-run, maintenance/update, login,
  registration, recovery, OTP, and password states.
- Retain proof-bound reset, redacted logs, account-block handling, and existing session keys.

**Visual gate**: compare all auth and onboarding states to boards 01 and 02.

### Phase 3 - Main Shell, Home, and Search

- Implement the five-destination shell, approved top bar, expandable search, compact Home,
  skeleton refresh, recent search, and results/empty states.
- Reuse current home/catalog repositories while splitting section state from global overlays.

**Visual gate**: compare shell, Home, search, and loading states to boards 06, 07, and 08.

### Phase 4 - Categories, Listings, and Filters

- Implement inventory-section hierarchy, product list/grid, sort/filter sheet, product cards, and
  no-product/offline/error states.
- Keep only verified filters interactive; document dependencies for brand/rating/stock filtering.

**Visual gate**: compare category/list/filter/cards to boards 02, 06, and 08.

### Phase 5 - Product Detail and Media

- Refactor product detail into reusable sections and typed media presentation.
- Implement image gallery and video; enable 3D/360 only after a real asset/viewer contract.
- Integrate rating/review presentation, options, quantity, stock, cart, buy-now, and policy areas.

**Visual gate**: compare every single/multiple/image/video/3D state to boards 04 and 05.

### Phase 6 - Favorites and Cart

- Add favorites only after persistence authority is resolved.
- Refactor cart around stable cart-line identity, selection/quantity/remove/coupon intent, and
  authoritative revalidation at checkout.

**Visual gate**: compare favorites/cart to boards 02, 03, 06, and product-card tokens in 08.

### Phase 7 - Checkout

- Split address, shipping, payment, review/submission, and success into explicit steps.
- Keep account-role choice, listing IDs, COD limitations, Shiply quote, coupon validation, and
  checkout-attempt idempotency authoritative.

**Visual gate**: compare all three steps and success to boards 03 and 06.

### Phase 8 - Orders and Tracking

- Refactor list/status tabs, order snapshot detail, logs, Shiply timeline, and eligible actions.
- Expose only server-authorized cancellation and other actions.

**Visual gate**: compare list/detail/summary/tracking/actions to boards 02, 03, and 06.

### Phase 9 - Profile, Settings, Notifications, and Reviews

- Implement profile hierarchy, account data, addresses/payment capability gates, language,
  settings, support, notification categories/read state, review mutation, logout, and deletion.

**Visual gate**: compare profile/authenticated states and global messages to boards 02 and 08.

### Phase 10 - States, Accessibility, and Fidelity Polish

- Complete skeleton, empty, no-result, no-product, offline, error, success, placeholder, and refresh
  coverage across all phases.
- Validate RTL/LTR text mixtures, semantics, text scale, safe areas, keyboard behavior, and small
  screens. Resolve calibrated token differences with documented screenshot comparisons.

**Visual gate**: no unapproved high-impact difference remains in the 44-screen matrix.

### Phase 11 - Integration and Release Verification

- Run targeted static/automated checks, live API contract verification, Android/iOS device journeys,
  checkout retry/replay checks, notification deep links, and visual regression capture.
- Report static, device, API, and visual evidence separately.

**Visual gate**: final reference matrix is signed off for all implemented supported states.

## Dependency Order

`Phase 0 -> Phase 1 -> {Phase 2, Phase 3} -> Phase 4 -> Phase 5 -> Phase 6 -> Phase 7 -> Phase 8`

Phase 9 can begin after Phase 1 and the relevant backend gaps resolve. Phase 10 consumes every
implemented phase. Phase 11 is final. A phase may ship independently only when its linked shell,
state, contract, and visual gates pass.

## Complexity Tracking

No constitution violations. The plan deliberately preserves one application, one state-management
approach, one API client, and existing repository boundaries.

## Post-Design Constitution Re-check

*GATE: PASS.* The data model retains backend authority and typed identities; interface contracts
make unsupported features explicit; the UI state contract prohibits silent success; visual mapping
covers all references; implementation is phased and scoped to Store Flutter paths only.
