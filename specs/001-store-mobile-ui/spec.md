# Feature Specification: Doctor Bike Store Mobile UI

**Feature Branch**: `feat/store-mobile-ui`

**Created**: 2026-10-05

**Status**: Ready for implementation review

**Input**: Approved implementation specification for the complete Doctor Bike Store mobile
UI/UX, governed by all eight images in `docs/design-reference/` and constrained to reuse the
existing Store application and authoritative backend contracts.

## Clarifications

### Session 2026-10-05

- No critical ambiguities required a user question: the approved references, navigation model,
  Arabic-first direction, backend authority, scope boundaries, and phased-delivery requirement
  are explicit. Unsupported capabilities are dependencies to document, not behavior to invent.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Recognizable and Safe App Entry (Priority: P1)

A new or returning customer launches a clearly branded Doctor Bike Store, sees the correct
first-run or returning path, and receives truthful maintenance, offline, or required-update
guidance before entering the store.

**Why this priority**: Every other journey depends on predictable initialization and routing.

**Independent Test**: Exercise first launch, returning guest, authenticated return, offline,
store-closed, and required-update states and verify that each reaches only its permitted path.

**Acceptance Scenarios**:

1. **Given** a first launch, **When** initialization completes, **Then** the animated brand intro
   proceeds to the approved onboarding sequence.
2. **Given** a returning user, **When** initialization completes, **Then** existing session and
   first-run state route the user without clearing retained data.
3. **Given** an authoritative closed-store or mandatory-update response, **When** the app starts,
   **Then** the matching blocking state appears and normal shopping is not presented as available.

---

### User Story 2 - Authenticate and Recover Access (Priority: P1)

A customer can sign in, create an account, or recover access through an OTP and proof-bound
password reset while keeping failures and unsupported social providers honest.

**Why this priority**: Checkout, orders, notifications, and account management require identity.

**Independent Test**: Complete login, registration, forgot-password, OTP, and new-password
journeys with valid, invalid, expired, offline, blocked-account, and upgrade-required responses.

**Acceptance Scenarios**:

1. **Given** valid credentials, **When** the customer signs in, **Then** the authoritative session
   and roles are retained and the customer reaches the store.
2. **Given** a valid reset proof, **When** matching new passwords are submitted, **Then** success
   is shown only after server confirmation and the proof is not exposed.
3. **Given** Google or Apple is not supported by the active contract, **When** auth is displayed,
   **Then** that provider is disabled or omitted rather than simulated.

---

### User Story 3 - Browse a Compact Store Home (Priority: P1)

A guest or authenticated customer can use the five-destination shell, see a compact home page,
expand search from the top bar, refresh content, and open store sections or products.

**Why this priority**: This is the primary discovery and navigation surface.

**Independent Test**: Open each shell destination, expand and close search, refresh home, and
open hero, category, best-seller, service, offer, and new-arrival destinations.

**Acceptance Scenarios**:

1. **Given** home data is available, **When** the customer opens Home, **Then** the approved
   compact composition and hierarchy appear in Arabic RTL without excessive scrolling.
2. **Given** a section is loading or unavailable, **When** Home opens or refreshes, **Then** the
   section uses its skeleton, empty, error, or offline state without turning failure into success.

---

### User Story 4 - Search, Categorize, Sort, and Filter (Priority: P1)

A customer can browse inventory-backed store sections, find products by search, and narrow a
listing only by filters and sort options supported by authoritative catalog data.

**Why this priority**: Customers must reach relevant products quickly and accurately.

**Independent Test**: Traverse section hierarchy, use recent search and chips, submit queries,
open results, reset/apply filters, sort, and exercise no-result and offline states.

**Acceptance Scenarios**:

1. **Given** an inventory store section, **When** it is selected, **Then** only products published
   for that authoritative section are listed.
2. **Given** unsupported brand, rating, or stock filtering, **When** the filter sheet is built,
   **Then** unsupported controls are not treated as functional and the dependency is recorded.

---

### User Story 5 - Evaluate Product and Media (Priority: P1)

A customer can inspect authoritative product identity, pricing, availability, options, quick
specifications, reviews, and every actually available image, video, or 3D/360 medium.

**Why this priority**: Product confidence is required before cart or immediate purchase.

**Independent Test**: Open products with one image, multiple images, video, 3D/360 metadata,
options, discounts, no stock, failed media, and no optional media.

**Acceptance Scenarios**:

1. **Given** mixed media, **When** a thumbnail or arrow is selected, **Then** the main medium and
   position indicator change while full-screen behavior follows the approved gallery.
2. **Given** no authoritative 3D/360 asset contract, **When** product media is shown, **Then** no
   fake rotatable experience is presented.
