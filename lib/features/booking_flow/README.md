# Booking Flow Feature

This folder contains the complete booking flow implementation with clean architecture.

## Structure

```
booking_flow/
├── domain/              # Business logic & models
│   ├── booking_models.dart   # Data models (BookingState, BookingRequest, BookingResponse)
│   └── booking_service.dart  # Business logic (formatting, validation, orchestration)
├── data/                # Data layer
│   └── booking_repository.dart  # API calls
└── presentation/        # UI layer
    ├── screens/         # Screen widgets
    │   ├── professional_selection_screen.dart
    │   ├── date_selection_screen.dart
    │   ├── time_selection_screen.dart
    │   └── booking_confirmation_screen.dart
    └── widgets/         # Reusable UI components
        ├── cart_summary_widget.dart
        ├── professional_card_widget.dart
        ├── date_picker_widget.dart
        └── time_slot_widget.dart
```

## Architecture Layers

### 1. **Domain Layer** (`domain/`)

- **`booking_models.dart`**: Core data models

  - `BookingState`: Manages booking state throughout the flow
  - `BookingRequest`: API request model
  - `BookingResponse`: API response model

- **`booking_service.dart`**: Business logic
  - Time formatting
  - Request building
  - Booking validation
  - Orchestrates repository calls

### 2. **Data Layer** (`data/`)

- **`booking_repository.dart`**: Handles API communication
  - Creates bookings via API
  - Handles responses and errors
  - Manages authentication

### 3. **Presentation Layer** (`presentation/`)

- **Screens**: Full-page booking flow screens
- **Widgets**: Reusable UI components

## Booking Flow

```
1. Professional Selection
   ↓
2. Date Selection
   ↓
3. Time Selection
   ↓
4. Booking Confirmation
   ↓
5. API Call → Success/Error
```

## Usage Example

```dart
// Initialize booking state
final bookingState = BookingState(
  salon: salon,
  salonId: salonId,
  cartItems: cartItems,
  // ... other fields
);

// Create booking
final bookingService = BookingService();
final response = await bookingService.createBooking(
  bookingState,
  specialNotes: 'Please be on time',
);

if (response.success) {
  // Handle success
} else {
  // Handle error
}
```

## Key Features

- ✅ Clean separation of concerns
- ✅ Comprehensive logging
- ✅ Type-safe models
- ✅ Error handling
- ✅ Validation logic
- ✅ Professional availability checking
- ✅ Time formatting (12h → 24h)
- ✅ Multiple payment methods
- ✅ Service and Deal support

## API Format

### Request Format

```json
{
  "salon_id": 123,
  "time": "'14:30', '2025-12-08'",
  "total_price": 150.0,
  "payment_status": true,
  "booking_type": "appointment",
  "service_id": [1, 2],
  "profession_id": [5, 0],
  "qty": { "1": 2, "2": 1 },
  "note": "Optional notes"
}
```

### Time Format

- Input: "2:30 PM"
- Output: "'14:30', '2025-12-08'"

## Migration from Old Code

To migrate existing booking screens:

1. Import models:

```dart
import 'package:app/features/booking_flow/domain/booking_models.dart';
```

2. Use BookingState instead of passing individual parameters

3. Use BookingService for API calls instead of direct API calls

4. Follow the new structure for new screens

## Testing

Each layer can be tested independently:

- **Models**: Unit tests for data transformations
- **Service**: Unit tests for business logic
- **Repository**: Mock HTTP responses
- **UI**: Widget tests

## Logging

All layers use comprehensive logging with namespace:

- `booking.service` - Business logic logs
- `booking.repository` - API call logs
- `booking.screen` - UI interaction logs

Enable in debug mode with:

```dart
if (kDebugMode) {
  developer.log('message', name: 'booking.service');
}
```
