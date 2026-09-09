# 11 — Data Models (booking)

Purpose

- Canonical list of models used in booking flow, with explicit vs inferred fields and sources.

## Concept

- Purpose: Provide canonical data shapes and guide mapping from API responses to domain models used by UI and persistence layers.
- User story: As a developer, I want a clear model reference so I can implement type-safe mappings and avoid mismatch bugs between payloads and UI code.
- Data inputs: sample JSON from `salon.json`, API response fragments; models must indicate which fields are inferred vs explicit.
- UX constraints: models should be stable and minimize breaking changes; prefer server-provided formatted fields for display when available.
- Success criteria: model definitions align with `lib/features/booking_flow/domain/models/` and enable straightforward serialization/deserialization.
- Implementation notes: mark legacy fields from `POSTMAN_CREATE_BOOKING_PAYLOADS.md` as compatibility-only and map them to domain models in one place.

Models

- `SalonOverview` — `id`, `name`, `images[]`, `location`, `categories[]`, `sections[]` (source: `salon.json`, `SALON_DETAIL_API.md`)
- `Service` — `id`, `salon_id`, `name`, `duration`, `price`, `professionals[]` (source: sample JSON)
- `Professional` — `id`, `name`, `profilePicture`, `availability`, `isRecommended`
- `TimeSlot` — `time`, `formatted`, `isAvailable`
- `CreateBookingRequest` — `salonId`, `bookingDate`, `bookingTime`, `services[]`, `payment`, `dealId?`, `loyalty_points_used?` (source: `NEW_BOOKING_API_IMPLEMENTATION.md`, `POSTMAN_CREATE_BOOKING_PAYLOADS.md`)

Notes

- Fields marked from `POSTMAN_CREATE_BOOKING_PAYLOADS.md` are legacy-format and may differ from the new API model; prefer domain models under `lib/features/booking_flow/domain/models/` when present.