3. **Given** an unavailable option, **When** quantity or purchase actions are considered, **Then**
   availability and action state reflect the server-provided stock boundary.

---

### User Story 6 - Retain Favorites and Cart Choices (Priority: P1)

A customer can manage favorites and a persistent cart, with selected product options, quantities,
coupon intent, totals, and removals represented consistently across the app.

**Why this priority**: These are the bridge between discovery and purchase.

**Independent Test**: Add/remove favorites and cart lines, change quantities, restore a retained
cart, handle stale listing identity, apply a coupon, and empty or clear the cart.

**Acceptance Scenarios**:

1. **Given** a retained cart, **When** the app restarts, **Then** listing identity and selected
   option identity are preserved without creating local price or stock authority.
2. **Given** a cart line cannot be validated for checkout, **When** checkout begins, **Then** the
   line is identified for refresh and no order is submitted with a product ID in place of a listing ID.

---

### User Story 7 - Complete an Idempotent Checkout (Priority: P1)

An authenticated eligible customer selects or adds an address, chooses authoritative shipping
and supported payment, reviews totals, submits once, and receives a confirmed order identity.

**Why this priority**: Checkout is the revenue-critical path and has financial integrity risks.

**Independent Test**: Complete address, shipping, payment, coupon, dual-role choice, retry,
duplicate tap, transport uncertainty, rejected stock/price, and confirmed success scenarios.

**Acceptance Scenarios**:

1. **Given** a valid cart and account, **When** submission is retried after uncertain transport,
   **Then** the same checkout attempt identity is reused until authoritative success.
2. **Given** an HTTP success without the expected order identity, **When** the response is parsed,
   **Then** the app retains the cart and presents a retryable failure rather than success.
3. **Given** a payment method not supported by the active contract, **When** payment is selected,
   **Then** it is absent or explicitly unavailable and is not submitted.

---

### User Story 8 - Review and Act on Orders (Priority: P2)

An authenticated customer can see order lists and filters, inspect details and totals, follow the
status/Shiply timeline, and use only actions authorized for the current order state.

**Why this priority**: Post-purchase visibility reduces uncertainty and unsafe repeated actions.

**Independent Test**: Open current, shipped, completed, and canceled orders with and without
tracking; attempt allowed and disallowed cancellation; refresh and retry failures.

**Acceptance Scenarios**:

1. **Given** tracking events, **When** details open, **Then** the current step and completed steps
   follow authoritative event order and timestamps.
2. **Given** cancellation is not allowed, **When** actions open, **Then** cancellation is omitted or
   disabled and the app does not infer permission locally.

---

### User Story 9 - Manage Notifications and Reviews (Priority: P2)

An authenticated customer can read categorized notifications and submit or view product reviews
without falsely marking failed server mutations as successful.

**Why this priority**: These features close communication and product-feedback loops.

**Independent Test**: Load/read notifications, handle empty lists, view reviews, submit valid and
invalid reviews, and exercise offline/retry behavior.

**Acceptance Scenarios**:

1. **Given** an unread notification, **When** it is opened, **Then** read state changes only after
   the backend accepts the mutation.
2. **Given** a review submission failure, **When** the request completes, **Then** the review is not
   inserted as successful local authority.

---

### User Story 10 - Manage Profile and Preferences (Priority: P2)

A customer can review account data, addresses, supported payment-method UI, language, settings,
support options, and safe logout or account deletion from the approved profile hierarchy.

**Why this priority**: Customers need control over retained personal data and preferences.

**Independent Test**: Exercise guest and authenticated profile states, edit account/address data,
switch locale, alter supported settings, contact support, logout, and confirm account deletion.

**Acceptance Scenarios**:

1. **Given** a guest, **When** a protected profile destination is selected, **Then** a clear login
   gate appears without erasing the guest cart.
2. **Given** account deletion is requested, **When** the customer confirms, **Then** local identity
   is cleared only after authoritative success.

---

### User Story 11 - Understand Every Global State (Priority: P2)

A customer receives visually consistent, actionable loading, empty, no-results, no-products,
offline, generic-error, and success states throughout the Store.

**Why this priority**: State quality is a core part of the approved experience.

**Independent Test**: Force each global state at representative home, listing, search, cart,
checkout, order, notification, and profile surfaces and compare with references.

**Acceptance Scenarios**:

1. **Given** a network-dependent surface is offline, **When** it opens, **Then** the approved offline
   state offers retry and does not use a generic success or empty result.
2. **Given** a successful mutation, **When** confirmation is shown, **Then** the success component
   reflects the authoritative result and offers the correct next navigation.

---

### User Story 12 - Verify Fidelity and Integration (Priority: P3)

