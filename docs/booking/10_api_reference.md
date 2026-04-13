# 10 — API Reference (booking)

Short table of booking endpoints and required params.

- GET `/api/booking/salon/{salonId}/overview` — path: `salonId`
- POST `/api/booking/professionals/available` — body: `salonId`, `serviceIds[]`, `date`
- POST `/api/booking/slots/available` — body: `salonId`, `professionalId`, `serviceIds[]`, `date`
- POST `/api/booking/validate` — body: booking preview fields
- POST `/api/booking/create` — body: `CreateBookingRequest` (canonical)
- POST `/api/create-booking` — legacy examples in `POSTMAN_CREATE_BOOKING_PAYLOADS.md`
- GET `/api/booking/{bookingId}/details` — path: `bookingId`

Use per-feature docs for examples and notes.

## Concept

- Purpose: Serve as a compact reference for developers to find booking endpoints and required parameters quickly.
- User story: As a developer, I want a one-page API index so I can implement network calls or validate backend contracts without scanning multiple docs.
- Data inputs: list of endpoints, path/query/body params and links to example payloads in per-feature docs.
- UX constraints: keep this file lightweight and link to per-feature docs for details and examples.
- Success criteria: developers can implement API calls using this reference and follow links to payload examples.
- Implementation notes: keep synced with `NEW_BOOKING_API_IMPLEMENTATION.md` and update if endpoints change.
