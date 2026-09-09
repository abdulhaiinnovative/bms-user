# Booking Flow — Full Specification

This single-file reference consolidates the booking flow: UI steps, endpoints, canonical payload examples, data models, UI→ViewModel mappings, and open questions for backend validation. Use this file when implementing or reviewing the booking feature.

## 1 — Summary

- Multi-step booking flow: load salon overview → select services → choose professionals (optional) → pick date/time slot → validate → create booking → post-booking actions (details, cancel, reschedule).

## 2 — Flow Steps (detailed)

Step 1 — Load Salon Overview

- Endpoint: `GET /api/booking/salon/{salonId}/overview` (preferred) or `GET /api/salons/{id}`
- Purpose: retrieve salon metadata, categories, sections, images, active_days and deals used to build UI and initial state.
- UI: category tabs and sections; example screen: `lib/screens/test/salon_details_scrolling_tabs_effect_b.dart`.

Step 2 — Select Services

- Pattern: categories → services list; user may multi-select services.
- Endpoint: `GET /api/salons/{salonId}/services/{categoryId}` (used to load per-tab data)
- Important: keep cart keyed by stable `service_id` to avoid duplication; UI should show duration and price.

Step 3 — Find Available Professionals

- Endpoint: `POST /api/booking/professionals/available`
- Purpose: return available/recommended professionals for selected services/date.
- Notes: support 'no-preference' semantics (legacy: `profession_id=0`).

Step 4 — Select Date & Time Slot

- Endpoint: `POST /api/booking/slots/available`
- Purpose: list available slots (with recommended slots first). Use server's `formatted` values for display and confirm timezone handling.

Step 5 — Optional Validation

- Endpoint: `POST /api/booking/validate`
- Purpose: pre-validate booking preview and return `valid`, `issues[]`, `suggestions[]` to avoid failed creates.

Step 6 — Create Booking

- Endpoint (new): `POST /api/booking/create` (preferred)
- Legacy examples: `POST /api/create-booking` (see Postman payloads)
- Body: `CreateBookingRequest` containing salonId, bookingDate, bookingTime, services[], payment object, optional deal/loyalty, and special notes.

Step 7 — Post-Booking Actions

- Endpoints: `GET /api/booking/{bookingId}/details`, `POST /api/booking/{bookingId}/cancel`, `POST /api/booking/{bookingId}/reschedule`
- Purpose: canonicalize booking display and enable lifecycle operations.

## 3 — Per-Feature Concepts (short)

Salon Overview

- Purpose: canonical salon metadata for UI; user story: browse salon info and categories to decide what to book.
- Success criteria: categories render, tabs load cached results and overview is performant.

Service Selection

- Purpose: let users discover and add services; user story: browse categories, add services and variations to cart for grouped booking.
- Success criteria: service selections persist across navigation and totals match cart.

Professional Selection

- Purpose: surface recommended professionals or allow no-preference; user story: select a professional or let server assign best-fit.
- Success criteria: recommendations appear first and selection persists.

Time Slots

- Purpose: present authoritative available slots; user story: choose a convenient time that backend will honor.
- Success criteria: slot remains available through validation; timezone handling is correct.

Validation

- Purpose: pre-flight check to detect conflicts or price changes; user story: get actionable suggestions before paying.
- Success criteria: reduces failed create attempts.

Create Booking

- Purpose: submit final booking; user story: confirm, pay (if required) and receive booking confirmation.
- Success criteria: returns booking id, scheduled datetime and payment confirmation.

Payment & Loyalty

- Purpose: securely accept payments and redeem loyalty points; user story: apply loyalty discounts and charge via gateway tokens.
- Success criteria: secure token usage and server-side validation of loyalty.

Cart Integration

- Purpose: consistent cart model used across screens; user story: review and edit services before checkout.
- Success criteria: cart remains consistent and modal behavior is stable.

Post-Booking

- Purpose: allow viewing, cancelling or rescheduling bookings with proper eligibility checks and UI updates.

UI ↔ ViewModel Mappings

- Purpose: map screens to `BookingFlowViewModel` methods to centralize state and actions.
- Pattern: Salon Details → set services; Professionals → set professional; Time → set slot; Validate → validateBooking; Create → createBooking.

## 4 — Canonical API Reference (summary)

