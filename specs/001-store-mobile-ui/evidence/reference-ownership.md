# Reference and Screen Ownership

**Captured**: 2026-10-05
**Coverage target**: 8 boards and 44 screen/flow contracts

## Board Ownership

| Board | Primary implementation ownership | Acceptance phase |
|-------|----------------------------------|------------------|
| 01 | Splash, onboarding, login, auth shared composition | Tasks Phase 3/4 |
| 02 | Auth/profile/settings/notifications/favorites and global states | Tasks Phase 3/4/8/10/11/12/13 |
| 03 | Cart, checkout, order success/list/detail/tracking/actions | Tasks Phase 8/9/10 |
| 04 | Product detail gallery, image, video, 360 variants | Tasks Phase 7 |
| 05 | Product media taxonomy and single/multiple/video/3D states | Tasks Phase 7 |
| 06 | Shell, home, categories, listing, filter, product, cart, checkout, orders | Tasks Phase 5-10 |
| 07 | Home, expandable search, refresh, skeletons | Tasks Phase 5/13 |
| 08 | Tokens and all shared components/states/navigation | Tasks Phase 2 and every later visual gate |

## Screen Contract Ownership

| Screen | Implementation task ownership | Reference owner |
|--------|-------------------------------|-----------------|
| SCR-01 | T025-T026 | Boards 01, 02 |
| SCR-02 | T027 | Boards 01, 02 |
| SCR-03 | T024-T025, T030 | Boards 01, 07 |
| SCR-04 | T024-T025, T028 | Board 02 |
| SCR-05 | T024-T025, T029 | Board 02 |
| SCR-06 | T032-T035 | Boards 01, 02 |
| SCR-07 | T032-T036 | Board 02 |
| SCR-08 | T032-T033, T037-T038 | Board 02 |
| SCR-09 | T032, T037-T038 | Board 02 |
| SCR-10 | T032-T033, T037, T039 | Board 02 |
| SCR-11 | T021, T041-T043 | Boards 06, 07, 08 |
| SCR-12 | T020, T041, T043 | Boards 06, 07, 08 |
| SCR-13 | T041, T043-T046 | Boards 06, 07 |
| SCR-14 | T020, T041, T047-T048 | Board 07 |
| SCR-15 | T041, T048 | Boards 02, 07 |
| SCR-16 | T050-T053 | Boards 02, 06 |
| SCR-17 | T017, T050-T056 | Boards 06, 08 |
| SCR-18 | T017, T050-T057 | Board 06 |
| SCR-19 | T017-T018, T059-T067 | Boards 04, 05, 06 |
| SCR-20 | T018, T059-T064, T066 | Boards 04, 05 |
| SCR-21 | T018, T059-T060, T064, T066 | Boards 04, 05 |
| SCR-22 | T018, T059-T061, T065-T066 | Boards 04, 05 |
| SCR-23 | T017, T069-T073 | Boards 02, 06, 08 |
| SCR-24 | T017-T019, T070, T074-T077 | Boards 03, 06 |
| SCR-25 | T016, T079-T083 | Boards 03, 06 |
| SCR-26 | T016-T017, T079-T080, T082, T084 | Boards 03, 06 |
| SCR-27 | T015-T017, T079-T080, T082, T085 | Boards 03, 06 |
| SCR-28 | T006, T079-T081, T086 | Boards 03, 06 |
| SCR-29 | T015, T079-T080, T087 | Board 03 |
| SCR-30 | T017-T019, T089-T092 | Boards 02, 03, 06 |
| SCR-31 | T017-T019, T089-T093 | Boards 03, 06 |
| SCR-32 | T017, T089-T094 | Boards 03, 06 |
| SCR-33 | T015, T017, T089-T090, T095 | Board 03 |
| SCR-34 | T017-T020, T097, T099-T101 | Boards 02, 08 |
| SCR-35 | T015-T019, T098, T102 | Product references, Board 08 |
| SCR-36 | T015-T021, T104-T106 | Board 02 |
| SCR-37 | T016, T104-T105, T107 | Board 02 |
| SCR-38 | T015-T017, T104-T105, T108 | Board 02 |
| SCR-39 | T015-T017, T104-T105, T109 | Board 02 |
| SCR-40 | T015-T017, T104, T110 | Board 02 |
| SCR-41 | T015-T017, T104-T105, T111 | Board 02 |
| SCR-42 | T015, T017-T018, T104, T112 | Board 02 |
| SCR-43 | T015, T104-T105, T113 | Board 02 |
| SCR-44 | T014-T019, T115-T120 | Boards 02, 07, 08 |

## Coverage Result

- Boards assigned: **8/8**.
- Screen/flow contracts assigned: **44/44**.
- Phase 2 owns only the shared primitives referenced by later screen owners; it does not implement
  later screen orchestration or redesign.