Reviewers can trace every screen and component to an approved reference, compare implemented
states at a controlled viewport, and validate critical journeys against real contracts.

**Why this priority**: Functional completion without visual fidelity does not meet acceptance.

**Independent Test**: Execute the reference matrix, screenshot comparison set, accessibility
checks, contract tests, and end-to-end journeys without modifying backend or Admin code.

**Acceptance Scenarios**:

1. **Given** a completed phase, **When** its visual review runs, **Then** every included screen and
   state has a mapped reference and documented comparison result.
2. **Given** a deliberate reference deviation, **When** the phase is reviewed, **Then** its technical
   reason and approval are recorded before acceptance.

### Edge Cases

- First launch has no connectivity before the first-run flag can be resolved.
- A retained session is expired, blocked, or belongs to no active customer/seller link.
- Backend store settings report closed operation while cached catalog content exists.
- An API returns HTTP success with malformed or partial JSON, unexpected field types, or no ID.
- A section or product disappears between home/listing, cart, and checkout.
- Retail and wholesale roles both exist and require an explicit per-checkout choice.
- Price, promotion, coupon eligibility, stock, shipping fee, or order status changes mid-journey.
- A media list contains duplicate, blank, unsupported, or unreachable URLs.
- A product has one image, no optional media, video only, or metadata claiming unsupported 3D/360.
- Quantity exceeds authoritative stock, becomes zero, or an option becomes unavailable.
- A cart restored from an older schema lacks listing or option identity.
- Checkout is tapped repeatedly or a response is lost after server-side creation.
- Notification/read or review mutations fail after optimistic user interaction.
- RTL content mixes Arabic, Latin product codes, phone numbers, prices, and tracking identifiers.
- Text scaling, small devices, notches, keyboards, and long localized labels stress compact layouts.

## Requirements *(mandatory)*

### Screen and Flow Contract

The following state profiles apply to the inventory below:

- **L** (local): immediate content plus explicit empty/disabled behavior; no artificial success.
- **R** (read): skeleton or progress while loading, distinct empty and error states, offline state with
  retry, refresh where specified, and content only after successful parsing.
- **M** (mutation): disable/coalesce repeat action, show progress, retain recoverable input on error,
  and show success only after authoritative confirmation.
- **VF** (visual fidelity): Arabic RTL, hierarchy, composition, spacing, typography, color, border,
  radius, shadow, image ratio, icon placement, top/bottom navigation, and shown states MUST match
  the cited board. Dimensions not safely inferable are calibration tokens, not invented constants.

