# 08 — Cart Integration

Purpose

- Document the cart model, modal behavior and provider integration for booking flow.

Key points

- Cart entries must be keyed by stable `service_id` (see `CART_REDESIGN_PLAN.md`).
- Cart modal should subscribe to a `CartProvider` and update totals/react to item removal.

Flow

- Add service → update `CartProvider` → show modal via `showModalBottomSheet(..., builder: (_) => CartModal())`.

Acceptance criteria (from plan)

- Modal closes when last item removed; cart keys stable; no modal plumbing leakage.

## Concept

- Purpose: Maintain a dependable, predictable cart representing the user's selected services across the booking flow and provide a simple checkout surface.
- User story: As a customer, I want to review added services, change quantities or variations, and proceed to booking with a single checkout action.
- Data inputs: cart entries keyed by `service_id`, quantities, selected variations, optional professional preference per service.
- UX constraints: cart must remain consistent when service lists reload; avoid duplicate entries by using stable keys; provide quick editing inside modal.
- Success criteria: totals and item counts always match selections, modal closes or updates correctly when items removed, and checkout triggers `BookingFlowViewModel.prepareCheckout()`.
- Implementation notes: implement `CartProvider` with immutable state updates; prefer provider or Riverpod patterns used in repo; ensure modal subscribes to provider instead of plumbing callbacks.
