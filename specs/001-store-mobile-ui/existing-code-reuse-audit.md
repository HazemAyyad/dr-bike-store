# Existing-Code Reuse Audit

**Repository**: `F:/flutter_projects/doctorbike_store`
**Branch inspected**: `feat/store-mobile-ui` at `7b6950d`
**Inventory**: 345 tracked/untracked-discoverable files, 138 Dart files, 2 test files

The app does not require a rewrite. The audit below classifies the existing implementation using
the five required categories. Classification describes the likely implementation treatment; it is
not authorization to edit application code during this planning task.

## 1. Reusable Without Meaningful Changes

| Area / paths | Existing capability | Reuse boundary |
|--------------|---------------------|----------------|
| `lib/main.dart` Firebase/notification/storage initialization | Initializes Firebase, local notifications, SharedPreferences, GetStorage and DI before app start | Keep startup ordering; integrate explicit bootstrap state around it rather than replace services |
| `lib/core/api_client.dart` | Central HTTP client, JSON parsing, timeouts, debug request/response summaries, sensitive-value redaction | Keep one networking stack; extend typed error classification without bypassing redaction |
| `lib/core/functions/store_client_metadata.dart` | Store/platform/version/build metadata | Reuse for recovery/update contracts |
| `lib/core/functions/checkout_attempt.dart` | UUID lifecycle, in-flight coalescing, retry identity | Preserve exactly; cover with regression tests |
| `lib/core/functions/native_checkout.dart` | Listing-based payload, COD contract, account-role resolution, typed success | Preserve authoritative rules; UI consumes it |
| `lib/core/functions/upgrade_required.dart` | Explicit HTTP 426 message mapping | Reuse inside a consolidated upgrade state |
| `lib/core/model/otp_model.dart` | Typed reset-request and opaque-proof response | Preserve proof boundary |
| `lib/core/model/discount_code_model.dart` | Typed coupon response | Reuse after null/error contract validation |
| `lib/core/model/notification_model.dart` | Basic notification/pagination parsing | Reuse for current fields; extend only for verified category/deep link fields |
| `lib/core/model/commint_model.dart` | Review/pagination parsing | Reuse current contract; extend only with verified eligibility fields |
| `lib/core/model/city_model.dart` | City, village, and delivery identifiers | Reuse for current Shiply selection/quote flows |
| `lib/core/functions/notification_api.dart` and notification controller token retrieval | Firebase messaging/local notification bootstrap | Reuse platform setup; presentation/deep links need later refactor |
| `test/t140_secure_store_client_test.dart` | 22 focused Store security/contract tests | Keep as regression baseline; split later only if helpful |

## 2. Reusable but Visually Refactor

| Area / paths | Reusable behavior | Visual work required |
|--------------|-------------------|----------------------|
| `lib/features/splash`, `onbarding`, `intro` | First-run navigation and three-page onboarding | Animated approved splash, board-specific onboarding composition, truthful bootstrap states |
| `lib/features/auth/**` | Login, registration, recovery page sequence, OTP, reset | Boards 01/02 layout, compact fields/buttons, supported-provider gating, consistent states |
| `lib/features/home_screen/**` | Hero ads, best sellers, store sections, pull-to-refresh, skeleton primitives | Approved compact section order, identity top bar, expandable search, shared cards/skeletons |
| `lib/features/category/category_screen.dart` and list/grid widgets | Product list/grid navigation and cart/product actions | Board 06 cards, count/sort/filter header, shared empty/error/offline states |
| `lib/features/supCategory/supCategory.dart` | Optional sub-section navigation | Approved category hierarchy/card styling when authoritative data exists |
| `lib/features/search/search_screen.dart` | Search request and result list | Inline expanded search, recent queries/chips, debounce state, no-result/offline designs |
| `lib/features/product/product_details_screen.dart` | Product identity, pricing, options, quantity, reviews, similar items, cart/share/WhatsApp actions | Split into board 04/05/06 sections; replace monolithic layout with reusable media/detail components |
| `lib/features/product/widget/video_view.dart`, `image_view.dart`, `view_image_and_video.dart` | Basic image/video display | Approved full-screen gallery controls, counters, thumbnail rail, loading/error behavior |
| `lib/features/shop/shop_car_screen.dart` and cart widgets | Retained lines, quantity/remove, totals, coupon entry, checkout entry | Board 03/06 cart density, selection/clear semantics where supported, shared line cards/states |
| `lib/features/shop/check_out_done.dart` | Displays created order identity and next navigation | Board 03 success composition and authoritative action set |
| `lib/features/order/order_screen.dart`, `order_details_screen.dart`, order widgets | Status groups, product snapshots, details, Shiply timeline, cancellation entry | Board 02/03/06 tabs/cards/timeline/actions and shared state components |
| `lib/features/notification/notification_screen.dart` | Notification list and read flow | Board 02 tabs/cards/unread treatment and deep-link-safe presentation |
| `lib/features/acount/**`, `lang/**` | Profile/account/contact/about/terms/language/theme/logout/delete | Board 02 hierarchy, neutral compact surfaces, addresses/payment/settings capability gates |
| `lib/core/widget/custom_image_widget.dart` | Cached image and error placeholder boundary | Apply approved placeholder/aspect/corner treatments |
| `lib/core/widget/custom_button.dart`, fields, dialogs, dropdowns | Repeated interaction primitives | Wrap/migrate into board 08 variants with semantics and consistent tokens |

