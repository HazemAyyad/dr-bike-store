# Phase 13 - Global states structural review

SCR-44 was compared structurally with boards 02, 07, and 08. No device
pixel-diff or final fidelity is claimed.

| Variant | Evidence |
|---|---|
| Skeleton/loading | Shared skeleton has a loading semantic label; retained content may remain visible |
| Empty | Dedicated neutral empty state, never used for transport/parser failure |
| Offline | Dedicated offline state with retry; previous content can remain visible |
| Error | Dedicated recoverable error state with retry |
| Retry | Single callback; tested offline-to-content recovery |
| Refreshed content | Home/category refresh retains truthful typed state |
| Media fallback | Stable semantic placeholder replaces missing/broken media |
| Arabic RTL / Hebrew RTL | Direction follows locale |
| English LTR | Direction follows locale |
| Large text | Representative narrow 1.3 and 1.6 scale layouts tested |
| Safe area | Shell top content and bottom navigation use SafeArea |

Final screenshots and board-by-board visual diff remain T121-T129.
