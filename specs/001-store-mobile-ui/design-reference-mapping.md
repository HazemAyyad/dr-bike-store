# Design Reference Mapping

All eight approved boards were inspected at original resolution on 2026-10-05. This matrix is the
traceability source for implementation and visual review.

| Reference | Defines | Mapped screens/components | Required fidelity evidence |
|-----------|---------|---------------------------|----------------------------|
| `01-splash-onboarding-login.png` | Six-stage logo animation; dark cinematic splash; three light onboarding panels; login composition | SCR-01, SCR-02, SCR-06; brand motion, onboarding pager, auth logo/form | Capture animation keyframes and final state; compare all onboarding pages and login at agreed viewport |
| `02-auth-profile-settings-states.png` | Dark welcome variant; onboarding variants; login/register/forgot/OTP/new-password; profile/account/addresses/payments/orders/favorites/notifications/settings/language/help; empty/offline/error states | SCR-01/02, SCR-06..10, SCR-23, SCR-30, SCR-34, SCR-36..44 | Auth state set, profile hierarchy, preference controls, and all six illustrated global-state cards |
| `03-cart-checkout-orders.png` | Cart; address/shipping/payment stepper; success; order list/detail/summary/tracking/actions | SCR-24..33 | Cart line/totals layout, each checkout step, authoritative success, order cards/timeline/actions |
| `04-product-media-gallery.png` | Product detail media hierarchy; full-screen image; video; 360; thumbnails/counters/arrows | SCR-19..22 | One product rendered in base, image, video, and supported interactive states with media switching |
| `05-product-details-media-states.png` | Single vs multiple images; video panel; 3D tab; media taxonomy and thumbnail rules | SCR-19..22 | Variant matrix for one image, multiple images, video present, 3D/360 present/absent |
| `06-main-store-flows.png` | Home, categories, listing, filter, product detail, cart, checkout, order list/detail and five-tab shell | SCR-11..13, SCR-16..19, SCR-24..32 | Full Arabic RTL browse-to-order journey screenshots and shell selected states |
| `07-home-search-loading.png` | Long-form compact home composition; expandable search; recent searches/chips; pull-to-refresh; skeleton home | SCR-12..15, SCR-44 | Home section order, expanded/collapsed search, refreshing state, skeleton state, bottom bar |
| `08-design-system.png` | Logo; exact palette; Cairo 300-700; top/bottom navigation; buttons/inputs/chips/statuses; spacing/radii/shadows; cards; skeletons; states; placeholders; pull-to-refresh | All screens, especially SCR-11/12/17/44 | Component catalog capture plus token audit; all uncertain measures tagged/calibrated rather than claimed exact |

## Board 08 Token Extraction

### Explicit values visible in the board

| Token | Value |
|-------|-------|
| Primary navy | `#0F0F31` |
| Primary purple | `#6B65BD` |
| Light purple | `#E9E8F7` |
| App background | `#F8F9FB` |
| Card surface | `#FFFFFF` |
| Success | `#22A06B` |
| Warning | `#F5A623` |
| Error | `#EB4D4F` |
| Information | `#3B82F6` |
| Primary text | `#17172B` |
| Secondary text | `#73737D` |
| Disabled text | `#A0A3B1` |
| Border | `#E5E6EA` |
| Cairo weights | Light 300, Regular 400, Medium 500, SemiBold 600, Bold 700 |
| Spacing scale shown | 4, 8, 12, 16, 24, 32, 40, 48 |
| Radius scale shown | 8, 12, 16, 24 |

### Component families

- Logo: navy/purple mark with Doctor Bike wordmark and `Boost | Repair | Sell` tagline; clear-space
  and dark/light asset variants require calibration against source assets.
- Buttons: primary purple fill, secondary purple outline, disabled neutral, icon-button, loading.
- Inputs: normal, focused purple, error red, success green, disabled neutral.
- Chips: availability, unavailability, new, best seller, discount, removable category; order status
  chips for complete, pending, preparing, shipped, canceled.
- Cards: product card variants, unavailable disabled card, category image/list variants.
- Navigation: identity-led top bar with search/notification/cart/menu variants; five-item bottom bar.
- States: skeleton patterns, empty/no-product/no-result, generic error, success, offline, media
  placeholder, pull-to-refresh progression.

### Visual calibration tokens

Exact screen padding, component heights, icon sizes, type sizes/line heights, card aspect ratios,
border widths, shadow blur/offset/opacity, and animation durations MUST be calibrated during
implementation. The raster boards alone do not safely establish density-independent exact values.

## Coverage Confirmation

- Reference files inspected: 8/8.
- Reference files mapped: 8/8.
- Screen/flow contracts with at least one mapped reference: 44/44.
- Unaccounted reference files: 0.
