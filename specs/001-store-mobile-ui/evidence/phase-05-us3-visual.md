# Phase 05 / US3 Home Shell and Search Review

- **Reviewed**: 2026-10-05
- **Scope**: T041-T049 correction only
- **Baseline under review**: `a1ecda37b7815effd05faa16d5649ca9949a5c7b`
- **Primary references**: `docs/design-reference/06-main-store-flows.png`,
  `docs/design-reference/07-home-search-loading.png`, and
  `docs/design-reference/08-design-system.png`
- **Supporting state reference**: `docs/design-reference/02-auth-profile-settings-states.png`
- **Render contract**: 390 x 844 logical pixels, Arabic RTL, light theme

## Pricing Authority Conclusion

`typeUser` is not a proven retail/wholesale display-price selector.

- `lib/repository/auth/auth_repository.dart` reads both `typeUser` and the separate
  `accountRoles` collection from the authenticated user payload. The login controller persists
  `typeUser` under the legacy SharedPreferences key in
  `lib/controller/auth/login.controller.dart` and `lib/core/functions/app_usage_service.dart`.
- The value is refreshed on authentication, not by every catalog read, so the persisted value can
  be stale after an account change.
- The legacy Home/Search endpoints in `lib/repository/home/home_repository.dart` are public catalog
  reads. Their item payload contains both `normailPrice` and `wholesalePrice`; it contains no
  authoritative user-specific selected display price.
- Before Phase 5, the legacy Home/Search controller also interpreted the exact string `Normail` as
  retail and every other authenticated `typeUser` as wholesale. Phase 5 inherited that behavior;
  reuse did not establish authority.
- Read-only backend contract inspection confirms the separation. Laravel
  `app/Http/Controllers/API/Store/StoreBaseController.php` returns `typeUser` from the generic user
  type and independently returns `accountRoles` from `StoreIdentityService`. Its
  `tests/Feature/OnlineStore/LegacyStoreContractTest.php` asserts `typeUser == User` for both a
  customer and a seller while the roles differ.
- Secure checkout does not use `typeUser`: `app/Services/OnlineStore/StorePricingService.php`
  selects retail for a customer link and wholesale for a seller link, and
  `app/Http/Controllers/API/Store/StoreOrdersController.php` requires an explicit
  `account_role`.

Home and Search therefore display `normailPrice` (retail), the safest public catalog price, and do
not infer a seller price from `typeUser` or from authentication alone. Checkout remains separately
responsible for authoritative role validation and final pricing. No Laravel code was changed.

## Evidence Types

### Actual rendered-reference comparisons

These files place an approved-board crop beside the current 390 x 844 Flutter render. They are the
visual review evidence; they are not generated acceptance baselines.

| Artifact | Compared state |
|----------|----------------|
| `evidence/phase-05-comparisons/shell-home-loaded-side-by-side.png` | SCR-11 shell, SCR-12 collapsed bar, SCR-13 loaded Home |
| `evidence/phase-05-comparisons/search-expanded-discovery-side-by-side.png` | SCR-12 expanded bar and SCR-14 discovery |
| `evidence/phase-05-comparisons/home-skeleton-side-by-side.png` | SCR-13 Home skeleton |
| `evidence/phase-05-comparisons/search-results-side-by-side.png` | SCR-15 results |
| `evidence/phase-05-comparisons/search-empty-side-by-side.png` | SCR-15 no results |

The reference crops are normalized to the implementation column width while preserving aspect
ratio. A numeric pixel-difference score would be misleading because the approved board contains
source artwork that is not available to the deterministic widget fixtures. The side-by-side files
are used to compare hierarchy, geometry, density, direction, color, and component treatment.

### Regression goldens

The following goldens lock the corrected implementation against accidental regressions. A golden
matching itself is not visual approval and is not reported as such.

- `test/widgets/goldens/p05-home-loaded-ar-390x844.png`
- `test/widgets/goldens/p05-home-skeleton-ar-390x844.png`
- `test/widgets/goldens/p05-search-expanded-ar-390x844.png`
- `test/widgets/goldens/p05-search-results-ar-390x844.png`
- `test/widgets/goldens/p05-search-no-results-ar-390x844.png`

The existing `p02-shared-components-ar-390x844.png` and
`p02-shared-cards-ar-390x844.png` baselines were also regenerated because both include the shared
top bar. Their only intentional correction is the RTL notification/cart order seen in Boards 06
and 07; the non-compact shared product-card treatment remains unchanged.

## Screen-by-Screen Result

