# Phase 02 Shared Foundation Visual Review

- **Reviewed**: 2026-10-05
- **Reference**: `docs/design-reference/08-design-system.png`
- **Direction/theme**: Arabic RTL / light
- **Logical viewport**: 390 x 844
- **Raster output**: 1170 x 2532 (DPR 3.0)

## Rendered Evidence

| Capture | Scope | Result |
|---------|-------|--------|
| `test/widgets/goldens/p02-shared-components-ar-390x844.png` | Customer top bar, field, chips, status, media fallback, button hierarchy, and five-destination navigation | REGRESSION BASELINE |
| `test/widgets/goldens/p02-shared-cards-ar-390x844.png` | Product cards, category cards, prices, discount/rating/availability, typed media badge, and navigation | REGRESSION BASELINE |

Both captures are rendered by `test/widgets/store_foundation_test.dart` with the bundled Cairo font
and Material icon font loaded explicitly. They detect changes relative to the committed render only;
they do not independently prove fidelity to board 08 and are not visual acceptance evidence by
themselves.

## Board 08 Comparison

| Reference annotation | Expected | Observed | Result | Follow-up |
|----------------------|----------|----------|--------|-----------|
| Explicit palette | All 13 board values are exact, including navy, light purple, disabled text, and border | Source and tests assert every value from `design-reference-mapping.md`; no similar substitute remains | TOKEN AUDIT PASS | Reviewer should confirm use in later real screens |
| Arabic typography | Cairo hierarchy and stable RTL shaping | Cairo variable font renders display, title, body, label, and caption roles in RTL | RENDER CHECK PASS | Device rasterization can vary by platform |
| Controls | Primary filled, secondary outlined, destructive and text variants; minimum 48 logical-pixel height | Primary/secondary renders preserve hierarchy; all four variants share the 48-pixel token and semantic state | RENDER CHECK PASS | Destructive/text variants are code and widget-test covered, not shown in the compact capture |
| Fields and validation | Rounded neutral field, clear focus/validation states, password reveal | Rounded field and search treatment render without overflow; error/success colors use approved tokens and accessibility copy is localized | RENDER CHECK PASS | Focus-ring thickness remains a calibration value |
| Chips and badges | Compact status, discount, rating, availability, and media labels | Types retain distinct color/meaning; video is explicitly labeled and is not presented as an image | RENDER CHECK PASS | Exact reference spacing remains reviewer comparison work |
| Product/category cards | Compact rounded cards with media hierarchy, price, discount, availability, and rating | Two product states and two category cards render without overflow at the reference viewport | RENDER CHECK PASS | Real catalog images will be reviewed in Phase 6/7 |
| Async states | Loading, empty, offline, error, and success remain visually and semantically distinct | Typed wrappers exist; Arabic state titles and retry copy are resolved through the existing GetX locale in RTL tests | FUNCTIONAL CHECK PASS | Screen-specific copy remains owned by later phases |
| Customer top bar | Avatar/name, search, notifications, and cart badges remain compact in RTL | Long names ellipsize; absent counts are safe; search and accessibility labels are localized | FUNCTIONAL CHECK PASS | Expanded-search reference comparison is deferred to the Home/Search phase |
| Bottom navigation | Exactly five RTL destinations with clear selected state | Five localized destinations render in the approved RTL order with selected state and safe badges | FUNCTIONAL CHECK PASS | Final shell wiring belongs to T042-T043 and was not started |
| Text scaling | No semantic loss or overflow at 1.30 text scale | Button and password-field semantics/layout pass the 1.30 widget test | FUNCTIONAL CHECK PASS | Full-screen large-text captures remain screen-phase evidence |
| Direct visual fidelity to board 08 | Independent rendered-reference comparison, not self-comparison | Golden self-comparison exists, but no independent overlay/diff or reviewer approval is recorded | PENDING | Reviewer/device comparison required before Phase 2 visual acceptance |
| Shadows and exact board spacing | Hierarchy should match while minor values stay within the documented calibration tolerance | Elevation, card media ratio, and spacing values are centralized under named calibration tokens | CALIBRATION | Confirm on Android/iOS device screenshots before pixel-level acceptance |

## Automated Evidence

Command:

```text
flutter test test/widgets/store_foundation_test.dart
```

Covered assertions:

- all 13 exact approved palette values plus spacing/radius/control-height constants;
- Cairo family and weights 300, 400, 500, 600, and 700;
- distinct empty/offline/error/success presentation types;
- five localized semantic RTL destinations and selection behavior;
- localized Arabic error/retry state behavior in RTL;
- 1.30 text scaling for shared controls;
- inline expandable search with missing badge data;
- deterministic golden comparison for both rendered captures.

## Acceptance Boundary

The deterministic Flutter renders and functional checks pass as regression evidence, but Phase 02
visual acceptance remains pending independent comparison and reviewer approval. Exact platform font
rasterization, shadows, and device-safe-area calibration also remain pending real Android and iOS
screenshots. No Phase 3 screen or app-shell wiring is included in this evidence.
