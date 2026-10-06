---
description: "Dependency-ordered implementation tasks for the Doctor Bike Store mobile UI"
---

# Tasks: Doctor Bike Store Mobile UI

**Input**: Design documents in `specs/001-store-mobile-ui/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `api-mapping.md`,
`screen-inventory.md`, `existing-code-reuse-audit.md`, `design-reference-mapping.md`, and `contracts/`

**Tests**: Focused automated tests are required by FR-041 for changed contract, authentication,
persistence, cart, and checkout behavior. Device, live API, and visual checks are separate evidence.

**Format**: Every item follows `- [ ] T### [P?] [US#?] Description with file path`.

## Phase 1: Baseline and Contract Lock

**Purpose**: Freeze current behavior and resolve implementation blockers before UI migration.

- [x] T001 Record the implementation-start branch, Flutter/Dart versions, Android/iOS targets, and clean-worktree evidence in `specs/001-store-mobile-ui/evidence/baseline.md`
- [x] T002 [P] Replace the stale counter test with an app bootstrap smoke test in `test/widget_test.dart`
- [x] T003 [P] Add regression coverage for retained session keys, locale, and account-role parsing in `test/contracts/session_contract_test.dart`
- [x] T004 [P] Add regression coverage for cart-line serialization, `listingId`, options, and quantity in `test/contracts/cart_persistence_contract_test.dart`
- [x] T005 [P] Add regression coverage for password-reset proof handling and redacted diagnostics in `test/contracts/recovery_contract_test.dart`
- [x] T006 Extend checkout-attempt replay and duplicate-submit coverage in `test/t140_secure_store_client_test.dart`
- [x] T007 Resolve each critical capability decision for favorites, address books, saved payment methods, advanced filters, and 3D/360 in `specs/001-store-mobile-ui/evidence/backend-capabilities.md`
- [x] T008 Define reference viewport sizes, supported device matrix, screenshot naming, and visual-diff tolerance in `specs/001-store-mobile-ui/evidence/visual-baseline.md`
- [x] T009 Capture ownership and planned implementation phase for all eight boards and all 44 screen contracts in `specs/001-store-mobile-ui/evidence/reference-ownership.md`

**Checkpoint**: Existing security and persistence behavior is protected, every blocking backend gap has
an owner or an explicit capability-off decision, and the visual comparison method is reproducible.

---

## Phase 2: Shared Design and State Foundation

**Purpose**: Establish the reusable visual/state layer that blocks all screen work.

- [x] T010 Add approved Cairo font assets and declare required weights in `pubspec.yaml` and `assets/font/`
- [x] T011 [P] Define approved palette, spacing, radii, elevation, icon sizes, and motion tokens in `lib/core/theme/store_tokens.dart`
- [x] T012 [P] Define Cairo typography roles and Arabic-first text styles in `lib/core/theme/store_typography.dart`
- [x] T013 Integrate Store tokens and typography without breaking theme persistence in `lib/core/theme/light.dart` and `lib/core/functions/theme_services.dart`
- [x] T014 [P] Add typed loading, content, empty, offline, error, and success presentation states in `lib/core/classes/store_view_state.dart`
- [x] T015 [P] Build accessible primary, secondary, text, and destructive controls in `lib/core/widget/store_buttons.dart`
- [x] T016 [P] Build RTL-safe fields, password fields, selectors, and validation presentation in `lib/core/widget/store_fields.dart`
- [x] T017 [P] Build shared product, category, status, discount, rating, and filter chips in `lib/core/widget/store_cards.dart` and `lib/core/widget/store_chips.dart`
- [x] T018 [P] Build stable media placeholder, broken-image fallback, and typed media badge in `lib/core/widget/store_media.dart`
- [x] T019 [P] Build skeleton, empty, offline, error, success, and pull-to-refresh wrappers in `lib/core/widget/store_states.dart`
- [x] T020 Build the reusable customer top bar and inline expandable search in `lib/core/widget/store_top_bar.dart`
- [x] T021 Build the five-destination RTL-safe bottom navigation in `lib/core/widget/store_bottom_navigation.dart`
- [x] T022 [P] Add widget coverage for tokens, RTL layout, semantics, and text scaling in `test/widgets/store_foundation_test.dart`
- [x] T023 Compare shared components against `docs/design-reference/08-design-system.png` and record annotated pass/fail evidence in `specs/001-store-mobile-ui/evidence/phase-02-visual.md`