| Screen/state | Corrected result | Remaining classified difference | Review status |
|--------------|------------------|---------------------------------|---------------|
| SCR-11 main shell | Identity-led top bar, exactly five destinations, 72 px bottom navigation, RTL order, selected Home state, safe-area handling, and retained tab/search back behavior | Test avatar uses a neutral placeholder; no authoritative customer portrait source is part of this flow | STRUCTURE ALIGNED; REVIEW REQUIRED |
| SCR-12 collapsed search | 72 px top bar, 44 px avatar, compact name/greeting hierarchy, and 24 px search/notification/cart icons | Board portrait and exact custom icon artwork are not available as isolated assets | STRUCTURE ALIGNED; ASSET DIFFERENCE |
| SCR-12 expanded search | Normal identity row remains visible; 48 px inline search field and localized cancel action are directly below it | Minor platform font/icon rasterization remains | ALIGNED; REVIEW REQUIRED |
| SCR-13 loaded Home | 168 px hero, five compact quick categories, three visible compact product cards, 16 px section rhythm, supported Store categories next, and total page density close to Board 06 | Hero/category/product artwork is absent from deterministic fixtures. Service is omitted because there is no authoritative feed | STRUCTURE ALIGNED; ASSET/CAPABILITY DIFFERENCE |
| SCR-13 Home skeleton | Shell remains stable; hero, five category blocks, heading bars, and three product blocks mirror loaded hierarchy | Shimmer phase can vary by animation frame | ALIGNED; REVIEW REQUIRED |
| SCR-14 search discovery | One-line horizontally scrollable compact category chips, selected All state, compact recent rows, clear-all action, and correct Arabic RTL order | Extra authoritative categories remain horizontally discoverable instead of being discarded | ALIGNED; REVIEW REQUIRED |
| SCR-15 results | Compact 140 px list rows show three results, image region, state/discount, rating, retail price, and add-to-cart action | Sort/filter gateways stay visibly disabled because server metadata is unconfirmed; product artwork is absent from fixtures | STRUCTURE ALIGNED; CAPABILITY/ASSET DIFFERENCE |
| SCR-15 no results | Purple search state, query-specific title/message, and full-width primary retry action match the approved hierarchy | Exact magnifier illustration is not available as an isolated asset; Material icon is used | STRUCTURE ALIGNED; ASSET DIFFERENCE |

No correctable Flutter layout mismatch found in these eight reviewed states is intentionally left as
"pending." Final visual acceptance remains reviewer-owned.

## Calibration Corrections

| Element | Baseline | Corrected |
|---------|----------|-----------|
| Hero height | 190 px, pill radius | 168 px, 16 px radius |
| Quick category card | 96 x 112 px | 64 x 96 px |
| Store category card | 132 x 156 px | 84 x 120 px |
| Home product card | 176 x 292 px | 112 x 236 px |
| Search results | responsive 1/2-column cards, 292 px extent | one-column 140 px compact rows |
| Section separation | 24 px | 16 px |
| Compact CTA height | shared 48 px control | 40 px for compact cards/hero only; shared default remains 48 px |
| Search category chips | multi-line wrap | 40 px single-line horizontal strip |

The already-approved shell measurements were retained: 16 px screen padding, 72 px top bar, 44 px
avatar, and 72 px bottom navigation.

## Before / After Summary

- Before: the Home hierarchy was a tall generic carousel composition with only two product cards
  visible. After: five quick categories and three product cards fit above the next supported section.
- Before: the hero text/media sides and notification/cart order were reversed from the Arabic RTL
  reference. After: text is on the right, media on the left, and notification/cart/search follow the
  approved visible order.
- Before: Search results used tall grid cards. After: they use the compact RTL list composition in
  Board 06.
- Before: expanded discovery wrapped chips over two lines and used two competing row icons. After:
  chips remain on one line and recent searches use the single approved circular affordance.
- Before: the no-results action was a small intrinsic-width button. After: the action spans the
  content width and the state icon has the approved prominence.
- Before: authenticated non-`Normail` users could see wholesale prices solely because of a legacy
  local string. After: Home/Search always render the public retail price and have regression tests
  proving `typeUser` cannot change it.

## Capability Omissions Permitted by the Contract

- The maintenance/service banner is omitted: no authoritative service feed or settings contract
  exists for this Store client.
- Offers and new arrivals render only when authoritative item flags provide content; no local
  campaign is fabricated.
- Favorites affordances are omitted from product cards because no supported favorites read/write
  contract exists in this phase.
- Search sort/filter gateways remain disabled until T050+ establishes their supported behavior.

## Missing Source Assets

| Missing asset | Affected region | Why parity stops at the placeholder |
|---------------|-----------------|-------------------------------------|
| Approved scooter hero artwork/background | SCR-13 hero | The repository has no isolated approved hero asset; production may only provide an ad URL |
| Approved category thumbnails | SCR-13 quick and Store categories | The deterministic fixtures intentionally have no media URLs and no approved local cutouts exist |
| Approved product cutouts | SCR-13 cards and SCR-15 results | Product media is backend content; the exact board images are not checked in as reusable assets |
| Approved customer portrait | SCR-11/12 top bar | The reviewed shell has no authoritative profile-image contract |
| Approved no-results illustration | SCR-15 empty state | Only the flattened board contains it; no standalone app asset exists |

## Test Coverage

- `test/controllers/shell_search_test.dart` now proves Home/Search display retail pricing for legacy
  `typeUser` values `User`, `Normail`, `admin`, and empty, including an authenticated session.
- `test/widgets/home_search_test.dart` covers Arabic RTL, shell preservation, compact/small viewport,
  1.30 text scale, loaded/skeleton/discovery/results/no-results, and all five phase goldens.
- `test/widgets/store_foundation_test.dart` covers the added localized View all and Search again
  keys alongside the shared foundation contract.

## Validation

- `dart format` completed on every modified Dart file.
- `flutter analyze`: no issues found.
- `flutter test`: 84 tests passed.
- `git diff --check`: clean.

## Acceptance Boundary

This review corrects and records T041-T049 only. It does not implement Categories/listing/filter
work from T050+, does not redesign Product/Cart/Checkout/Orders/Profile, and does not change Laravel,
Flutter Admin, or `checklists/implementation.md`.
