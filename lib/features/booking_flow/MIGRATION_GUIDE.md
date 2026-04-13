# Booking Flow Migration Guide

## Overview

The booking flow has been reorganized into a clean, modular structure under `lib/features/booking_flow/`.

## File Mapping

### Old Location → New Location

| Old Path                                              | New Path                                                                            | New Name                      |
| ----------------------------------------------------- | ----------------------------------------------------------------------------------- | ----------------------------- |
| `lib/screens/test_scroll/select_professionals.dart`   | `lib/features/booking_flow/presentation/screens/professional_selection_screen.dart` | `ProfessionalSelectionScreen` |
| `lib/screens/test_scroll/SelectDateScreen.dart`       | `lib/features/booking_flow/presentation/screens/date_selection_screen.dart`         | `DateSelectionScreen`         |
| `lib/screens/test_scroll/select_time_screen.dart`     | `lib/features/booking_flow/presentation/screens/time_selection_screen.dart`         | `TimeSelectionScreen`         |
| `lib/screens/test_scroll/confirm_booking_screen.dart` | `lib/features/booking_flow/presentation/screens/booking_confirmation_screen.dart`   | `BookingConfirmationScreen`   |
| `lib/screens/test_scroll/CartSummarySection.dart`     | `lib/features/booking_flow/presentation/widgets/cart_summary_widget.dart`           | `CartSummaryWidget`           |

### Route Names Changed

| Old Route               | New Route                       |
| ----------------------- | ------------------------------- |
| `/select_professionals` | `/booking/select_professionals` |
| `/select-date`          | `/booking/select-date`          |
| `/select-time`          | `/booking/select-time`          |
| `/confirm-booking`      | `/booking/confirm`              |

## Step-by-Step Migration

### 1. Update routes.dart

```dart
// OLD
import 'package:app/screens/test_scroll/select_professionals.dart';
import 'package:app/screens/test_scroll/SelectDateScreen.dart';
import 'package:app/screens/test_scroll/select_time_screen.dart';
import 'package:app/screens/test_scroll/confirm_booking_screen.dart';

SelectProfessionals.routeName: (context) => const SelectProfessionals(),
SelectDateScreen.routeName: (context) => const SelectDateScreen(),
SelectTimeScreen.routeName: (context) => const SelectTimeScreen(),
ConfirmBookingScreen.routeName: (context) => const ConfirmBookingScreen(),

// NEW
import 'package:app/features/booking_flow/booking_flow.dart';

ProfessionalSelectionScreen.routeName: (context) => const ProfessionalSelectionScreen(),
DateSelectionScreen.routeName: (context) => const DateSelectionScreen(),
TimeSelectionScreen.routeName: (context) => const TimeSelectionScreen(),
BookingConfirmationScreen.routeName: (context) => const BookingConfirmationScreen(),
```

### 2. Update Navigation Calls

```dart
// OLD
Navigator.pushNamed(context, SelectProfessionals.routeName);
Navigator.pushNamed(context, SelectDateScreen.routeName);
Navigator.pushNamed(context, SelectTimeScreen.routeName);
Navigator.pushNamed(context, ConfirmBookingScreen.routeName);

// NEW
Navigator.pushNamed(context, ProfessionalSelectionScreen.routeName);
Navigator.pushNamed(context, DateSelectionScreen.routeName);
Navigator.pushNamed(context, TimeSelectionScreen.routeName);
Navigator.pushNamed(context, BookingConfirmationScreen.routeName);
```

### 3. Update Imports in Other Files

```dart
// OLD
import 'package:app/screens/test_scroll/select_professionals.dart';

// NEW
import 'package:app/features/booking_flow/booking_flow.dart';
// or more specific:
import 'package:app/features/booking_flow/presentation/screens/booking_screens.dart';
```

### 4. Update Widget References

```dart
// OLD
CartSummarySection(...)

// NEW
CartSummaryWidget(...)
```

## New Features Available

### 1. Booking Models

```dart
import 'package:app/features/booking_flow/booking_flow.dart';

// Create booking state
final bookingState = BookingState(
  salon: salon,
  salonId: salonId,
  salonName: salonName,
  cartItems: cartItems,
  selectedDate: selectedDate,
  selectedTime: selectedTime,
  paymentMethod: 'Cash',
);

// Calculate totals
double total = bookingState.calculateTotalPrice();
int serviceCount = bookingState.getServiceCount();
bool isValid = bookingState.isValid();
```

### 2. Booking Service

```dart
import 'package:app/features/booking_flow/booking_flow.dart';

final bookingService = BookingService();

// Create booking
final response = await bookingService.createBooking(
  bookingState,
  specialNotes: 'Please be on time',
);

if (response.success) {
  print('Booking created: ${response.bookingId}');
} else {
  print('Error: ${response.message}');
}
```

### 3. Booking Repository

```dart
import 'package:app/features/booking_flow/booking_flow.dart';

final repository = BookingRepository();
final request = BookingRequest(...);
final response = await repository.createBooking(request);
```

## Testing Migration

After migration, test:

1. ✅ Professional selection screen loads
2. ✅ Date selection with professional availability
3. ✅ Time slot generation based on salon active days
4. ✅ Booking confirmation
5. ✅ API call success/failure handling
6. ✅ Navigation between screens
7. ✅ Cart summary displays correctly

## Rollback Plan

If issues occur, the old files are still available at:

- `lib/screens/test_scroll/` (original location)

To rollback:

1. Revert route changes in `routes.dart`
2. Revert import statements
3. Use old route names and class names

## Benefits of New Structure

1. **Clean Architecture**: Separation of concerns (Domain/Data/Presentation)
2. **Easier Testing**: Each layer can be tested independently
3. **Better Maintainability**: Clear folder structure
4. **Reusability**: Models and services can be reused
5. **Type Safety**: Strong typing throughout
6. **Documentation**: Comprehensive inline documentation

## Support

For questions or issues:

1. Check the README.md in `lib/features/booking_flow/`
2. Review inline documentation in files
3. Check logs with namespace `booking.*`

## Timeline

- **Phase 1**: Update routes.dart ✅
- **Phase 2**: Test each screen individually
- **Phase 3**: Test complete booking flow
- **Phase 4**: Remove old files (optional, can keep as backup)
