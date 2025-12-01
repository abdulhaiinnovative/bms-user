# 🚀 Quick Reference Guide - Booking System

> A developer-friendly quick reference for the booking system architecture

---

## 📍 Navigation Flow

```
Home Screen
    ↓
Search/Browse (search_service_screen_new.dart)
    ↓
Salon Details (salon_details_scrolling_tabs_effect_b.dart)
    ↓
Service Selection (salon_category_and_services_list.dart)
    ↓
Professional Selection (select_professionals.dart)
    ↓
Date & Time Selection (SelectDateScreen.dart)
    ↓
Confirm Booking (confirm_booking_screen.dart)
    ↓
API Call (BookingService.dart)
    ↓
Success Dialog
    ↓
Back to Home (navigator.popUntil)
```

---

## 🗂️ File Structure

### Core Booking Files

```
lib/
├── api_services/
│   └── BookingService.dart           # API calls & dialogs
├── screens/
│   └── test_scroll/
│       ├── salon_category_and_services_list.dart  # Services
│       ├── select_professionals.dart              # Professionals
│       ├── SelectDateScreen.dart                  # Date/Time
│       └── confirm_booking_screen.dart            # Confirmation
└── features/
    └── search/
        └── presentation/
            ├── screens/
            │   └── search_service_screen_new.dart # Search
            └── widgets/
                └── salon_card_new.dart            # Salon Card
```

---

## 🎨 Design Tokens

### Colors

```dart
kPrimaryColor:      Color(0xFF73308B)  // Purple
kPrimaryDarkColor:  Color(0xFF5A2470)  // Dark Purple
Success:            Color(0xFF4CAF50)  // Green
Error:              Color(0xFFF44336)  // Red
Warning:            Color(0xFFFF9800)  // Orange
```

### Typography

```dart
Title:    22px, w900, -0.5 spacing
Heading:  18px, w800, -0.3 spacing
Body:     15px, w500
Caption:  13px, w500
```

### Spacing

```dart
xs: 4px   sm: 8px   md: 12px
lg: 16px  xl: 20px  xxl: 24px
```

### Shadows

```dart
Card Shadow: BoxShadow(
  color: Colors.black.withOpacity(0.06),
  blurRadius: 12,
  offset: Offset(0, 4),
)
```

---

## 🔑 Key Components

### Cart Summary Section

```dart
CartSummarySection(
  totalItems: cartItems.length,
  totalAmount: totalAmount,
  onContinue: () => navigate(),
)
```

### Modern AppBar

```dart
AppBar(
  toolbarHeight: 70,
  // Purple back button (42x42)
  // Salon name (19px, w800)
  // Salon image (48x48)
)
```

### Beautiful Dialogs

```dart
// Loading
_buildLoadingDialog()  // Gradient circles + loader

// Success
_buildSuccessDialog(message, onClose)  // Green + check

// Error
_buildErrorDialog(title, message, onClose)  // Red + error
```

---

## 📡 API Structure

### Booking Creation

```dart
POST /create-booking

Body: {
  "salon_id": int,
  "profession_id": int[],
  "time": "HH:MM, YYYY-MM-DD",
  "payment_status": bool,
  "payment_method": String,
  "total_price": double,
  "booking_type": String,
  "service_id": int[],
  "qty": Map<String, int>,
}

Response: {
  "status": bool,
  "message": String,
  "data": { booking details }
}
```

---

## ✅ Validation Checklist

### Before Professional Screen

- [ ] Cart has at least 1 item
- [ ] Service/deal data is complete

### Before Date Selection

- [ ] Professional selected (or "Any")
- [ ] Professional has working days > 0

### Before Confirmation

- [ ] Date selected
- [ ] Time selected
- [ ] Date is in future
- [ ] Date matches salon active days
- [ ] Time is within salon hours

### Before API Call

- [ ] Payment method selected
- [ ] All required data present
- [ ] User is authenticated

---

## 🐛 Common Issues & Solutions

### Issue: "No available dates"

**Cause:** Professional has zero working days  
**Fix:** Select "Any" or different professional

### Issue: 422 Error

**Cause:** Incomplete profile  
**Fix:** Complete profile screen

### Issue: Cart items lost

**Cause:** Not passed through navigation  
**Fix:** Pass cartItems in arguments

### Issue: Date picker shows no dates

**Cause:** Salon has no active days  
**Fix:** Check salon.activeDays array

