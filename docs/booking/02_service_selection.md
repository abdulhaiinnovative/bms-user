# 02 — Service Selection

Purpose

- Describe service discovery, category tabs, selection UX and interaction with cart/provider.

Key behavior

- Tabs: load services per category using `GET /api/salons/{salonId}/services/{categoryId}`.
- Allow multiple service selection; store selected service IDs in `BookingFlowViewModel`.

## Concept

- Purpose: Let users discover and select salon services efficiently while preserving selection state for checkout.
- User story: As a customer, I want to browse services by category and add one or more items to my booking/cart so I can schedule them together.
- Data inputs: categoryId, pagination params; service objects with id, name, duration, price and available professionals.
- UX constraints: support multi-select, show service duration and price, surface offers/deals inline, keep cart consistent when service list refreshes.
- Success criteria: selected services persist across navigation, cart shows correct totals, and adding/removing services updates provider state atomically.
- Implementation notes: key cart entries by `service_id` (see `CART_REDESIGN_PLAN.md`); present quantity and variation options where applicable; show confirmation toast on add.

Important UI files

- `SERVICES_TABS_IMPLEMENTATION.md`
- `lib/screens/test/salon_details_scrolling_tabs_effect_b.dart`

Model fields

- `Service`: `id`, `salon_id`, `name`, `duration`, `price`, `professionals[]`, `category_id`

Cart interaction

- Cart entries should be keyed by stable `service_id` (see `CART_REDESIGN_PLAN.md`).

Open items

- Confirm whether service `duration` is returned as minutes or human string.