| ID | Screen / flow and purpose | Exact reference | Required content, components, and interaction | Entry -> exit navigation | Backend/API dependency | State and acceptance contract |
|----|---------------------------|-----------------|-----------------------------------------------|--------------------------|------------------------|-------------------------------|
| SCR-01 | Animated splash: identify the brand while initialization starts | 01 frames 1-6; 02 first card | Navy cinematic background, logo stroke sequence, logo/tagline reveal, progress cue | App launch -> SCR-02, SCR-03, SCR-04, or SCR-05 | Store settings, retained session/first-run state | L/R + VF; animation must not conceal a failed initialization or loop indefinitely |
| SCR-02 | Onboarding: explain products, quality, and service | 01 lower row; 02 first three cards | Three image-led pages, skip, dots, previous/next/start controls | SCR-01 -> SCR-06 or SCR-11; skip follows approved route | Local first-run preference; no fake remote content | L + VF; first-run completion is retained and pages match approved order |
| SCR-03 | App initialization: resolve locale, session, cart, settings, and initial data | 01; 07 loading | Branded transition with deterministic routing | SCR-01 -> allowed destination | Auth/session validation, store settings, client version | R + VF; retained data is preserved unless authority invalidates only the affected identity |
| SCR-04 | Maintenance/store-closed: stop unavailable commerce truthfully | 02 global states | State illustration, authoritative message, retry/support action | SCR-01/SCR-03 -> retry or support | Store operating-state setting | R + VF; cached products cannot appear as purchasable success |
| SCR-05 | Upgrade/version state: require or recommend supported client version | 02 global states styling | Required/recommended update copy and supported destination | SCR-01/SCR-03/auth reset -> store/update or limited continuation when allowed | Version/update policy | R/M + VF; mandatory upgrade fails closed |
| SCR-06 | Login: create an authenticated session | 01 last card; 02 login card | Email/phone, password, reveal, remember, forgot link, submit, supported social providers, register link | Onboarding/profile gate -> SCR-11 or SCR-07/SCR-08 | Login, FCM token, account roles/block state; Google/Apple only if supported | M + VF; invalid/blocked/offline responses remain failure and secrets are never exposed |
| SCR-07 | Registration: create a customer account | 02 registration card | Name where supported, phone country code, email, password, terms consent, submit, login link | SCR-06 -> SCR-06 or verified next step | Registration contract and terms links | M + VF; fields match the actual contract and unsupported identity data is not fabricated |
| SCR-08 | Forgot password request: start recovery | 02 forgot card | Email/phone identifier, explanation, send action, recovery illustration | SCR-06 -> SCR-09 or SCR-05 | Forgot-password request with Store client metadata | M + VF; unknown user and upgrade-required responses are distinct |
| SCR-09 | OTP verification: prove recovery possession | 02 OTP card | Code cells, destination hint, countdown, resend, numeric keyboard | SCR-08 -> SCR-10 | OTP verification returns opaque reset proof | M + VF; resend timer is accurate and invalid/expired codes retain safe retry |
| SCR-10 | New password: complete recovery | 02 new-password card | New/confirm fields, strength cue, submit | SCR-09 -> success then SCR-06 | Proof-bound password reset | M + VF; reset never sends user identity in place of proof |
| SCR-11 | Main shell: provide stable primary navigation | 06; 07; 08 navigation bars | Top region plus Home, Categories, My Orders, Favorites, Profile bottom destinations | Post-entry -> SCR-13/SCR-16/SCR-30/SCR-23/SCR-36 | Per-destination dependencies | L + VF; selected state, safe areas, back behavior, and guest gates match references |
| SCR-12 | Top bar and expandable search: expose identity, notifications, cart, search | 06 home; 07; 08 top bar | Avatar/name, notification badge, cart badge where applicable, collapsed search icon expanding inline with close/cancel | Any shell destination -> SCR-14/SCR-24/SCR-34/profile | User summary, unread count, cart count | R/L + VF; expansion does not replace bottom navigation or lose entered query unexpectedly |
| SCR-13 | Home: compact storefront discovery | 06 home; 07 home/loading | Hero, quick categories, best sellers, service block, store categories, offers, new arrivals | SCR-11 -> listings/product/search/service destinations | Ads/hero, inventory sections, product groups, promotions, settings | R + VF; sections follow approved order and hide only when contract says unavailable |
| SCR-14 | Search discovery: prepare and refine a query | 07 expanded search | Expanded field, cancel, category chips, recent searches, clear history | SCR-12 -> SCR-15 or prior destination | Search suggestions/history; recent history may be local preference only | L/R + VF; local history is not catalog authority and clearing is explicit |
| SCR-15 | Search results/no results: show authoritative matches | 02 no-results; 07 search | Query header, results cards, optional filter/sort, no-results action | SCR-14 -> SCR-19 or SCR-16 | Search endpoint and supported filters | R + VF; zero results, request failure, and offline are visually distinct |
| SCR-16 | Categories: browse inventory-backed hierarchy | 06 categories; 02 no-products | Search field, quick grid, sub-section rows/counts where available | SCR-11/SCR-13 -> SCR-17 | Store sections and optional hierarchy/counts | R + VF; legacy route names do not change inventory-section authority |
| SCR-17 | Product listing: compare products in a section | 06 listing | Title, count, list/grid cards, availability, discount, rating, favorite, add-to-cart, sort/filter controls | SCR-16/SCR-15 -> SCR-18/SCR-19/cart feedback | Published listings with typed product payload | R/M + VF; prices, stock, discounts, rating, and listing identity come from backend |
| SCR-18 | Filter and sort: narrow a listing | 06 filter sheet | Price range, supported brand, stock, rating, reset/apply, selected-count badge | SCR-17 -> updated SCR-17 | Backend-supported filter/sort metadata or documented client-safe view filtering | L/R + VF; unsupported controls are omitted/disabled and reset restores documented defaults |
| SCR-19 | Product detail: support purchase decision | 04 first card; 05; 06 detail | Main media, thumbnails/arrows, share, favorite, name/code/brand, price/old price/discount, rating, quick specs, options, quantity, availability, cart, buy now, specs, shipping/warranty, returns | SCR-13/15/17/23 -> SCR-20/21/22/24/25/reviews | Product/listing detail, price, stock, options, promotions, reviews, policy/settings | R/M + VF; every displayed business value is authoritative and sections follow approved hierarchy |
| SCR-20 | Image gallery: inspect product photography | 04 gallery; 05 media state | Full-screen image, index, arrows/swipe, thumbnails, zoom/fullscreen affordance | SCR-19 -> selected media or back | Product image list | R/L + VF; one/many-image variants and failed-image placeholder are defined |
| SCR-21 | Video player: view supported product video | 04 video; 05 video state | Poster, play/pause, progress/time, fullscreen, thumbnail selection | SCR-19/SCR-20 -> video or back | Valid video URL/type/poster if available | R/L + VF; invalid media becomes an error/omitted medium, never an endless spinner |
| SCR-22 | 3D/360 viewer: inspect interactive product media where real support exists | 04 360; 05 3D state | 3D/360 badge, viewer, drag guidance, thumbnails/fullscreen | SCR-19/SCR-20 -> viewer or back | Explicit asset type and viewer-compatible source | R/L + VF; absence of contract is a documented gap and no static image is mislabeled interactive |
| SCR-23 | Favorites: retain a personal shortlist | 02 favorites; 06/08 product-card heart | Product rows/cards, remove, add to cart, empty state | SCR-11 or product heart -> SCR-19/SCR-24 | Favorites read/write and identity policy | R/M + VF; persistence authority and guest behavior must be explicitly resolved before implementation |
| SCR-24 | Cart: review selected lines and totals | 03 cart; 06 cart | Select/clear where supported, line media/options, quantity, remove, coupon, subtotal, discount, shipping, total, checkout | Top bar/product -> SCR-25 or product | Cart persistence plus server validation, coupon and shipping dependencies | L/R/M + VF; retained local cart is intent only, totals are revalidated before order |
| SCR-25 | Checkout address: select or add delivery identity | 03 step 1; 06 checkout | Three-step indicator, address cards, add/edit, contact data, notes | SCR-24 -> SCR-26 or address editor | User profile, address capability, cities/villages | R/M + VF; absent address-book contract is recorded and current profile-address fallback is explicit |
| SCR-26 | Checkout shipping: select fulfillment and timing | 03 step 2; 06 shipping | Standard/express/pickup only when supported, preferred time, order summary | SCR-25 -> SCR-27 | Shiply cities/villages/fee/methods/times or store pickup settings | R/M + VF; fee/method availability is authoritative and recalculated for selected destination |
| SCR-27 | Checkout payment: select a supported method | 03 step 3; 06 payment | Supported payment methods, conditional fields, save-method toggle only if supported, final total | SCR-26 -> SCR-28 | Active payment contract; current native checkout supports cash/COD only unless expanded | R/M + VF; unsupported card/wallet/bank choices are not interactive promises |
| SCR-28 | Order submission: create exactly one authoritative order | 03 steps; 06 checkout | Final review, confirm action, in-flight lock, recoverable error | SCR-27 -> SCR-29 or retained checkout | Native checkout, account-role choice, listing IDs, idempotency key, coupon, delivery | M + VF; duplicate taps coalesce and uncertain retries reuse the attempt identity |
| SCR-29 | Order success: confirm created identity and next actions | 03 success | Success mark, order number/time, view order, track, return home, continue shopping | SCR-28 -> SCR-31/SCR-32/SCR-13 | Confirmed response containing order ID | M + VF; malformed success stays retryable checkout with cart intact |
| SCR-30 | Order list: find current and historical orders | 02 orders; 03/06 lists | Tabs/filters, order number/date/status, thumbnails/count/total, refresh, empty states | SCR-11/profile -> SCR-31 | Orders by user/status | R + VF; statuses are mapped consistently and unknown status remains visible, not discarded |
| SCR-31 | Order details: inspect products, totals, address, payment, notes | 03 details/payment summary; 06 details | Status header/timeline, lines, totals, payment, address/map link where supported, notes | SCR-30/SCR-29 -> SCR-32/SCR-33 | Order detail, logs, handover, tracking | R + VF; details use order snapshot values and do not recalculate historical totals locally |
| SCR-32 | Tracking: follow delivery progress | 03 tracking; 06 detail timeline | Ordered status timeline, timestamps, tracking code, current location/map only if supplied | SCR-29/SCR-31 -> back | Shiply tracking/handover events | R + VF; absent location is not fabricated and event order follows authoritative sequence |
| SCR-33 | Order actions: perform only eligible post-order actions | 03 actions | Track, edit address, add note, cancel, reorder, share as individually authorized | SCR-31 -> action result/back | Per-action eligibility and endpoints | M + VF; cancellation requires confirmation and server success; unsupported actions are dependencies |
| SCR-34 | Notifications: review categorized store messages | 02 notifications; 08 chips/styles | All/offers/orders/system tabs, icon, title, summary, age, unread state, deep link | SCR-12/profile -> related screen | Notifications, read mutation, optional type/deep-link fields | R/M + VF; failed read mutation remains unread and unknown deep links fail safely |
| SCR-35 | Reviews: inspect and contribute product feedback | Product-detail references imply rating/review; 02/08 state styles | Rating summary, reviews, empty, add/edit eligibility, text/rate submission | SCR-19 -> review result/back | Reviews list/manage, eligibility/visibility | R/M + VF; review success and visibility are backend-authoritative |
| SCR-36 | Profile hub: organize account and support destinations | 02 profile | Avatar/name/email, account, addresses, payment, orders, favorites, notifications, language, settings, support, logout | SCR-11 -> SCR-37/38/39/30/23/34/40/41/42/43 | User summary and guest/auth state | R/L + VF; guest view uses explicit sign-in gates and retains guest cart |
| SCR-37 | Account information: view/edit supported personal data | 02 account | Avatar, name, email, phone, gender/date only if supported, save | SCR-36 -> back | User profile/edit and upload only if supported | R/M + VF; unsupported fields are not persisted locally as truth |
| SCR-38 | Addresses: manage delivery locations | 02 addresses | Address cards, default selection, add/edit/remove | SCR-36/SCR-25 -> back or selected address | Address-book CRUD; current profile has only one address/city | R/M + VF; full address-book UI is blocked on contract if CRUD is absent |
| SCR-39 | Payment methods UI: manage only supported saved methods | 02 payment methods | Supported method cards, default, add/remove only when real tokenized support exists, COD option | SCR-36/SCR-27 -> back/selection | Payment-method capability/tokenization | R/M + VF; no raw card persistence and current unsupported methods remain non-functional/omitted |
| SCR-40 | Language: choose supported locale | 02 language/settings | Arabic, English, Turkish only if product decision/backend content supports it; selected state and save | SCR-36/SCR-41 -> refreshed current screen | Local preference plus localized content availability | L + VF; Arabic remains default/first-class and reference language list is reconciled with supported locales |
| SCR-41 | Settings: manage notification, marketing, dark mode, and data preferences only where supported | 02 settings | Toggles, language, appearance, delete-account entry, app version | SCR-36 -> back/SCR-40/SCR-43 | Notification consent/preferences and local appearance settings | L/M + VF; remote preferences require endpoint success; local-only settings are labeled by behavior |
| SCR-42 | Help and support: reach approved assistance and policies | 02 help | FAQ, contact, privacy, terms, about/version, call/message/social only when configured | SCR-36 -> external approved destination/back | Store settings/contact/policy content | R/L + VF; missing contact channel is hidden or shows truthful unavailability |
| SCR-43 | Logout and account deletion: end identity safely | 02 profile/settings | Confirmation, destructive emphasis, progress, failure/success | SCR-36/SCR-41 -> guest shell or retained account | Logout local session boundary; server-confirmed account deletion | M + VF; account data is not cleared on failed deletion and cart policy is explicit |
| SCR-44 | Global state library: present consistent non-happy paths | 02 bottom row; 07 loading; 08 states | Skeletons, empty cart, no search results, no products, offline, generic error, success, placeholders, pull-to-refresh | Any async surface -> retry/relevant destination | Original request context | R/M + VF; each state has specific copy/action and is not reused to mask a different condition |