**Checkpoint**: The design foundation passes Arabic RTL, semantics, scaling, and board-08 visual review;
compatibility wrappers allow incremental migration of existing screens.

---

## Phase 3: User Story 1 - Recognizable and Safe App Entry (Priority: P1) MVP

**Goal**: Route every launch deterministically through branded startup, onboarding, maintenance, and
upgrade decisions without hiding failures.

**Independent Test**: Launch as first-run, returning guest, valid user, offline user, store-closed,
recommended-upgrade, and mandatory-upgrade; verify each reaches its permitted destination.

- [x] T024 [P] [US1] Add startup-decision tests for first run, session, offline, maintenance, and upgrade paths in `test/controllers/startup_controller_test.dart`
- [x] T025 [US1] Extract a deterministic startup decision model from launch side effects in `lib/controller/check_account/account_service.dart`
- [x] T026 [US1] Implement the bounded logo sequence, progress cue, timeout-safe error state, and reduced-motion fallback in `lib/features/splash/splash.dart`
- [x] T027 [US1] Rebuild the three approved onboarding pages with retained completion and skip/start routing in `lib/features/onbarding/onbarding.dart`
- [x] T028 [P] [US1] Add truthful maintenance/store-closed presentation in `lib/features/splash/store_unavailable_screen.dart`
- [x] T029 [P] [US1] Add required and recommended upgrade presentation with capability-safe actions in `lib/features/splash/update_required_screen.dart`
- [x] T030 [US1] Register startup, onboarding, maintenance, and upgrade routes without changing protected route semantics in `lib/core/helper/route_helper.dart`
- [x] T031 [US1] Compare SCR-01 through SCR-05 with boards 01, 02, and 07 and record annotated results in `specs/001-store-mobile-ui/evidence/phase-03-us1-visual.md`

**Checkpoint**: US1 is independently testable and failed initialization never appears as catalog success.

---

## Phase 4: User Story 2 - Authenticate and Recover Access (Priority: P1)

**Goal**: Deliver contract-accurate login, registration, OTP, and proof-bound password recovery.

**Independent Test**: Complete valid and invalid login/registration/recovery flows, including blocked
accounts, expired OTP, resend countdown, upgrade requirement, and offline behavior.

- [x] T032 [P] [US2] Add controller tests for validation, blocked users, OTP expiry/resend, and proof-bound reset in `test/controllers/auth_flow_test.dart`
- [x] T033 [US2] Normalize auth result types and prevent secrets from reaching logs or display errors in `lib/repository/auth/auth_repository.dart`
- [x] T034 [US2] Refactor login orchestration to preserve session and role authority in `lib/controller/auth/login.controller.dart`
- [x] T035 [P] [US2] Rebuild the login screen with approved fields, reveal behavior, gates, and states in `lib/features/auth/signin/sign_in_screen.dart`
- [x] T036 [P] [US2] Rebuild registration with only backend-supported identity fields and terms consent in `lib/features/auth/signup/sign_up_screen.dart`
- [x] T037 [US2] Refactor recovery request, OTP countdown/resend, and opaque reset-proof transitions in `lib/controller/auth/forgetpassword.controller.dart`
- [x] T038 [US2] Rebuild recovery request and OTP screens in `lib/features/auth/forget_password/forget_password_page.dart` and `lib/features/auth/forget_password/otp_page.dart`
- [x] T039 [US2] Rebuild new-password and recovery-complete screens in `lib/features/auth/reset password/change_password_screen.dart` and `lib/features/auth/forget_password/done_screen.dart`
- [x] T040 [US2] Compare SCR-06 through SCR-10 with boards 01 and 02 and record annotated results in `specs/001-store-mobile-ui/evidence/phase-04-us2-visual.md`

**Checkpoint**: US2 works independently; reset proof, blocked state, and failures remain authoritative.

---

## Phase 5: User Story 3 - Browse a Compact Store Home (Priority: P1)

**Goal**: Provide the approved five-tab shell, top bar, compact Home, expandable search, skeletons,
recent queries, and honest results states.

