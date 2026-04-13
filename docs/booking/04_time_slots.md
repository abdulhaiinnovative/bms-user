# 04 — Time Slots

Purpose

- Explain slot discovery and selection UX.

Endpoint

- `POST /api/booking/slots/available`

Request (common fields)

- `salonId`, `professionalId`, `serviceIds[]`, `date`

Response (slot example)

```
{
  "slots": [ { "time": "10:00", "formatted": "10:00 AM", "isAvailable": true } ]
}
```

UI

- Calendar + horizontal slot list; show recommended slots first.
- Screen: `lib/screens/test_scroll/select_time_screen.dart`

## Concept

- Purpose: Provide an authoritative list of available time slots for a given date/professional/services so users can schedule bookings the backend will honor.
- User story: As a customer, I want to pick a convenient date/time and see clearly which slots are available or recommended.
- Data inputs: `salonId`, `professionalId`, `serviceIds[]`, `date`; server returns `slots[]` with availability metadata.
- UX constraints: show recommended slots visually, handle timezone/localization, debounce repeated slot queries, display loading states and graceful empty-state messaging.
- Success criteria: selected slot remains consistent through validation; user sees conflicts if slot becomes unavailable before create.
- Implementation notes: treat server times as source-of-truth; confirm whether times are salon-local or UTC. Prefer using server-provided `formatted` strings for display.

Open items

- Confirm timezone handling and whether server returns UTC or salon-local times.
