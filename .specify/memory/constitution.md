# Doctor Bike Store Mobile Constitution

## Core Principles

### I. Approved References Are the Visual Source of Truth

Every Store mobile screen MUST implement the approved images in
`docs/design-reference/` as closely as reasonably possible. Layout, hierarchy, direction,
spacing, typography, color, radius, borders, shadows, icon placement, media sizing,
navigation, and state presentation are acceptance criteria, not optional polish. A design
departure MUST be documented with the technical constraint that requires it and receive
explicit approval. Personal preference MUST NOT create a new ecommerce design.

### II. Arabic RTL Is First-Class

Arabic and right-to-left direction MUST be the baseline composition for every screen,
component, gesture, navigation control, number/text mixture, and state. Cairo is the
approved type family for the new experience. Supported non-Arabic locales MUST remain
functional, but they MUST NOT determine the primary visual hierarchy. User-facing text
MUST be localized rather than embedded in widgets, except diagnostic or contract values.

### III. Reuse Sound Architecture

The existing Flutter application, GetX controllers, repositories, API client, typed models,
routes, persistence, and native checkout work MUST be reused where their behavior and
boundaries are sound. Existing code MUST be classified before replacement as reusable,
visually refactorable, functionally refactorable, obsolete, or missing. A rewrite requires
an objective architectural reason recorded in the plan; visual mismatch alone is not such
a reason.

### IV. The Backend Owns Business State

The application MUST treat backend responses as authoritative for product identity,
published listings, inventory, customer and seller roles, retail and wholesale pricing,
promotions, coupons, credit, debt, orders, reviews, notifications, and store operating
state. Flutter MUST NOT create persisted local substitutes for missing authoritative data
or independently decide eligibility. Missing capabilities MUST be recorded as backend
dependencies and fail closed where security, money, stock, or order integrity is involved.

### V. Contracts Are Typed and Explicit

Remote payloads, UI view data, persisted cart data, and navigation arguments MUST have
typed contracts with explicit nullability, identifiers, units, and state values. Product IDs
MUST NOT be substituted for listing IDs, and display labels MUST NOT be used as stable
identifiers. Contract changes MUST preserve compatibility deliberately or include a
migration and targeted contract tests.

### VI. Shared Foundations Before Screen Duplication

Colors, Cairo weights, spacing, radii, shadows, buttons, fields, chips, cards, navigation,
media placeholders, skeletons, and state components MUST be defined through reusable
foundations before repeated screen implementation. Exact values that cannot be safely
read from references MUST be named visual-calibration tokens and tuned against the
approved images during implementation; invented one-off values are prohibited.

### VII. Every Async Surface Has Complete States

Each asynchronous screen or component MUST define loading, empty, error, and success
behavior, plus offline and retry behavior where network access is required. Loading MUST
use the approved skeleton or progress treatment and MUST NOT expose stale content as a
fresh success. Pull-to-refresh MUST be available where specified. Image and media failures
MUST have a stable placeholder and recovery behavior.

### VIII. Session, Cart, and User Continuity Are Protected

Existing authentication sessions, selected locale, user data, role resolution, and persisted
cart behavior MUST NOT be broken casually. Changes to persistence keys, serialization,
startup routing, logout, account deletion, or cart identity require migration analysis and
tests for retained and guest states. Destructive account and order actions require explicit
confirmation and authoritative server acknowledgment.

### IX. Security-Sensitive Contracts Fail Closed

Authentication, password reset proofs, account roles, checkout idempotency, payment
selection, cancellation eligibility, and upgrade requirements MUST retain their existing
security boundaries. Secrets, OTP values, proofs, credentials, and bearer tokens MUST NOT
be logged. Duplicate submission controls MUST preserve the same request identity across
uncertain retries and clear it only after authoritative success.

### X. Failures Stay Failures

Transport, parsing, authorization, validation, stock, pricing, coupon, checkout, and order
failures MUST NOT be silently converted into successful UI. Error states MUST retain enough
typed context for a truthful user message and a safe retry. A success screen MUST require
an authoritative success payload with the expected identity, not merely an HTTP status.

### XI. Repository Scope Is Strict

This repository may change only the Doctor Bike Store Flutter application and its Spec Kit
or planning documents. Laravel and the Flutter Admin application MUST NOT be modified by
Store implementation work. Backend gaps are documentation outputs unless a separately
authorized task explicitly changes the backend in its own repository.

### XII. Delivery Is Phased and Reviewable

Implementation MUST be divided into small, dependency-ordered phases that can be
reviewed and validated independently. Each phase MUST identify its screens, reused code,
contract dependencies, state coverage, tests, and visual acceptance checks. A single
catch-all redesign task is prohibited.

### XIII. Visual Fidelity Is Verified Screen by Screen

No screen is complete based only on functional behavior. Each implemented screen and
meaningful state MUST be compared with its mapped reference at an agreed device size,
with discrepancies recorded and resolved or explicitly accepted. All eight reference
boards MUST remain mapped to concrete screens, components, tokens, or states.

## Product and Technical Constraints

- The approved identity is the original Doctor Bike logo, primary navy `#0F0F31`, primary
  purple `#6B65BD`, light purple `#E9E8F7`, application background `#F8F9FB`, and white
  card surface, subject only to visual calibration against `08-design-system.png`.
- The main shell MUST expose Home, Categories, My Orders, Favorites, and Profile in the
  approved order and MUST define guest versus authenticated behavior.
- Product media requirements MUST distinguish image, video, and 3D/360 capabilities.
  Unsupported media MUST be omitted or represented honestly, never simulated as working.
- Payment-method UI MUST appear only for methods supported by the active backend contract.
- Tests MUST cover changed parsing, persistence, authentication, checkout, and other
  business-sensitive behavior. Static analysis and tests do not substitute for device,
  integration, or visual proof.
- Accessibility requirements MUST include readable contrast, scalable text within the
  approved compact layout, semantic labels for icon-only actions, and usable touch targets.

## Specification and Delivery Gates

Before implementation begins, the feature package MUST contain a validated specification,
research, existing-code reuse audit, screen inventory, API mapping, design-reference
mapping, implementation plan, dependency-ordered tasks, and requirements-quality
checklist. Open backend gaps MUST name the affected screen and safe fallback without
blocking unrelated work.

Before a phase is accepted, reviewers MUST confirm: mapped visual reference coverage;
Arabic RTL behavior; loading, empty, error, offline, and success states as applicable;
backend authority; typed contract handling; no silent success; focused automated checks;
and screen-level visual comparison. Before commit, staged paths MUST be inspected so only
Store Spec Kit, planning, or authorized implementation files are included.

## Governance

This constitution supersedes conflicting feature plans and task descriptions. Amendments
require an explicit rationale, an updated Sync Impact Report during review, and semantic
versioning: MAJOR for incompatible governance changes, MINOR for new or materially
expanded principles, and PATCH for clarifications. Each specification, plan, task set, and
implementation review MUST include a constitution check. Unjustified violations block
delivery; necessary exceptions MUST state scope, risk, mitigation, and approver. The Sync
Impact Report is review-only and MUST be removed before the constitution is committed.

**Version**: 1.0.0 | **Ratified**: 2026-10-05 | **Last Amended**: 2026-10-05
