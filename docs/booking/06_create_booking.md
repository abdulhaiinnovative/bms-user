# 06 — Create Booking

Purpose

- Canonical guide for creating bookings (preferred new API plus legacy compatibility notes).

Primary endpoint

- `POST /api/booking/create` (preferred)

Legacy endpoint (examples)

- `POST /api/create-booking` — payloads in `POSTMAN_CREATE_BOOKING_PAYLOADS.md`

Canonical `CreateBookingRequest` (summary)

- `salonId` (int)
- `bookingDate` (YYYY-MM-DD)
- `bookingTime` (HH:MM or formatted string)
- `services`: array of `{ serviceId, professionalId?, qty?, variation? }`
- `payment`: `{ method, amount, status?, token? }`
- optional: `dealId`, `loyalty_points_used`, `specialNotes`

Success response

- booking id/number, scheduled datetime, summary of services, payment status

Error handling

- handle validation errors (see `05_validation.md`) and transient server errors with retry/backoff.

## Concept

- Purpose: Define the canonical create booking contract and client responsibilities to submit a booking that the backend can fulfil.
- User story: As a customer, I want to confirm my selected services, professional and slot, pay (if required), and receive a guaranteed booking confirmation.
- Data inputs: fully-populated `CreateBookingRequest` including services[], selected professional(s) or no-preference marker, timeslot, and payment metadata where required.
- UX constraints: prevent double-submits, show clear progress while creating booking, and surface deterministic success or actionable failure details.
- Success criteria: create returns booking id/number and accurate scheduled data; payment is confirmed if required and booking appears in user's bookings list.
- Implementation notes: prefer `POST /api/booking/create`; for legacy compatibility map fields from `POSTMAN_CREATE_BOOKING_PAYLOADS.md`. Lock UI during create and handle idempotency (server-side idempotency key recommended).