### Functional Requirements

- **FR-001**: All eight approved boards MUST be mapped to at least one screen, component, state,
  or design token, and no board may remain unaccounted for.
- **FR-002**: Every screen MUST satisfy the VF contract and preserve Arabic RTL as the baseline.
- **FR-003**: The product MUST retain the original Doctor Bike logo and the approved navy,
  purple, light-purple, background, and card-surface identity.
- **FR-004**: New UI text MUST use Cairo in weights corresponding to the design system.
- **FR-005**: The main shell MUST contain exactly Home, Categories, My Orders, Favorites, and
  Profile in the approved order.
- **FR-006**: The top bar MUST show customer identity when available plus notification, search,
  and context-appropriate cart access.
- **FR-007**: Search MUST expand from the top-bar icon into the approved field without changing
  the primary navigation model.
- **FR-008**: Home MUST remain compact and include the reference-defined hero, category, best-
  seller, service, store-category, offer, and new-arrival hierarchy when data exists.
- **FR-009**: Applicable read surfaces MUST provide skeleton loading and pull-to-refresh.
- **FR-010**: Every network-dependent surface MUST distinguish loading, empty, error, offline,
  and success states relevant to that surface.
- **FR-011**: Catalog browsing MUST use authoritative inventory-backed Store sections while
  retaining compatible endpoint naming where needed.
