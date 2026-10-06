# Phase 08 — US6 structural visual review

Scope: SCR-23 Favorites and SCR-24 Cart. References: boards 02, 03, 06, and 08.

This is a source-level structural sanity review. No device screenshots or pixel-diff claims are made; final device calibration remains deferred.

## SCR-23 Favorites

- The approved five-tab shell and Favorites destination are retained.
- Guest selection continues through the accepted shell login gate.
- Authenticated users see a deliberate capability-unavailable state using shared Store state components, Arabic RTL-compatible copy, Store tokens, and Cairo typography.
- No saved-product content, optimistic heart state, refresh gesture, local synced state, or remote-success claim is rendered.

## SCR-24 Cart

- Populated: Store surface cards, authoritative storefront media snapshot, localized name, retail price, option labels, and quantity controls.
- Empty: shared Store empty-state presentation with cart icon and continuation guidance.
- Variant item: size and color labels are retained and the line identity remains distinct.
- Revalidation/unavailable: an explicit pre-checkout validation message is shown without claiming live availability.
- Coupon: entry and retained-intent status are visible; verification remains tied to the existing backend endpoint.
- Remove confirmation: deletes only the exact listing/option identity.
- Clear confirmation: clears all retained cart lines only after explicit confirmation.
- Summary: derives subtotal/discounted product total from current lines and states that delivery is not yet included.
- Checkout CTA: enabled only for structurally valid lines and continues to the existing checkout boundary.

## Reference comparison notes

- Board 02/06: shell destination remains stable; unsupported Favorites appears intentional rather than broken.
- Board 03/06: cart hierarchy is top bar, line list, coupon, summary, and checkout action with explicit destructive confirmations.
- Board 08: StorePalette, StoreSpacing, StoreRadii, StoreTypography, StoreButton, StoreMessageState, and StoreNetworkMedia are reused.
- `bill_details.dart` remains checkout-owned and was intentionally not redesigned in Phase 8; the cart-only summary is isolated in `cart_summary.dart` to preserve T079+ scope.