**Independent Test**: Reach every shell destination with one tap, browse Home, expand/cancel search,
submit a query, clear recent searches, refresh, and distinguish zero results from failures.

- [x] T041 [P] [US3] Add shell navigation, guest-gate, back behavior, and search-state tests in `test/controllers/shell_search_test.dart`
- [x] T042 [US3] Replace the three-destination shell with Home, Categories, My Orders, Favorites, and Profile in `lib/features/home_screen/home_screen.dart`
- [x] T043 [US3] Coordinate destination state, badge counts, guest gates, and state restoration in `lib/controller/home/home_controller.dart`
- [x] T044 [US3] Recompose Home into hero, quick categories, best sellers, service, store categories, offers, and new arrivals in `lib/features/home_screen/home_page.dart`
- [x] T045 [P] [US3] Refactor hero and promotional content to consume only repository-backed data in `lib/features/home_screen/widget/promo.dart`
- [x] T046 [P] [US3] Refactor inventory-section shortcuts and product groups into compact reusable sections in `lib/features/home_screen/widget/main_categorys.dart`
- [x] T047 [US3] Implement recent-query persistence and explicit clear behavior in `lib/core/helper/search_history_store.dart`
- [x] T048 [US3] Rebuild query discovery, results, no-results, offline, error, refresh, sort, and filter entry in `lib/features/search/search_screen.dart`
- [x] T049 [US3] Compare SCR-11 through SCR-15 with boards 02, 06, 07, and 08 and record annotated results in `specs/001-store-mobile-ui/evidence/phase-05-us3-visual.md`

**Checkpoint**: US3 is independently navigable and each async state has distinct copy and action.

---

## Phase 6: User Story 4 - Search, Categorize, Sort, and Filter (Priority: P1)

**Goal**: Browse inventory-backed sections and compare products using only supported sorting/filtering.

**Independent Test**: Open a section, switch list/grid, sort, apply/reset supported filters, refresh,
and verify authoritative prices, stock, ratings, discounts, and listing identity.

- [x] T050 [P] [US4] Add parsing and controller tests for Online Store categories, product cards, capability gates, pagination metadata, and failure states in `test/controllers/catalog_browse_test.dart`
- [x] T051 [US4] Replace ambiguous category state with typed Online Store category and listing states in `lib/controller/categores/categores_controller.dart`
- [x] T052 [US4] Normalize Online Store category/listing response parsing and reject incompatible field types in `lib/repository/categories/categories_repository.dart`
- [x] T053 [US4] Rebuild the Online Store category hierarchy and complete async states in `lib/features/category/category_screen.dart` and `lib/features/home_screen/home_screen.dart`
- [x] T054 [P] [US4] Rebuild authoritative product grid cards with availability, pricing, rating, favorite capability, and cart action in `lib/features/category/widget/build_grid_view.dart`
- [x] T055 [P] [US4] Rebuild authoritative product list cards with matching behavior in `lib/features/category/widget/build_list_view.dart`
- [x] T056 [US4] Implement list/grid switch and refresh while omitting unsupported pagination and selected-filter claims in `lib/features/category/category_and_filtter.dart`
- [x] T057 [US4] Gate unsupported server filtering and sorting with truthful unavailable presentation in `lib/features/category/filter_screen.dart`
- [x] T058 [US4] Compare SCR-16 through SCR-18 with boards 02, 06, and 08 and record annotated results in `specs/001-store-mobile-ui/evidence/phase-06-us4-visual.md`

**Checkpoint**: US4 works independently and unsupported filters are omitted or visibly disabled.

---

## Phase 7: User Story 5 - Evaluate Product and Media (Priority: P1)

**Goal**: Support a purchase decision with authoritative product detail and typed image/video/360 media.

**Independent Test**: Open single- and multi-image products, valid/invalid video, missing media,
supported 360 media, options, quantities, reviews, similar items, share, cart, and buy-now.

