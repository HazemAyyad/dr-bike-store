# Visual Fidelity Contract

## Source Hierarchy

1. The exact mapped area in `docs/design-reference/01..08`.
2. Explicit product decisions in [spec.md](../spec.md).
3. Board-08 design tokens and reusable component rules.
4. Existing Doctor Bike assets and behavior when references are silent.

An existing screen never overrides an approved reference. A technical limitation may justify a
documented deviation but not an unapproved redesign.

## Required Comparison Set

For each implemented screen/state, record:

- screen ID and board/region;
- device, viewport, pixel ratio, OS, locale, text scale, and theme;
- expected and actual capture;
- hierarchy/direction, spacing, typography, colors, borders/radii/shadows, images/media, icon
  placement, top/bottom navigation, and state differences;
- severity: blocking, high, medium, calibration, or accepted deviation;
- resolution or approval reference.

## Blocking Differences

- Wrong RTL/LTR layout or mirrored control meaning.
- Different primary navigation or component hierarchy.
- Missing primary content/action/state shown in the reference.
- Unapproved palette/logo/type family.
- Product/media scale that materially changes hierarchy.
- Error/offline/empty/success shown as a different state.

## Calibration Differences

Small spacing, font-size, line-height, corner, border, or shadow adjustments may be tuned through
named tokens. A calibration value becomes stable only after representative screens pass; do not
introduce screen-local exceptions without a documented constraint.

## Phase Acceptance

- Every screen in the phase has at least one Arabic RTL capture.
- Every applicable state in the phase has a capture or deterministic component story/test.
- No blocking or unapproved high-severity difference remains.
- Shared-token changes are rechecked against all previously accepted representative components.
- Functional success and visual acceptance are reported separately.