- GET /api/booking/salon/{salonId}/overview — path: `salonId` — returns overview (categories, sections, images, deals)
- GET /api/salons/{id}/services/{categoryId} — query: `per_page`, `page` — returns paginated services for category
- POST /api/booking/professionals/available — body: `{ salonId, serviceIds[], date, preferredTime? }`
- POST /api/booking/slots/available — body: `{ salonId, professionalId, serviceIds[], date }`
- POST /api/booking/validate — body: booking preview — returns `{ valid, issues[], suggestions[] }`
- POST /api/booking/create — body: `CreateBookingRequest` — returns booking id and details
- POST /api/create-booking — legacy payloads exist in `POSTMAN_CREATE_BOOKING_PAYLOADS.md`
- GET /api/booking/{bookingId}/details — path: `bookingId`
- POST /api/booking/{bookingId}/cancel — body: optional reason
- POST /api/booking/{bookingId}/reschedule — body: new slot info

## 5 — Payload Examples (trimmed)

Basic minimal (legacy Postman example):

```
{
  "salon_id": 1,
  "service_id": [5, 7],
  "profession_id": [3, 3],
  "time": "02:30 PM, 2025-12-15",
  "total_price": 100.00,
  "payment_status": true
}
```

Complete (legacy, many optional fields):

```
{
  "salon_id": 1,
  "service_id": [5,7,12],
  "profession_id": [3,3,0],
  "time": "03:30 PM, 2025-12-25",
  "total_price": 300.00,
  "payment_status": false,
  "booking_type":"appointment",
  "loyalty_points_used":30,
  "deal_id":5,
  "qty":{ /* service qty mapping */ },
  "variation":{ /* variations per service */ }
}
```

Preferred new-API `CreateBookingRequest` (canonical shape — implementers should prefer domain models under `lib/features/booking_flow/domain/models/`):

```
{
  "salonId": 1,
  "bookingDate": "2025-12-25",
  "bookingTime": "15:30",
  "services": [ { "serviceId": 5, "professionalId": 3, "qty": 1 } ],
  "payment": { "method": "card", "amount": 300.0, "token": "tok_xxx" },
  "dealId": 5,
  "loyaltyPointsUsed": 30,
  "specialNotes": "Please use the rear room"
}
```

## 6 — Data Models (canonical)

- SalonOverview: `id, name, images[], location, categories[], sections[], active_days[]`
- Service: `id, salon_id, name, duration (mins), price, professionals[]`
- Professional: `id, name, profilePicture, availability, isRecommended, rating?`
- TimeSlot: `time (HH:MM), formatted, isAvailable, meta` (server-provided formatted recommended)
- CreateBookingRequest: `salonId, bookingDate, bookingTime, services[], payment, dealId?, loyaltyPointsUsed?, specialNotes?`

Notes: fields marked as inferred come from sample JSON and `POSTMAN_CREATE_BOOKING_PAYLOADS.md`. Prefer domain models under `lib/features/booking_flow/domain/models/` when available.

## 7 — UI → ViewModel Wiring

- Salon Details Screen: call `BookingFlowViewModel.loadSalonOverview(salonId)` on init; on service selection call `setSelectedServices(serviceIds)`.
- Select Professionals Screen: call `loadAvailableProfessionals({ salonId, serviceIds, date })`; set `setSelectedProfessional(id)` on selection.
- Select Time Screen: call `loadAvailableSlots({ salonId, professionalId, serviceIds, date })`; set `setSelectedSlot(slot)`.
- Review/Payment Screen: call `validateBooking(preview)`; after validation call `createBooking(request)`.

Follow `VIEWMODEL_INTEGRATION_GUIDE.md` for examples and provider wiring.

## 8 — Success Criteria & Acceptance Tests (suggested)

- Salon Overview loads categories and first-page services for each tab within 2s on good network.
- Service selection persists across navigation and cart totals match server-calculated totals.
- Professional recommendations appear and recommended staff are selectable.
- Time slots show availability and validation prevents booking creation for taken slots.
- Create booking returns id and details; payment tokens are handled securely and no raw card data is stored.

## 9 — Open Questions (requires backend confirmation)

1. Which create endpoint should be treated as authoritative: `/api/booking/create` or legacy `/api/create-booking`? Update examples accordingly.
2. Are customer contact details required in `CreateBookingRequest`, or are they derived from authenticated user/session?
3. For payments, what exact token/gateway fields are required (field names, structure) in the create payload?
4. For multi-service bookings, does the backend compute aggregated duration/sequence, or must client provide ordering/total duration?

## 10 — References

- NEW_BOOKING_API_IMPLEMENTATION.md
- NEW_BOOKING_API_QUICK_START.md
- POSTMAN_CREATE_BOOKING_PAYLOADS.md
- SALON_DETAIL_API.md
- VIEWMODEL_INTEGRATION_GUIDE.md
- salon.json

---

Generated by consolidating `docs/booking/*` and top-level docs. If you want this exported as JSON-schema or OpenAPI fragments, I can generate them next.
