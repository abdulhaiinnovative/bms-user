# ViewModel Integration Guide

## How to Integrate BookingFlowViewModel into Existing Screens

This guide shows you how to integrate the new `BookingFlowViewModel` into your existing booking flow screens.

---

## 🏗️ Setup: Provide ViewModel in App

### Step 1: Add Provider to main.dart or parent widget

```dart
import 'package:provider/provider.dart';
import 'package:app/features/booking_flow/presentation/viewmodels/booking_flow_viewmodel.dart';

// In your main app or parent widget
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => BookingFlowViewModel()),
    // ... your other providers
  ],
  child: YourApp(),
)
```

---

## 📱 Screen 1: Salon Details (Service Selection)

**File:** `lib/screens/test/salon_details_scrolling_tabs_effect_b.dart`

### Changes:

```dart
import 'package:provider/provider.dart';
import 'package:app/features/booking_flow/presentation/viewmodels/booking_flow_viewmodel.dart';

class _SalonDetailsScrollingTabsEffectB extends State<...> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final salonId = /* get from route args */;

      // Load salon overview using new ViewModel
      context.read<BookingFlowViewModel>().loadSalonOverview(salonId);
    });
  }

  // When user adds services to cart
  void onServicesSelected(List<int> serviceIds) {
    context.read<BookingFlowViewModel>().setSelectedServices(serviceIds);
  }

  // When user clicks "Continue" from cart
  void proceedToBooking() {
    final viewModel = context.read<BookingFlowViewModel>();

    if (!viewModel.canSelectProfessionals()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one service')),
      );
      return;
    }

    // Navigate to professional selection
    Navigator.pushNamed(
      context,
      SelectProfessionals.routeName,
      arguments: {
        'salonId': salonId,
        // ViewModel state is already set, no need to pass data
      },
    );
  }
}
```

---

## 📱 Screen 2: Professional Selection

**File:** `lib/screens/test_scroll/select_professionals.dart`

### Complete Refactor:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/booking_flow/presentation/viewmodels/booking_flow_viewmodel.dart';
import 'package:app/features/booking_flow/domain/models/available_professionals_model.dart';

class SelectProfessionals extends StatefulWidget {
  static String routeName = "/select_professionals";
  const SelectProfessionals({Key? key}) : super(key: key);

  @override
  _SelectProfessionalsState createState() => _SelectProfessionalsState();
}

class _SelectProfessionalsState extends State<SelectProfessionals> {
  int? salonId;
  String selectedDate = DateTime.now().toString().split(' ')[0];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      salonId = args?['salonId'];

      // Load available professionals
      context.read<BookingFlowViewModel>().loadAvailableProfessionals(
        salonId: salonId!,
        date: selectedDate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Professional')),
      body: Consumer<BookingFlowViewModel>(
        builder: (context, viewModel, child) {
          // Loading state
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          // Error state
          if (viewModel.isError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(viewModel.errorMessage ?? 'An error occurred'),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.loadAvailableProfessionals(
                        salonId: salonId!,
                        date: selectedDate,
                      );
                    },
                    child: Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (viewModel.availableProfessionals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No professionals available'),
                  Text('Try selecting a different date'),
                ],
              ),
            );
          }

