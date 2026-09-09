# Postman JSON Payloads for Create Booking API

## Overview
This document contains ready-to-use JSON payloads for testing the `/api/create-booking` endpoint in Postman.

---

## Postman Collection Setup

### Base Configuration

**URL**: `{{base_url}}/api/create-booking`  
**Method**: `POST`  
**Headers**:
```
Content-Type: application/json
Accept: application/json
Authorization: Bearer {{access_token}}
```

### Environment Variables
Create these variables in your Postman environment:
- `base_url`: `http://localhost:8000` (or your server URL)
- `access_token`: Your authentication token

---

## JSON Payloads

### 1. Basic Booking (Minimal Required Fields)

```json
{
  "salon_id": 1,
  "service_id": [5, 7],
  "profession_id": [3, 3],
  "time": "02:30 PM, 2025-12-15",
  "total_price": 100.00,
  "payment_status": true
}
```

**Description**: Simple booking with 2 services, specific professionals, cash payment.

---

### 2. Booking with No Professional Preference

```json
{
  "salon_id": 1,
  "service_id": [5, 7, 12],
  "profession_id": [0, 0, 0],
  "time": "10:00 AM, 2025-12-16",
  "total_price": 150.00,
  "payment_status": true
}
```

**Description**: User doesn't care which professional provides the services (all profession_id = 0).

---

### 3. Booking with Mixed Professional Preference

```json
{
  "salon_id": 1,
  "service_id": [5, 7, 12],
  "profession_id": [3, 0, 8],
  "time": "03:45 PM, 2025-12-17",
  "total_price": 175.50,
  "payment_status": false
}
```

**Description**: Specific professional for services 5 and 12, no preference for service 7. Online payment.

---

### 4. Booking with Online Payment

```json
{
  "salon_id": 1,
  "service_id": [5, 7],
  "profession_id": [3, 3],
  "time": "11:30 AM, 2025-12-18",
  "total_price": 120.00,
  "payment_status": false,
  "booking_type": "appointment"
}
```

**Description**: Online payment (payment_status = false).

---

### 5. Walk-in Booking

```json
{
  "salon_id": 1,
  "service_id": [5],
  "profession_id": [3],
  "time": "09:00 AM, 2025-12-19",
  "total_price": 50.00,
  "payment_status": true,
  "booking_type": "walk-in"
}
```

**Description**: Walk-in customer booking.

---

### 6. Booking with Loyalty Points

```json
{
  "salon_id": 1,
  "service_id": [5, 7, 12],
  "profession_id": [3, 0, 4],
  "time": "02:00 PM, 2025-12-20",
  "total_price": 200.00,
  "payment_status": false,
  "booking_type": "appointment",
  "loyalty_points_used": 20
}
```

**Description**: Using 20 loyalty points for discount. Final price will be 180.00.

---

### 7. Booking with Single Deal

```json
{
  "salon_id": 1,
  "service_id": [5, 7],
  "profession_id": [3, 3],
  "time": "04:15 PM, 2025-12-21",
  "total_price": 90.00,
  "payment_status": true,
  "deal_id": 5
}
```

**Description**: Booking includes a deal (single deal ID).

---

### 8. Booking with Multiple Deals

```json
{
  "salon_id": 1,
  "service_id": [5, 7],
  "profession_id": [3, 3],
  "time": "01:30 PM, 2025-12-22",
  "total_price": 130.00,
  "payment_status": false,
  "deal_id": [5, 7]
}
```

**Description**: Booking includes multiple deals (array of deal IDs).

---

### 9. Booking with Service Quantities

```json
{
  "salon_id": 1,
  "service_id": [5, 7, 12],
  "profession_id": [3, 3, 0],
  "time": "05:00 PM, 2025-12-23",
  "total_price": 250.00,
  "payment_status": true,
  "qty": {
    "5": 1,
    "7": 2,
    "12": 1
  }
}
```

**Description**: Service 7 is booked twice (quantity = 2).

---

### 10. Booking with Service Variations

