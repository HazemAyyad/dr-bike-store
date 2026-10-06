# Phase 04 / US2 Authentication Visual Review

- **Reviewed**: 2026-10-05
- **Primary references**: `docs/design-reference/01-splash-onboarding-login.png`, `docs/design-reference/02-auth-profile-settings-states.png`
- **Direction/theme**: Arabic RTL / light
- **Logical viewport**: 390 x 844

## Rendered Evidence

| Artifact | Scope | Result |
|----------|-------|--------|
| `test/widgets/goldens/p04-login-ar-390x844.png` | Login brand, compact form, password reveal affordance, remember/forgot row, CTA, and registration route | REGRESSION BASELINE |
| `test/widgets/startup_auth_screens_test.dart` | Arabic RTL, 1.30 text scale, localized labels, no overflow, and unsupported-provider omission | FUNCTIONAL RENDER CHECK |
| `test/controllers/auth_flow_test.dart` | Validation, blocked login, session authority, registration validation, resend timing, OTP failures, and proof-bound reset | AUTHORITY/STATE CHECK |
| `test/t140_secure_store_client_test.dart` | Redacted auth requests and upgrade-required recovery behavior | SECURITY REGRESSION CHECK |

The committed login golden detects changes against this implementation. It is not an independent
comparison to boards 01/02 and does not establish visual acceptance by itself.

## Screen Comparison

| Screen | Reference | Expected hierarchy | Observed hierarchy | Known difference / calibration | Status |
|--------|-----------|--------------------|--------------------|--------------------------------|--------|
| SCR-06 Login | Boards 01, 02 | Original mark, compact centered fields, password reveal, remember/forgot, primary CTA, registration and only supported providers | Original mark and compact max-width composition render in Cairo; fields use shared components; reveal semantics are localized; remember and forgot actions are wired; Google/Apple actions are absent | Exact reference spacing/shadow comparison is pending. No social provider is rendered because the current contract proves none | PENDING-REVIEW |
| SCR-07 Registration | Board 02 | Supported identity fields, validation, loading/error/success, keyboard-safe layout | Email, phone, password, and confirmation only; shared status treatment and scroll/inset-safe scaffold | Full name and terms consent are absent because neither is supported by the current registration contract. This is intentional capability fidelity, not a visual omission to fake locally | PENDING-REVIEW |
| SCR-08 Forgot-password request | Board 02 | Identifier input, clear recovery intent, authoritative advance only after accepted request | Localized compact request screen advances only on normalized backend success and reports offline/server/upgrade states distinctly | Exact board illustration is not available as a matching repository asset; shared brand scaffold is used | PENDING-REVIEW |
| SCR-09 OTP verification | Board 02 | Numeric code, masked destination, resend countdown, invalid/expired/offline/server states | Four-digit numeric entry, localized masked destination, real deadline-based countdown, gated resend, and distinct normalized failures | Countdown duration is a centralized controller input because exact reference timing is not specified | PENDING-REVIEW |
| SCR-10 Set new password / completion | Board 02 | New/confirm fields, reveal controls, requirement cue, proof-bound submit, completion only on authority | Shared secure fields provide reveal controls; requirement copy is localized; opaque proof stays in memory and is never displayed; completion appears only after backend success | Recovery-complete is the terminal state within the same protected flow rather than an independently routable screen, preserving proof semantics | PENDING-REVIEW |

## Contract and Capability Notes

- No Google or Apple provider capability is exposed by the existing Store contract, so no inert provider UI is shown.
- Registration exposes no invented full-name or consent payload.
- OTP values are not read from responses; verification is server-side and returns only an opaque reset proof.
- The reset proof is held in controller memory, submitted with the new password, retained after a failed reset for retry, cleared after authoritative success, and never rendered or logged.
- Upgrade-required recovery responses route to the truthful update-required presentation.

## Acceptance Boundary

Functional, security, localization, RTL, large-text, and regression evidence is complete for T032-T040.
Independent board overlay/diff comparison, real-device keyboard/safe-area captures, and reviewer approval
remain pending. No screen is reported as pixel-perfect or visually accepted.
