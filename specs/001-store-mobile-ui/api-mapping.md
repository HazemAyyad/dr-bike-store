# API Mapping: Doctor Bike Store Mobile UI

**Inspected client base URL**: `https://dr-bike.duosparktech.com/public`
**Authority**: current source in `lib/core/constants/app_constants.dart`
**Note**: `docs/api-endpoints.md` still names an older base URL and is not current authority.

All calls use the single `ApiClient`. HTTP 200 alone is not sufficient proof: each UI contract must
parse the expected shape and retain failure when content type, field type, or required identity is
missing.

## Authentication, Account, Settings, and Orders

| Method and endpoint | Current caller | Auth | Current typed use | UI coverage | Status / gap |
|---------------------|----------------|------|-------------------|-------------|--------------|
| `POST /Auth/login` | `AuthRepository.login` | No | `AuthResponse` with user, token, `accountRoles` | SCR-06, session bootstrap | Reusable; provider login is not established |
| `POST /Users/Register` | `AuthRepository.register` | No | Success/error body; current body has email, phone, password | SCR-07 | Reusable but full name/terms semantics need confirmation |
| `POST /Auth/CheckUser?UserId=` | auth/home services | Bearer | Account close/block signal | SCR-03/04/43 | Existing polling is unsafe; response schema needs typed consolidation |
| `POST /Auth/ForgotPassword` | forgot controller | No | `ForgotPasswordResponse`; sends Store metadata | SCR-08/05 | Reusable and tested |
| `POST /Auth/VerifyForgotPasswordOtp` | forgot controller | No | `OtpVerificationResponse.resetProof` | SCR-09 | Reusable and tested; OTP length/expiry error shape should be documented |
| `PATCH /Auth/ChangePasswordToForgot` | forgot controller | No | Proof-bound reset; Store metadata | SCR-10/05 | Reusable and tested; HTTP 426 supported |
| `POST /Auth/ChangePassword` | account controller | Bearer | Success/errors | Profile password change | Reusable with typed error mapping |
| `POST /Users/GetById?id=` | account/shop controllers | Bearer | `UserModel` / `user_data_model.UserModel` | SCR-12/25/36/37 | Duplicate model shapes should be normalized; address book not included |
| `POST /Users/Edit` | account/shop repositories | Bearer | Updated user | SCR-25/37 | Supports profile city/address edit, not independent address CRUD |
| `POST /Users/BlockUserAndNotActive?userId=` | account controller | Bearer | Deletion/deactivation acknowledgment | SCR-43 | UI must clear identity only after accepted response |
| `POST /Settings/CheckSetting` | auth/account services | No | `ApiResponse` contact + close settings | SCR-03/04/42 | Reusable; version/update and richer policy fields need confirmation |
| `POST /Orders/GetAllOrdersByUserId?statusOrder=&userId=` | account controller | Bearer | `OrderResponse` | SCR-30/31/32 | Current client sends three requests for Done/Canceled/New; status vocabulary needs consolidation |
| `POST /Orders/ManageOrder` | legacy edit path | Bearer | Legacy order mutation | Legacy cancellation path | Do not use for new checkout; current cancellation now has dedicated route |
| `POST /Orders/CancelOrder?id=&userId=` | `AuthRepository.cancelOrder` | Bearer | Success/error | SCR-33 | Cancellation eligibility/error contract needs explicit fields |

## Catalog, Search, Media, and Reviews

| Method and endpoint | Current caller | Auth | Current typed use | UI coverage | Status / gap |
|---------------------|----------------|------|-------------------|-------------|--------------|
| `POST /MainCategorys/GetAllShowMainCategories` | `HomeRepository.getMainCategories` | No | `OnlineStoreCategory` hierarchy | SCR-13/16 | Compatibility name returns active `online_store_categories`; identity is the Online Store category ID |
| `POST /OnlineAds/GetAllAds` | Home | No | `Ad` | SCR-13 hero | Banner/Home presentation is owned by the Online Store content layer; no inventory-section semantics |
| `POST /Items/GetAllItemIsMoreSales` | Home | No | `Item` list | SCR-13 best sellers | Reusable; publication/listing identity required in every row |
| `POST /Items/GetAllItemByName?Name=&language=` | Home search | No | `Item` list | SCR-14/15 | Reusable; recent searches are local intent, suggestions/chips need mapping |
| `POST /Items/GetAllItemsShowByMainCategory?MainCategory=` | Categories | No | eligible `OnlineStoreListing` rows as `ItemsResponse` | SCR-16/17 | Filters through active `online_store_category_listing` membership; Product alone is not publication authority |
| `POST /Items/GetItemById?itemId=` | Product | No | eligible `OnlineStoreListing -> Product` Storefront payload | SCR-19..22 | Product compatibility identity is `productId`; response retains distinct `listingId`, retail display price, availability, and typed `storefrontMedia` from `online_store_media_presentations` |
| `POST /Items/GetAllShowItemsBySupCatId?supCategoryId=` | Categories/product | No | eligible `OnlineStoreListing` list | Optional hierarchy/similar products | Compatibility alias maps `supCategoryId` to an Online Store category and uses the same active category-listing membership query |
| `POST /SupCategorys/GetAllShowSupCategories?mainCategoryId=` | Categories | No | Online Store child categories | SCR-16 | Compatibility hierarchy is backed by `online_store_categories`, not inventory Store sections |
| `POST /Comments/GetAllCommentsToItem?ItemId=` | Product | No | `Review` list | SCR-35 | Reusable; endpoint path differs from older doc `/api/Comments/...` |
| `POST /Comments/ManageComment` | Product | Bearer | Success/error | SCR-35 | Eligibility/edit/moderation response requires clarification |

