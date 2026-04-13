# 01 — Salon Overview

Purpose

- Explain how to load and use salon overview data for booking UI.

## Concept

- Purpose: Provide a single canonical source of salon metadata used by booking screens so UI can reliably build category tabs, hero data and availability hints.
- User story: As a user, I want to view salon details (services, hours, deals) so I can decide what to book.
- Data inputs: salonId path param; server returns categories, sections, images, active_days and location.
- UX constraints: tabs must render quickly; show placeholders while categories load; support per-category pagination.
- Success criteria: categories render with services, tab switching fetches cached results, and overview loads within acceptable time (<2s on good network).
- Implementation notes: prefer `GET /api/booking/salon/{salonId}/overview` when available; fall back to `GET /api/salons/{id}` for compatibility. Cross-link `docs/BOOKING_FLOW_SPEC.md`.

Endpoints

- `GET /api/booking/salon/{salonId}/overview` (new)
- `GET /api/salons/{id}` (used by UI in some places)

Response (trimmed example)

```
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Salon Name",
    "images": ["..."],
    "categories": [ { "id": 5, "name": "Hair" } ],
    "active_days": ["Mon","Tue"]
  }
}
```

UI usage

- Build category tabs from `categories` and sections from `sections`.
- Screen reference: `lib/screens/test/salon_details_scrolling_tabs_effect_b.dart`

Model fields (important)

- `id`, `name`, `images[]`, `location`, `categories[]`, `sections[]`, `active_days[]`

Notes / Open items

- Confirm pagination behavior for services per category and rate-limits for overview endpoint.
