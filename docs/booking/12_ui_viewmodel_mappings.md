# 12 — UI → ViewModel Mappings

Purpose

- Map screens to `BookingFlowViewModel` methods and outline navigation order.

Primary mappings

- Salon Details (services) → `BookingFlowViewModel.loadSalonOverview(salonId)`; `setSelectedServices(serviceIds)`
- Cart / Checkout Modal → `CartProvider`, `BookingFlowViewModel.prepareCheckout()`
- Select Professionals → `BookingFlowViewModel.loadAvailableProfessionals(...)`; `setSelectedProfessional(id)`
- Select Time → `BookingFlowViewModel.loadAvailableSlots(...)`; `setSelectedSlot(slot)`
- Validate & Confirm → `BookingFlowViewModel.validateBooking(...)`; `createBooking(request)`

## Concept

- Purpose: Clarify responsibilities between screens and the `BookingFlowViewModel` to keep navigation and state predictable.
- User story: As an engineer, I want a clear mapping so I can implement screens that use the same ViewModel methods and avoid duplicated logic.
- Data inputs: mapping table of screen → methods; expected preconditions and postconditions for each method (e.g., services selected before loading professionals).
- UX constraints: ViewModel methods should be idempotent where possible and resilient to repeated calls from hot reloads or lifecycle events.
- Success criteria: screens call ViewModel methods in defined order, state transitions are deterministic, and bugs due to misplaced state updates are minimized.
- Implementation notes: follow `VIEWMODEL_INTEGRATION_GUIDE.md` and wire ViewModel via provider or context.read as the project pattern requires.

Navigation flow

1. Salon Details → 2. Select Professionals (if needed) → 3. Select Time → 4. Review/Payment → 5. Booking Success

References

- `VIEWMODEL_INTEGRATION_GUIDE.md`
