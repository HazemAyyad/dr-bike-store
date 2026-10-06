# Phase 09 — US7 structural visual review

Scope: SCR-25 through SCR-29. References: boards 03, 06, and shared board 08 foundations.

This is a source-level structural comparison only. No device capture or pixel-diff is claimed.

- Address: compact profile fallback form for name, phones, and submitted customer address; no invented address book.
- Shipping loading: explicit village and quote progress; city and village data remain endpoint-backed.
- Shipping quote: current quote is labeled provisional because checkout revalidates delivery.
- Payment: only cash/COD is shown. Card, credit, mixed, wallet, and bank options are absent.
- Dual role: customer/seller choice appears only when both authoritative roles exist.
- Review: cart identities/quantities, address, destination, quote, role, and COD are visible with an authority disclaimer.
- Submitting: submit button locks and shows progress through the typed submitting state.
- Validation: recoverable inline state categorizes item, coupon, location, role, and payment failures.
- Uncertain: timeout/network ambiguity retains the attempt identity and offers retry without clearing cart.
- Success: authoritative order ID is required, auto-redirect is removed, and explicit Orders/Home actions remain.

Shared Store palette, typography, spacing, radii, buttons, media/state components, Arabic RTL hierarchy, and compact progress treatment align structurally with boards 03/06/08. Final device calibration remains deferred.
