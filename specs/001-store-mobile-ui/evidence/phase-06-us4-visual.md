# Phase 06 — US4 Catalog Visual Evidence

## Scope

- SCR-16: Online Store category hierarchy
- SCR-17: customer-visible listing grid and list
- SCR-18: browse controls and truthful unsupported filter state
- Reference boards: `02`, `06`, and `08`
- Baseline: Arabic RTL, light theme, 390x844 logical viewport

## Implementation comparison

| Screen | Reference | Implemented evidence | Result |
|---|---|---|---|
| SCR-16 | Boards 06 and 08 | Root and child `OnlineStoreCategory` entries, Online Store images, RTL two-column cards, refresh and complete async states | PASS — structural/static |
| SCR-17 | Boards 06 and 08 | Grid/list toggle, resolved main Storefront media, retail display price, availability, rating, discount, and listing-backed cart identity | PASS — structural/static |
| SCR-18 | Boards 02, 06, and 08 | Refresh and view switch remain available; unimplemented server sort/filter control is visibly disabled and no local business eligibility is invented | PASS — truthful capability gate |

## State coverage

- Loading: progress presentation while catalog request is active.
- Content: hierarchy or listing cards using typed Storefront contracts.
- Empty: dedicated no-products state with retry.
- Offline: dedicated offline state with retry and no false empty result.
- Error/malformed: dedicated error state; malformed payloads are rejected.
- Refresh: pull-to-refresh reloads the selected Online Store category without duplicate navigation.

## Contract and visual notes

- Physical `store_section_id` is rejected as a category identity.
- Category counts are omitted because the backend does not provide authoritative counts.
- Media selection uses exactly the resolved `is_main` presentation ordered by `sort_order`.
- Wholesale price is not selected from local user type; cards use the Storefront retail display price.
- Favorites remain omitted/capability-gated.
- Backend pagination and advanced server sort/filter are not currently advertised, so no fake paging/filter behavior is shown.

## Remaining global visual QA

Pixel-diff captures on Android and iOS were not produced in this CLI-only pass. Final device screenshots and calibration remain part of the later global Visual QA phase; no deliberate hierarchy, RTL, palette, or compact-geometry deviation was introduced here.