          // Success state - show professionals
          return ListView.builder(
            itemCount: viewModel.availableProfessionals.length,
            itemBuilder: (context, index) {
              final pro = viewModel.availableProfessionals[index];
              return _buildProfessionalCard(pro, viewModel);
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<BookingFlowViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.selectedProfessional == null) return SizedBox();

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _proceedToTimeSelection(viewModel),
                child: Text('Continue'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfessionalCard(
    AvailableProfessional pro,
    BookingFlowViewModel viewModel,
  ) {
    final isSelected = viewModel.selectedProfessional?.id == pro.id;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: pro.profilePicture != null
              ? NetworkImage(pro.profilePicture!)
              : null,
          child: pro.profilePicture == null
              ? Icon(Icons.person)
              : null,
        ),
        title: Row(
          children: [
            Text(pro.name),
            if (pro.isRecommended) ...[
              SizedBox(width: 8),
              Chip(
                label: Text('Recommended', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.green[100],
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pro.specialization != null)
              Text(pro.specialization!),
            SizedBox(height: 4),
            Text(
              '${pro.availability.totalAvailableSlots} slots available',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: Colors.blue)
            : null,
        onTap: () => viewModel.selectProfessional(pro),
      ),
    );
  }

  void _proceedToTimeSelection(BookingFlowViewModel viewModel) {
    Navigator.pushNamed(
      context,
      SelectTimeScreen.routeName,
      arguments: {'salonId': salonId},
    );
  }
}
```

---

## 📱 Screen 3: Time Selection

**File:** `lib/screens/test_scroll/select_time_screen.dart`

### Complete Refactor:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/booking_flow/presentation/viewmodels/booking_flow_viewmodel.dart';
import 'package:app/features/booking_flow/domain/models/available_slots_model.dart';
import 'package:table_calendar/table_calendar.dart';

class SelectTimeScreen extends StatefulWidget {
  static const String routeName = '/select-time';
  const SelectTimeScreen({Key? key}) : super(key: key);

  @override
  _SelectTimeScreenState createState() => _SelectTimeScreenState();
}

class _SelectTimeScreenState extends State<SelectTimeScreen> {
  int? salonId;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      salonId = args?['salonId'];

      // Set initial date and load slots
      final viewModel = context.read<BookingFlowViewModel>();
      viewModel.selectDate(DateTime.now());
      viewModel.loadAvailableSlots(salonId: salonId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Date & Time')),
      body: Consumer<BookingFlowViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Calendar
              _buildCalendar(viewModel),

              // Time slots
              Expanded(
                child: _buildTimeSlots(viewModel),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<BookingFlowViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.selectedSlot == null) return SizedBox();

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Selected: ${viewModel.selectedSlot!.formatted}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _proceedToConfirmation(),
                    child: Text('Continue to Confirmation'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendar(BookingFlowViewModel viewModel) {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(Duration(days: 90)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(viewModel.selectedDate, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() => _focusedDay = focusedDay);
        viewModel.selectDate(selectedDay);
        viewModel.loadAvailableSlots(salonId: salonId!);
      },
    );
  }

  Widget _buildTimeSlots(BookingFlowViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (viewModel.isError) {
      return Center(child: Text(viewModel.errorMessage ?? 'Error'));
    }

    if (viewModel.availableSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No available time slots'),
            if (viewModel.slotsResponse?.data.summary.nextAvailable != null)
              Text('Next available: ${viewModel.slotsResponse!.data.summary.nextAvailable}'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: viewModel.availableSlots.length,
      itemBuilder: (context, index) {
        final slot = viewModel.availableSlots[index];
        return _buildTimeSlotCard(slot, viewModel);
      },
    );
  }

  Widget _buildTimeSlotCard(TimeSlot slot, BookingFlowViewModel viewModel) {
    final isSelected = viewModel.selectedSlot?.time == slot.time;
    final isRecommended = viewModel.isTimeRecommended(slot.time);

    return InkWell(
      onTap: () => viewModel.selectTimeSlot(slot),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue
              : (isRecommended ? Colors.green[100] : Colors.white),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slot.formatted,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isRecommended && !isSelected)
              Text(
                'Recommended',
                style: TextStyle(fontSize: 10, color: Colors.green[700]),
              ),
          ],
        ),
      ),
    );
  }

  void _proceedToConfirmation() {
    Navigator.pushNamed(
      context,
      ConfirmBookingScreen.routeName,
      arguments: {'salonId': salonId},
    );
  }
}
```

---

## 📱 Screen 4: Booking Confirmation

**File:** `lib/screens/test_scroll/confirm_booking_screen.dart`

### Key Changes:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/booking_flow/presentation/viewmodels/booking_flow_viewmodel.dart';
import 'package:app/features/booking_flow/domain/models/create_booking_model.dart';
import 'package:app/providers/cart_provider.dart';

class ConfirmBookingScreen extends StatefulWidget {
  static const String routeName = '/confirm-booking';
  // ... existing code
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  int? salonId;
  String selectedPaymentMethod = 'cash';
  bool isCreatingBooking = false;

  // ... existing variables

  Future<void> _confirmBooking() async {
    final viewModel = context.read<BookingFlowViewModel>();
    final cartProvider = context.read<CartProvider>();

    setState(() => isCreatingBooking = true);

    // Build services from cart
    final services = cartProvider.items.entries.map((entry) {
      final service = entry.key;
      final professionalId = viewModel.selectedProfessional!.id;

      return BookingServiceItem(
        serviceId: service.id!,
        professionalId: professionalId,
        quantity: entry.value,
      );
    }).toList();

    // Calculate total
    final totalAmount = cartProvider.totalAmount;

    // Optional: Validate first
    final isValid = await viewModel.validateBooking(
      salonId: salonId!,
      services: services,
      paymentMethod: selectedPaymentMethod,
    );

    if (!isValid && viewModel.validationResponse != null) {
      _showValidationIssues(viewModel.validationResponse!);
      setState(() => isCreatingBooking = false);
      return;
    }

    // Create booking
    final success = await viewModel.createBooking(
      salonId: salonId!,
      services: services,
      paymentMethod: selectedPaymentMethod,
      totalAmount: totalAmount,
      specialNotes: notesController.text.isNotEmpty
          ? notesController.text
          : null,
    );

    setState(() => isCreatingBooking = false);

    if (success) {
      // Clear cart
      cartProvider.clear();

      // Show success and navigate
      _showSuccessDialog(viewModel.createdBooking!);
    } else {
      // Error already shown by ViewModel
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Booking failed')),
      );
    }
  }

  void _showSuccessDialog(BookingDetails booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('✅ Booking Confirmed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Booking Number: ${booking.bookingNumber}'),
            SizedBox(height: 8),
            Text('Date: ${booking.appointment.dateFormatted}'),
            Text('Time: ${booking.appointment.timeFormatted}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showValidationIssues(validate.ValidateBookingResponse validation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ Validation Issues'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (validation.issues != null)
              ...validation.issues!.map((issue) =>
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('• ${issue.message}'),
                )
              ),
            if (validation.suggestion != null) ...[
              SizedBox(height: 16),
              Text('Suggestion:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(validation.suggestion!.reason),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confirm Booking')),
      body: isCreatingBooking
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Show booking summary from ViewModel
                  Consumer<BookingFlowViewModel>(
                    builder: (context, viewModel, child) {
                      return Column(
                        children: [
                          _buildSalonInfo(viewModel.salonOverview),
                          _buildProfessionalInfo(viewModel.selectedProfessional),
                          _buildDateTimeInfo(viewModel.selectedDate, viewModel.selectedSlot),
                          _buildServicesInfo(),
                          _buildPaymentMethod(),
                          _buildNotesField(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: isCreatingBooking ? null : _confirmBooking,
            child: Text('Confirm Booking'),
          ),
        ),
      ),
    );
  }

  // ... build methods for UI sections
}
```

---

## 🎯 Key Points

1. **Use Consumer/context.read**: Access ViewModel via Provider
2. **Automatic State Management**: ViewModel handles loading/error/success states
3. **Step Validation**: Use `canSelectProfessionals()`, `canSelectDate()`, etc.
4. **Auto-Selection**: ViewModel auto-selects when only one option
5. **Recommendations**: Use `isTimeRecommended()` to highlight
6. **Error Handling**: ViewModel provides user-friendly error messages
7. **Reset Flow**: Use `resetBookingFlow()` or `resetFromStep(step)` when going back

---

## 📦 Dependencies to Add

```yaml
# pubspec.yaml
dependencies:
  provider: ^6.1.1
  table_calendar: ^3.0.9 # For date selection UI
```

---

_Happy integrating! 🚀_
