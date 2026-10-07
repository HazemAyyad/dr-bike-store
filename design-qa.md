# Design QA — Store onboarding and authentication

## Comparison target

- Source visual truth:
  - `C:/Users/hp/Downloads/Electric Ride Onboarding Screen-1.png` (841 × 1870)
  - `C:/Users/hp/Downloads/Original Scooter Parts Onboarding UI-2.png` (853 × 1844)
  - `C:/Users/hp/Downloads/Professional Scooter Maintenance Onboarding-3.png` (841 × 1870)
  - `C:/Users/hp/Downloads/Doctor Bike Arabic Login Screen-5.png` (853 × 1844)
  - `C:/Users/hp/Downloads/Doctor Bike Arabic Registration Screen-6.png` (941 × 1672)
  - `C:/Users/hp/Downloads/Doctor Bike Password Reset Screen-7.png` (841 × 1870)
- Implementation screenshots:
  - `test/widgets/goldens/p03-onboarding-ar-390x844.png`
  - `test/widgets/goldens/p03-onboarding-2-ar-390x844.png`
  - `test/widgets/goldens/p03-onboarding-3-ar-390x844.png`
  - `test/widgets/goldens/p04-login-ar-390x844.png`
  - `test/widgets/goldens/p04-register-ar-390x844.png`
  - `test/widgets/goldens/p04-forgot-password-ar-390x844.png`
  - `test/widgets/goldens/p04-otp-ar-390x844.png`
  - `test/widgets/goldens/p04-new-password-ar-390x844.png`
- Viewport: 390 × 844 logical pixels, device scale factor 1 in Flutter widget tests.
- Density normalization: each source was aspect-fitted into a 390 × 844 panel; implementation captures are native 390 × 844 pixels.
- State: Arabic, RTL, light theme, empty form state. OTP uses a masked example destination.

## Full-view comparison evidence

Side-by-side source/implementation boards were inspected at:

- `build/visual_qa/onboarding-1.png`
- `build/visual_qa/onboarding-2.png`
- `build/visual_qa/onboarding-3.png`
- `build/visual_qa/login.png`
- `build/visual_qa/register.png`
- `build/visual_qa/forgot-password.png`

Focused crops were not needed because typography, controls, icons, borders, imagery, and copy remained legible in the normalized full-view boards.

## Findings

- No actionable P0, P1, or P2 mismatches remain.
- Fonts and typography: Cairo preserves the bold Arabic heading hierarchy and lighter supporting copy. Wrapping remains stable at 390 × 844 and at the tested 320 × 568 viewport with 1.2× text scaling.
- Spacing and layout rhythm: the three onboarding pages retain the large visual region, centered copy, page indicator, and split previous/next CTA composition. Auth screens preserve the reference's logo, heading, rounded fields, compact auxiliary actions, and full-width CTA.
- Colors and tokens: navy text, neutral white/light-gray surfaces, restrained borders, and the purple CTA treatment match the reference direction. Error/success colors remain authoritative app tokens.
- Image quality and asset fidelity: the old cartoon onboarding art was replaced by dedicated high-resolution realistic scooter, parts, and maintenance assets. Password recovery uses a dedicated 3D envelope/lock asset matching the supplied art direction.
- Copy and content: Arabic reference copy is retained where it maps to supported behavior. Login intentionally omits Google/Apple. Registration intentionally omits full name, terms acceptance, and a decorative country selector because the current backend contract does not support those inputs. These are product-contract deviations, not unfinished controls.
- OTP and New Password have no separate supplied source boards. They use the same logo, type, fields, radii, spacing, and CTA system as Login/Forgot Password and were visually captured for regression coverage.

## Comparison history

1. First pass found blank deferred onboarding assets in page-transition golden captures, a reversed RTL back chevron, missing first-page callouts, and an incorrectly placed first-page brand lockup.
2. Assets were explicitly preloaded for deterministic capture, the chevron direction and brand alignment were corrected, the callouts were restored, and the onboarding image proportions were recalibrated.
3. Post-fix screenshots were recaptured at 390 × 844 and compared side by side. No actionable P0/P1/P2 issue remained.

## Interaction and responsive evidence

- Tested onboarding next navigation through all three pages.
- Tested direct auth screen rendering, registration field contract, remember/forgot affordances, OTP resend state, proof-bound reset behavior, and no fake success paths.
- Tested onboarding/auth at 320 × 568 with 1.2× text scaling without layout exceptions.
- `flutter analyze`: no issues.
- Auth/onboarding/startup suites: 37 tests passed.

## Follow-up polish

- P3: exact scooter model, workshop crop, and source-image lighting differ slightly because the supplied boards were references rather than reusable isolated production assets.
- P3: device status bars and home indicators from the mockups are intentionally runtime-owned and are not recreated as app content.

final result: passed
