# 09 — Post-Booking Actions

Purpose

- Describe retrieval of booking details and cancel/reschedule flows.

Endpoints

- `GET /api/booking/{bookingId}/details`
- `POST /api/booking/{bookingId}/cancel`
- `POST /api/booking/{bookingId}/reschedule`

Notes

- After create, navigate to BookingSuccess screen and call details endpoint for canonical info.

## Concept

- Purpose: Provide the app and user with authoritative booking lifecycle operations (view, cancel, reschedule) and ensure consistent state across client and server.
- User story: As a customer, I want to view my booking details, cancel when eligible, or reschedule if supported so I can manage my appointments.
- Data inputs: bookingId path param; server-side validation of cancel/reschedule eligibility; optional new slot info for reschedule.
- UX constraints: show eligibility rules (cancellation window, fees), confirm destructive actions with modal, and update local bookings cache after operations.
- Success criteria: booking details page shows canonical data after create; cancel/reschedule return updated booking state and UI reflects changes immediately.
- Implementation notes: call details endpoint after create to normalize display; implement optimistic UI updates only after successful server responses.
