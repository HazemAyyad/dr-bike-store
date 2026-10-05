# Research: Doctor Bike Store Mobile UI

**Date**: 2026-10-05
**Scope**: Repository and reference inspection for planning only; no UI implementation

## Decision 1: Evolve the Existing Architecture

**Decision**: Keep the existing GetX/controller/repository/API-client/model structure and migrate
screens incrementally behind shared design-system components.

**Rationale**: The application already has working boundaries for bootstrap, routing, localization,
authentication, catalog, cart persistence, checkout, orders, tracking, notifications, reviews, and
profile flows. Recent secure Store migration code provides listing identity, authoritative account
roles, password reset proof, client metadata, and idempotent checkout. Rewriting would add risk
without solving a demonstrated architectural blocker.

**Alternatives considered**:

- Full feature-first rewrite: rejected because it would duplicate proven commerce/security logic.
- New state-management stack: rejected because no requirement needs two coexisting stacks.
- Visual-only patching inside monolithic screens: rejected because repeated tokens/states would
  drift across 44 screen/flow contracts.

## Decision 2: Introduce a Shared Design Foundation First

**Decision**: Establish centralized Doctor Bike tokens and reusable shell/state/card/input/media
components before migrating screens.

**Rationale**: `08-design-system.png` explicitly defines palette, Cairo weights, spacing, radii,
shadows, controls, cards, navigation, skeletons, and global states. The current code repeats
colors/sizes and uses Almarai; a shared foundation is required for fidelity and safe calibration.

**Alternatives considered**:

- Copy dimensions from screenshots as hard facts: rejected because raster references do not prove
  every density-independent measurement.
- Screen-local styling: rejected because it prevents consistent calibration and regression review.

## Decision 3: Treat Uncertain Values as Calibration Tokens

**Decision**: Use the exact readable palette values from board 08, but label ambiguous spacing,
radius, elevation, typography size, and motion duration values as calibration tokens.

**Rationale**: The board provides explicit colors and scales but device/density context is not a
complete implementation measurement. Named tokens can be tuned against approved viewport captures.

**Alternatives considered**: Claim exact pixel measurements from the composite image; rejected as
false precision.

## Decision 4: Keep Backend Authority and Fail Closed

**Decision**: Continue using backend data for listings, stock, price tiers, promotions, coupons,
roles, checkout, orders, reviews, notifications, and store settings. Do not create persisted local
fallback authority for missing capabilities.

**Rationale**: The current code already relies on published listing identity and account-role
resolution for secure checkout. Local authority could create financial, inventory, or permission
errors.

**Alternatives considered**:

- Locally compute final checkout totals: rejected; client totals are previews only.
- Store fake favorite/address/payment state to unblock screens: rejected; dependencies must remain
  visible and affected controls disabled or omitted.

## Decision 5: Preserve Secure Store Client Boundaries

**Decision**: Retain opaque reset proofs, Store client metadata, redacted debug output,
`listingId`, authoritative `accountRoles`, native checkout payloads, and `client_request_id` reuse.

**Rationale**: The focused test suite proves these boundaries. They address replay, identity,
account eligibility, upgrade, and sensitive-data risks that a UI migration must not regress.

**Alternatives considered**: Reuse the legacy `typeUser`, product ID, or order payload; rejected by
existing secure migration tests and current backend contract.

## Decision 6: Separate UI State from Blocking Global Overlays

**Decision**: Model screen/section loading, empty, error, offline, refreshing, and success states
explicitly. Reserve modal/blocking progress for short sensitive mutations.

**Rationale**: Current controllers frequently use `OverlayLoadingProgress` and snackbars, which
cannot reproduce reference skeletons, inline errors, or partial section states. Explicit states
enable truthful recovery while preserving existing repositories.

**Alternatives considered**: Continue using one global spinner/error snackbar; rejected because it
cannot meet boards 02, 07, or 08 and can hide partial failures.

## Decision 7: Use a Five-Destination Shell Without Rewriting Routes

**Decision**: Replace the current three-tab Home/Cart/Profile shell presentation with the approved
Home/Categories/My Orders/Favorites/Profile destinations while retaining named detail routes and
controller bindings where compatible.

**Rationale**: The five destinations are an approved product decision shown consistently across the
references. Existing named routes can remain for secondary flows; route migration should preserve
back-stack and deep-link behavior.

**Alternatives considered**: Keep Cart as a primary bottom tab; rejected because it contradicts the
approved navigation. Cart remains a top-bar/context action.

## Decision 8: Build Media as a Typed Collection

**Decision**: Normalize product media for presentation into typed image, video, and 3D/360 entries
with stable order, thumbnail, and capability metadata.

**Rationale**: The current model separates view images, normal images, 3D images, and one video URL,
while current UI scatters gallery logic through a large detail screen. Typed presentation supports
single/multiple/media-specific states without changing backend authority.

**Alternatives considered**:

- Treat every URL as an image: rejected because video/interactive affordances would be dishonest.
- Implement 360 from a static 3D image list: rejected until a viewer-compatible contract is proven.

## Decision 9: Gate Missing Product Capabilities

**Decision**: Favorites, address book, saved payments, expanded filters, advanced order actions,
notification categories/deep links, and true 3D/360 remain dependency-gated.

**Rationale**: These are visible in references but not established in the reviewed Store client.
The overall design work can proceed while affected capabilities remain disabled, omitted, or mocked
only in non-production design tests—not persisted or presented as functioning.

**Alternatives considered**: Block the entire project until all endpoints exist; rejected because
most screens can be built and reviewed independently.

## Decision 10: Keep Cart as Intent, Revalidate Commerce

**Decision**: Continue local cart persistence for UX continuity, but treat retained values as a
presentation snapshot and revalidate listing, option, quantity, price, promotion, coupon, delivery,
and role at checkout.

**Rationale**: This preserves current behavior without transferring business authority to Flutter.

**Alternatives considered**: Eliminate local cart until a remote cart exists; rejected because it
would casually break established guest and retained-cart behavior.

## Decision 11: Phase Visual Verification

**Decision**: Each implementation task identifies its reference board and ends with a controlled
Arabic RTL comparison; the final pass covers all 44 screen/flow contracts.

**Rationale**: Visual fidelity is the primary acceptance rule. A final-only pass would allow layout
drift to compound and make remediation expensive.

**Alternatives considered**: Functional acceptance followed by optional polish; rejected because a
working but visually different screen is explicitly incomplete.

## Decision 12: Verification Layers Stay Distinct

**Decision**: Report static analysis, focused automated tests, live API checks, device journeys,
and visual comparison as separate evidence.

**Rationale**: The current two test files provide only partial coverage, and a passing analyzer does
not prove remote contracts, iOS/Android runtime behavior, or fidelity.

**Alternatives considered**: Treat `flutter analyze` and widget tests as release proof; rejected.

## Resolved Technical Context

- Flutter/Dart versions and mobile platform targets were read from the live repository/toolchain.
- All 8 reference boards were inspected at original resolution.
- All 138 Dart files were inventoried; key controllers, repositories, routes, models, persistence,
  screens, localization, theme, tests, and assets were inspected directly.
- No `NEEDS CLARIFICATION` item remains in the plan. Product/backend gaps are explicit dependencies
  with safe fallback rules, not unresolved implementation guesses.
