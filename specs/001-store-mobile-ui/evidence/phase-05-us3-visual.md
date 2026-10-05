# Phase 05 / US3 Home Shell and Search Visual Review

- **Reviewed**: 2026-10-05
- **Primary references**: `docs/design-reference/06-main-store-flows.png`,
  `docs/design-reference/07-home-search-loading.png`, and
  `docs/design-reference/08-design-system.png`
- **Supporting reference**: `docs/design-reference/02-auth-profile-settings-states.png`
  (no-results/offline/error distinction)
- **Direction/theme**: Arabic RTL / light
- **Logical viewport**: 390 x 844

## Rendered Evidence

| Artifact | Scope | Result |
|----------|-------|--------|
| `test/widgets/goldens/p05-home-loaded-ar-390x844.png` | Identity top bar, repository ad hero, authoritative inventory shortcuts, best sellers, five-destination navigation | REGRESSION BASELINE |
| `test/widgets/goldens/p05-home-skeleton-ar-390x844.png` | Home skeleton hierarchy inside the retained shell | REGRESSION BASELINE |
| `test/widgets/goldens/p05-search-expanded-ar-390x844.png` | Inline expanded search, authoritative category chips, local recent history, clear action, retained bottom navigation | REGRESSION BASELINE |
| `test/widgets/goldens/p05-search-results-ar-390x844.png` | Query, result count, product cards, and disabled capability-gated sort/filter gateways | REGRESSION BASELINE |
| `test/widgets/goldens/p05-search-no-results-ar-390x844.png` | Query-specific zero-result state distinct from transport failure and offline | REGRESSION BASELINE |
| `test/widgets/home_search_test.dart` | Arabic RTL, smaller width, text scale 1.30, tab-state retention, search overlay restoration, loaded/skeleton/result/no-result states | FUNCTIONAL RENDER CHECK |
| `test/controllers/shell_search_test.dart` | Five destinations, guest/auth gates, back behavior, restart restoration, recent-query rules, and distinct empty/offline/failure states | DETERMINISTIC STATE CHECK |

The committed goldens detect regressions against this implementation. They are not independent
board overlays, do not prove pixel parity, and do not constitute reviewer visual acceptance.

## Screen Comparison

| Screen | Reference | Expected hierarchy | Observed hierarchy | Known difference / calibration | Status |
|--------|-----------|--------------------|--------------------|--------------------------------|--------|
| SCR-11 Main shell | Boards 06, 07, 08 | Identity top bar plus exactly Home, Categories, My Orders, Favorites, Profile; selected state, safe areas, back and restoration | Shared Store top/bottom navigation, five approved destinations, selected state, normal route back, search-first back, tab-first back, persisted safe destination, and `IndexedStack` tab retention | My Orders opens the retained authoritative order route after the auth gate. Favorites remains a truthful unavailable destination because no read/write contract exists | PENDING-REVIEW |
| SCR-12 Top bar / expandable search | Boards 06, 07, 08 | Avatar/name, search, notifications, cart, badges only from real state, inline close/cancel | Retained identity, expandable controlled search, localized semantics, unread notification count and local cart count only when present; search overlays rather than destroys tab state | Test avatar uses the approved neutral placeholder because no repository-backed customer image is established | PENDING-REVIEW |
| SCR-13 Compact Home | Boards 06, 07 | Hero, quick categories, best sellers, service, store categories, offers, new arrivals in compact order | Hero uses `/OnlineAds/GetAllAds`; categories use inventory Store sections; best sellers use `/Items/GetAllItemIsMoreSales`; offers and new arrivals are subsets of authoritative discount/new flags | No service feed/settings contract exists, so the service block is omitted. Offers/new arrivals are shown only when authoritative product flags provide content; they are not fabricated campaigns | PENDING-REVIEW |
| SCR-14 Search discovery | Board 07 | Expanded field, category chips, recent searches, clear history | Category chips use authoritative Store sections. Recent queries are trimmed, blank-rejected, case-insensitively deduplicated, newest-first, capped, persisted locally, and explicitly clearable | Recent history is local intent only and stores no user/account data. No unproven suggestion feed is rendered | PENDING-REVIEW |
| SCR-15 Search results / no results | Boards 02, 07 | Loading, results, zero-result, offline and failure remain distinct; refresh and supported sort/filter entries | Typed states remain distinct, results support pull-to-refresh, and no-results includes the submitted query | Expanded server sort/filter metadata is unconfirmed; gateways are visible but disabled with localized capability semantics. T050+ catalog/filter logic is not implemented | PENDING-REVIEW |

## Contract and Capability Notes

- Home, Categories, search discovery, and local cart remain guest-safe.
- My Orders and Favorites apply a login gate without clearing cart, locale, search history, or
  other guest preferences. Profile remains a guest hub with the existing sign-in entry.
- Favorites persistence is not simulated. Authenticated users see an explicit unavailable state
  until the planned backend contract exists.
- Notification and cart badges are omitted at zero/unknown and are never fabricated.
- Hero navigation uses only the repository ad URL. Empty or failed optional promotion content is
  omitted instead of replaced by a local campaign.
- Search response parsing requires a typed `rows` collection. HTTP failure or malformed content is
  not converted to an empty result.
- Query values are URI encoded before the existing Store search request.

## Acceptance Boundary

Functional, localization, RTL, large-text, state, persistence, and golden-regression evidence is
recorded for T041-T049. Independent overlay/diff comparison against boards 02/06/07/08, live API
contract execution, Android/iOS device captures, and reviewer approval remain pending. No screen is
reported as pixel-perfect or visually accepted.