```json
{
  "salon_id": 1,
  "service_id": [5, 7, 12],
  "profession_id": [3, 3, 0],
  "time": "12:00 PM, 2025-12-24",
  "total_price": 180.00,
  "payment_status": false,
  "variation": {
    "5": 1,
    "7": 3,
    "12": 2
  }
}
```

**Description**: Each service has a specific variation selected.

---

### 11. Complete Booking (All Optional Fields)

```json
{
  "salon_id": 1,
  "service_id": [5, 7, 12],
  "profession_id": [3, 3, 0],
  "time": "03:30 PM, 2025-12-25",
  "total_price": 300.00,
  "payment_status": false,
  "booking_type": "appointment",
  "loyalty_points_used": 30,
  "deal_id": 5,
  "qty": {
    "5": 1,
    "7": 2,
    "12": 1
  },
  "variation": {
    "5": 1,
    "7": 3,
    "12": 2
  }
}
```

**Description**: All possible fields included.

---

### 12. Morning Appointment

```json
{
  "salon_id": 2,
  "service_id": [8, 9],
  "profession_id": [5, 5],
  "time": "08:00 AM, 2025-12-26",
  "total_price": 85.00,
  "payment_status": true
}
```

**Description**: Early morning appointment.

---

### 13. Evening Appointment

```json
{
  "salon_id": 2,
  "service_id": [8, 9, 10],
  "profession_id": [5, 6, 7],
  "time": "07:30 PM, 2025-12-27",
  "total_price": 145.00,
  "payment_status": false
}
```

**Description**: Evening appointment with multiple professionals.

---

### 14. Weekend Booking

```json
{
  "salon_id": 3,
  "service_id": [15, 16],
  "profession_id": [10, 10],
  "time": "11:00 AM, 2025-12-28",
  "total_price": 110.00,
  "payment_status": true,
  "booking_type": "appointment"
}
```

**Description**: Weekend booking (Saturday).

---

### 15. Single Service Booking

```json
{
  "salon_id": 1,
  "service_id": [5],
  "profession_id": [3],
  "time": "02:15 PM, 2025-12-29",
  "total_price": 50.00,
  "payment_status": true
}
```

**Description**: Booking for just one service.

---

### 16. Premium Services Package

```json
{
  "salon_id": 1,
  "service_id": [20, 21, 22, 23],
  "profession_id": [8, 8, 9, 9],
  "time": "10:30 AM, 2025-12-30",
  "total_price": 450.00,
  "payment_status": false,
  "loyalty_points_used": 50,
  "qty": {
    "20": 1,
    "21": 1,
    "22": 1,
    "23": 1
  }
}
```

**Description**: Multiple premium services with loyalty points discount.

---

### 17. Noon Appointment

```json
{
  "salon_id": 4,
  "service_id": [12, 13],
  "profession_id": [6, 6],
  "time": "12:30 PM, 2025-12-31",
  "total_price": 95.00,
  "payment_status": true
}
```

**Description**: Midday appointment.

---

### 18. New Year Booking

```json
{
  "salon_id": 1,
  "service_id": [5, 7, 12, 15],
  "profession_id": [3, 3, 4, 4],
  "time": "09:30 AM, 2026-01-01",
  "total_price": 280.00,
  "payment_status": false,
  "booking_type": "appointment",
  "loyalty_points_used": 25,
  "deal_id": 8
}
```

**Description**: Special New Year booking with deal and loyalty points.

---

### 19. Quick Service Booking

```json
{
  "salon_id": 2,
  "service_id": [25],
  "profession_id": [0],
  "time": "04:00 PM, 2026-01-02",
  "total_price": 35.00,
  "payment_status": true,
  "booking_type": "walk-in"
}
```

**Description**: Quick walk-in service.

---

### 20. Couple's Booking

```json
{
  "salon_id": 3,
  "service_id": [30, 31, 32, 33],
  "profession_id": [12, 12, 13, 13],
  "time": "06:00 PM, 2026-01-03",
  "total_price": 350.00,
  "payment_status": false,
  "qty": {
    "30": 2,
    "31": 2,
    "32": 2,
    "33": 2
  }
}
```

