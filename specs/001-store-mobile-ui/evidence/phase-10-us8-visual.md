# Phase 10 — US8 structural visual review

Scope: SCR-30 through SCR-33. References: boards 02, 03, 06, and shared board 08 foundations.

This is static structural QA only; no device pixel-diff is claimed.

- Current/completed/canceled lists use the accepted `New`, `Done`, and `Canceled` compatibility filters.
- Compact RTL segmented tabs, historical order cards, pull-to-refresh, skeleton, empty, offline, and error presentations use Store foundations.
- Details display payload snapshots for line prices/totals, order subtotal/discount/coupon/delivery totals, address, and optional handover data.
- Shiply events and status logs are chronological; missing tracking has a neutral state and unknown statuses remain visible.
- Cancellation for `New` is a server-validated request with confirmation. Failure keeps the snapshot unchanged; success uses the returned authoritative order.
- Reorder, share, address editing, and note editing are omitted because no accepted capability contract exists.
- `StoreDestination.orders` renders the new order experience inside the approved five-tab shell.

Final device calibration and live cancellation verification remain separate deferred evidence.
