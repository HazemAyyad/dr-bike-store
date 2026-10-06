# Phase 07 — US5 Product Detail and Media Evidence

## Scope

- SCR-19: product detail
- SCR-20: fullscreen image gallery
- SCR-21: video player
- SCR-22: capability-gated interactive 360 media
- Reference boards: `04`, `05`, `06`, and `08`
- Baseline: Arabic RTL, light theme, compact phone layout

## Quick visual sanity

The four source boards were inspected at original repository resolution during this phase. The
implementation follows their material hierarchy: top bar, large media hero, ordered thumbnails,
capability-only media controls, name/status/retail price, availability, quantity/options,
description, reviews/similar items, and fixed purchase actions. It uses Cairo, the approved navy,
purple, neutral surfaces, spacing, borders, and radii from the Store foundation.

This is a structural/static comparison, not final Android/iOS pixel-diff proof. No device capture
or live media playback was claimed in this CLI pass. Application-wide device calibration remains
in the later visual-QA phase as requested.

| Screen | Reference | Implemented evidence | Result |
|---|---|---|---|
| SCR-19 | Boards 04, 05, 06, 08 | Compact RTL detail hierarchy, retail price, truthful availability, bounded quantity, backend-only options, reviews/similar sections, fixed add/buy actions | PASS — structural/static |
| SCR-20 | Boards 04, 05 | Fullscreen page gallery, current/total counter, RTL-aware swipe/arrows, zoom/pan, ordered thumbnails, loading/error fallback; arrows omitted for one image | PASS — structural/static |
| SCR-21 | Boards 04, 05 | Video appears only for explicit typed capability; poster/loading, play/pause, seek/progress, mute, fullscreen, 15-second initialization bound, terminal unavailable state | PASS — structural/static |
| SCR-22 | Boards 04, 05 | 360 control/view appears only for explicit `media_type`/`is_360`; a normal image or `image3d` source alone never gains 360 semantics | PASS — capability-gated |

## Required media and availability variants

| Variant | Evidence | Result |
|---|---|---|
| One image | Typed-media test and gallery branch omit thumbnails/arrows | PASS |
| Multiple images | Ordering, main selection, stable thumbnail/hero index, swipe/arrows and fullscreen tests/code paths | PASS |
| Valid video | Explicit `video` / `video/*` parser coverage and player controls | PASS |
| Invalid video | Unsupported-type parser coverage plus bounded terminal player failure | PASS |
| Interactive 360 supported | Explicit metadata parser coverage and gated interactive presentation | PASS |
| 360 unsupported/absent | Static `image3d` regression and unsupported/omitted control behavior | PASS |
| Out of stock | `visible=true`, `purchasable=false` parsing; detail remains visible and both purchase actions disable | PASS |
| Media error/missing media | Broken-image placeholder, unsupported state, malformed metadata and missing-authoritative-media rejection | PASS |

## Contract and deviation notes

- The detail read remains `POST /Items/GetItemById?itemId=<productId>`.
- `productId` is navigation/read identity; `listingId` is required for Add to Cart and Buy Now.
- One typed `storefrontMedia` collection drives hero, thumbnails, fullscreen, video, and 360 state.
- Media order uses `sort_order`; exactly one visible main item is required for eligible detail.
- Wholesale price and local `typeUser` switching are absent from public product presentation.
- Product code, brand, warranty, structured specs, shipping/return claims, and fake review counts are
  omitted because the active Storefront payload does not authoritatively supply them.
- Share is omitted because no stable public product route/deep-link contract is established.
- Similar products use only the existing Online Store category compatibility endpoint when the
  detail payload supplies an authoritative category relation; otherwise the section is honestly
  empty rather than populated randomly.
- Board imagery contains richer specification/policy rows and a 3D tab. They are intentionally
  omitted when unsupported by backend fields; this is a truthful capability constraint, not a new
  visual hierarchy.

## Automated evidence

`test/controllers/product_detail_test.dart` covers 28 focused parsing, state, media, availability,
quantity/options, and listing-identity cases, including every variant above. Final command results
are recorded in the phase handoff report.