- [ ] T059 [P] [US5] Add typed product/media parsing and controller-state tests in `test/controllers/product_detail_test.dart`
- [ ] T060 [US5] Split product-detail orchestration into identity, media, option, quantity, review, and purchase state in `lib/controller/product/product_controller.dart`
- [ ] T061 [US5] Introduce explicit image, video, and interactive-360 media capability types in `lib/core/model/product_media_model.dart`
- [ ] T062 [US5] Recompose the monolithic product page into approved hierarchy and reusable sections in `lib/features/product/product_details_screen.dart`
- [ ] T063 [P] [US5] Rebuild fullscreen image gallery with index, swipe/arrows, zoom, thumbnails, and fallback in `lib/features/product/widget/image_view.dart`
- [ ] T064 [P] [US5] Rebuild video presentation with poster, controls, progress, fullscreen, and terminal error in `lib/features/product/widget/video_view.dart`
- [ ] T065 [US5] Add a capability-gated interactive viewer or explicit unavailable presentation in `lib/features/product/widget/product_360_view.dart`
- [ ] T066 [US5] Coordinate typed thumbnail selection and fullscreen navigation in `lib/features/product/widget/view_image_and_video.dart`
- [ ] T067 [P] [US5] Refactor reviews and similar items to shared cards and honest states in `lib/features/product/widget/commints.dart` and `lib/features/product/widget/items_similar.dart`
- [ ] T068 [US5] Compare SCR-19 through SCR-22 with every media variant in boards 04 and 05 and record annotated results in `specs/001-store-mobile-ui/evidence/phase-07-us5-visual.md`

**Checkpoint**: US5 works independently; no static image is labeled interactive and no bad video spins forever.

---

## Phase 8: User Story 6 - Retain Favorites and Cart Choices (Priority: P1)

**Goal**: Retain a trustworthy shortlist and stable cart intent while preserving authoritative revalidation.

**Independent Test**: Add/remove favorites as guest and user per resolved policy; add option variants to
cart, change quantity, remove lines, apply coupon intent, restart the app, and preserve line identity.

- [ ] T069 [P] [US6] Add favorites authority, guest policy, persistence, and failure-transition tests in `test/controllers/favorites_controller_test.dart`
- [ ] T070 [P] [US6] Add cart identity, quantity, coupon intent, retained restart, and invalid-listing tests in `test/controllers/cart_controller_test.dart`
- [ ] T071 [US6] Implement favorites repository behavior only for the resolved authority in `lib/repository/favorites/favorites_repository.dart`
- [ ] T072 [US6] Implement capability-gated favorites orchestration and guest/auth transitions in `lib/controller/favorites/favorites_controller.dart`
- [ ] T073 [US6] Build favorites content, remove, add-to-cart, loading, empty, offline, and error states in `lib/features/favorites/favorites_screen.dart`
- [ ] T074 [US6] Refactor cart state around stable listing/option identity and server-revalidation boundaries in `lib/controller/shop/shop_controller.dart`
- [ ] T075 [US6] Rebuild cart layout, summary, coupon entry, clear/remove confirmations, and checkout gate in `lib/features/shop/shop_car_screen.dart`
- [ ] T076 [P] [US6] Refactor cart line, quantity, media, availability, and option presentation in `lib/features/shop/widget/item_shop_car.dart`
- [ ] T077 [P] [US6] Align empty-cart and bill-summary components with shared global states/tokens in `lib/features/shop/widget/empty_car.dart` and `lib/features/shop/widget/bill_details.dart`
- [ ] T078 [US6] Compare SCR-23 and SCR-24 with boards 02, 03, 06, and 08 and record annotated results in `specs/001-store-mobile-ui/evidence/phase-08-us6-visual.md`

**Checkpoint**: US6 works under the resolved favorites policy; retained cart remains intent, not authority.

---

## Phase 9: User Story 7 - Complete an Idempotent Checkout (Priority: P1)

**Goal**: Complete address, delivery, supported payment, authoritative submission, and success exactly once.

**Independent Test**: Complete COD checkout across address and Shiply choices, dual-role selection,
coupon/fee changes, rapid duplicate taps, timeout/retry, malformed success, and confirmed success.

