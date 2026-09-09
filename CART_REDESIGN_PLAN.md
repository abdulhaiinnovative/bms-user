# Cart Redesign Plan

## Goal

Redesign the in-page cart & modal to be modular, reliable, and testable. Fix current bugs (modal not closing reliably, fragile cart-keying by object identity, mixed responsibilities) and improve UX (clear quantity controls, animations, provider sync).

---

## Quick analysis of current cart code

- Cart stored as `Map<dynamic,int> _cartItems` where keys are `Service`/`Deal` objects. Using object instances as map keys risks identity mismatches when items are reloaded from API; code tries to mitigate this via `_syncCartWithLoadedData()` but this is fragile.
- Modal is built with `StatefulBuilder` and exposes `_modalStateSetter` to trigger modal rebuilds from parent methods. This works but is error-prone.
- `_removeItem`, `_increaseQuantity`, `_decreaseQuantity` correctly update `_cartItems` inside `setState` and call `_modalStateSetter?.call(() {})` to refresh modal. However earlier edits left empty setState bodies (now fixed) — ensure all state updates occur inside `setState` callbacks.
- Modal close/pop logic was previously placed inside the IconButton handler (broken during edits); moved to `_removeItem` to guarantee closing when last item removed. Use of `Navigator.of(context).canPop()` with `rootNavigator` fallback is acceptable but ensure correct navigator is targeted for modal.
- `_getCartItem` searches by `id` and returns matching instance; this is good but requires synced loaded data to keep keys stable.
- `_syncCartWithLoadedData` exists but may not run in all flows; consider storing cart items in provider as canonical objects (or use id-based keys) to avoid instance mismatch.
- Several analyzer/info warnings unrelated to cart (deprecated withOpacity, use_build_context_synchronously) exist across the project.

## Identified issues to address

1. Using object instances as map keys -> use id-based keys or canonical objects from provider/DB.
2. Modal-state coordination via global `_modalStateSetter` is brittle — prefer local stateful modal components that subscribe to provider or accept value/onChange callbacks.
3. Closing modal: ensure modal closes when last item removed regardless of removal source (button, other flow). Move pop logic to cart remove flow and ensure correct navigator is used.
4. Race conditions: avoid using BuildContext across async gaps. Use `if (!mounted) return;` and prefer reading provider outside async gaps where possible.
5. Tests missing for cart behavior (add/remove/quantity change/modal close).

## Constraints & decisions

- Keep `CartProvider` as single source of truth for global cart state; local widget should reflect provider state where possible.
- Minimize API surface changes; do refactor in UI layer primarily.
- Maintain backward compatibility with existing `_syncCartWithLoadedData` while improving robustness.

## Proposed architecture (high-level)

- CartProvider (existing): store items as Map<int, CartEntry> where key is `itemId` and `CartEntry` holds itemType (service/deal), quantity, and a canonical reference to the item when available.
- New UI components (under `lib/screens/cart/` or `lib/screens/test_scroll/components/`):
  - `CartModal` — a self-contained `StatefulWidget` or `Consumer` that reads `CartProvider` and renders items, quantities, totals, and handles closing when empty.
  - `CartItemRow` — presentational widget for a single cart entry with increase/decrease/remove callbacks.
  - `CartSummary` — bottom summary bar (total + checkout button).
- Modal display: call `showModalBottomSheet` which builds `CartModal` (no `StatefulBuilder` needed). `CartModal` subscribes to provider; provider updates trigger rebuilds.

## Implementation steps

1. Create `CartEntry` model (id, type, itemRef?, quantity).
2. Update `CartProvider` (if necessary) to expose map keyed by id and helper methods: `addItem(item)`, `removeItemById(id)`, `updateQuantity(id, q)`, `itemsMap` getter. (If you prefer not to change provider now, adapt UI to map provider items into stable id-keyed structure locally.)
3. Add new UI components:
   - `lib/screens/test_scroll/components/cart_modal.dart` (or `lib/screens/cart/cart_modal.dart`) — read provider with `Consumer<CartProvider>` and render list + summary.
   - `lib/screens/test_scroll/components/cart_item_row.dart` — presentational + callbacks.
4. Replace existing modal builder in `salon_category_and_services_list.dart` to call `showModalBottomSheet(..., builder: (_) => const CartModal())` and remove `_modalStateSetter` plumbing.
5. Ensure `_handleAddToCart`, `_removeItem`, `_increaseQuantity`, `_decreaseQuantity` delegate to `CartProvider` methods and update local `_cartItems` only if necessary; preferably let provider be the source of truth and remove local duplication.
6. Add unit/widget tests: widget test for `CartModal` and provider unit tests for add/remove/quantity and empty-cart pop behavior.
7. Run `flutter analyze` and manual test on emulator/device to verify: add items, adjust qty, remove items, last-item removal closes modal, checkout navigation works.

## Acceptance criteria

- Modal closes automatically when the last cart item is removed from any code path.
- Quantity changes and removals update UI immediately (no manual modal rebuild hacks required).
- Cart items keyed by stable ids; reloading services from API maps to same cart entries.
- No regressions in existing booking flow; `flutter analyze` shows no new errors from refactor.

## Estimated effort

- Analysis & plan: 1–2 hours (done)
- Provider adjustments & CartEntry: 1–2 hours
- UI components & wiring: 2–4 hours
- Tests & verification: 1–2 hours
- Cleanup and PR: 30–60 minutes

---

## Next action (after your approval)

1. Implement `CartEntry` and adapt `CartProvider` (or create adapter in UI layer).
2. Implement `CartModal` + `CartItemRow` and wire showModalBottomSheet.
3. Remove `_modalStateSetter` usage and local `_cartItems` duplication (or keep sync adapter during transition).
4. Add tests and run analyzer.

If you approve, I will start with step 1 (implement `CartEntry` and provider adapter) and then implement the modal component.
