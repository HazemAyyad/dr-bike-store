# Phase 03 / US1 Startup Visual Review

- **Reviewed**: 2026-10-05
- **Primary references**: `docs/design-reference/01-splash-onboarding-login.png`, `docs/design-reference/02-auth-profile-settings-states.png`
- **Supporting reference**: `docs/design-reference/07-home-search-loading.png` (loading-state boundary only)
- **Direction/theme**: Arabic RTL; dark splash and light onboarding/state surfaces
- **Logical viewport**: 390 x 844

## Rendered Evidence

| Artifact | Scope | Result |
|----------|-------|--------|
| `test/widgets/goldens/p03-onboarding-ar-390x844.png` | First onboarding page, navigation controls, pager, Cairo typography, and RTL composition | REGRESSION BASELINE |
| `test/widgets/startup_auth_screens_test.dart` | Reduced-motion splash final state, large-text onboarding, and distinct offline/maintenance presentations | FUNCTIONAL RENDER CHECK |
| `test/controllers/startup_controller_test.dart` | First run, guest, retained session, invalid session, offline, maintenance, update, and initialization-error decisions | DETERMINISTIC STATE CHECK |

The golden is a self-comparison baseline. It does not independently prove fidelity to the reference
boards and is not reviewer approval.

## Screen Comparison

| Screen | Reference | Expected hierarchy | Observed hierarchy | Known difference / calibration | Status |
|--------|-----------|--------------------|--------------------|--------------------------------|--------|
| SCR-01 Animated splash | Boards 01, 02 | Navy cinematic field, progressive original mark reveal, staged wordmark/tagline, subtle progress | Approved navy background, original light Doctor Bike mark, progressive clip/fade, wordmark/tagline, and restrained linear progress; reduced-motion path shows the final state immediately | The exact photographic/cinematic backdrop shown in the board is not present as a licensed repository asset. The implementation uses a named derived navy glow and restrained purple trail. Exact motion timing remains centralized calibration, not reference-proven timing | PENDING-REVIEW |
| SCR-02 Onboarding | Boards 01, 02 | Three image-led pages in approved order, title/body, dots, skip, previous/next/start | Three retained pages with RTL controls, Cairo type, safe areas, scrolling for small/large text, and persisted completion | Repository assets `splash2.png`, `splash3.png`, and `splash4.png` are legacy vector illustrations and do not match the board's product-photo treatment exactly. No replacement art was invented. First-page golden is a regression baseline; pages two and three are functionally exercised but not independent reference captures | PENDING-REVIEW |
| SCR-03 Initialization/routing | Boards 01, 07 | Loading remains subordinate to bootstrap and never exposes catalog success before authority resolves | Splash resolves a typed startup decision after the bounded reveal; timeout/failure remains on an explicit retry state | Board 07's catalog skeleton is intentionally not implemented because Home starts at T041+. This phase only uses its principle that loading is truthful and non-successful | PENDING-REVIEW |
| SCR-04 Maintenance/store closed | Board 02 | Blocking state, authoritative message, valid retry/support action, distinct from offline | Shared Store state presentation distinguishes offline and maintenance; catalog is never shown behind the block; support is shown only for a valid authoritative contact | Board illustration is not available as a matching repository asset, so the shared semantic state treatment is used | PENDING-REVIEW |
| SCR-05 Upgrade/version | Board 02 | Required update blocks continuation; recommended update permits continuation only when supported | Required and recommended variants are distinct. Update action requires a valid authoritative URI; otherwise retry is shown. Required has no continue action | The current startup contract proves required update/426 only. Recommended update remains capability-gated and is not fabricated by the live resolver | PENDING-REVIEW |

## Automated Checks

- Arabic direction is RTL and all visible copy resolves through the existing GetX locale.
- Onboarding renders without overflow at 390 x 844 with text scale 1.30.
- Reduced-motion splash bypasses staged movement and exposes the complete final brand state.
- Offline and maintenance titles/messages remain visibly distinct.
- Startup policy tests assert that initialization error, offline, maintenance, and required update do not fall through to catalog success.

## Acceptance Boundary

Functional and regression evidence is complete for T024-T031. Direct device screenshots, independent
overlay/diff comparison, final motion calibration, and reviewer approval are not recorded; therefore no
screen is marked visually accepted or pixel-perfect.