- [ ] T079 [P] [US7] Add address/delivery/payment capability and checkout transition tests in `test/controllers/checkout_flow_test.dart`
- [ ] T080 [US7] Split checkout state into address, quote, payment, review, submitting, uncertain, and success states in `lib/controller/shop/shop_controller.dart`
- [ ] T081 [US7] Preserve listing IDs, account roles, coupon, Shiply destination, and idempotency in request mapping in `lib/repository/shop/shop_repository.dart`
- [ ] T082 [US7] Rebuild checkout as explicit address, shipping, payment, and review steps in `lib/features/shop/check_out_screen.dart`
- [ ] T083 [P] [US7] Build capability-gated address selection/editor with documented profile fallback in `lib/features/shop/widget/checkout_address_step.dart`
- [ ] T084 [P] [US7] Build authoritative Shiply destination, fee, method, pickup, and time controls in `lib/features/shop/widget/checkout_shipping_step.dart`
- [ ] T085 [P] [US7] Build supported-payment-only selection and role-choice presentation in `lib/features/shop/widget/checkout_payment_step.dart`
- [ ] T086 [US7] Add final review, in-flight lock, uncertain retry, and recoverable validation presentation in `lib/features/shop/widget/checkout_review_step.dart`
- [ ] T087 [US7] Require an authoritative order identity before clearing cart and rebuild success actions in `lib/features/shop/check_out_done.dart`
- [ ] T088 [US7] Compare SCR-25 through SCR-29 with boards 03 and 06 and record annotated results in `specs/001-store-mobile-ui/evidence/phase-09-us7-visual.md`

**Checkpoint**: US7 is independently testable; retries reuse the attempt identity and unsupported payment promises are absent.

---

## Phase 10: User Story 8 - Review and Act on Orders (Priority: P2)

**Goal**: Present authoritative order history, snapshots, tracking, and only eligible post-order actions.

**Independent Test**: Filter orders, refresh, inspect snapshot totals/address/payment, view Shiply timeline,
handle unknown statuses, cancel an eligible order with confirmation, and reject ineligible actions.

- [ ] T089 [P] [US8] Add order snapshot, status, timeline ordering, eligibility, and cancellation tests in `test/controllers/orders_controller_test.dart`
- [ ] T090 [US8] Extract order-list, detail, tracking, and action state from the shop controller in `lib/controller/order/order_controller.dart`
- [ ] T091 [US8] Normalize unknown statuses, logs, handover, Shiply tracking, and optional fields in `lib/core/model/orders_model.dart`
- [ ] T092 [US8] Rebuild order tabs/cards, refresh, loading, empty, offline, and error states in `lib/features/order/order_screen.dart`
- [ ] T093 [US8] Rebuild snapshot detail, line items, totals, address, payment, notes, and action eligibility in `lib/features/order/order_details_screen.dart`
- [ ] T094 [P] [US8] Build authoritative status timeline and optional tracking/location presentation in `lib/features/order/widget/order_tracking_timeline.dart`
- [ ] T095 [US8] Implement confirm-then-server-success cancellation and capability gates for reorder/share/edit/note in `lib/features/order/widget/order_actions.dart`
- [ ] T096 [US8] Compare SCR-30 through SCR-33 with boards 02, 03, and 06 and record annotated results in `specs/001-store-mobile-ui/evidence/phase-10-us8-visual.md`

**Checkpoint**: US8 works independently and historical values are never recalculated from current catalog data.

---

## Phase 11: User Story 9 - Manage Notifications and Reviews (Priority: P2)

**Goal**: Review categorized messages, preserve unread truth, follow safe deep links, and mutate reviews authoritatively.

**Independent Test**: Filter notifications, mark one read with success/failure, open known/unknown deep
links, and add/edit a review only when eligible while preserving server visibility state.

- [ ] T097 [P] [US9] Add notification category, unread mutation, and safe deep-link tests in `test/controllers/notification_controller_test.dart`
- [ ] T098 [P] [US9] Add review eligibility, submission, failure, and visibility tests in `test/controllers/review_controller_test.dart`
- [ ] T099 [US9] Normalize optional notification type/deep-link data and preserve unread state on mutation failure in `lib/controller/notification/notification_controller.dart`
- [ ] T100 [US9] Rebuild categorized notifications, badge/read states, refresh, empty, offline, and error views in `lib/features/notification/notification_screen.dart`
- [ ] T101 [US9] Implement known-destination allow-listing and safe unknown-link fallback in `lib/core/functions/notification_api.dart`
- [ ] T102 [US9] Add eligibility-gated review composer/edit flow and authoritative submission state in `lib/features/product/review_screen.dart`
- [ ] T103 [US9] Compare SCR-34 and SCR-35 with boards 02 and 08 plus product-detail references and record results in `specs/001-store-mobile-ui/evidence/phase-11-us9-visual.md`

