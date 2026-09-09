# Booking Flow Specification

This document consolidates the repository's booking flow knowledge: UI flow, API endpoints, example payloads, data models (explicit and inferred), UI -> ViewModel mappings, and open questions for backend validation.

## Summary

- Multi-step booking flow: load salon overview (categories, services, staff) → select services → find available professionals → select date and time slot → optional validation → create booking → post-booking actions (details, cancel, reschedule).

## Flow Steps

1. Load Salon Overview

   - Endpoint: `GET /api/booking/salon/{salonId}/overview` (or `GET /api/salons/{id}`)
   - Purpose: salon metadata, categories, services, staff and deals used to build UI tabs and initial state.
   - References: `SALON_DETAIL_API.md`, `lib/screens/test/salon_details_scrolling_tabs_effect_b.dart`

2. Select Services

   - User picks one or more services (grouped by category). Selections saved in `BookingFlowViewModel`.
   - References: `SERVICES_TABS_IMPLEMENTATION.md`, `VIEWMODEL_INTEGRATION_GUIDE.md`

3. Find Available Professionals

   - Endpoint: `POST /api/booking/professionals/available`
   - Body: salonId, serviceIds, date, optional preferredTime
   - UI: professional selection screen; recommended professionals flagged
   - References: `NEW_BOOKING_API_IMPLEMENTATION.md`, `lib/screens/test_scroll/select_professionals.dart`

4. Select Date & Time Slot

   - Endpoint: `POST /api/booking/slots/available`
   - Body: salonId, professionalId, serviceIds, date
   - UI: calendar + slot list; pick recommended or available slot
   - References: `NEW_BOOKING_API_QUICK_START.md`, `lib/screens/test_scroll/select_time_screen.dart`

5. Optional Validation

   - Endpoint: `POST /api/booking/validate`
   - Purpose: pre-validate availability/pricing/rules and return suggestions or issues
   - References: `NEW_BOOKING_API_IMPLEMENTATION.md`

6. Create Booking

   - Endpoint (new): `POST /api/booking/create`
   - Legacy endpoint seen: `POST /api/create-booking` (POSTMAN examples)
   - Body: structured `CreateBookingRequest` (see Payloads section)
   - Outcome: booking created, return booking id/number and details
   - References: `NEW_BOOKING_API_QUICK_START.md`, `POSTMAN_CREATE_BOOKING_PAYLOADS.md`

7. Post-Booking Actions
   - Endpoints: `GET /api/booking/{bookingId}/details`, `POST /api/booking/{bookingId}/cancel`, `POST /api/booking/{bookingId}/reschedule`
   - Purpose: show confirmation, allow cancel/reschedule flows
   - References: `NEW_BOOKING_API_IMPLEMENTATION.md`

## Canonical API Table (short)

- GET /api/booking/salon/{salonId}/overview — salon overview
- POST /api/booking/professionals/available — find professionals
- POST /api/booking/slots/available — available slots
- POST /api/booking/validate — validate booking
- POST /api/booking/create — create booking (new API)
- POST /api/create-booking — legacy create-booking payloads exist (Postman)
- GET /api/booking/{bookingId}/details — booking details

## Payload Examples (trimmed)

- Basic minimal (from `POSTMAN_CREATE_BOOKING_PAYLOADS.md`):

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

- Complete (all optional fields present):

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

Notes: these payloads are legacy/compat examples. Prefer the structured `CreateBookingRequest` objects used by the new booking API (see Data Models section).

## Data Models (explicit & inferred)

- `SalonOverview` (id, name, images, location, active_days, categories)
- `Service` (id, salon_id, name, duration, price, professionals[])
- `Professional` (id, name, profile, availability, isRecommended)
- `TimeSlot` (time, formatted, isAvailable)
- `CreateBookingRequest` (salonId, bookingDate, bookingTime, services[], payment, loyalty?, dealId?, specialNotes?) — defined in `NEW_BOOKING_API_IMPLEMENTATION.md` and domain models under `lib/features/booking_flow/domain/models/`.

Fields marked as "inferred" were derived from sample JSON and Postman docs; confirm with backend.

## UI -> ViewModel mappings

- Salon Details (services list) → `BookingFlowViewModel.loadSalonOverview(salonId)` and `setSelectedServices(serviceIds)`
- Select Professionals screen → `BookingFlowViewModel.loadAvailableProfessionals(...)` and `setSelectedProfessional(id)`
- Select Time screen → `BookingFlowViewModel.loadAvailableSlots(...)` and `setSelectedSlot(slot)`
- Confirmation / Create Booking → `BookingFlowViewModel.validateBooking(...)` then `createBooking(request)`

Reference integration guide: `VIEWMODEL_INTEGRATION_GUIDE.md`

## Open Questions (needs backend confirmation)

1. Which endpoint is authoritative for creation: `/api/booking/create` (new) or `/api/create-booking` (legacy)?
2. Should client send customer contact info in `CreateBookingRequest` or rely on authenticated user context?
3. For online payments, is a payment token / transaction id required in the booking create payload?
4. For multi-service bookings, does backend compute aggregated duration and sequence, or must client send that ordering/total duration?

## References

- NEW_BOOKING_API_IMPLEMENTATION.md
- NEW_BOOKING_API_QUICK_START.md
- POSTMAN_CREATE_BOOKING_PAYLOADS.md
- SALON_DETAIL_API.md
- VIEWMODEL_INTEGRATION_GUIDE.md
- salon.json

---

Generated from repository docs and sample JSON. Use this file as the single source for developers implementing booking UI and repository layers.
