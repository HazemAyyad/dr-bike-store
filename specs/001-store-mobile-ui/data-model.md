# Data Model: Doctor Bike Store Mobile UI

This document defines presentation and contract entities for planning. It does not authorize new
backend tables or local business authority.

## Identity and Session

### StoreSession

| Field | Type | Rules |
|-------|------|-------|
| `userId` | nullable string | Present only for authenticated identity; never inferred from email |
| `token` | nullable secret string | Stored through the existing session boundary; never logged |
| `displayName` | nullable string | Presentation value from authenticated profile |
| `email` | nullable string | Presentation/contact value from profile |
| `accountRoles` | list of enum | Allowed checkout roles are `customer` and `seller`; unknown roles confer no access |
| `isRemembered` | boolean | Controls session continuity, not backend account validity |
| `locale` | locale code | Arabic default; supported locale set must match available content |
| `isFirstRunComplete` | boolean | Controls onboarding only |
| `notificationToken` | nullable secret string | Submitted only through the supported auth/notification contract |

**State transitions**: guest -> authenticating -> authenticated; authenticated -> expired/blocked ->
guest; authenticated -> logout -> guest. Cart policy is independent and must be preserved unless an
explicit migration says otherwise.

### RecoverySession

| Field | Type | Rules |
|-------|------|-------|
| `identifier` | string | Email or phone only as supported by backend |
| `otpLength` | positive integer | Supplied/confirmed by contract; reference currently depicts four cells |
| `resendAvailableAt` | timestamp | UI countdown derives from this value |
| `resetProof` | nullable opaque secret | Required before password reset; never replaced by user ID and never logged |
| `status` | enum | `requesting`, `codePending`, `verifying`, `proofReady`, `resetting`, `complete`, `failed`, `upgradeRequired` |

## Catalog

### StoreSection

| Field | Type | Rules |
|-------|------|-------|
| `id` | integer | Stable inventory-section identity |
| `localizedName` | localized text | Arabic/English/Hebrew values when available |
| `localizedDescription` | localized text | Optional presentation content |
| `imageUrl` | nullable URL | Empty/failed source uses placeholder |
| `isActive` | boolean | Inactive sections are not browseable |
| `sortOrder` | integer | Backend order when supplied |
| `parentId` | nullable integer | Only if authoritative hierarchy is supported |
| `publishedCount` | nullable integer | Display only if supplied; never derived as inventory authority |

### PublishedListing

| Field | Type | Rules |
|-------|------|-------|
| `listingId` | integer | Required for checkout; distinct from product ID |
| `productId` | integer | Product identity used for product/read endpoints |
| `storeSectionIds` | list of integer | Inventory-backed browse placement |
| `publicationState` | enum | Active/published authority from backend |
| `retailPrice` | money | Backend authoritative |
| `wholesalePrice` | money | Backend authoritative and role-sensitive |
| `oldPrice` | nullable money | Display only when authoritative |
| `discount` | nullable percentage/value | Backend authoritative; validation defines valid range |
| `stock` | non-negative integer | Backend authoritative; option stock overrides base when selected |
| `rating` | non-negative decimal | Display only if supplied |
| `reviewCount` | nullable non-negative integer | Display only if supplied |

### ProductPresentation

| Field | Type | Rules |
|-------|------|-------|
| `productId` | integer | Required |
| `code` | nullable string | Do not equate to model unless contract defines it |
| `localizedName` | localized text | Fallback rules must be explicit |
| `localizedDescription` | localized text | Plain/structured content as provided |
| `brand` | nullable brand | Omit when absent; no local invention |
| `model` | nullable string | Existing product attribute |
| `manufactureYear` | nullable integer | Existing product attribute |
| `quickSpecifications` | ordered list | Requires structured contract or documented mapping |
| `policies` | shipping/warranty/returns | Requires settings/product contract |
| `media` | ordered list of MediaAsset | See below |
| `options` | ordered list of ProductOption | See below |

### ProductOption

| Field | Type | Rules |
|-------|------|-------|
| `sizeId` | nullable integer | Stable option identity |
| `sizeLabel` | string | Presentation only |
| `sizeDescription` | nullable string | Presentation only |
| `colorId` | nullable integer | Stable nested option identity |
| `localizedColorLabel` | localized text | Text label; UI swatch needs authoritative color value or mapping |
| `retailPrice` | nullable money | Backend authoritative |
| `wholesalePrice` | nullable money | Backend authoritative |
| `discount` | nullable number | Backend authoritative |
| `stock` | nullable non-negative integer | Selected-option authority |

### MediaAsset