## 3. Reusable but Functionally Refactor

| Area / paths | Issue found | Refactor direction |
|--------------|-------------|--------------------|
| `lib/my_app.dart`, route/binding helpers | Global back is disabled; route set lacks five-shell destinations and missing features; multiple `Get.put` paths can duplicate dependencies | Preserve GetX but centralize stable bindings, shell routing, guarded destinations, and normal back/deep-link behavior |
| `lib/controller/check_account/account_service.dart` | Account polling method can run every 500 ms; connectivity expression is logically always true for common results; close-site routing/state is incomplete | Replace with event/startup-driven typed session/store status and explicit offline recovery |
| `lib/controller/home/home_controller.dart` | Independent sections collapse failures into snackbars/empty; search replaces Rx objects; notification state can duplicate IDs | Use stable section state objects, safe refresh, deterministic search debounce, and server-confirmed read state |
| `lib/controller/categores/categores_controller.dart` | Filtering conditions and range checks are inconsistent; navigation is performed inside fetch methods; duplicated category paths | Separate fetch, view filtering, navigation, sort/filter selection, and authoritative capabilities |
| `lib/controller/product/product_controller.dart` | HEAD request precedes media, controllers can leak, multiple sequential similar-product requests, errors are swallowed, media types are not normalized | Typed media presenter, lifecycle-safe playback, explicit errors, batched/cached related data where contract allows |
| `lib/controller/shop/shop_controller.dart` | 1,333 lines; cart uniqueness is inconsistent (`addToCart` uses only product ID); duplicated order-total code; local totals mix preview and authority; UI dialog in controller | Preserve cart/checkout contracts but split cart identity, preview totals, checkout orchestration, delivery, coupon, and role-selection presentation |
| `lib/controller/account/account_controller.dart` | Multiple sequential order requests accept partial 200 with unsafe parsing; controller owns navigation/dialog effects; delete/logout semantics need clearer server boundary | Typed per-status/result state, capability-driven actions, server-success-first deletion, presentation-owned navigation |
| Auth controllers | Some error branches index `response.body` without type guards; OTP timer decrements every two seconds while presented as seconds; provider UI is disconnected from contracts | Typed auth failures, accurate countdown, explicit provider capability, stable submit states |
| `lib/core/model/get_all_item_model.dart` | Required booleans/lists/dates assume non-null; date parsing can throw; legacy spelling (`normailPrice`) leaks; presentation fields and cart state share one mutable transport model | Add defensive typed parsing and separate immutable API/product view data from mutable cart-line state while preserving compatibility |
| `lib/core/model/auth_eesponse.dart`, `user_data_model.dart` | Duplicate user shapes and legacy types | Consolidate shared typed account presentation without weakening `accountRoles` |
| `lib/core/model/orders_model.dart` | Good typed tracking additions coexist with legacy item duplication | Preserve order snapshot/tracking types; normalize shared media/product presentation carefully |
| `lib/controller/LocalizationController.dart` and `locale.dart` | Arabic/English/Hebrew exist, some hard-coded strings remain, direction only distinguishes Arabic, reference shows Turkish | Establish supported-locale decision, move all new text to keys, add RTL/LTR-safe mixed-text rules |
| `lib/core/theme/light.dart`, constants/styles/dimensions | Current font is Almarai, theme uses scattered/invalid-looking color constants, no design-token ownership | Replace presentation values through centralized Cairo/board-08 tokens with compatibility aliases during migration |
| `lib/features/shop/check_out_screen.dart` | Current single long form does not expose three-step address/shipping/payment state | Reuse form/selectors and secure submit but split into explicit steps and capability-gated methods |

