# 03 — Professional Selection

Purpose

- Document how to request available professionals and surface recommended staff for selected services/date.

Endpoint

- `POST /api/booking/professionals/available`

Request (example fields)

- `salonId`, `serviceIds[]`, `date`, `preferredTime?`

Response (important fields)

- `professionals[]`: `{ id, name, profilePicture, availability, isRecommended }`

## Concept

- Purpose: Surface the best-fit professionals for the selected services and date, enabling user choice or 'no-preference'.
- User story: As a customer, I want to pick a professional I trust or choose no-preference so the system assigns the best match.
- Data inputs: selected serviceIds, date, optional preferredTime; server returns recommended flag and availability windows.
- UX constraints: highlight recommendations, allow quick-select and show professional rating/experience; handle empty results by showing "no preference" fallback.
- Success criteria: recommended professionals appear first, selection persists to time-slot step, and 'no-preference' booking is supported.
- Implementation notes: call `POST /api/booking/professionals/available`, map legacy `profession_id=0` semantics for compatibility.

UI reference

- `lib/screens/test_scroll/select_professionals.dart`

Notes

- Support `no-preference` by sending `profession_id` = 0 in legacy payloads; new API uses `serviceIds` + server-side recommendations.