**Description**: Services for two people (quantity = 2 for each service).

---

## Postman Collection JSON

Complete Postman Collection you can import:

```json
{
  "info": {
    "name": "BookMySpot - Create Booking API",
    "description": "Collection for testing create-booking endpoint with various scenarios",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "1. Basic Booking",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          },
          {
            "key": "Accept",
            "value": "application/json"
          },
          {
            "key": "Authorization",
            "value": "Bearer {{access_token}}"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"salon_id\": 1,\n  \"service_id\": [5, 7],\n  \"profession_id\": [3, 3],\n  \"time\": \"02:30 PM, 2025-12-15\",\n  \"total_price\": 100.00,\n  \"payment_status\": true\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/create-booking",
          "host": [
            "{{base_url}}"
          ],
          "path": [
            "api",
            "create-booking"
          ]
        }
      }
    },
    {
      "name": "2. Booking with No Professional Preference",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          },
          {
            "key": "Accept",
            "value": "application/json"
          },
          {
            "key": "Authorization",
            "value": "Bearer {{access_token}}"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"salon_id\": 1,\n  \"service_id\": [5, 7, 12],\n  \"profession_id\": [0, 0, 0],\n  \"time\": \"10:00 AM, 2025-12-16\",\n  \"total_price\": 150.00,\n  \"payment_status\": true\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/create-booking",
          "host": [
            "{{base_url}}"
          ],
          "path": [
            "api",
            "create-booking"
          ]
        }
      }
    },
    {
      "name": "3. Booking with Loyalty Points",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          },
          {
            "key": "Accept",
            "value": "application/json"
          },
          {
            "key": "Authorization",
            "value": "Bearer {{access_token}}"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"salon_id\": 1,\n  \"service_id\": [5, 7, 12],\n  \"profession_id\": [3, 0, 4],\n  \"time\": \"02:00 PM, 2025-12-20\",\n  \"total_price\": 200.00,\n  \"payment_status\": false,\n  \"booking_type\": \"appointment\",\n  \"loyalty_points_used\": 20\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/create-booking",
          "host": [
            "{{base_url}}"
          ],
          "path": [
            "api",
            "create-booking"
          ]
        }
      }
    },
    {
      "name": "4. Booking with Deal",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          },
          {
            "key": "Accept",
            "value": "application/json"
          },
          {
            "key": "Authorization",
            "value": "Bearer {{access_token}}"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"salon_id\": 1,\n  \"service_id\": [5, 7],\n  \"profession_id\": [3, 3],\n  \"time\": \"04:15 PM, 2025-12-21\",\n  \"total_price\": 90.00,\n  \"payment_status\": true,\n  \"deal_id\": 5\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/create-booking",
          "host": [
            "{{base_url}}"
          ],
          "path": [
            "api",
            "create-booking"
          ]
        }
      }
    },
    {
      "name": "5. Complete Booking (All Fields)",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          },
          {
            "key": "Accept",
            "value": "application/json"
          },
          {
            "key": "Authorization",
            "value": "Bearer {{access_token}}"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"salon_id\": 1,\n  \"service_id\": [5, 7, 12],\n  \"profession_id\": [3, 3, 0],\n  \"time\": \"03:30 PM, 2025-12-25\",\n  \"total_price\": 300.00,\n  \"payment_status\": false,\n  \"booking_type\": \"appointment\",\n  \"loyalty_points_used\": 30,\n  \"deal_id\": 5,\n  \"qty\": {\n    \"5\": 1,\n    \"7\": 2,\n    \"12\": 1\n  },\n  \"variation\": {\n    \"5\": 1,\n    \"7\": 3,\n    \"12\": 2\n  }\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/create-booking",
          "host": [
            "{{base_url}}"
          ],
          "path": [
            "api",
            "create-booking"
          ]
        }
      }
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:8000"
    },
    {
      "key": "access_token",
      "value": "your_token_here"
    }
  ]
}
```

---

## Quick Copy-Paste Payloads

