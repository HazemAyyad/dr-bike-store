# Backend Capability Decisions for T001-T023

**Decision date**: 2026-10-05
**Method**: Current Store Flutter repositories, models, endpoints, and approved API mapping only.

These decisions prevent shared UI primitives from implying capabilities that the current contract
does not prove. Phase 2 components are presentation primitives and do not persist business state.

| Capability | Current proof | Decision | Safe UI behavior | Affected later screens | Resolution owner |
|------------|---------------|----------|------------------|------------------------|------------------|
| Favorites | No Store read/add/remove/sync endpoint or guest policy appears in current repositories | **Capability off** | Shared heart icon may exist as a component, but no production favorite mutation or success state is wired | SCR-12, SCR-17, SCR-19, SCR-23, SCR-36 | Backend/product contract owner |
| Address book | Profile edit exposes one address/city; city, village, and fee APIs exist; no address CRUD/default contract | **Single-profile-address fallback only** | Shared selectors may render supplied values; do not claim multiple saved addresses or default management | SCR-25, SCR-36, SCR-38 | Backend/account contract owner |
| Saved payments | Native checkout proves `payment.type = cash` and `paid_amount = 0`; no tokenization/list/add/remove endpoint | **COD/cash only** | Payment primitives must not collect or persist raw card data; saved/card/wallet/bank controls remain omitted | SCR-27, SCR-36, SCR-39 | Backend/payment owner |
| Advanced filters | Current client has limited price presentation filtering; no verified brand/rating/stock facet request contract | **Unverified filters off** | Generic filter-chip component is allowed; interactive business filters must be enabled only from later confirmed capability data | SCR-15, SCR-17, SCR-18 | Catalog API owner |
| True 3D/360 | Product payload has image lists and video URL, but no typed interactive asset/viewer contract | **Interactive viewer off** | Media badge can label a caller-supplied verified type; static images must not be presented as rotatable media | SCR-19, SCR-22 | Catalog/media owner |

## Non-Blocking Foundation Rule

Buttons, chips, cards, media badges, and navigation components accept presentation values and
callbacks supplied by later features. A disabled or absent callback is not a successful business
operation. No local favorite, address, payment, filter, or 360 authority is introduced in Phase 2.