- **FR-012**: Product cards MUST present authoritative availability, discount, price, rating,
  favorite state, and cart action without local business-rule inference.
- **FR-013**: Search and filter MUST offer only criteria supported by the current backend contract
  or explicitly safe presentation-only filtering documented in the plan.
- **FR-014**: Product detail MUST include the reference-defined identity, pricing, availability,
  options, quantity, actions, specifications, shipping/warranty, returns, and reviews sections.
- **FR-015**: Media MUST be typed by image, video, and 3D/360 capability and support thumbnail-
  driven switching, arrows where shown, counters, and full-screen states.
- **FR-016**: Missing or failed media MUST use a stable placeholder and MUST NOT be mislabeled as
  a supported interactive medium.
- **FR-017**: Favorites behavior MUST define authenticated and guest persistence before release.
- **FR-018**: Cart persistence MUST preserve listing, selected option, and quantity identity while
  treating cached stock and prices as non-authoritative.
- **FR-019**: Checkout MUST revalidate authoritative listing availability, price, promotion,
  coupon, shipping, and eligibility before order confirmation.
- **FR-020**: Checkout MUST require an explicit role choice when both eligible customer and seller
  roles exist and MUST fail closed when neither exists.
- **FR-021**: Checkout retry MUST preserve its idempotency identity until authoritative success,
  and repeated in-flight submission MUST be coalesced.