## 4. Obsolete or Candidate for Removal After Migration

These paths MUST remain until callers are migrated and tests prove removal is safe.

| Path / pattern | Reason |
|----------------|--------|
| `lib/features/category/categorey_page.dart` and `category_and_filtter.dart` | Duplicate/legacy category navigation and rendering paths overlap `category_screen.dart` |
| `lib/features/shop/widget/build_two_item.dart` and `build_three_item.dart` | Duplicated product-card implementations superseded by one responsive card component |
| Product-card implementations inside `home_screen.dart` and `category_screen.dart` | Repeated card/business presentation that should use shared product cards |
| Large commented legacy checkout blocks in `shop_controller.dart` | Dead alternative payload logic increases financial-flow confusion |
| `lib/core/functions/code_picker_widget.dart` and `lib/core/widget/code_picker_widget.dart` | Duplicate mostly commented/legacy code-picker implementations |
| `lib/core/functions/pdf_invoice.dart` and `lib/core/widget/select_button.dart` | Empty one-line placeholders with no active capability |
| `lib/core/widget/on_hover.dart` | Desktop hover helper is not part of the approved mobile interaction system unless a live caller proves need |
| `test/widget_test.dart` | Default counter template does not describe the app and is expected to fail after real bootstrap dependencies |
| Legacy theme/style names such as `roboto*` | Naming contradicts actual font and future Cairo system; retain temporary aliases only during migration |

## 5. Missing

| Missing capability | Dependency / planned location |
|--------------------|-------------------------------|
| Central Doctor Bike design tokens and Cairo assets | Phase 1 under `lib/core/theme` / `assets/font`, with board 08 calibration |
| Reusable five-tab shell/top bar/expandable search | Phase 1/3 shared navigation components |
| Shared async state model and global state components | Phase 1; controllers adopt incrementally |
| Full Home service/offers/new-arrivals feeds | Backend mapping required; shell sections can remain capability-gated |
| Recent search persistence and category chips | Local preference plus authoritative catalog categories; Phase 3 |
| Supported sort/filter capability model | Backend confirmation; Phase 4 |
| Typed unified media presentation and true 3D/360 viewer | Phase 5; interactive contract blocks viewer |
| Favorites repository/controller/model | Backend authority required; Phase 6 |
| Address-book repository/controller/model | Backend CRUD/default contract required; Phase 7/9 |
| Saved payment-method support | Tokenized backend/payment provider required; raw local storage prohibited |
| Advanced order action eligibility/endpoints | Backend contract required; Phase 8 |
| Notification category/deep-link model | Backend fields and route allowlist required; Phase 9 |
| Notification preferences | Backend preference contract required; local permission status alone is insufficient |
| Structured product specs/brand/policies | Product/settings contract mapping required |
| Screenshot-based visual regression harness and reference viewport matrix | Phase 0/10/11 |
| Journey tests for bootstrap, shell, catalog, media, cart, checkout, orders, profile | Added incrementally by phase |

## Current Architecture Summary

```text
main / MyApp
  -> GetX bindings and named routes
  -> feature screens
  -> GetX controllers (state + orchestration + some navigation/dialogs)
  -> domain repositories
  -> one ApiClient
  -> Laravel compatibility endpoints

Local continuity
  -> SharedPreferences: session, user summary, locale, first-run/theme flags
  -> GetStorage: serialized cart

Platform services
  -> Firebase Messaging + local notifications
  -> connectivity monitoring, URL launch, video, sharing/screenshots
```

## Audit Conclusion

The implementation should retain the layered spine and secure Store client work, then reduce
controller/UI coupling and duplicated presentation as each screen is migrated. The high-risk work is
contract/state fidelity, not framework replacement. No objective reason for a full rewrite was found.
