# Appointments API

**Endpoint:** `GET /api/appointments`

**Full URL examples:**
- Local: `http://localhost:8000/api/appointments`
- Local with all: `http://localhost:8000/api/appointments?status=all`
- Local with status filter: `http://localhost:8000/api/appointments?status=booked`
- Production: `https://your-domain.com/api/appointments`

**Route implementation:** [routes/api.php](routes/api.php#L99)
**Controller:** [app/Http/Controllers/Api/BookingController.php](app/Http/Controllers/Api/BookingController.php#L37)

---

## Summary
Ye endpoint authenticated user ki appointments list return karta hai.

- Agar `status` query param empty ho ya `all` ho, to saari appointments paginated form me aati hain.
- Agar `status` diya ho, to sirf us status wali bookings return hoti hain.

## Authentication
- Guard: `auth:api`
- Header: `Authorization: Bearer <token>`

## HTTP Method
- `GET`

## Query Params
- `status` (optional, string)
  - `all` → saari appointments
  - empty / missing → saari appointments
  - specific status → filtered results

### Allowed booking statuses
Booking table me commonly ye status values use ho rahe hain:
- `booked`
- `pending`
- `confirmed`
- `complete`
- `completed`
- `cancelled by customer`
- `cancelled by salon`
- `no show`

> Note: codebase me `complete` aur `completed` dono values mil rahi hain, is liye frontend ko dono handle karne chahiye.

## URL Hit Examples
- All appointments: `GET /api/appointments`
- All appointments explicitly: `GET /api/appointments?status=all`
- Booked appointments: `GET /api/appointments?status=booked`
- Completed appointments: `GET /api/appointments?status=completed`
- Cancelled by customer: `GET /api/appointments?status=cancelled%20by%20customer`
- No show appointments: `GET /api/appointments?status=no%20show`

## Pagination
Default pagination size: `10`

Response contains standard pagination keys:
- `current_page`
- `data`
- `first_page_url`
- `from`
- `last_page`
- `last_page_url`
- `next_page_url`
- `path`
- `per_page`
- `prev_page_url`
- `to`
- `total`

## Response Example

```json
{
  "statusCode": 200,
  "response": {
    "data": {
      "current_page": 1,
      "data": [
        {
          "id": 123,
          "status": "Approved",
          "title": "Services:\nHair Cut\nBeard Trim",
          "salon": {
            "id": 10,
            "name": "Salon Name"
          }
        }
      ],
      "first_page_url": "http://localhost:8000/api/appointments?page=1",
      "from": 1,
      "last_page": 3,
      "last_page_url": "http://localhost:8000/api/appointments?page=3",
      "next_page_url": "http://localhost:8000/api/appointments?page=2",
      "path": "http://localhost:8000/api/appointments",
      "per_page": 10,
      "prev_page_url": null,
      "to": 10,
      "total": 28
    }
  },
  "message": "Success!",
  "status": true,
  "errors": []
}
```

## cURL Examples

```bash
curl -X GET "http://localhost:8000/api/appointments" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Accept: application/json"
```

```bash
curl -X GET "http://localhost:8000/api/appointments?status=booked" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Accept: application/json"
```

## Developer Notes
- The controller is using `Booking::MyBooking()` so results are always scoped to the authenticated user.
- The endpoint normalizes `status=all` and empty status to the same behavior: return all appointments.
- If you need a new filter value, add it in the controller and align frontend dropdown values with the database status values.