- **FR-022**: Order success MUST require the expected authoritative order identity.
- **FR-023**: Payment UI MUST include only active backend-supported methods and MUST never persist
  raw card credentials locally.
- **FR-024**: Order lists and details MUST use authoritative order snapshots, statuses, logs,
  tracking, totals, and action eligibility.
- **FR-025**: Cancellation and other destructive/order mutations MUST require confirmation and
  preserve current state on failure.
- **FR-026**: Notification read state and review mutations MUST update as success only after server
  acceptance.
- **FR-027**: Protected destinations MUST use a consistent guest-to-login gate without casually
  clearing the guest cart or preferences.
- **FR-028**: Existing sessions, locale, account data, cart serialization, listing identity, reset
  proof, account-role resolution, and checkout idempotency MUST be migration-safe.
- **FR-029**: API and persisted models MUST use explicit types and nullability; incompatible or
  malformed values MUST yield an error state rather than unchecked coercion.
- **FR-030**: Authentication secrets, tokens, passwords, OTPs, and reset proofs MUST not appear in
  logs, screenshots, analytics, or user-facing diagnostic text.
- **FR-031**: API failures MUST NOT be silently converted into empty or success states.
- **FR-032**: Store-closed and mandatory-upgrade authority MUST block affected actions and provide
  an approved recovery destination.
- **FR-033**: A shared design foundation MUST define logo use, palette, Cairo weights, spacing,
  radii, shadows, buttons, fields, chips, cards, navigation, placeholders, skeletons, and states.
- **FR-034**: Values not safely measurable from the images MUST be marked visual-calibration
  tokens and adjusted through screenshot comparison rather than asserted as exact reference data.
- **FR-035**: Icon-only actions MUST have semantic labels and interactive controls MUST remain
  usable with supported text scaling and mobile safe areas.
- **FR-036**: Each implementation phase MUST include explicit reference mapping and visual
  acceptance checks for every screen and state it changes.
- **FR-037**: No feature work under this specification may modify Laravel or Flutter Admin.
- **FR-038**: Missing backend contracts MUST be recorded by affected screen, required data,
  impact, safe fallback, and whether they block that screen or only an optional capability.
- **FR-039**: Existing code MUST be classified as reusable unchanged, visually refactorable,
  functionally refactorable, obsolete, or missing before implementation tasks replace it.
- **FR-040**: The implementation MUST be divided into reviewable phases rather than one aggregate
  UI task.
- **FR-041**: Critical contract and persistence changes MUST have focused automated tests; device,
  API, and visual verification MUST be reported separately from static analysis.

### Key Entities *(include if feature involves data)*

- **Store session**: Authenticated or guest identity, roles, token lifecycle, locale, first-run,
  notification token, and retained preferences.
- **Store section**: Inventory-backed browsing location with stable identity, localized name,
  image, ordering, active state, and optional hierarchy/count data.
- **Published listing**: Store publication identity linked to a product and authoritative retail or
  wholesale availability, price, promotion, stock, and option selection.
- **Product presentation**: Localized product identity, code, brand where provided, descriptions,
  rating, specifications, policies, and typed media collection.
- **Media asset**: Image, video, or 3D/360 entry with source, thumbnail/poster, ordering, and
  capability metadata.
- **Favorite entry**: User or explicitly defined guest association with a listing/product identity.
- **Cart line**: Listing identity, selected size/color identity, quantity, and cached presentation
  snapshot that requires checkout revalidation.
- **Checkout attempt**: Stable client request identity, account role, cart lines, address, delivery,
  supported payment, and optional coupon retained through uncertain retries.
