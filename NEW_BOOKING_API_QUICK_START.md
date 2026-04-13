# Quick Start Guide: New Booking API

This guide shows how to use the new booking API in your Flutter screens.

## 🚀 Quick Setup

### 1. Import the Repository

```dart
import 'package:app/features/booking_flow/data/new_booking_repository.dart';
import 'package:app/features/booking_flow/domain/models/create_booking_model.dart';
```

### 2. Initialize in Your Screen

```dart
class YourBookingScreen extends StatefulWidget {
  @override
  _YourBookingScreenState createState() => _YourBookingScreenState();
}

class _YourBookingScreenState extends State<YourBookingScreen> {
  final _repository = NewBookingRepository();

  // Your state variables
}
```

---

## 📝 Common Use Cases

### Use Case 1: Load Salon Information

```dart
Future<void> loadSalonInfo() async {
  try {
    final salon = await _repository.getSalonOverview(salonId);

    setState(() {
      salonName = salon.name;
      salonAddress = salon.location.fullAddress;
      services = salon.info.servicesOffered;
      workingHours = salon.workingHours;
    });
  } catch (e) {
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load salon: $e')),
    );
  }
}
```

### Use Case 2: Find Available Professionals

```dart
Future<void> findProfessionals() async {
  try {
    final professionals = await _repository.getAvailableProfessionals(
      salonId: widget.salonId,
      serviceIds: selectedServiceIds,
      date: selectedDate.toString().split(' ')[0], // "2025-12-08"
      preferredTime: "14:00", // Optional
    );

    setState(() {
      availableProfessionals = professionals;
    });

    // Show if no professionals available
    if (professionals.isEmpty) {
      _showNoProfessionalsDialog();
    }
  } catch (e) {
    // Handle error
  }
}
```

### Use Case 3: Get Available Time Slots

```dart
Future<void> loadTimeSlots() async {
  try {
    final response = await _repository.getAvailableSlots(
      salonId: widget.salonId,
      professionalId: selectedProfessional.id,
      serviceIds: selectedServiceIds,
      date: selectedDate.toString().split(' ')[0],
    );

    setState(() {
      allSlots = response.data.slots;
      availableSlots = response.data.slots
          .where((slot) => slot.isAvailable)
          .toList();
      recommendedTimes = response.data.summary.recommendedTimes;
    });
  } catch (e) {
    // Handle error
  }
}
```

### Use Case 4: Create Booking

```dart
Future<void> confirmBooking() async {
  try {
    // Build the request
    final request = CreateBookingRequest(
      salonId: widget.salonId,
      bookingDate: selectedDate.toString().split(' ')[0], // "2025-12-08"
      bookingTime: selectedTime, // "14:00"
      services: selectedServices.map((service) {
        return BookingServiceItem(
          serviceId: service.id,
          professionalId: service.assignedProfessionalId,
          quantity: service.quantity ?? 1,
        );
      }).toList(),
      payment: BookingPayment(
        method: selectedPaymentMethod, // "cash", "card", "online"
        totalAmount: calculateTotal(),
      ),
      specialNotes: notesController.text.isNotEmpty
          ? notesController.text
          : null,
    );

    // Create the booking
    final bookingDetails = await _repository.createBooking(request);

    // Navigate to success screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSuccessScreen(
          bookingNumber: bookingDetails.bookingNumber,
          bookingId: bookingDetails.id,
        ),
      ),
    );
  } catch (e) {
    // Show error
    _showErrorDialog('Failed to create booking: $e');
  }
}
```

### Use Case 5: Validate Before Booking (Optional)

```dart
Future<bool> validateBeforeConfirm() async {
  try {
    final validation = await _repository.validateBooking(
      salonId: widget.salonId,
      services: selectedServices.map((s) {
        return validate.BookingServiceItem(
          serviceId: s.id,
          professionalId: s.assignedProfessionalId,
        );
      }).toList(),
      date: selectedDate.toString().split(' ')[0],
      time: selectedTime,
      paymentMethod: selectedPaymentMethod,
    );

    if (!validation.valid) {
      // Show validation issues
      _showValidationIssues(validation.issues ?? []);

      // Show suggestions if available
      if (validation.suggestion != null) {
        _showSuggestions(validation.suggestion!);
      }

      return false;
    }

    return true;
  } catch (e) {
    // Validation failed, but allow user to proceed
    return true;
  }
}
```

### Use Case 6: Cancel Booking

```dart
Future<void> cancelBooking(int bookingId) async {
  try {
    final success = await _repository.cancelBooking(
      bookingId: bookingId,
      reason: cancellationReason,
      cancelReasonId: selectedReasonId, // Optional
    );

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking cancelled successfully')),
      );
    }
  } catch (e) {
    _showErrorDialog('Failed to cancel booking: $e');
  }
}
```

