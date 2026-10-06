# API-to-UI Contract

## Result Envelope

Every repository operation exposed to a controller/presenter MUST resolve into one of:

- `success(data, metadata?)`: body parsed into the expected typed value.
- `empty(reason)`: a successful read whose typed collection is genuinely empty.
- `offline(previousData?)`: no usable connection/timeout before a read result.
- `unauthenticated` or `forbidden`: identity or role boundary rejected.
- `upgradeRequired(message, minimumBuild?)`: explicit policy response.
- `validationFailure(fieldErrors, message)`: accepted request with business/input rejection.
- `conflict(message, refreshRequired)`: stock/price/order state changed.
- `uncertain(attemptIdentity)`: mutation transport failed after possible submission.
- `failure(message, retryable, diagnosticsCode?)`: transport, content type, parsing, or server error.

HTTP status alone MUST NOT create `success`. `success` requires the expected typed data, including
order identity for checkout.

## Identity Rules

- Product read/navigation uses `productId`.
- Store cart and checkout use `listingId`; product ID is not a fallback.
- Size and color IDs are nullable only for products without those option levels.
- User-facing labels, email, names, and translated text are never used as stable IDs.
- Account role is resolved only from active `accountRoles`: `customer`, `seller`, both (prompt), or
  neither (fail closed).

## Read Contract

Reads expose stable `loading -> data|empty|offline|failure` transitions. Refresh preserves previous
data only when it is visibly marked refreshing/stale. A section-level failure does not force
unrelated successful Home sections to disappear.

## Mutation Contract

Mutations expose `idle -> submitting -> confirmed|rejected|uncertain`. Controls coalesce repeat taps
while submitting. Rejected mutations retain safe input and current authoritative state. UI updates
such as notification read, favorite, review publication, cancellation, and account deletion become
confirmed only after server acceptance.

## Checkout Contract

- A draft validates authentication, roles, listing IDs, option identities, positive quantities,
  destination, coupon, and supported payment before submission.
- `client_request_id` is generated before the first submission.
- In-flight repeats are ignored/coalesced.
- A transport-uncertain retry reuses the same ID.
- 201 create and 200 replay are accepted only with `data.id`.
- Confirmed success clears the attempt and cart; malformed success, rejection, or uncertainty keeps
  the cart and current attempt as required for safe retry.

## Capability Gates

The UI consumes explicit capabilities for favorite persistence, address book, payment methods,
filters, media types, order actions, notification targets/preferences, and review eligibility.
Absent capability means omit or disable with truthful explanation; it never means local success.
