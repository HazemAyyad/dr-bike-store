# Screen Inventory: Doctor Bike Store Mobile UI

**Inventory count**: 44 screens/flows
**Baseline**: Arabic RTL
**Detailed contract**: [spec.md](spec.md#screen-and-flow-contract)

| ID | Area | Screen / flow | Reference board(s) | Existing status |
|----|------|---------------|--------------------|-----------------|
| SCR-01 | Bootstrap | Animated splash | 01, 02 | Existing static splash; functional + visual refactor |
| SCR-02 | Bootstrap | Onboarding | 01, 02 | Existing three pages; visual refactor |
| SCR-03 | Bootstrap | App initialization/routing | 01, 07 | Existing partial logic; functional refactor |
| SCR-04 | Bootstrap | Maintenance/store closed | 02 | Partial service logic; screen missing |
| SCR-05 | Bootstrap | Upgrade/version state | 02 | Helper exists for one auth path; global flow missing |
| SCR-06 | Auth | Login | 01, 02 | Existing; visual refactor and provider gating |
| SCR-07 | Auth | Registration | 02 | Existing; visual/contract refactor |
| SCR-08 | Auth | Forgot-password request | 02 | Existing; visual refactor |
| SCR-09 | Auth | OTP verification | 02 | Existing; visual/functional refinement |
| SCR-10 | Auth | Set new password | 02 | Existing; visual refactor |
| SCR-11 | Shell | Five-destination main shell | 06, 07, 08 | Current shell has three destinations; functional/visual refactor |
| SCR-12 | Shell | Top bar and expandable search | 06, 07, 08 | Partial fixed search bar; functional/visual refactor |
| SCR-13 | Home | Compact storefront home | 06, 07 | Existing hero/best sellers/sections; several sections missing |
| SCR-14 | Search | Search discovery/recent/chips | 07 | Mostly missing |
| SCR-15 | Search | Results and no-results | 02, 07 | Basic results exist; state/visual refactor |
| SCR-16 | Catalog | Categories/inventory hierarchy | 02, 06 | Inventory sections exist; visual/hierarchy refactor |
| SCR-17 | Catalog | Product listing | 06, 08 | Existing list/grid; visual/functional refactor |
| SCR-18 | Catalog | Filter and sort | 06 | Basic price filter exists; major functional refactor |
| SCR-19 | Product | Product detail | 04, 05, 06 | Existing large screen; reusable behavior, major visual refactor |
| SCR-20 | Product | Full image gallery | 04, 05 | Partial existing image views; functional/visual refactor |
| SCR-21 | Product | Video player | 04, 05 | Existing video player; visual/error-state refactor |
| SCR-22 | Product | 3D/360 viewer | 04, 05 | Real interactive support not proven; dependency-gated |
| SCR-23 | Shopping | Favorites | 02, 06, 08 | Missing contract and feature |
| SCR-24 | Shopping | Cart | 03, 06 | Existing retained cart; visual/identity refactor |
| SCR-25 | Checkout | Address step | 03, 06 | Current single form; address-book gap |
| SCR-26 | Checkout | Shipping step | 03, 06 | City/village/fee exist; methods/time largely missing |
| SCR-27 | Checkout | Payment step | 03, 06 | COD contract exists; other methods dependency-gated |
| SCR-28 | Checkout | Idempotent submission | 03, 06 | Secure implementation reusable |
| SCR-29 | Checkout | Order success | 03 | Existing basic success; visual/contract refactor |
| SCR-30 | Orders | Order list/tabs | 02, 03, 06 | Existing status groups; visual/refetch refactor |
| SCR-31 | Orders | Order details/summary | 03, 06 | Existing typed snapshot detail; visual refactor |
| SCR-32 | Orders | Tracking timeline | 03 | Existing Shiply timeline; visual refinement |
| SCR-33 | Orders | Order actions | 03 | Cancellation exists; other actions are gaps |
| SCR-34 | Communication | Notifications | 02, 08 | List/read exists; categories/deep links need contract |
| SCR-35 | Communication | Reviews | Product references, 08 states | List/add exists; eligibility/visual refactor |
| SCR-36 | Profile | Profile hub | 02 | Existing basic hub; navigation hierarchy refactor |
| SCR-37 | Profile | Account information | 02 | Existing profile edit; fields/media contract gaps |
| SCR-38 | Profile | Addresses | 02 | Full address-book feature missing |
| SCR-39 | Profile | Payment methods UI | 02 | Missing; dependency-gated |
| SCR-40 | Preferences | Language | 02 | Existing Arabic/English/Hebrew; reference mismatch to resolve |
| SCR-41 | Preferences | Settings | 02 | Dark mode/language partial; notification preferences missing |
| SCR-42 | Support | Help/support/policies | 02 | Contact/about/terms exist; FAQ/privacy polish missing |
| SCR-43 | Account | Logout/account deletion | 02 | Existing; server-success and visual refinement |
| SCR-44 | Global | Loading/empty/error/offline/success library | 02, 07, 08 | Scattered partial states; shared foundation missing |

## Navigation Inventory

- Primary: Home -> Categories -> My Orders -> Favorites -> Profile.
- Context actions: Search, notifications, cart, share, favorite, add to cart, buy now.
- Protected destinations: orders, server favorites if authenticated-only, notifications, checkout,
  account, addresses, payment methods, review submission, logout/delete.
- Guest-safe destinations: splash/onboarding, home, categories, search, listings, product detail,
  local cart, language, support, login/register/recovery.

## Completion Rule

A screen moves from its current classification to complete only when functional behavior, all
applicable global states, Arabic RTL, accessibility, contract checks, and mapped visual comparison
pass. A dependency-gated screen may have a reviewed non-interactive shell but cannot be reported as
functional until its backend contract is verified.