---

## 📊 State Management

### Cart State (salon_category_and_services_list.dart)

```dart
Map<dynamic, int> _cartItems = {};
double _totalAmount = 0.0;
```

### Professional State (select_professionals.dart)

```dart
Map<dynamic, String?> selectedProfessionals = {};
// Auto-initialized with "Any"
```

### Date/Time State (SelectDateScreen.dart)

```dart
DateTime? _selectedDay;
String? _selectedTime;
```

### Payment State (confirm_booking_screen.dart)

```dart
String? _paymentMethod = 'Cash';
```

---

## 🔐 Navigation Arguments

### Salon Details → Service Selection

```dart
{
  'item': service/deal,
  'salonDetailsss': salonData,
}
```

### Service Selection → Professional Selection

```dart
{
  'cartItems': Map<dynamic, int>,
  'salonName': String,
  'salonImage': String,
  'salonAddress': String,
  'salon': Salon,
  'salonId': int,
}
```

### Professional Selection → Date Selection

```dart
{
  'selectedProfessionals': Map<dynamic, String?>,
  'cartItems': Map<dynamic, int>,
  // ... salon details
}
```

### Date Selection → Confirm Booking

```dart
{
  'selectedDay': DateTime,
  'selectedTime': String,
  'selectedProfessionals': List<Professional>,
  'cartItems': Map<dynamic, int>,
  // ... salon details
}
```

---

## 🧪 Testing Quick Commands

### Run Tests

```bash
flutter test
```

### Run Specific Test

```bash
flutter test test/booking_test.dart
```

### Check for Errors

```bash
flutter analyze
```

### Format Code

```bash
flutter format lib/
```

---

## 📝 Logging Pattern

```dart
log('════════════════════════════════');
log('🔵 SCREEN NAME - Event Description');
log('════════════════════════════════');
log('📍 Section:');
log('   Key: Value');
log('════════════════════════════════');
```

### Log Emoji Guide

- 🔵 Info/Flow
- 🟢 Success
- 🟡 Warning
- 🔴 Error
- 📍 Location
- 📤 Outgoing data
- 📥 Incoming data
- 🔄 Process

---

## ⚡ Performance Tips

### Images

```dart
// Use CachedNetworkImage
CachedNetworkImage(
  imageUrl: url,
  placeholder: (_, __) => Shimmer(...),
  errorWidget: (_, __, ___) => Icon(...),
)
```

### State Updates

```dart
// Check mounted before setState
if (mounted) setState(() { ... });
```

### Navigation

```dart
// Capture navigator before async
final navigator = Navigator.of(context);
await apiCall();
if (navigator.mounted) navigator.pop();
```

### Lists

```dart
// Use SliverList for long lists
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) => Item(items[index]),
    childCount: items.length,
  ),
)
```

---

## 🎯 Code Patterns

### Widget Building

```dart
// Separate build methods
Widget _buildCard() { ... }
Widget _buildSection() { ... }
Widget _buildItem() { ... }
```

### Error Handling

```dart
try {
  await operation();
} on NetworkException {
  showErrorDialog('Check internet');
} on ValidationException {
  showErrorDialog('Invalid data');
} catch (e) {
  showErrorDialog('Something went wrong');
}
```

### Dialog Display

```dart
await showDialog(
  context: context,
  barrierDismissible: false,  // For critical operations
  builder: (context) => CustomDialog(...),
);
```

---

## 📚 Related Documentation

- 📖 [Complete Documentation](BOOKING_SYSTEM_DOCUMENTATION.md)
- 📋 [TODO List](TODO.md)
- 🏗️ [Architecture Analysis](ARCHITECTURE_ANALYSIS.md)

---

## 🆘 Quick Help

### Need to...

**Add a new service to cart**
→ See `salon_category_and_services_list.dart` → `_handleAddToCart()`

**Validate professional availability**
→ See `select_professionals.dart` → `_validateProfessionalAvailability()`

**Generate time slots**
→ See `SelectDateScreen.dart` → `_generateTimeSlots()`

**Make booking API call**
→ See `BookingService.dart` → `createBooking()`

**Add a custom dialog**
→ See `BookingService.dart` → `_buildLoadingDialog()`, etc.

**Navigate back to home**
→ Use `navigator.popUntil((route) => route.isFirst)`

---

**Version:** 1.0.0  
**Last Updated:** November 30, 2025  
**Maintainer:** Development Team
