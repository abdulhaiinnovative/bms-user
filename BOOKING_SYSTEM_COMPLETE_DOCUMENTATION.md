# 📋 Booking System Complete Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Bookings List (My Bookings)](#bookings-list-my-bookings)
4. [Booking Details](#booking-details)
5. [Create Booking](#create-booking)
6. [API Endpoints](#api-endpoints)
7. [Data Models](#data-models)
8. [UI Components](#ui-components)
9. [State Management](#state-management)
10. [User Flow](#user-flow)

---

## Overview

The Booking System is a comprehensive feature that allows users to:
- **View all their bookings** (upcoming, past, and all)
- **See detailed information** about individual bookings
- **Create new bookings** with services, deals, and memberships
- **Cancel bookings** (when allowed)
- **Leave reviews** after service completion

### Key Features
✅ Paginated booking list with infinite scroll  
✅ Tab-based filtering (All, Upcoming, Past)  
✅ Pull-to-refresh functionality  
✅ Detailed booking information with salon details  
✅ Support for services, deals, and memberships  
✅ Review display and management  
✅ Payment status tracking  
✅ Cancellation functionality  

---

## Architecture

### Layer Structure
```
┌─────────────────────────────────────────────────────┐
│              Presentation Layer                      │
│  ┌──────────────────┐  ┌────────────────────────┐  │
│  │  My Bookings     │  │  Booking Details       │  │
│  │  Screen          │  │  Screen                │  │
│  └────────┬─────────┘  └──────────┬─────────────┘  │
│           │                        │                 │
│           ▼                        ▼                 │
│  ┌────────────────────────────────────────────┐    │
│  │      BookingsViewModel                     │    │
│  └────────────────┬───────────────────────────┘    │
└───────────────────┼────────────────────────────────┘
                    │
┌───────────────────▼────────────────────────────────┐
│               Data Layer                            │
│  ┌─────────────────────┐  ┌─────────────────────┐ │
│  │  BookingsRepository │  │  BookingDetailAPI   │ │
│  └─────────┬───────────┘  └──────────┬──────────┘ │
│            │                          │             │
│            ▼                          ▼             │
│  ┌─────────────────────┐  ┌─────────────────────┐ │
│  │  MyBookingsAPI      │  │  BookingService     │ │
│  └─────────┬───────────┘  └──────────┬──────────┘ │
└────────────┼──────────────────────────┼────────────┘
             │                          │
             ▼                          ▼
    ┌────────────────────────────────────────────┐
    │      ProtectedHttpClient                   │
    │      (Handles Authentication)              │
    └────────────────────────────────────────────┘
```

---

## Bookings List (My Bookings)

### 📱 Screen: `my_bookings.dart`
**Route:** `/my-bookings`

### What User Sees

#### Tab Structure
1. **All Tab** - Shows all bookings regardless of status
2. **Upcoming Tab** - Shows only future booked appointments
3. **Past Tab** - Shows completed, cancelled, or past bookings

#### Booking Card Display

Each booking card shows:

```
┌───────────────────────────────────────────────┐
│ 🏪 [Salon Logo]  Salon Name                  │
│                   📍 Address                   │
├───────────────────────────────────────────────┤
│ [STATUS BADGE]             ID: #12345         │
├───────────────────────────────────────────────┤
│ ✂️  Service Booked                            │
│     Haircut & Beard Trim                      │
├───────────────────────────────────────────────┤
│ 📅 DATE         ⏰ TIME                        │
│   Dec 24, 2025    10:30 AM                    │
├───────────────────────────────────────────────┤
│ 💳 PAYMENT      📋 TYPE                        │
│   Paid           Appointment                  │
└───────────────────────────────────────────────┘
```

### What Comes from API

**Endpoint:** `GET /api/appointments?page={page}`

**Response Structure:**
```json
{
  "status": true,
  "message": "Success",
  "response": {
    "data": {
      "current_page": 1,
      "data": [
        {
          "id": 123,
          "title": "Haircut & Beard Trim",
          "salon_id": 45,
          "user_id": 67,
          "team_id": null,
          "date": "2025-12-24",
          "time": "10:30:00",
          "payment_method": "Cash",
          "payment": 1500,
          "commission": 150,
          "payment_status": "paid",
          "booking_type": "appointment",
          "status": "booked",
          "used_loyalty_points": 0,
          "salon": {
            "id": 45,
            "name": "Elite Salon & Spa",
            "logo": "https://example.com/salon-logo.jpg",
            "address": "123 Main Street, Karachi",
            "average_rating": 4.5,
            "review_count": 120
          }
        }
      ],
      "first_page_url": "https://api.example.com/appointments?page=1",
      "from": 1,
      "last_page": 5,
      "last_page_url": "https://api.example.com/appointments?page=5",
      "links": [...],
      "next_page_url": "https://api.example.com/appointments?page=2",
      "path": "https://api.example.com/appointments",
      "per_page": 12,
      "prev_page_url": null,
      "to": 12,
      "total": 56
    }
  }
}
```

### API to UI Mapping

| API Field | UI Display | Location | Transformation |
|-----------|------------|----------|----------------|
| `salon.name` | Salon Name | Card Header | Direct display |
| `salon.logo` | Salon Logo | Card Header (Left) | Image widget with fallback |
| `salon.address` | Address | Below salon name | Direct with location icon |
| `status` | Status Badge | Below header | Uppercase + color coding |
| `id` | Booking ID | Top right | Formatted as "ID: #123" |
| `title` | Service Name | Middle section | Direct in styled container |
| `date` | Date | Bottom grid | Formatted as "MMM d, y" (e.g., "Dec 24, 2025") |
| `time` | Time | Bottom grid | Converted from "HH:mm:ss" to "h:mm a" (e.g., "10:30 AM") |
| `payment_status` | Payment Status | Bottom grid | Capitalized (hidden if cancelled) |
| `booking_type` | Type | Bottom grid | Capitalized |

### Status Color Coding

```dart
Color _getStatusColor(String? status) {
  switch (status?.toLowerCase()) {
    case 'booked':
      return Colors.green;
    case 'completed':
      return Colors.blue;
    case 'cancelled':
      return Colors.red;
    case 'pending':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
```

### Filtering Logic

**Upcoming Bookings:**
- Status must be `"booked"`
- DateTime (date + time) must be in the future

**Past Bookings:**
- Status is NOT `"booked"` OR
- DateTime (date + time) is in the past

### Pagination

- **Initial Load:** Loads page 1 with 12 items
- **Infinite Scroll:** Triggered at 90% scroll position
- **Pull-to-Refresh:** Resets to page 1
- **Loading Indicators:**
  - Shimmer placeholders for initial load
  - Circular indicator at bottom for pagination
  - RefreshIndicator for pull-to-refresh

### Empty States

**No Bookings:**
```
     🗓️
No Bookings Yet

You haven't made any salon bookings.
Explore salons and book your first appointment!

[Explore Salons Button]
```

**Error State:**
```
     ☁️ (or 🔒 for auth errors)
Oops! Something went wrong
(or Authentication Required)

[Error message]

[Try Again Button] (or [Login Button])
```

---

## Booking Details

### 📱 Screen: `booking_details_screen.dart`

### What User Sees

```
╔═══════════════════════════════════════════════╗
║              Booking Details                  ║
╠═══════════════════════════════════════════════╣
║                                               ║
║         [Salon Logo - Circle]                 ║
║            Elite Salon & Spa                  ║
║         ⭐ 4.5 (120 reviews)                  ║
║                                               ║
╠═══════════════════════════════════════════════╣
║  Booking Information                          ║
║  📅 Date: Dec 24, 2025                       ║
║  ⏰ Time: 10:30 AM                           ║
║  ✅ Status: Booked                           ║
║  📋 Type: Appointment                        ║
║  💳 Payment Method: Cash                     ║
║  🧾 Payment Status: Paid                     ║
║  💰 Amount: PKR 1500                         ║
╠═══════════════════════════════════════════════╣
║  Services (2)                                 ║
║  ┌─────────────────────────────────────┐    ║
║  │ Haircut                              │    ║
║  │ Duration: 30 min | PKR 800           │    ║
║  └─────────────────────────────────────┘    ║
║  ┌─────────────────────────────────────┐    ║
║  │ Beard Trim                           │    ║
║  │ Duration: 15 min | PKR 700           │    ║
║  └─────────────────────────────────────┘    ║
╠═══════════════════════════════════════════════╣
║  Reviews                                      ║
║  ⭐⭐⭐⭐⭐ 5.0                              ║
║  "Excellent service! Highly recommend."      ║
║  - John Doe                                   ║
╠═══════════════════════════════════════════════╣
║                                               ║
║        [Cancel Booking Button]                ║
║                                               ║
╚═══════════════════════════════════════════════╝
```

### What Comes from API

**Endpoint:** `GET /api/booking-detail/{id}`

**Response Structure:**
```json
{
  "statusCode": 200,
  "status": true,
  "message": "Booking details retrieved successfully",
  "response": {
    "data": {
      "id": 123,
      "salon_id": 45,
      "user_id": 67,
      "team_id": null,
      "date": "2025-12-24",
      "time": "10:30:00",
      "payment_method": "Cash",
      "payment": 1500.0,
      "tip": 0.0,
      "feedback": null,
      "cancel_message": null,
      "commission": 150.0,
      "booking_from": 1,
      "payment_status": "paid",
      "booking_type": "appointment",
      "status": "booked",
      "used_loyalty_points": 0,
      "kind": null,
      "CNIC": null,
      "address": null,
      "created_at": "2025-12-20T10:00:00.000000Z",
      "utilized_sessions": null,
      "membership_status": null,
      "salon": {
        "id": 45,
        "vendor_id": 12,
        "name": "Elite Salon & Spa",
        "logo": "https://example.com/salon-logo.jpg",
        "image": "https://example.com/salon-image.jpg",
        "address": "123 Main Street, Karachi",
        "latitude": "24.8607",
        "longitude": "67.0011",
        "average_rating": 4.5,
        "review_count": 120,
        "is_favourite": false,
        "active_days": [
          {
            "id": 1,
            "salon_id": 45,
            "day": "Monday",
            "opening_time": "09:00:00",
            "closing_time": "21:00:00",
            "status": 1
          }
        ],
        "images": [
          "https://example.com/image1.jpg",
          "https://example.com/image2.jpg"
        ]
      },
      "services": [
        {
          "id": 101,
          "name": "Haircut",
          "short_description": "Men's classic haircut",
          "duration": "30",
          "price": 800,
          "gender": "male",
          "pivot": {
            "booking_id": 123,
            "service_id": 101,
            "staff_id": 5,
            "quantity": 1
          },
          "staff": {
            "id": 5,
            "name": "Ahmed Ali",
            "image": "https://example.com/staff.jpg",
            "phone": "+92-300-1234567"
          }
        },
        {
          "id": 102,
          "name": "Beard Trim",
          "short_description": "Professional beard styling",
          "duration": "15",
          "price": 700,
          "gender": "male",
          "pivot": {
            "booking_id": 123,
            "service_id": 102,
            "staff_id": 5,
            "quantity": 1
          },
          "staff": {
            "id": 5,
            "name": "Ahmed Ali",
            "image": "https://example.com/staff.jpg"
          }
        }
      ],
      "deal": [],
      "membership": [],
      "review": [
        {
          "id": 456,
          "salon_id": 45,
          "user_id": 67,
          "booking_id": 123,
          "comment": "Excellent service! Highly recommend.",
          "rating": 5,
          "status": 1,
          "is_home": 0,
          "user": {
            "id": 67,
            "first_name": "John",
            "last_name": "Doe",
            "name": "John Doe",
            "email": "john@example.com",
            "image": "https://example.com/user.jpg",
            "phone": "+92-300-9876543"
          }
        }
      ]
    }
  },
  "errors": []
}
```

### API to UI Mapping

#### Salon Header Section
| API Field | UI Display | Transformation |
|-----------|------------|----------------|
| `salon.logo` | Circle avatar | 120x120 circle with shadow |
| `salon.name` | Large title | Direct display, bold |
| `salon.average_rating` | Star rating + number | Formatted as "⭐ 4.5" |
| `salon.review_count` | Review count | Formatted as "(120 reviews)" |

#### Booking Information Card
| API Field | UI Display | Format/Icon |
|-----------|------------|-------------|
| `date` | Date | 📅 "MMM dd, yyyy" (Dec 24, 2025) |
| `time` | Time | ⏰ "hh:mm a" (10:30 AM) |
| `status` | Status | ✅ Capitalized |
| `booking_type` | Type | 📋 Capitalized |
| `payment_method` | Payment Method | 💳 Capitalized |
| `payment_status` | Payment Status | 🧾 Capitalized (hidden if cancelled) |
| `payment` | Amount | 💰 "PKR {amount}" |

#### Services Section
Each service shows:
| API Field | UI Display |
|-----------|------------|
| `services[].name` | Service name (bold) |
| `services[].duration` | "Duration: 30 min" |
| `services[].price` | "PKR 800" |
| `services[].staff.name` | "Professional: Ahmed Ali" |
| `services[].pivot.quantity` | "Quantity: 1" |

#### Deals Section
Similar structure for deals (if present):
| API Field | UI Display |
|-----------|------------|
| `deal[].name` | Deal name |
| `deal[].total_price` | Total price |
| `deal[].services` | Services included |

#### Membership Section
| API Field | UI Display |
|-----------|------------|
| `membership[].name` | Membership name |
| `membership[].total_sessions` | Total sessions |
| `utilized_sessions` | Sessions used |
| `membership_status` | Status |

#### Reviews Section
| API Field | UI Display |
|-----------|------------|
| `review[].rating` | Star rating (⭐⭐⭐⭐⭐) |
| `review[].comment` | Review text |
| `review[].user.name` | Reviewer name |
| `review[].user.image` | Reviewer avatar |

### Cancel Booking Button

**Visibility Logic:**
```dart
if (!(booking.status?.toLowerCase().contains('cancelled') == true ||
      booking.status?.toLowerCase().contains('completed') == true))
```

Shows only when status is NOT "cancelled" or "completed"

---

## Create Booking

### 📝 Service: `BookingService.dart`

### Input Parameters

The booking creation requires:

```dart
{
  required BuildContext context,
  required int salonId,              // Salon ID where booking is made
  required Map<dynamic, int>? cartItems,  // Service/Deal objects with quantities
  required DateTime? selectedDay,    // Selected appointment date
  required String? selectedTime,     // Selected time slot (e.g., "10:30 AM")
  required List<Professional> selectedProfessionals,  // Selected staff
  required String? paymentMethod,    // "Cash" or "Online"
  required String bookingType,       // "appointment" or "deal"
}
```

### API Payload Construction

**Endpoint:** `POST /api/book-appointment`

**Payload Format:**
```json
{
  "salon_id": 45,
  "time": "'10:30', '2025-12-24'",
  "total_price": 1500.0,
  "payment_status": true,
  "booking_type": "appointment",
  "service_id": [101, 102],
  "quantity": {
    "101": 1,
    "102": 1
  },
  "staff_id": [5, 5]
}
```

### Time Formatting Logic

**Input:** `"10:30 AM"` (12-hour format)  
**Output:** `"'10:30', '2025-12-24'"` (API required format)

```dart
// Steps:
1. Parse "10:30 AM" into hour and minute
2. Convert to 24-hour format (10:30 AM → 10:30, 2:30 PM → 14:30)
3. Format date as YYYY-MM-DD
4. Combine: "'HH:mm', 'YYYY-MM-DD'"
```

### Cart Items Processing

```dart
// Separate services and deals
List<int> serviceIds = [];
List<int> dealIds = [];
Map<String, int> qtyMap = {};

for (item, quantity in cartItems) {
  if (item is Service) {
    serviceIds.add(item.id);
    qtyMap[item.id.toString()] = quantity;
  } else if (item is Deal) {
    dealIds.add(item.id);
  }
}
```

### Professional Assignment

```dart
// If professionals selected:
List<int> staffIds = selectedProfessionals.map((p) => p.id).toList();

// If no professionals (user selected "Any"):
// Staff IDs will be auto-assigned by backend
```

### Payment Status Boolean

```dart
payment_status: paymentMethod == 'Cash'  // true = Cash, false = Online
```

### Response Handling

**Success Response (200):**
```json
{
  "status": true,
  "message": "Booking created successfully",
  "data": {
    "booking_id": 123,
    "confirmation_code": "ABC123"
  }
}
```

**Error Response (400/422):**
```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "time": ["The time field is required"],
    "salon_id": ["Invalid salon"]
  }
}
```

### UI Feedback

1. **Loading Dialog** - Shown during API call
2. **Success** - Navigate to booking confirmation
3. **Profile Incomplete** - Redirect to complete profile
4. **Error** - Show error dialog with retry option

---

## API Endpoints

### 1. Get Bookings List
```
GET /api/appointments?page={page}
```
**Authentication:** Required  
**Parameters:**
- `page` (optional): Page number for pagination (default: 1)
- `url` (optional): Direct pagination URL

**Response:** Paginated list of bookings with salon info

### 2. Get Booking Detail
```
GET /api/booking-detail/{id}
```
**Authentication:** Required  
**Parameters:**
- `id`: Booking ID

**Response:** Complete booking details with services, deals, reviews

### 3. Create Booking
```
POST /api/book-appointment
```
**Authentication:** Required  
**Body:**
```json
{
  "salon_id": int,
  "time": "'HH:mm', 'YYYY-MM-DD'",
  "total_price": float,
  "payment_status": boolean,
  "booking_type": string,
  "service_id": int[] (optional),
  "deal_id": int[] (optional),
  "quantity": object (optional),
  "staff_id": int[] (optional),
  "used_loyalty_points": int (optional)
}
```

### 4. Cancel Booking
```
POST /api/cancel-booking/{id}
```
**Authentication:** Required  
**Body:**
```json
{
  "cancel_message": string (optional)
}
```

---

## Data Models

### MyBookingResponse
```dart
class MyBookingResponse {
  bool? status
  String? message
  ResponseData? response
}

class ResponseData {
  BookingData? data
}

class BookingData {
  int? currentPage
  List<Booking>? data
  String? nextPageUrl
  int? total
  int? lastPage
  // ... pagination fields
}

class Booking {
  int? id
  String? title
  int? salonId
  String? date           // Format: "YYYY-MM-DD"
  String? time           // Format: "HH:mm:ss"
  String? paymentMethod
  int? payment
  String? paymentStatus
  String? bookingType
  String? status
  Salon? salon
}
```

### BookingDetailResponse
```dart
class BookingDetailResponse {
  int statusCode
  bool status
  String message
  BookingDetailData response
}

class BookingDetail {
  int id
  String? date
  String? time
  String? paymentMethod
  double? payment
  double? tip
  String? paymentStatus
  String? bookingType
  String? status
  int? usedLoyaltyPoints
  
  BookingSalon? salon
  List<BookingService> services
  List<dynamic> deal
  List<dynamic> membership
  List<BookingReview> review
}

class BookingService {
  int id
  String? name
  String? duration
  int? price
  String? gender
  BookingServicePivot pivot
  BookingStaff? staff
}

class BookingReview {
  int id
  String? comment
  int? rating
  ReviewUser? user
}
```

---

## UI Components

### Booking Card Component
**Location:** `my_bookings.dart` (inline)

**Features:**
- Salon logo with fallback
- Status color-coded badges
- Date/time formatting
- Payment status (conditional)
- Hero animation for logo
- Tap to view details

### Modern Info Card
```dart
Widget _buildModernInfoCard({
  required IconData icon,
  required String label,
  required String value,
  required Color cardColor,
})
```

Displays formatted info with:
- Color-coded background
- Icon
- Label (uppercase, small)
- Value (bold, larger)

### Status Color Helper
```dart
Color _getStatusColor(String? status)
```

Returns color based on booking status:
- `booked` → Green
- `completed` → Blue
- `cancelled` → Red
- `pending` → Orange
- default → Grey

---

## State Management

### BookingsViewModel

**Extends:** `BaseViewModel` (with loading/error states)

**Properties:**
- `_allBookings` - Complete list
- `_upcomingBookings` - Filtered future bookings
- `_pastBookings` - Filtered past bookings
- `_currentPage` - Current pagination page
- `_nextPageUrl` - URL for next page
- `_totalBookings` - Total count

**Methods:**
```dart
Future<void> loadBookings({bool refresh = false})
void _filterBookings()
Future<void> loadNextPage()
Future<void> refresh()
```

**Filtering Logic:**
```dart
Upcoming: status == 'booked' && dateTime >= now
Past: status != 'booked' || dateTime < now
```

---

## User Flow

### View Bookings Flow
```
1. User taps "My Bookings" from navigation
2. App loads page 1 of bookings
3. BookingsViewModel fetches from API
4. Bookings filtered into tabs
5. User can:
   - Switch tabs (All/Upcoming/Past)
   - Pull to refresh
   - Scroll to load more
   - Tap booking to view details
```

### View Booking Details Flow
```
1. User taps a booking card
2. Navigate to BookingDetailsScreen with booking ID
3. Fetch detailed info from API
4. Display:
   - Salon information
   - Booking info
   - Services/Deals/Membership
   - Reviews
5. User can:
   - Cancel booking (if allowed)
   - View salon details
   - Pull to refresh
```

### Create Booking Flow
```
1. User adds services to cart
2. Selects salon and time slot
3. Chooses professional (or "Any")
4. Selects payment method
5. Reviews booking summary
6. Confirms booking
7. BookingService processes:
   - Validates cart items
   - Formats time/date
   - Constructs payload
   - Sends to API
8. On success:
   - Clears cart
   - Shows confirmation
   - Navigates to booking details
9. On error:
   - Shows error message
   - Allows retry
```

### Cancel Booking Flow
```
1. User views booking details
2. Taps "Cancel Booking" button
3. Confirmation dialog appears
4. User confirms cancellation
5. API call to cancel endpoint
6. On success:
   - Show success message
   - Refresh booking list
   - Navigate back
7. On error:
   - Show error message
   - Stay on details screen
```

---

## Error Handling

### Common Errors

**401 Unauthorized:**
- User not logged in
- Token expired
- Action: Redirect to login

**404 Not Found:**
- No bookings found
- Action: Show empty state

**422 Validation Error:**
- Invalid booking data
- Action: Show specific field errors

**500 Server Error:**
- Backend issue
- Action: Show retry option

### Error Display

**Authentication Error:**
```
🔒
Authentication Required
Please log in to view your bookings

[Login Button]
```

**Network Error:**
```
☁️
Oops! Something went wrong
Unable to connect to the server

[Try Again Button]
```

**Empty State:**
```
🗓️
No Bookings Yet
You haven't made any salon bookings

[Explore Salons Button]
```

---

## Performance Optimizations

1. **Pagination** - Load 12 items at a time
2. **Caching** - Cache booking responses
3. **Image Loading** - Cached network images with placeholders
4. **Lazy Loading** - Infinite scroll for seamless UX
5. **Pull-to-Refresh** - Manual refresh capability
6. **Shimmer Loading** - Better perceived performance
7. **Hero Animations** - Smooth transitions

---

## Testing Checklist

- [ ] Load bookings (all, upcoming, past)
- [ ] Pagination works correctly
- [ ] Pull-to-refresh updates data
- [ ] Tap booking shows details
- [ ] All booking info displays correctly
- [ ] Services, deals, reviews show properly
- [ ] Cancel booking works (when allowed)
- [ ] Error states display correctly
- [ ] Empty states display correctly
- [ ] Authentication errors handled
- [ ] Create booking with services
- [ ] Create booking with deals
- [ ] Create booking with custom time
- [ ] Payment method selection works
- [ ] Professional selection works

---

## Related Documentation

- [Booking Flow Spec](docs/booking/BOOKING_FLOW_SPEC.md)
- [Create Booking API](BOOKING_CREATE_API.md)
- [Salon Detail API](SALON_DETAIL_API.md)
- [New Booking API Structure](NEW_SALON_BOOKING_API_STRUCTURE.md)

---

**Last Updated:** January 20, 2026  
**Version:** 1.0.0