**Checkpoint**: US9 works independently; local optimism never falsely commits unread or review mutation state.

---

## Phase 12: User Story 10 - Manage Profile and Preferences (Priority: P2)

**Goal**: Organize account, capability-gated addresses/payments, language, settings, support, logout, and deletion.

**Independent Test**: Use guest and authenticated profile hubs, edit supported fields, exercise resolved
address/payment capabilities, switch supported locale, open support links, logout, and test deletion failure/success.

- [ ] T104 [P] [US10] Add profile capability, supported-field, locale, logout, and deletion-boundary tests in `test/controllers/profile_settings_test.dart`
- [ ] T105 [US10] Refactor profile/account orchestration into typed guest, loading, content, mutation, and failure states in `lib/controller/account/account_controller.dart`
- [ ] T106 [US10] Rebuild the profile hub hierarchy and consistent protected-destination gates in `lib/features/acount/profile_screen.dart`
- [ ] T107 [US10] Restrict account editing to supported personal fields and authoritative save results in `lib/features/acount/personal_screen.dart`
- [ ] T108 [P] [US10] Build capability-gated address book or documented single-profile-address fallback in `lib/features/acount/addresses_screen.dart`
- [ ] T109 [P] [US10] Build payment-method capability view that never stores raw card details in `lib/features/acount/payment_methods_screen.dart`
- [ ] T110 [US10] Reconcile Arabic, English, Hebrew, and reference Turkish availability before rebuilding locale selection in `lib/features/lang/lang_screen.dart`
- [ ] T111 [US10] Build supported local/remote settings with truthful persistence behavior in `lib/features/acount/settings_screen.dart`
- [ ] T112 [P] [US10] Consolidate configured FAQ, contact, terms, privacy, about, and version destinations in `lib/features/acount/help_support_screen.dart`
- [ ] T113 [US10] Implement confirmed logout and server-confirmed deletion without clearing account data on failure in `lib/features/acount/account_actions_screen.dart`
- [ ] T114 [US10] Compare SCR-36 through SCR-43 with board 02 and design tokens in board 08 and record annotated results in `specs/001-store-mobile-ui/evidence/phase-12-us10-visual.md`

**Checkpoint**: US10 works within resolved backend capabilities and never represents a local-only value as server truth.

---

## Phase 13: User Story 11 - Understand Every Global State (Priority: P2)

**Goal**: Make loading, empty, offline, error, success, media fallback, and refresh behavior consistent and truthful.

**Independent Test**: Drive every applicable async surface through each reachable state at normal and large
text sizes, RTL and LTR, small screens, keyboard-open layouts, and offline-to-online recovery.

- [ ] T115 [P] [US11] Add shared-state semantics, retry, refresh, and state-distinction widget tests in `test/widgets/store_states_test.dart`
- [ ] T116 [US11] Audit all 44 contracts for loading, empty, offline, error, success, refresh, and placeholder applicability in `specs/001-store-mobile-ui/evidence/state-coverage.md`
- [ ] T117 [US11] Centralize generic response-to-view-state mapping without converting failures to empty content in `lib/core/api_checker.dart` and `lib/core/functions/handingData.dart`
- [ ] T118 [US11] Complete shell-level offline, error, retry, refresh, and overlay integration in `lib/features/home_screen/home_screen.dart`
- [ ] T119 [US11] Add Arabic/English mixed-text, semantic label, focus order, keyboard, safe-area, and text-scale coverage in `test/widgets/accessibility_layout_test.dart`
- [ ] T120 [US11] Compare SCR-44 and every applicable screen state with boards 02, 07, and 08 and record annotated results in `specs/001-store-mobile-ui/evidence/phase-13-us11-visual.md`

**Checkpoint**: US11 is independently reviewable and no failure is mislabeled as empty or success.

---

## Phase 14: User Story 12 - Verify Fidelity and Integration (Priority: P3)

**Goal**: Prove contract preservation, complete reference coverage, visual fidelity, and platform readiness with separated evidence.