---

## 🎨 UI Examples

### Display Professional with Availability

```dart
Widget buildProfessionalCard(AvailableProfessional pro) {
  return Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(pro.profilePicture ?? ''),
      ),
      title: Text(pro.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pro.specialization != null)
            Text(pro.specialization!),
          if (pro.availability.totalAvailableSlots > 0)
            Text(
              '${pro.availability.totalAvailableSlots} slots available',
              style: TextStyle(color: Colors.green),
            ),
        ],
      ),
      trailing: pro.isRecommended
          ? Chip(label: Text('Recommended'))
          : null,
      onTap: () => selectProfessional(pro),
    ),
  );
}
```

### Display Time Slot

```dart
Widget buildTimeSlot(TimeSlot slot) {
  return InkWell(
    onTap: slot.isAvailable ? () => selectSlot(slot) : null,
    child: Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: slot.isAvailable
            ? (isRecommended(slot) ? Colors.green[100] : Colors.white)
            : Colors.grey[200],
        border: Border.all(
          color: selectedSlot == slot ? Colors.blue : Colors.grey,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            slot.formatted, // "2:00 PM"
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: slot.isAvailable ? Colors.black : Colors.grey,
            ),
          ),
          if (isRecommended(slot))
            Text('Recommended', style: TextStyle(fontSize: 10)),
          if (!slot.isAvailable && slot.nextAvailable != null)
            Text(
              'Next: ${slot.nextAvailable}',
              style: TextStyle(fontSize: 10),
            ),
        ],
      ),
    ),
  );
}

bool isRecommended(TimeSlot slot) {
  return recommendedTimes.contains(slot.time);
}
```

---

## ⚠️ Error Handling Best Practices

### Handle Common Errors

```dart
try {
  // Your API call
} catch (e) {
  String errorMessage;

  if (e.toString().contains('Please login to continue')) {
    // Navigate to login
    Navigator.pushNamed(context, '/login');
    return;
  } else if (e.toString().contains('network')) {
    errorMessage = 'Check your internet connection';
  } else if (e.toString().contains('SLOT_UNAVAILABLE')) {
    errorMessage = 'This time slot is no longer available';
  } else {
    errorMessage = 'Something went wrong. Please try again';
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMessage)),
  );
}
```

---

## 💡 Pro Tips

### Tip 1: Use Loading States

```dart
bool _isLoading = false;

Future<void> loadData() async {
  setState(() => _isLoading = true);
  try {
    // Your API call
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### Tip 2: Cache Salon Overview

```dart
SalonOverview? _cachedSalon;

Future<SalonOverview> getSalon() async {
  if (_cachedSalon != null) {
    return _cachedSalon!;
  }
  _cachedSalon = await _repository.getSalonOverview(salonId);
  return _cachedSalon!;
}
```

### Tip 3: Format Dates Consistently

```dart
String formatDate(DateTime date) {
  return date.toString().split(' ')[0]; // "2025-12-08"
}

String formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute'; // "14:30"
}
```

### Tip 4: Handle Empty States

```dart
if (availableProfessionals.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_off, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text('No professionals available'),
        Text('Try selecting a different date'),
        ElevatedButton(
          onPressed: () => selectDifferentDate(),
          child: Text('Change Date'),
        ),
      ],
    ),
  );
}
```

---

## 🔄 Migration from Old API

### Before (Old API)

```dart
// Complex nested data
final response = await api.getSalonDetail(salonId);
final services = response['data']['services'];
final professionals = response['data']['professionals'];

// Manual validation
if (!isValidTime(selectedTime)) {
  showError('Invalid time');
}

// Complex booking creation
final bookingData = {
  'salon_id': salonId,
  'booking_date': formatDateOld(selectedDate),
  'booking_time': formatTimeOld(selectedTime),
  'services_data': servicesData, // Complex array
  // ... many more fields
};
```

### After (New API)

```dart
// Clean, typed data
final salon = await _repository.getSalonOverview(salonId);
final professionals = await _repository.getAvailableProfessionals(...);

// Server-side validation
final validation = await _repository.validateBooking(...);

// Simple booking creation
final request = CreateBookingRequest(
  salonId: salonId,
  bookingDate: formatDate(selectedDate),
  bookingTime: formatTime(selectedTime),
  services: selectedServices,
  payment: paymentDetails,
);
final booking = await _repository.createBooking(request);
```

---

## 📚 Further Reading

- See `NEW_BOOKING_API_IMPLEMENTATION.md` for complete implementation details
- See `NEW_SALON_BOOKING_API_STRUCTURE.md` for API specifications
- See model files in `lib/features/booking_flow/domain/models/` for all available fields

---

_Happy coding! 🚀_