### Minimal (Copy & Edit)
```json
{"salon_id":1,"service_id":[5],"profession_id":[3],"time":"02:30 PM, 2025-12-15","total_price":50.00,"payment_status":true}
```

### With Loyalty Points (Copy & Edit)
```json
{"salon_id":1,"service_id":[5,7],"profession_id":[3,3],"time":"02:30 PM, 2025-12-15","total_price":100.00,"payment_status":false,"loyalty_points_used":10}
```

### With Everything (Copy & Edit)
```json
{"salon_id":1,"service_id":[5,7,12],"profession_id":[3,3,0],"time":"03:30 PM, 2025-12-25","total_price":300.00,"payment_status":false,"booking_type":"appointment","loyalty_points_used":30,"deal_id":5,"qty":{"5":1,"7":2,"12":1},"variation":{"5":1,"7":3,"12":2}}
```

---

## Testing Tips

### 1. Time Format Testing
Test different time formats:
- `"09:00 AM, 2025-12-15"` ✅ Valid
- `"09:30 AM, 2025-12-15"` ✅ Valid
- `"12:00 PM, 2025-12-15"` ✅ Valid (noon)
- `"12:30 PM, 2025-12-15"` ✅ Valid
- `"11:59 PM, 2025-12-15"` ✅ Valid

### 2. Date Testing
- Past dates should be rejected
- Very far future dates (>90 days) might be rejected depending on salon settings
- Weekend dates may have different availability

### 3. Edge Cases to Test

**Invalid Profession/Service Count**:
```json
{
  "salon_id": 1,
  "service_id": [5, 7, 12],
  "profession_id": [3, 3],
  "time": "02:30 PM, 2025-12-15",
  "total_price": 150.00,
  "payment_status": true
}
```
❌ Should fail - mismatched array lengths

**Insufficient Loyalty Points**:
```json
{
  "salon_id": 1,
  "service_id": [5],
  "profession_id": [3],
  "time": "02:30 PM, 2025-12-15",
  "total_price": 50.00,
  "payment_status": true,
  "loyalty_points_used": 1000
}
```
❌ Should fail if user doesn't have 1000 points

**Invalid Salon ID**:
```json
{
  "salon_id": 99999,
  "service_id": [5],
  "profession_id": [3],
  "time": "02:30 PM, 2025-12-15",
  "total_price": 50.00,
  "payment_status": true
}
```
❌ Should fail - salon doesn't exist

---

## Expected Success Response

```json
{
  "success": true,
  "message": "Booking created successfully!",
  "data": {
    "id": 123,
    "salon_id": 1,
    "user_id": 45,
    "team_id": 3,
    "date": "2025-12-15",
    "time": "14:30:00",
    "payment_method": "cash",
    "payment": 100.00,
    "payment_status": "pending",
    "status": "booked",
    "booking_type": "appointment",
    "commission": 10.00,
    "used_loyalty_points": 0,
    "created_at": "2025-12-10T10:30:00.000000Z",
    "updated_at": "2025-12-10T10:30:00.000000Z"
  }
}
```

---

## Common Error Responses

### Profile Incomplete (422)
```json
{
  "success": false,
  "message": "Please complete your profile before booking.\nWould you like to complete it now?"
}
```

### Invalid Salon (422)
```json
{
  "success": false,
  "message": "Invalid salon"
}
```

### Unauthorized (401)
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

### Validation Error (422)
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "service_id": ["The service id field is required."],
    "time": ["The time field is required."]
  }
}
```

---

## Import Instructions

### To Import Postman Collection:

1. Open Postman
2. Click **Import** button (top left)
3. Select **Raw Text** tab
4. Copy the entire Postman Collection JSON from above
5. Paste and click **Continue**
6. Click **Import**

### To Set Environment Variables:

1. Click the **Environments** tab (left sidebar)
2. Click **+** to create new environment
3. Name it "BookMySpot Local" or similar
4. Add variables:
   - `base_url`: `http://localhost:8000`
   - `access_token`: (paste your actual token after login)
5. Click **Save**
6. Select this environment from dropdown (top right)

---

**Last Updated**: December 10, 2025
