# UI State Contract

## Canonical States

| State | Required presentation | Allowed actions |
|-------|-----------------------|-----------------|
| Initial | Stable shell/placeholder without false content | Begin load or remain local |
| Loading | Reference-mapped skeleton or short blocking progress for sensitive mutation | Cancel only if safe |
| Refreshing | Existing content plus visible refresh indicator | Continue safe browsing; no duplicate refresh |
| Data | Successfully parsed authoritative content | Context actions by capability |
| Empty | Specific illustration/copy explaining a successful zero-data result | Relevant discovery/create action |
| Search empty | Query-specific no-results copy | Edit query, clear filters, browse categories |
| No products | Section-specific zero-published-products copy | Browse sections |
| Offline | Offline illustration/copy; optional stale content visibly identified | Retry, safe local navigation |
| Error | Generic or typed error copy that is not an empty state | Retry, support where appropriate |
| Success | Authoritative result identity/message | Next action tied to result |
| Unsupported | Truthful capability message or omitted control | Back/support; no simulated interaction |

## Section Composition

Home and detail pages can contain independently loaded sections. Each section owns its state and
must not use a page-wide success simply because another request succeeded. Global blocking state is
reserved for startup gates and sensitive submissions.

## Refresh

Pull-to-refresh follows the board-08 sequence: idle prompt -> refreshing indicator -> updating copy
-> success confirmation, with error/offline replacing success when refresh fails. Multiple refresh
gestures coalesce.

## Media

Every media tile has idle/loading/ready/failed/unsupported states. A failed thumbnail retains the
item's position and accessible type label. Video/player failure offers retry or returns to another
medium. 3D/360 controls exist only for real supported capability.

## Accessibility and RTL

- Arabic direction applies to layout, not to phone numbers, product codes, order IDs, time, or
  other inherently LTR tokens; mixed text must remain readable.
- Icon-only controls expose semantic labels and selected/disabled state.
- Focus order follows visual RTL order, forms remain visible above the keyboard, and destructive
  actions are never color-only.
- Text scaling must not hide critical actions or totals; compactness cannot require truncating
  identity, price, status, or validation messages beyond recognition.
