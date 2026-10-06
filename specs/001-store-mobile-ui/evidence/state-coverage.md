# Store state coverage audit

Values: **C** Covered, **A** Applicable but retained for later evidence, **N** Not
applicable, **G** protected/login gate covered. “Covered” reflects code or tests,
not live-device proof. Phase 14 remains open.

| Screen | Loading | Content | Empty | Offline | Error | Success | Refresh | Media | Gate |
|---|---|---|---|---|---|---|---|---|---|
| SCR-01 Splash | C | C | N | C | C | N | N | C | N |
| SCR-02 Onboarding | N | C | N | N | N | C | N | C | N |
| SCR-03 Initialization | C | C | N | C | C | C | C | C | N |
| SCR-04 Maintenance | C | C | N | C | C | N | C | C | N |
| SCR-05 Upgrade | C | C | N | C | C | C | C | C | N |
| SCR-06 Login | C | C | N | C | C | C | N | C | N |
| SCR-07 Registration | C | C | N | C | C | C | N | N | N |
| SCR-08 Forgot request | C | C | N | C | C | C | N | C | N |
| SCR-09 OTP | C | C | N | C | C | C | N | N | N |
| SCR-10 New password | C | C | N | C | C | C | N | N | N |
| SCR-11 Shell | C | C | N | C | C | N | C | N | C |
| SCR-12 Top/search | C | C | C | C | C | N | C | N | G |
| SCR-13 Home | C | C | C | C | C | N | C | C | N |
| SCR-14 Search discovery | C | C | C | C | C | N | C | N | N |
| SCR-15 Search results | C | C | C | C | C | N | C | C | N |
| SCR-16 Categories | C | C | C | C | C | N | C | C | N |
| SCR-17 Listing | C | C | C | C | C | N | C | C | N |
| SCR-18 Filter/sort | N | C | C | N | N | C | N | N | N |
| SCR-19 Product detail | C | C | C | C | C | N | C | C | N |
| SCR-20 Image gallery | C | C | C | C | C | N | C | C | N |
| SCR-21 Video | C | C | C | C | C | N | C | C | N |
| SCR-22 3D/360 | C | C | C | C | C | N | C | C | N |
| SCR-23 Favorites | N | C | C | N | C | N | N | C | G |
| SCR-24 Cart | N | C | C | N | C | C | C | C | N |
| SCR-25 Checkout address | C | C | C | C | C | C | C | N | G |
| SCR-26 Checkout shipping | C | C | C | C | C | C | C | N | G |
| SCR-27 Checkout payment | N | C | N | N | C | C | N | N | G |
| SCR-28 Submission | C | C | N | C | C | C | C | N | G |
| SCR-29 Order success | N | C | N | N | C | C | N | N | G |
| SCR-30 Order list | C | C | C | C | C | N | C | C | G |
| SCR-31 Order detail | C | C | C | C | C | N | C | C | G |
| SCR-32 Tracking | C | C | C | C | C | N | C | N | G |
| SCR-33 Order actions | C | C | N | C | C | C | C | N | G |
| SCR-34 Notifications | C | C | C | C | C | C | C | N | G |
| SCR-35 Reviews | C | C | C | C | C | C | C | N | G |
| SCR-36 Profile | C | C | N | C | C | N | C | N | G |
| SCR-37 Account info | C | C | N | C | C | C | C | N | G |
| SCR-38 Address fallback | N | C | C | N | N | N | N | N | G |
| SCR-39 Payment capability | N | C | C | N | N | N | N | N | G |
| SCR-40 Language | N | C | N | N | N | C | N | N | N |
| SCR-41 Settings | N | C | N | N | C | C | N | N | N |
| SCR-42 Support | C | C | C | C | C | N | C | N | N |
| SCR-43 Account actions | C | C | N | C | C | C | C | N | G |
| SCR-44 State library | C | C | C | C | C | C | C | C | N |

No failure is intentionally mapped to empty. Remaining live API, device, and
pixel-comparison proof is explicitly Phase 14 scope.
