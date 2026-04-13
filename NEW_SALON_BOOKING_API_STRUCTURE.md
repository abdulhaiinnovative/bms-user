# New Salon Booking API Structure

**Document Version:** 1.0  
**Date:** December 18, 2025  
**Purpose:** Complete API restructuring for salon booking flow

---

## Table of Contents

1. [Overview](#overview)
2. [Current API Structure Analysis](#current-api-structure-analysis)
3. [Proposed New API Structure](#proposed-new-api-structure)
4. [Detailed API Specifications](#detailed-api-specifications)
5. [Migration Strategy](#migration-strategy)
6. [Benefits of New Structure](#benefits-of-new-structure)

---

## Overview

### Current State

The booking flow currently uses multiple separate APIs and requires complex client-side logic:

- `/api/salons/{id}` - Get salon details (with ALL data)
- `/api/salons/{id}/services/{categoryId}` - Get services by category
- `/api/salons/{id}/staff` - Get staff members
- `/api/salons/{id}/deals` - Get deals
- `/api/create-booking` - Create booking (complex payload)

### Proposed State

Streamlined APIs that follow the natural booking flow:

- `/api/booking/salon/{id}/overview` - Initial salon info
- `/api/booking/salon/{id}/services` - Services with availability context
- `/api/booking/professionals/available` - Available professionals for selected services
- `/api/booking/slots/available` - Available time slots
- `/api/booking/create` - Simplified booking creation
- `/api/booking/{id}/details` - Booking details

---

## Current API Structure Analysis

### Problems Identified

1. **Salon Detail API** (`/api/salons/{id}`)

   - ❌ Returns ALL data at once (services, staff, deals, reviews, etc.)
   - ❌ Not optimized for booking flow
   - ❌ Over-fetching data user doesn't need initially
   - ❌ No availability information
   - ❌ Large response size (slow on mobile)

2. **Services API** (`/api/salons/{id}/services/{categoryId}`)

   - ✅ Good pagination support
   - ❌ Includes professional data that might not be available
   - ❌ No real-time availability check
   - ❌ Missing service combinations/packages

3. **Staff API** (`/api/salons/{id}/staff`)

   - ✅ Paginated
   - ❌ Shows ALL staff (even unavailable ones)
   - ❌ No filtering by service capability
   - ❌ No time slot information
   - ❌ Requires client-side availability calculation

4. **Create Booking API** (`/api/create-booking`)
   - ❌ Complex payload structure
   - ❌ Time format requires special formatting (`'14:30', '2025-12-08'`)
   - ❌ Separate arrays for services and professionals (easy to mismatch)
   - ❌ No validation before final submission
   - ❌ Doesn't return available alternatives if slot is taken

---

## Proposed New API Structure

### Booking Flow Sequence

```
Step 1: Browse Salon → /api/booking/salon/{id}/overview
Step 2: Select Services → /api/booking/salon/{id}/services
Step 3: Select Professional → /api/booking/professionals/available
Step 4: Select Date & Time → /api/booking/slots/available
Step 5: Confirm Booking → /api/booking/validate (optional pre-check)
Step 6: Create Booking → /api/booking/create
Step 7: View Booking → /api/booking/{id}/details
```

---

## Detailed API Specifications

### 1. Get Salon Overview (Step 1)

**Purpose:** Provide essential salon information for booking initiation

```
GET /api/booking/salon/{salonId}/overview
```

**Response:**

```json
{
  "success": true,
  "message": "Salon overview retrieved successfully",
  "data": {
    "salon": {
      "id": 1,
      "name": "Premium Salon & Spa",
      "logo": "https://example.com/logo.jpg",
      "images": ["url1.jpg", "url2.jpg"],
      "rating": 4.5,
      "review_count": 125,
      "is_favourite": false,
      "location": {
        "address": "123 Main St, Gulberg, Lahore",
        "city": "Lahore",
        "area": "Gulberg",
        "lat": "31.5204",
        "long": "74.3587"
      },
      "contact": {
        "phone": "+92 300 1234567",
        "facebook": "https://facebook.com/salon",
        "instagram": "https://instagram.com/salon"
      },
      "info": {
        "gender": "unisex",
        "type": "Salon",
        "kind": "Premium",
        "about": "Professional salon services...",
        "policy": "Cancellation policy..."
      },
      "working_hours": [
        {
          "day": "Monday",
          "open_time": "09:00",
          "close_time": "21:00",
          "is_open": true
        }
      ],
      "availability": {
        "accepts_bookings": true,
        "earliest_available": "2025-12-18",
        "average_wait_time": "15 minutes"
      }
    }
  }
}
```

---

### 2. Get Services with Booking Context (Step 2)

**Purpose:** Get services optimized for booking with availability info

```
GET /api/booking/salon/{salonId}/services
```

**Query Parameters:**

- `category_id` (optional) - Filter by category
- `gender` (optional) - Filter by gender (male/female/unisex)
- `min_price` (optional) - Minimum price filter
- `max_price` (optional) - Maximum price filter
- `available_on` (optional) - Date to check availability (YYYY-MM-DD)
- `page` (optional, default: 1)
- `per_page` (optional, default: 20)

**Response:**

```json
{
  "success": true,
  "message": "Services retrieved successfully",
  "data": {
    "categories": [
      {
        "id": 1,
        "name": "Hair Services",
        "icon": "hair_icon.png",
        "service_count": 15
      }
    ],
    "services": {
      "current_page": 1,
      "data": [
        {
          "id": 5,
          "name": "Men's Haircut",
          "description": "Professional men's haircut",
          "short_description": "Haircut for men",
          "duration": 30,
          "duration_formatted": "30 minutes",
          "price": 150.0,
          "discounted_price": 135.0,
          "discount": {
            "type": "percentage",
            "value": 10,
            "amount": 15.0
          },
          "category": {
            "id": 1,
            "name": "Hair Services"
          },
          "gender": "male",
          "is_featured": false,
          "availability": {
            "is_available": true,
            "available_professionals_count": 3,
            "next_available_slot": "2025-12-18 10:00:00"
          },
          "tags": ["popular", "quick-service"]
        }
      ],
      "pagination": {
        "current_page": 1,
        "per_page": 20,
        "total": 45,
        "last_page": 3,
        "from": 1,
        "to": 20
      }
    },
    "deals": [
      {
        "id": 1,
        "name": "Weekend Special Package",
        "price": 1200.0,
        "discounted_price": 1000.0,
        "discount": {
          "type": "percentage",
          "value": 16.67
        },
        "image": "deal_image.jpg",
        "valid_until": "2026-01-31",
        "service_ids": [5, 7, 12],
        "services": [
          {
            "id": 5,
            "name": "Men's Haircut"
          }
        ]
      }
    ]
  }
}
```

---

### 3. Get Available Professionals (Step 3)

**Purpose:** Get professionals who can perform selected services

```
POST /api/booking/professionals/available
```

**Request Body:**

```json
{
  "salon_id": 1,
  "service_ids": [5, 7, 12],
  "date": "2025-12-18",
  "preferred_time": "14:00"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Available professionals retrieved",
  "data": {
    "professionals": [
      {
        "id": 3,
        "name": "Zaeem Altaf",
        "first_name": "Zaeem",
        "last_name": "Altaf",
        "image": "professional_photo.jpg",
        "experience": "5 years",
        "rating": 4.8,
        "review_count": 89,
        "specialties": ["Hair Cutting", "Styling", "Coloring"],
        "can_provide_all_services": true,
        "service_coverage": {
          "5": true,
          "7": true,
          "12": false
        },
        "availability": {
          "is_available": true,
          "next_available_slot": "2025-12-18 14:00:00",
          "available_slots_count": 8,
          "busy_until": null
        },
        "working_hours": {
          "monday": { "start": "09:00", "end": "18:00" },
          "tuesday": { "start": "09:00", "end": "18:00" }
        }
      },
      {
        "id": 0,
        "name": "No Preference",
        "description": "Let the salon assign any available professional",
        "is_placeholder": true,
        "availability": {
          "is_available": true,
          "available_professionals_count": 5
        }
      }
    ],
    "recommendations": {
      "most_booked": 3,
      "highest_rated": 3,
      "fastest_available": 5
    }
  }
}
```

---

### 4. Get Available Time Slots (Step 4)

**Purpose:** Get available time slots for selected date and professional

```
POST /api/booking/slots/available
```

**Request Body:**

```json
{
  "salon_id": 1,
  "professional_id": 3,
  "service_ids": [5, 7],
  "date": "2025-12-18"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Available slots retrieved",
  "data": {
    "date": "2025-12-18",
    "salon_hours": {
      "open": "09:00",
      "close": "21:00"
    },
    "total_duration": 60,
    "slots": [
      {
        "time": "09:00",
        "formatted": "9:00 AM",
        "is_available": true,
        "can_accommodate_all_services": true,
        "professional_available": true,
        "end_time": "10:00",
        "confidence": "high"
      },
      {
        "time": "09:30",
        "formatted": "9:30 AM",
        "is_available": true,
        "can_accommodate_all_services": true,
        "professional_available": true,
        "end_time": "10:30",
        "confidence": "high"
      },
      {
        "time": "10:00",
        "formatted": "10:00 AM",
        "is_available": false,
        "reason": "Professional has booking",
        "next_available": "10:30"
      }
    ],
    "summary": {
      "total_slots": 24,
      "available_slots": 18,
      "next_available": "09:00",
      "recommended_times": ["09:00", "14:00", "16:00"]
    }
  }
}
```

---

### 5. Validate Booking (Step 5 - Optional Pre-check)

**Purpose:** Validate booking before final creation (prevent errors)

```
POST /api/booking/validate
```

**Request Body:**

```json
{
  "salon_id": 1,
  "services": [
    {
      "service_id": 5,
      "professional_id": 3,
      "quantity": 1
    },
    {
      "service_id": 7,
      "professional_id": 3,
      "quantity": 1
    }
  ],
  "date": "2025-12-18",
  "time": "14:00",
  "payment_method": "cash"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Booking is valid",
  "data": {
    "is_valid": true,
    "total_price": 285.0,
    "total_duration": 60,
    "estimated_end_time": "15:00",
    "warnings": [],
    "price_breakdown": {
      "subtotal": 300.0,
      "discount": 15.0,
      "total": 285.0
    }
  }
}
```

**Error Response (if invalid):**

```json
{
  "success": false,
  "message": "Booking validation failed",
  "data": {
    "is_valid": false,
    "errors": [
      {
        "code": "SLOT_UNAVAILABLE",
        "message": "Selected time slot is no longer available",
        "field": "time",
        "suggestions": [
          {
            "time": "14:30",
            "professional_id": 3
          },
          {
            "time": "15:00",
            "professional_id": 5
          }
        ]
      }
    ]
  }
}
```

---

### 6. Create Booking (Step 6)

**Purpose:** Create the final booking

```
POST /api/booking/create
```

**Request Body (Simplified):**

```json
{
  "salon_id": 1,
  "booking_date": "2025-12-18",
  "booking_time": "14:00",
  "services": [
    {
      "service_id": 5,
      "professional_id": 3,
      "quantity": 1,
      "variation_id": null
    },
    {
      "service_id": 7,
      "professional_id": 3,
      "quantity": 1,
      "variation_id": null
    }
  ],
  "payment": {
    "method": "cash",
    "total_amount": 285.0
  },
  "booking_type": "appointment",
  "special_notes": "Please be ready on time",
  "loyalty_points_to_use": 0,
  "deal_id": null
}
```

**Response:**

```json
{
  "success": true,
  "message": "Booking created successfully!",
  "data": {
    "booking": {
      "id": 123,
      "booking_number": "BMS-2025-123",
      "status": "confirmed",
      "salon": {
        "id": 1,
        "name": "Premium Salon & Spa",
        "phone": "+92 300 1234567",
        "address": "123 Main St, Gulberg, Lahore"
      },
      "appointment": {
        "date": "2025-12-18",
        "date_formatted": "Wednesday, Dec 18, 2025",
        "time": "14:00",
        "time_formatted": "2:00 PM",
        "end_time": "15:00",
        "end_time_formatted": "3:00 PM",
        "duration": 60
      },
      "services": [
        {
          "id": 5,
          "name": "Men's Haircut",
          "duration": 30,
          "price": 135.0,
          "quantity": 1,
          "professional": {
            "id": 3,
            "name": "Zaeem Altaf",
            "image": "photo.jpg"
          }
        }
      ],
      "payment": {
        "method": "cash",
        "status": "pending",
        "total": 285.0,
        "subtotal": 300.0,
        "discount": 15.0,
        "loyalty_points_earned": 28
      },
      "customer": {
        "id": 45,
        "name": "John Doe",
        "phone": "+92 300 9876543",
        "email": "john@example.com"
      },
      "special_notes": "Please be ready on time",
      "created_at": "2025-12-18T10:30:00Z"
    },
    "next_steps": [
      "You will receive a confirmation SMS shortly",
      "Arrive 10 minutes before your appointment",
      "You can cancel free of charge up to 2 hours before"
    ]
  }
}
```

---

### 7. Get Booking Details (Step 7)

**Purpose:** Retrieve full booking information

```
GET /api/booking/{bookingId}/details
```

**Response:**

```json
{
  "success": true,
  "message": "Booking details retrieved",
  "data": {
    "booking": {
      "id": 123,
      "booking_number": "BMS-2025-123",
      "status": "confirmed",
      "can_cancel": true,
      "can_reschedule": true,
      "salon": {
        "id": 1,
        "name": "Premium Salon & Spa",
        "logo": "logo.jpg",
        "phone": "+92 300 1234567",
        "address": "123 Main St, Gulberg, Lahore",
        "location": {
          "lat": "31.5204",
          "long": "74.3587"
        }
      },
      "appointment": {
        "date": "2025-12-18",
        "date_formatted": "Wednesday, Dec 18, 2025",
        "time": "14:00",
        "time_formatted": "2:00 PM",
        "end_time": "15:00",
        "end_time_formatted": "3:00 PM",
        "duration": 60,
        "time_until_appointment": "2 hours"
      },
      "services": [
        {
          "id": 5,
          "name": "Men's Haircut",
          "description": "Professional haircut",
          "duration": 30,
          "price": 135.0,
          "quantity": 1,
          "professional": {
            "id": 3,
            "name": "Zaeem Altaf",
            "image": "photo.jpg",
            "rating": 4.8
          }
        }
      ],
      "payment": {
        "method": "cash",
        "status": "pending",
        "total": 285.0,
        "subtotal": 300.0,
        "discount": 15.0,
        "breakdown": {
          "services_total": 300.0,
          "discount_applied": -15.0,
          "loyalty_points_discount": 0.0,
          "final_total": 285.0
        }
      },
      "timeline": [
        {
          "status": "created",
          "timestamp": "2025-12-18T10:30:00Z",
          "description": "Booking created"
        },
        {
          "status": "confirmed",
          "timestamp": "2025-12-18T10:31:00Z",
          "description": "Booking confirmed by salon"
        }
      ],
      "policies": {
        "cancellation": "Free cancellation up to 2 hours before",
        "reschedule": "Can reschedule once free of charge",
        "no_show": "No-show fee: 50% of booking amount"
      },
      "created_at": "2025-12-18T10:30:00Z",
      "updated_at": "2025-12-18T10:31:00Z"
    }
  }
}
```

---

## Additional Helper APIs

### 8. Get Service Categories

```
GET /api/booking/categories
```

**Response:**

```json
{
  "success": true,
  "data": {
    "categories": [
      {
        "id": 1,
        "name": "Hair Services",
        "icon": "hair_icon.png",
        "service_count": 15,
        "popular": true
      }
    ]
  }
}
```

---

### 9. Cancel Booking

```
POST /api/booking/{bookingId}/cancel
```

**Request:**

```json
{
  "reason": "Schedule conflict",
  "cancel_reason_id": 2
}
```

**Response:**

```json
{
  "success": true,
  "message": "Booking cancelled successfully",
  "data": {
    "booking_id": 123,
    "status": "cancelled",
    "refund_amount": 285.0,
    "refund_method": "original_payment_method"
  }
}
```

---

### 10. Reschedule Booking

```
POST /api/booking/{bookingId}/reschedule
```

**Request:**

```json
{
  "new_date": "2025-12-20",
  "new_time": "15:00",
  "keep_professional": true
}
```

---

## Benefits of New Structure

### 1. Performance

- ✅ Smaller, focused responses
- ✅ Only fetch data when needed
- ✅ Better caching opportunities
- ✅ Faster page loads

### 2. User Experience

- ✅ Step-by-step guidance
- ✅ Real-time availability checks
- ✅ Better error prevention
- ✅ Helpful suggestions

### 3. Developer Experience

- ✅ Simpler request/response format
- ✅ Clear API naming convention
- ✅ Consistent error handling
- ✅ Better documentation

### 4. Business Logic

- ✅ Centralized availability logic on server
- ✅ Accurate booking validation
- ✅ Prevents double bookings
- ✅ Better analytics potential

---

## Migration Strategy

### Phase 1: Implement New APIs (Week 1-2)

1. Create new booking endpoints
2. Keep old endpoints running
3. Add feature flags

### Phase 2: Update Flutter App (Week 3-4)

1. Update booking flow to use new APIs
2. Test thoroughly
3. Gradual rollout (10% → 50% → 100%)

### Phase 3: Deprecate Old APIs (Week 5-6)

1. Monitor usage of old endpoints
2. Send deprecation notices
3. Remove old endpoints

---

## Comparison: Old vs New

| Aspect                     | Old Structure                 | New Structure                      |
| -------------------------- | ----------------------------- | ---------------------------------- |
| **Initial Load**           | 1 large API call              | 1 small API call                   |
| **Response Size**          | ~500KB                        | ~50KB                              |
| **Booking Steps**          | 4 screens, 1 final API        | 4 screens, validation at each step |
| **Error Prevention**       | Client-side only              | Server validates at each step      |
| **Time Format**            | `'14:30', '2025-12-08'`       | `"14:00"` and `"2025-12-08"`       |
| **Professional Selection** | Separate arrays (error-prone) | Embedded in service object         |
| **Availability Check**     | Client calculates             | Server provides real-time data     |
| **Booking Validation**     | Only on final submit          | Pre-validate before submit         |

---

## Error Code Standards

All APIs will use consistent error codes:

| Code                       | Description                              |
| -------------------------- | ---------------------------------------- |
| `SALON_NOT_FOUND`          | Salon ID doesn't exist                   |
| `SERVICE_NOT_FOUND`        | Service ID doesn't exist                 |
| `PROFESSIONAL_NOT_FOUND`   | Professional ID doesn't exist            |
| `SLOT_UNAVAILABLE`         | Time slot is no longer available         |
| `PROFESSIONAL_UNAVAILABLE` | Professional not available at that time  |
| `INVALID_DATE`             | Date is in the past or too far in future |
| `INVALID_TIME`             | Time is outside salon hours              |
| `INSUFFICIENT_BALANCE`     | Not enough loyalty points                |
| `BOOKING_LIMIT_REACHED`    | User has too many pending bookings       |
| `PROFILE_INCOMPLETE`       | User profile needs completion            |

---

**End of Document**
