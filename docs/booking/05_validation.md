# 05 — Validation

Purpose

- Describe `POST /api/booking/validate` semantics and how clients should handle validation responses.

Endpoint

- `POST /api/booking/validate`

Typical request fields

- `salonId`, `services[]`, `date`, `time`, `paymentMethod?`

Typical response

- `valid`: boolean
- `issues[]`: list of problems (e.g., slot taken, price changed)
- `suggestions[]`: optional alternative slots or professionals

Client behavior

- Show issues to user and offer `suggestions` as auto-selection options.

## Concept

- Purpose: Provide a safety-check that booking requests remain valid before final creation, reducing failed bookings and user frustration.
- User story: As a customer, I want the app to tell me if my selected slot or service has changed so I can adjust before confirming payment.
- Data inputs: preview of booking (`salonId`, `services`, `date`, `time`, payment intent); response contains `valid`, `issues[]` and `suggestions[]`.
- UX constraints: surface issues clearly with actionable suggestions (alternate slots/professionals), avoid blocking UX for transient errors, and guide user to quick resolution.
- Success criteria: validation catches conflicts and prevents failed creates; suggested alternatives reduce manual retry rate.
- Implementation notes: run validation immediately before payment/creation; show inline alternatives and allow one-tap accept.