- **Address and delivery quote**: Customer destination, city/village identity, optional address-book
  identity, shipping method, timing, and authoritative fee.
- **Order**: Authoritative order identity, immutable commercial snapshot, status, lines, totals,
  payment summary, delivery, notes, logs, handover, tracking, and eligible actions.
- **Notification**: Typed user message, read state, timestamp, category, and safe destination.
- **Review**: Product/user association, rating, comment, visibility, eligibility, and timestamps.
- **Design token**: Named palette, type, spacing, radius, shadow, component, placeholder, and state
  value derived from the approved design system or marked for calibration.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of the eight approved reference boards are mapped to concrete screens,
  components, states, or tokens before implementation begins.
- **SC-002**: 100% of the 44 screen/flow contracts have purpose, reference, content/interaction,
  navigation, dependency, state behavior, and visual acceptance defined.
- **SC-003**: Every implemented async screen demonstrates all applicable loading, empty, error,
  offline, and success states with no failure shown as successful content.
- **SC-004**: A reviewer can complete browse-to-product and cart-to-confirmed-order journeys in
  Arabic RTL without a dead end, unsupported promise, or duplicated order.
- **SC-005**: Duplicate checkout taps create at most one active attempt, and an uncertain retry
  retains the same client request identity until confirmed success.
- **SC-006**: 100% of displayed stock, pricing, discounts, coupon results, shipping fees, roles,
  order statuses, and notification/review mutations trace to backend authority.
- **SC-007**: Screen-level comparison at the agreed reference viewport records no unapproved
  high-impact differences in hierarchy, direction, navigation, primary spacing, or brand color.
- **SC-008**: All changed contract, authentication, persistence, cart, and checkout tests pass;
  static analysis introduces no new errors in changed files.
- **SC-009**: First launch, returning guest, returning authenticated user, offline launch, closed
  store, and required-upgrade routing each reach the specified state without losing unrelated data.
- **SC-010**: A user can reach any primary bottom-navigation destination with one tap from the
  shell and return without losing the active cart.
- **SC-011**: A user can discover a product from Home or Categories and reach its purchase action
  in at most four meaningful navigation actions under normal data conditions.
- **SC-012**: All icon-only interactive controls in implemented screens expose an accessible label,
  and all critical actions remain operable at supported mobile text scaling.

## Assumptions

- Existing controllers, repositories, API client, routes, localization, and typed models are
  evolution points rather than grounds for a rewrite.
- The current Laravel-backed compatibility routes remain available during phased migration.
- Arabic is the default locale; English and Hebrew currently exist in code. Turkish shown in one
  reference is a product-content dependency and MUST NOT replace an existing supported locale
  without an explicit localization decision.
- The existing native checkout contract currently supports cash/COD; additional payment methods
  shown in references remain UI dependencies until authoritative support exists.
- Existing local cart persistence may continue as customer intent if listing identity is retained
  and all commercial values are revalidated before submission.
- Image references communicate intended appearance but not every exact dimension; calibration
  tokens will be measured and tuned during visual implementation.

## Dependencies and Backend Gaps

- Favorites persistence/read/write is not present in the reviewed Store client contract.
- Address-book CRUD/default-address support is not present; only profile city/address editing and
  Shiply city/village selection are currently evident.
- Saved payment methods, card/wallet/bank transfer, and payment tokenization are not present; the
  reviewed native checkout payload uses cash with zero paid amount.
- Sort/filter metadata and server-side filtering for brand, rating, and availability require
  confirmation; current client filtering is limited and partly local.
- Product brand, product code distinct from existing model, quick specification schema, shipping,
  warranty, returns, and structured color metadata require contract confirmation.
- Product media distinguishes view, normal, 3D-image lists and a video URL, but a true interactive
  3D/360 asset/viewer contract is not demonstrated.
- Home feeds for service block, store categories beyond inventory sections, special offers, and new
  arrivals are not all represented as distinct reviewed endpoints.
- Order actions beyond cancellation, including edit address, note, reorder, and share eligibility,
  require authoritative contracts.
- Notification type/category/deep-link fields and remote notification preference endpoints require
  confirmation.
- Review eligibility/edit semantics and rating aggregates require confirmation.
- Store-wide update policy and maintenance behavior are only partially represented and require a
  consolidated startup contract.

## Out of Scope

- Implementing Flutter UI or changing application source during this specification task.
- Modifying Laravel, Flutter Admin, database schema, or authoritative business rules.
- Inventing persisted local stock, price, credit, debt, promotion, coupon, order, favorite, address,
  payment, review, or notification authority.
- Adding Google, Apple, card, wallet, bank transfer, map tracking, or 3D/360 capability without a
  verified contract and implementation authorization.