**Independent Test**: Run automated checks, live API probes, Android/iOS journeys, checkout retry scenarios,
notification links, and screenshot comparisons; report each evidence class without overstating coverage.

- [ ] T121 [P] [US12] Add browse-to-product and cart-to-confirmed-order journey tests in `test/journeys/store_critical_journeys_test.dart`
- [ ] T122 [US12] Run formatter, analyzer, and focused automated suites and record exact commands/results in `specs/001-store-mobile-ui/evidence/static-and-automated.md`
- [ ] T123 [US12] Verify current live Store API envelopes and capability flags without mutating production data and record redacted evidence in `specs/001-store-mobile-ui/evidence/live-api.md`
- [ ] T124 [US12] Execute Android first-run, returning user, offline, browse, cart, checkout-retry, order, and notification journeys and record device/build evidence in `specs/001-store-mobile-ui/evidence/android-device.md`
- [ ] T125 [US12] Execute the equivalent supported iOS journeys and record distribution/build limitations separately in `specs/001-store-mobile-ui/evidence/ios-device.md`
- [ ] T126 [US12] Capture all applicable 44-screen Arabic RTL reference-viewport screenshots under `specs/001-store-mobile-ui/evidence/screenshots/`
- [ ] T127 [US12] Complete board-by-board visual diffs, list calibrated values, and resolve all unapproved high-impact differences in `specs/001-store-mobile-ui/evidence/final-visual-matrix.md`
- [ ] T128 [US12] Verify no implementation changes exist under Laravel or Flutter Admin and record scoped diff evidence in `specs/001-store-mobile-ui/evidence/scope-audit.md`
- [ ] T129 [US12] Complete release-readiness sign-off with remaining backend gaps, owner, impact, and disabled UI behavior in `specs/001-store-mobile-ui/evidence/release-readiness.md`

**Checkpoint**: US12 provides separate static, automated, live API, device, and visual proof; unsupported capabilities remain gated.

---

## Dependencies and Execution Order

### Phase Dependencies

- Phase 1 has no implementation dependency and must complete before application UI changes.
- Phase 2 depends on Phase 1 and blocks every screen phase.
- US1 and US2 may proceed in parallel after Phase 2.
- US3 depends on the shared foundation and startup routing; US4 depends on US3 shell/search integration.
- US5 depends on US4 typed listing identity; US6 depends on US5 card/detail actions.
- US7 depends on US6 stable cart identity; US8 depends on US7 order-success navigation and order model normalization.
- US9 and US10 may proceed in parallel after the shell and auth gates are stable.
- US11 depends on all intended screen phases; US12 depends on all release-scope stories and gates.

### Critical Path

`T001-T009 -> T010-T023 -> US1/US2 -> US3 -> US4 -> US5 -> US6 -> US7 -> US8 -> US11 -> US12`

### Parallel Opportunities

- Tasks marked `[P]` touch independent files or evidence artifacts after their phase prerequisite is met.
- US1 and US2 can run concurrently after the shared foundation.
- US9 and US10 can run concurrently once shell/auth routing is stable.
- Unit/widget test authoring can proceed beside UI composition when the relevant contract is frozen.
- Android and iOS device evidence can be collected concurrently from the same signed-off build.

## Implementation Strategy

1. Finish Phase 1 and treat unresolved critical authority as a capability-off decision, never fabricated UI.
2. Finish Phase 2 and approve the shared Arabic RTL visual baseline before migrating screens.
3. Deliver P1 stories in dependency order, stopping at every checkpoint for automated and visual review.
4. Add P2 account/communication/state coverage without weakening established contract boundaries.
5. Run US12 only on a fixed candidate revision and keep static, API, device, and visual claims separate.

## Task Discipline

- Write focused tests before behavior-changing implementation and confirm the pre-change failure is meaningful.
- Preserve existing session, locale, cart, listing identity, role, reset-proof, and idempotency compatibility.
- Do not modify Laravel or Flutter Admin under this feature.
- Do not expose a control until its backing capability is confirmed.
- Do not mark a visual task complete without reference viewport, board identifier, annotated comparison, and reviewer outcome.
- Stage and commit reviewable phase-sized changes; do not collapse this plan into a single implementation commit.
