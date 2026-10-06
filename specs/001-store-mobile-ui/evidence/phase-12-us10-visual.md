# Phase 12 - Profile and preferences structural review

Scope: SCR-36 through SCR-43 against boards 02 and 08. This is a static,
structural comparison; no device pixel-diff is claimed.

| Variant | Structural result |
|---|---|
| Guest profile | Guest header, authentication CTA, public language/settings/support destinations |
| Authenticated profile | Compact identity header and protected account destinations |
| Personal details | Only full name, email, two phones, city, and address are editable |
| Address fallback | One current profile address; no address-book CRUD controls |
| Payment capability | COD shown; saved cards explicitly unavailable |
| Language | Arabic, English, Hebrew with selected indicator and correct direction |
| Settings | Local persisted theme separated from server-owned store status |
| Support | Configured call, WhatsApp, Instagram, Twitter plus existing static routes |
| Logout confirmation | Explicit confirmation before local session removal |
| Deletion confirmation | Explicit server-first warning and confirmation |
| Deletion failure | Local identity remains preserved |
| Deletion success | Session clears only after HTTP 200 plus `message: success` |

Final screenshot fidelity remains Phase 14 work.
