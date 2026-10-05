# Phase 02 Shared Foundation Visual Review

- **Reviewed**: 2026-10-05
- **Reference**: `docs/design-reference/08-design-system.png`
- **Direction/theme**: Arabic RTL / light
- **Logical viewport**: 390 x 844
**Raster output**: 1170 x 2532 (DPR 3.0)

## Rendered Evidence

| Capture | Scope | Result |
|---------|-------|--------|
| `test/widgets/goldens/p02-shared-components-ar-390x844.png` | Customer top bar, field, chips, status, media fallback, button hierarchy, and five-destination navigation | PASS |
| `test/widgets/goldens/p02-shared-cards-ar-390x844.png` | Product cards, category cards, prices, discount/rating/availability, typed media badge, and navigation | PASS |

Both captures are rendered by `test/widgets/store_foundation_test.dart` with the bundled Cairo font
and Material icon font loaded explicitly. They are regression artifacts, not hand-authored mockups.

## Board 08 Comparison

| Reference annotation | Expected | Observed | Result | Follow-up |
|----------------------|----------|----------|--------|-----------|
| Brand and neutral palette | Purple is an accent over neutral light-gray surfaces with dark readable text | `#6B65BD` accent, `#F7F7F9` background, white cards, dark primary text | PASS | None |
| Arabic typography | Cairo hierarchy and stable RTL shaping | Cairo variable font renders display, title, body, label, and caption roles in RTL | PASS | Device rasterization can vary by platform |
| Controls | Primary filled, secondary outlined, destructive and text variants; minimum 48 logical-pixel height | Primary/secondary captures retain hierarchy; all four variants share the 48-pixel token and semantic state | PASS | Destructive/text variants are code and widget-test covered, not shown in the compact capture |
| Fields and validation | Rounded neutral field, clear focus/validation states, password reveal | Rounded field and search treatment match; error/success colors are tokenized and reveal action has an Arabic tooltip | PASS | Focus-ring thickness remains a calibration value |
| Chips and badges | Compact status, discount, rating, availability, and media labels | All types retain distinct color/meaning; video is explicitly labeled and is not presented as an image | PASS | None |
| Product/category cards | Compact rounded cards with media hierarchy, price, discount, availability, and rating | Two product states and two category cards render without overflow at the reference viewport | PASS | Real catalog images will be reviewed in Phase 6/7 |
| Async states | Loading, empty, offline, error, and success remain visually and semantically distinct | Typed models and wrappers exist; success is present in the component capture and other states have separate icons/copy/actions | PASS | Screen-specific copy remains owned by later phases |
| Customer top bar | Avatar/name, search, notifications, and cart badges remain compact in RTL | Long names ellipsize; absent counts are safe; expanded inline search is covered by widget interaction | PASS | Expanded-search raster is deferred to the Home/Search phase |
| Bottom navigation | Exactly five RTL destinations with clear selected state | Five destinations appear in the approved order with purple selected state and safe badges | PASS | Final shell wiring belongs to T042-T043 and was not started |
| Text scaling | No semantic loss or overflow at 1.30 text scale | Button and password-field semantics/layout pass the 1.30 widget test | PASS | Full-screen large-text captures remain screen-phase evidence |
| Shadows and exact board spacing | Hierarchy should match while minor values stay within the documented calibration tolerance | Hierarchy matches; elevation, card media ratio, and several spacing values are centralized under named calibration tokens | CALIBRATION | Confirm on Android/iOS device screenshots before pixel-level acceptance |

## Automated Evidence

Command:

```text
flutter test test/widgets/store_foundation_test.dart
```

Covered assertions:

- exact approved palette/spacing/radius/control-height constants;
- Cairo family and weights 300, 400, 500, 600, and 700;
- distinct empty/offline/error/success presentation types;
- five semantic RTL destinations and selection behavior;
- 1.30 text scaling for shared controls;
- inline expandable search with missing badge data;
- deterministic golden comparison for both rendered captures.

## Acceptance Boundary

The Phase 02 shared-component visual gate passes at the deterministic Flutter-test viewport. Exact
platform font rasterization, shadows, and device-safe-area calibration remain pending real Android
and iOS screenshots. No Phase 3 screen or app-shell wiring is included in this evidence.
