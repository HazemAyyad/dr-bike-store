# Reproducible Visual Comparison Baseline

**Defined**: 2026-10-05
**Primary reference**: `docs/design-reference/08-design-system.png` (1536 x 1404 composite)
**Baseline direction**: Arabic RTL
**Baseline theme**: Light

## Reference Files

| Board | Raster size |
|-------|-------------|
| `01-splash-onboarding-login.png` | 1536 x 1024 |
| `02-auth-profile-settings-states.png` | 1536 x 1024 |
| `03-cart-checkout-orders.png` | 1536 x 1024 |
| `04-product-media-gallery.png` | 1536 x 1024 |
| `05-product-details-media-states.png` | 1434 x 1536 |
| `06-main-store-flows.png` | 1536 x 1024 |
| `07-home-search-loading.png` | 877 x 1536 |
| `08-design-system.png` | 1536 x 1404 |

Composite pixel sizes describe the supplied boards, not Flutter logical dimensions.

## Comparison Viewports

| Matrix ID | Logical viewport | Pixel ratio | Use |
|-----------|------------------|-------------|-----|
| `android-compact-rtl` | 360 x 800 | 3.0 | Primary Android compact review |
| `ios-reference-rtl` | 390 x 844 | 3.0 | Primary board-proportion review |
| `android-small-rtl` | 320 x 568 | 2.0 | Overflow and compactness stress |
| `ios-large-text-rtl` | 390 x 844 | 3.0 | Text scale 1.30 accessibility stress |

The primary Phase 2 component comparison uses `ios-reference-rtl`, Arabic, text scale 1.0, and
light theme. LTR compatibility uses the same viewport after RTL acceptance.

## Capture and Naming Contract

Use `phase-screen-component_state-locale-viewport.png`, for example:
`p02-shared-top_bar_expanded-ar-390x844.png`.

Each evidence row records reference region, actual capture or deterministic widget test, direction,
text scale, expected hierarchy, observed difference, severity, and reviewer result. Never label a
code-level mapping as pixel-perfect visual proof.

## Tolerance and Severity

- **Blocking**: wrong direction, hierarchy, navigation count/order, brand color/type family, state,
  or missing primary action.
- **High**: component proportions or media scale materially change the reference hierarchy.
- **Calibration**: spacing up to 4 logical pixels, typography up to 1 logical pixel, radius up to
  2 logical pixels, or shadow tuning when hierarchy remains intact.
- **Accepted deviation**: only with written technical reason and reviewer approval.

Automated color/token/widget checks have zero tolerance for explicit board-08 values. Raster visual
acceptance requires a real rendered capture and remains pending when no emulator/device capture is
available.
