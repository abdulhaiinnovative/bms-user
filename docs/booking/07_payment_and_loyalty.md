# 07 — Payment and Loyalty

Purpose

- Document payment-related fields, loyalty usage, and UX recommendations.

Payment fields (observed)

- `payment_status` (bool) in legacy payloads
- new API: `payment` object `{ method, amount, token? }` — confirm token requirements

Loyalty

- `loyalty_points_used` appears in Postman payloads; server should validate and compute discount.

UX recommendations

- If payment is required, collect payment token via gateway SDK and include `payment.token`.
- Show loyalty points balance and confirm usage before booking create.

Open items

- Confirm gateway/token field names and whether client should persist minimal payment metadata.

## Concept

- Purpose: Ensure the booking flow captures required payment and loyalty inputs securely while providing clear user consent for charges and point redemption.
- User story: As a customer, I want to pay securely and optionally use loyalty points so I get the correct discount and confirmation.
- Data inputs: payment.method, payment.amount, optional payment.token (gateway-provided), loyalty_points_used.
- UX constraints: never persist raw card data; use gateway SDKs to obtain tokens; show breakdown of discounts and final payable amount before charging.
- Success criteria: payments succeed or fail with clear errors; loyalty deductions are validated server-side and reflected in totals before final create.
- Implementation notes: integrate gateway SDK flows asynchronously; surface retry options for declined payments and show receipt after successful booking.