## Notifications

| Method and endpoint | Current caller | Auth | Current typed use | UI coverage | Status / gap |
|---------------------|----------------|------|-------------------|-------------|--------------|
| `POST /Notifications/GetNotifications?UserId=` | Home | Bearer | `NotificationResponse` | SCR-12/34 | Reusable basic list; categories/deep link types need fields |
| `POST /Notifications/EditNotification?NotificationId=&IsRead=true` | Home | Bearer | Boolean/success body | SCR-34 | UI must wait for success; current code mutates local flag too early |

## Cart, Delivery, Coupon, and Checkout

| Method and endpoint | Current caller | Auth | Current typed use | UI coverage | Status / gap |
|---------------------|----------------|------|-------------------|-------------|--------------|
| Local GetStorage key `cart` | `ShopController` | Local | `Item.toJson/fromJson2` | SCR-24 | Reusable continuity; line identity and model separation need refactor |
| `POST /DiscoundCodes/GetByDiscoundCode?code=&userid=` | Shop | Bearer | `CouponModel` | SCR-24/28 | Reusable; server remains eligibility/value authority |
| `POST /Cities/GetAllCities` | Auth/Shop | Bearer in current client | `CitiesResponse` | SCR-25/26/37 | Reusable city list; address-book CRUD absent |
| `POST /Cities/GetVillagesByCityId?cityId=` | Shop | Bearer | `VillagesResponse` | SCR-25/26 | Reusable |
| `POST /Cities/CalculateDeliveryFee` | Shop | Bearer | `deliveryCost`/`priceDelivery`/nested fee fallbacks | SCR-26/27 | Response needs one typed canonical field; shipping methods/time absent |
| `POST /OnlineStore/Checkout` | Shop | Bearer | `NativeCheckoutSuccess` from `data.id`, 201 create/200 replay | SCR-28/29 | Reusable and tested; verified payment is cash/COD only |

### Verified Native Checkout Request

```json
{
  "client_request_id": "uuid-v4",
  "account_role": "customer-or-seller",
  "items": [
    {
      "listing_id": 407,
      "size_id": 7,
      "size_color_id": 8,
      "quantity": 3
    }
  ],
  "delivery": {
    "customer_address": "Ramallah",
    "shiply_city_id": 10,
    "shiply_village_id": 20
  },
  "payment": {
    "type": "cash",
    "paid_amount": 0
  },
  "coupon_code": "SAVE10"
}
```

`coupon_code` is optional. Product IDs, legacy `details`, locally calculated final totals, and
`typeUser` MUST NOT replace the verified fields.

## Backend Dependencies and Safe Fallbacks

| Capability | Missing/uncertain contract | Affected screens | Safe UI behavior | Blocking level |
|------------|----------------------------|------------------|------------------|----------------|
| Favorites | Read/add/remove/sync and guest policy | SCR-12/17/19/23/36 | Hide or disabled heart with explicit dependency in non-production; no fake persisted success | Blocks functional favorites only |
| Address book | CRUD, default, labels, eligibility | SCR-25/36/38 | Use current profile address/city/village form; do not claim multiple saved addresses | Blocks full address-book screen |
| Saved payments | Tokenized methods, list/add/remove/default | SCR-27/36/39 | Show only verified COD; omit card/wallet/bank/saved toggle | Blocks non-COD methods |
| Filter/sort | Supported fields, ranges, facets, server request shape | SCR-15/17/18 | Enable only verified price/local presentation filtering; label remaining controls unavailable or omit | Partial block |
| Product metadata | Brand, distinct code, structured specs, policies, color values | SCR-17/19 | Omit absent fields; do not derive business meaning from text | Partial block |
| True 3D/360 | Explicit `media_metadata.media_type` / `is_360` capability | SCR-19/22 | Show interactive control only when metadata proves support; `image3d` source alone remains a static/unsupported medium | Capability-gated per media item |
| Home feeds | Service, offers, new arrivals, store-category feed definitions | SCR-13 | Render sections only from mapped authoritative data; no hard-coded commercial claims | Partial block |
| Shipping methods/time | Method IDs, availability, ETA/time windows, pickup | SCR-26 | Use current city/village fee flow and verified method only | Partial block |
| Order actions | Eligibility plus edit-address/note/reorder/share endpoints | SCR-31/33 | Show cancellation only when contract authorizes; omit other actions | Partial block |
| Notification taxonomy | Category/type/deep-link target fields | SCR-12/34 | Show basic list/read; deep link only through allowlisted typed target | Partial block |
| Notification preferences | Remote settings endpoints and consent semantics | SCR-41 | Show OS permission status only if clearly local; omit remote toggles | Blocks remote preference toggles |
| Review eligibility | Purchase requirement, edit/delete, moderation status | SCR-19/35 | Preserve current read/add only where accepted; do not optimistically publish | Partial block |
| Startup policy | Consolidated maintenance/minimum/recommended version response | SCR-03/04/05 | Keep explicit offline/error; use only currently verified close/426 signals | Partial block |

## Contract Validation Rules

- Every list response is a JSON object with a list under the documented key before mapping.
- Required identifiers must parse to their declared type; missing listing ID blocks checkout only,
  not product browsing.
- Unknown enum/status values remain representable and visible with neutral presentation.
- 200/201 mutation success must include the expected result body; otherwise remain error/uncertain.
- 401/403 invalidate or gate only the affected session/action using backend guidance.
- 426 maps to the explicit upgrade state.
- Timeout/no connectivity maps to offline/uncertain based on whether the action could have reached
  the server; checkout uncertainty preserves `client_request_id` and cart.
- Sensitive request/response values are redacted from debug output.