| Field | Type | Rules |
|-------|------|-------|
| `id` | stable local/remote identity | Must be unique within product media presentation |
| `type` | enum | `image`, `video`, `model3d`, `spin360`; never inferred solely from button label |
| `sourceUrl` | URL | Required for usable medium |
| `thumbnailUrl` | nullable URL | Falls back only to an appropriate placeholder/poster |
| `posterUrl` | nullable URL | Recommended for video |
| `sortOrder` | integer | Stable gallery ordering |
| `capabilities` | set | Examples: zoom, fullscreen, playback, rotation; only real capabilities |
| `loadState` | enum | `idle`, `loading`, `ready`, `failed`, `unsupported` |

## Shopping

### FavoriteEntry

| Field | Type | Rules |
|-------|------|-------|
| `ownerId` | authenticated user or explicit guest scope | Persistence policy requires backend decision |
| `listingId` | integer | Preferred commerce identity |
| `productId` | integer | Product navigation identity |
| `createdAt` | timestamp | Authority depends on persistence contract |

No production persistence is authorized until the favorite contract is confirmed.

### CartLine

| Field | Type | Rules |
|-------|------|-------|
| `listingId` | integer | Mandatory for checkout; missing identity blocks submission |
| `productId` | integer | Required for product refresh |
| `sizeId` | nullable integer | Part of line uniqueness |
| `sizeColorId` | nullable integer | Part of line uniqueness |
| `quantity` | positive integer | UI intent; cannot exceed revalidated stock |
| `presentationSnapshot` | product/option labels and image | May be cached for continuity |
| `priceSnapshot` | nullable money | Display aid only; not checkout authority |

**Uniqueness**: `listingId + sizeId + sizeColorId`. Product ID alone is insufficient.

### CheckoutAttempt

| Field | Type | Rules |
|-------|------|-------|
| `clientRequestId` | UUID v4 | Created before submission; reused after transport uncertainty; replaced after confirmed success |
| `accountRole` | enum | Explicit `customer` or `seller` resolved from active authoritative roles |
| `items` | non-empty list | Listing/option identities and positive quantities only |
| `customerAddress` | non-empty string | Current contract field; address ID may replace/augment only with contract support |
| `shiplyCityId` | integer | Required for current delivery contract |
| `shiplyVillageId` | integer | Required for current delivery contract |
| `couponCode` | nullable trimmed string | Backend validates eligibility and value |
| `paymentType` | enum | Current verified value `cash`; other values require backend support |
| `paidAmount` | money | Current verified cash checkout uses zero |
| `state` | enum | `draft`, `validating`, `submitting`, `uncertain`, `confirmed`, `rejected` |

**State transitions**: draft -> validating -> submitting -> confirmed; submission transport failure
-> uncertain -> submitting with same ID; validation/business failure -> rejected/draft with cart kept.

### Address and DeliveryQuote

`Address` includes stable ID only when an address-book contract exists, label, recipient, phone,
city ID, village ID, street/detail, default flag, and validation state. `DeliveryQuote` includes
destination IDs, method, optional time window, authoritative fee, currency, expiry, and availability.
The current client proves city/village selection and fee calculation, not full address-book CRUD.

## Orders and Communication

### Order

Required presentation fields are authoritative order ID/number, creation time, status, line
snapshots, subtotal, discount, coupon, delivery, total, payment summary, address/contact snapshot,
notes, status logs, optional Shiply handover/tracking, and eligible actions.

**State rule**: unknown status strings remain visible and use a neutral chip; they are not discarded.
Cancellation availability is supplied/confirmed by backend, not inferred only from display status.

### TrackingTimeline

Contains tracking/parcel code, current status ID, ordered status sequence, and timestamped events.
Map location is optional and may appear only when coordinates or an approved tracking URL exist.

### Notification

Contains stable ID, localized title/body, created time, read state, optional category, optional deep
link target and target ID. Read state changes only after accepted mutation; unknown targets open no
unsafe route.

### Review

Contains stable ID, product ID, user display identity, rating, comment, visibility, created/updated
time, and optional edit eligibility. Backend remains authoritative for eligibility and moderation.

## Presentation State

### AsyncViewState<T>

`initial`, `loading`, `refreshing(previousData?)`, `data(T)`, `empty(reason)`, `offline(previousData?)`,
`error(message, retryContext, previousData?)`, and `success(result)` are distinct. A parsing or
transport failure cannot become `empty` or `success`.

### DesignTokens

The initial explicit palette is navy `#0F0F31`, purple `#6B65BD`, light purple `#E9E8F7`, app
background `#F8F9FB`, card `#FFFFFF`, success `#22A06B`, warning `#F5A623`, error `#EB4D4F`, info
`#3B82F6`, primary text `#17172B`, secondary text `#73737D`, disabled text `#A0A3B1`, and border
`#E5E6EA`. Cairo weights 300/400/500/600/700 are required. Spacing 4/8/12/16/24/32/40/48 and
radii 8/12/16/24 are reference-derived starting scales; exact use is calibrated per component.
