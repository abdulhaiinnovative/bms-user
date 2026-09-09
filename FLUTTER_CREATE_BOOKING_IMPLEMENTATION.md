# Flutter Create Booking API Implementation Guide

## Overview
This document provides a complete Flutter implementation for the `/api/create-booking` endpoint in the BookMySpot application. This API allows users to create salon service bookings with various options including service selection, professional assignment, payment methods, and loyalty points redemption.

## Table of Contents
1. [API Endpoint Details](#api-endpoint-details)
2. [Authentication](#authentication)
3. [Request Payload](#request-payload)
4. [Response Format](#response-format)
5. [Flutter Implementation](#flutter-implementation)
6. [Error Handling](#error-handling)
7. [Usage Examples](#usage-examples)
8. [Important Notes](#important-notes)

---

## API Endpoint Details

### Endpoint
```
POST /api/create-booking
```

### Authentication Required
Yes - Bearer Token required in headers

### Middleware
- `auth:api` - API authentication
- `checkTokenExpiry` - Token expiry validation

---

## Authentication

### Headers Required
```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer {your_access_token}
```

---

## Request Payload

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `salon_id` | integer | ID of the salon | `1` |
| `service_id` | array<integer> | Array of service IDs | `[5, 7, 12]` |
| `profession_id` | array<integer> | Array of professional IDs (use 0 for no preference) | `[3, 3, 0]` |
| `time` | string | Appointment time in format "HH:MM AM/PM, YYYY-MM-DD" | `"02:30 PM, 2025-12-15"` |
| `total_price` | number | Total booking price | `150.00` |
| `payment_status` | boolean | `true` for cash, `false` for online | `true` |

### Optional Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `booking_type` | string | Type of booking (default: "appointment") | `"appointment"` or `"walk-in"` |
| `loyalty_points_used` | integer | Number of loyalty points to redeem | `10` |
| `deal_id` | integer/array | Deal ID(s) to include | `5` or `[5, 7]` |
| `qty` | object | Quantity for each service (service_id => qty) | `{"5": 1, "7": 2}` |
| `variation` | object | Variation ID for each service (service_id => variation_id) | `{"5": 1, "7": 3}` |

### Complete JSON Payload Example

```json
{
  "salon_id": 1,
  "service_id": [5, 7, 12],
  "profession_id": [3, 3, 0],
  "time": "02:30 PM, 2025-12-15",
  "total_price": 150.00,
  "payment_status": true,
  "booking_type": "appointment",
  "loyalty_points_used": 10,
  "qty": {
    "5": 1,
    "7": 2,
    "12": 1
  },
  "variation": {
    "5": 1,
    "7": 3
  }
}
```

---

## Response Format

### Success Response (200/201)

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
    "payment": 150.00,
    "payment_status": "pending",
    "status": "booked",
    "booking_type": "appointment",
    "commission": 15.00,
    "used_loyalty_points": 1,
    "created_at": "2025-12-10T10:30:00.000000Z",
    "updated_at": "2025-12-10T10:30:00.000000Z"
  }
}
```

### Error Response (422 - Validation Error)

```json
{
  "success": false,
  "message": "Please complete your profile before booking.\nWould you like to complete it now?",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

### Error Response (401 - Unauthorized)

```json
{
  "success": false,
  "message": "Unauthorized"
}
```

---

## Flutter Implementation

### 1. Model Classes

#### booking_request.dart
```dart
class CreateBookingRequest {
  final int salonId;
  final List<int> serviceIds;
  final List<int> professionIds;
  final String time; // Format: "HH:MM AM/PM, YYYY-MM-DD"
  final double totalPrice;
  final bool paymentStatus; // true for cash, false for online
  final String? bookingType; // 'appointment' or 'walk-in'
  final int? loyaltyPointsUsed;
  final int? dealId;
  final Map<int, int>? qty; // service_id => quantity
  final Map<int, int>? variation; // service_id => variation_id

  CreateBookingRequest({
    required this.salonId,
    required this.serviceIds,
    required this.professionIds,
    required this.time,
    required this.totalPrice,
    required this.paymentStatus,
    this.bookingType = 'appointment',
    this.loyaltyPointsUsed,
    this.dealId,
    this.qty,
    this.variation,
  });

  Map<String, dynamic> toJson() {
    return {
      'salon_id': salonId,
      'service_id': serviceIds,
      'profession_id': professionIds,
      'time': time,
      'total_price': totalPrice,
      'payment_status': paymentStatus,
      'booking_type': bookingType,
      if (loyaltyPointsUsed != null) 'loyalty_points_used': loyaltyPointsUsed,
      if (dealId != null) 'deal_id': dealId,
      if (qty != null) 'qty': qty,
      if (variation != null) 'variation': variation,
    };
  }
}
```

#### booking_response.dart
```dart
class BookingResponse {
  final int id;
  final int salonId;
  final int userId;
  final int? teamId;
  final String date;
  final String time;
  final String paymentMethod;
  final double payment;
  final String paymentStatus;
  final String status;
  final String bookingType;
  final double commission;
  final bool usedLoyaltyPoints;
  final String createdAt;
  final String updatedAt;

  BookingResponse({
    required this.id,
    required this.salonId,
    required this.userId,
    this.teamId,
    required this.date,
    required this.time,
    required this.paymentMethod,
    required this.payment,
    required this.paymentStatus,
    required this.status,
    required this.bookingType,
    required this.commission,
    required this.usedLoyaltyPoints,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      id: json['id'],
      salonId: json['salon_id'],
      userId: json['user_id'],
      teamId: json['team_id'],
      date: json['date'],
      time: json['time'],
      paymentMethod: json['payment_method'],
      payment: double.parse(json['payment'].toString()),
      paymentStatus: json['payment_status'],
      status: json['status'],
      bookingType: json['booking_type'],
      commission: double.parse(json['commission'].toString()),
      usedLoyaltyPoints: json['used_loyalty_points'] == 1,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_id': salonId,
      'user_id': userId,
      'team_id': teamId,
      'date': date,
      'time': time,
      'payment_method': paymentMethod,
      'payment': payment,
      'payment_status': paymentStatus,
      'status': status,
      'booking_type': bookingType,
      'commission': commission,
      'used_loyalty_points': usedLoyaltyPoints,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
```

#### api_response.dart
```dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      errors: json['errors'],
    );
  }
}
```

### 2. API Service

#### booking_api_service.dart
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingApiService {
  final String baseUrl;
  final String authToken;

  BookingApiService({
    required this.baseUrl,
    required this.authToken,
  });

  /// Creates a new booking
  Future<ApiResponse<BookingResponse>> createBooking(
    CreateBookingRequest request,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/create-booking');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<BookingResponse>(
          success: data['success'] ?? true,
          message: data['message'] ?? 'Booking created successfully!',
          data: BookingResponse.fromJson(data['data']),
        );
      } else if (response.statusCode == 422) {
        // Validation error
        return ApiResponse<BookingResponse>(
          success: false,
          message: data['message'] ?? 'Validation error',
          errors: data['errors'],
        );
      } else if (response.statusCode == 401) {
        return ApiResponse<BookingResponse>(
          success: false,
          message: 'Unauthorized. Please login again.',
        );
      } else {
        return ApiResponse<BookingResponse>(
          success: false,
          message: data['message'] ?? 'Failed to create booking',
        );
      }
    } on http.ClientException catch (e) {
      return ApiResponse<BookingResponse>(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      return ApiResponse<BookingResponse>(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }
}
```

### 3. State Management (Provider)

#### booking_controller.dart
```dart
import 'package:flutter/material.dart';

class BookingController extends ChangeNotifier {
  final BookingApiService _apiService;
  
  bool _isLoading = false;
  String? _errorMessage;
  BookingResponse? _booking;

  BookingController(this._apiService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BookingResponse? get booking => _booking;

  /// Creates a booking with the given parameters
  Future<bool> createBooking({
    required int salonId,
    required List<int> serviceIds,
    required List<int> professionIds,
    required DateTime date,
    required TimeOfDay time,
    required double totalPrice,
    required bool isCashPayment,
    String bookingType = 'appointment',
    int? loyaltyPointsUsed,
    int? dealId,
    Map<int, int>? qty,
    Map<int, int>? variation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Format time as required by API: "HH:MM AM/PM, YYYY-MM-DD"
      final formattedTime = _formatDateTime(date, time);

      final request = CreateBookingRequest(
        salonId: salonId,
        serviceIds: serviceIds,
        professionIds: professionIds,
        time: formattedTime,
        totalPrice: totalPrice,
        paymentStatus: isCashPayment,
        bookingType: bookingType,
        loyaltyPointsUsed: loyaltyPointsUsed,
        dealId: dealId,
        qty: qty,
        variation: variation,
      );

      final response = await _apiService.createBooking(request);

      if (response.success && response.data != null) {
        _booking = response.data;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Formats DateTime and TimeOfDay to the required API format
  String _formatDateTime(DateTime date, TimeOfDay time) {
    // Convert TimeOfDay to 12-hour format with AM/PM
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final timeString = '${hour == 0 ? 12 : hour}:$minute $period';

    // Format date as YYYY-MM-DD
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return '$timeString, $dateString';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearBooking() {
    _booking = null;
    notifyListeners();
  }
}
```

### 4. UI Implementation

#### booking_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingScreen extends StatefulWidget {
  final int salonId;
  final String salonName;
  final List<ServiceModel> selectedServices;
  final List<ProfessionalModel> selectedProfessionals;

  const BookingScreen({
    Key? key,
    required this.salonId,
    required this.salonName,
    required this.selectedServices,
    required this.selectedProfessionals,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isCashPayment = true;
  int loyaltyPointsToUse = 0;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotalPrice();
  }

  void _calculateTotalPrice() {
    totalPrice = widget.selectedServices.fold(
      0.0,
      (sum, service) => sum + service.price,
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  Future<void> _createBooking() async {
    if (selectedDate == null || selectedTime == null) {
      _showErrorSnackBar('Please select date and time');
      return;
    }

    final controller = context.read<BookingController>();

    final success = await controller.createBooking(
      salonId: widget.salonId,
      serviceIds: widget.selectedServices.map((s) => s.id).toList(),
      professionIds: widget.selectedProfessionals.map((p) => p.id).toList(),
      date: selectedDate!,
      time: selectedTime!,
      totalPrice: totalPrice - loyaltyPointsToUse,
      isCashPayment: isCashPayment,
      loyaltyPointsUsed: loyaltyPointsToUse > 0 ? loyaltyPointsToUse : null,
    );

    if (success && mounted) {
      // Navigate to booking confirmation
      Navigator.pushReplacementNamed(
        context,
        '/booking-confirmation',
        arguments: controller.booking,
      );
    } else if (mounted) {
      _showErrorSnackBar(
        controller.errorMessage ?? 'Failed to create booking',
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        elevation: 0,
      ),
      body: Consumer<BookingController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salon Info Card
                _buildSalonInfoCard(),
                const SizedBox(height: 20),

                // Selected Services
                _buildSelectedServices(),
                const SizedBox(height: 20),

                // Date & Time Selection
                _buildDateTimeSection(),
                const SizedBox(height: 20),

                // Payment Method
                _buildPaymentMethodSection(),
                const SizedBox(height: 20),

                // Loyalty Points Section
                _buildLoyaltyPointsSection(),
                const SizedBox(height: 20),

                // Price Summary
                _buildPriceSummary(),
                const SizedBox(height: 30),

                // Book Button
                _buildBookButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSalonInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.store, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.salonName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.selectedServices.length} service(s) selected',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...widget.selectedServices.map((service) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(service.name),
                subtitle: Text(service.duration),
                trailing: Text(
                  '\$${service.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date & Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(
                  selectedDate != null
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : 'Not selected',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectDate,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Time'),
                subtitle: Text(
                  selectedTime?.format(context) ?? 'Not selected',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectTime,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              RadioListTile<bool>(
                title: const Text('Cash Payment'),
                subtitle: const Text('Pay at salon'),
                value: true,
                groupValue: isCashPayment,
                onChanged: (value) => setState(() => isCashPayment = value!),
              ),
              const Divider(height: 1),
              RadioListTile<bool>(
                title: const Text('Online Payment'),
                subtitle: const Text('Pay now'),
                value: false,
                groupValue: isCashPayment,
                onChanged: (value) => setState(() => isCashPayment = value!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoyaltyPointsSection() {
    // Implement loyalty points UI
    return const SizedBox.shrink();
  }

  Widget _buildPriceSummary() {
    final finalPrice = totalPrice - loyaltyPointsToUse;
    
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text('\$${totalPrice.toStringAsFixed(2)}'),
              ],
            ),
            if (loyaltyPointsToUse > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Loyalty Points:'),
                  Text(
                    '-\$${loyaltyPointsToUse.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${finalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _createBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Confirm Booking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
```

---

## Error Handling

### Common Errors and Solutions

| Error Code | Error Type | Solution |
|------------|------------|----------|
| 401 | Unauthorized | User needs to login again - redirect to login |
| 422 | Validation Error | Display validation messages to user |
| 500 | Server Error | Show generic error message, retry option |
| Network Error | Connection Issue | Check internet connection, retry |

### Example Error Handler

```dart
void handleBookingError(ApiResponse<BookingResponse> response) {
  if (response.errors != null) {
    // Handle validation errors
    response.errors!.forEach((field, messages) {
      debugPrint('$field: ${messages.join(", ")}');
    });
  }
  
  // Show user-friendly message
  if (response.message.contains('profile')) {
    // Profile incomplete - navigate to profile completion
    Navigator.pushNamed(context, '/complete-profile');
  } else if (response.message.contains('Unauthorized')) {
    // Token expired - navigate to login
    Navigator.pushReplacementNamed(context, '/login');
  } else {
    // Generic error
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Failed'),
        content: Text(response.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

---

## Usage Examples

### Example 1: Basic Booking

```dart
final controller = BookingController(apiService);

await controller.createBooking(
  salonId: 1,
  serviceIds: [5, 7],
  professionIds: [3, 3],
  date: DateTime(2025, 12, 15),
  time: TimeOfDay(hour: 14, minute: 30),
  totalPrice: 100.00,
  isCashPayment: true,
);
```

### Example 2: Booking with Loyalty Points

```dart
await controller.createBooking(
  salonId: 1,
  serviceIds: [5, 7, 12],
  professionIds: [3, 0, 4],
  date: DateTime(2025, 12, 20),
  time: TimeOfDay(hour: 10, minute: 0),
  totalPrice: 200.00,
  isCashPayment: false,
  loyaltyPointsUsed: 20,
);
```

### Example 3: Booking with Deal

```dart
await controller.createBooking(
  salonId: 1,
  serviceIds: [5, 7],
  professionIds: [3, 3],
  date: DateTime(2025, 12, 18),
  time: TimeOfDay(hour: 16, minute: 0),
  totalPrice: 150.00,
  isCashPayment: true,
  dealId: 5,
);
```

### Example 4: Booking with Quantities and Variations

```dart
await controller.createBooking(
  salonId: 1,
  serviceIds: [5, 7, 12],
  professionIds: [3, 3, 0],
  date: DateTime(2025, 12, 25),
  time: TimeOfDay(hour: 11, minute: 30),
  totalPrice: 180.00,
  isCashPayment: false,
  qty: {5: 1, 7: 2, 12: 1},
  variation: {5: 1, 7: 3},
);
```

---

## Important Notes

### 1. Time Format
- **Required Format**: `"HH:MM AM/PM, YYYY-MM-DD"`
- **Example**: `"02:30 PM, 2025-12-15"`
- The API expects this exact format. Make sure to format correctly using the helper function provided.

### 2. Profession and Service Arrays
- Must have **equal length** unless all profession IDs are `0`
- Use `0` for profession_id when user doesn't care about which professional
- **Example**:
  ```json
  "service_id": [5, 7, 12],
  "profession_id": [3, 0, 4]  // Service 7 has no preference
  ```

### 3. Payment Status Boolean
- `true` = Cash payment (pay at salon)
- `false` = Online payment (pay now)

### 4. Profile Completion
- User must have `complete_status >= 100` to create booking
- If not complete, API returns validation error
- Handle this by redirecting to profile completion

### 5. Loyalty Points
- Points are deducted immediately when booking is created
- If booking fails after points deduction, they are not automatically refunded
- Ensure proper error handling

### 6. Commission Calculation
- Automatically calculated based on vendor's commission rate
- Formula: `(total_price / 100) * vendor_commission`

### 7. Notifications
- System automatically sends notifications to:
  - User (booking confirmation)
  - Vendor (new booking alert)
  - Admin (booking created)

### 8. Loyalty Points Addition
- Points are added to user's account **1 day after booking** (queued job)
- Not immediate - delayed to prevent abuse

### 9. Booking Status Flow
- Initial status: `"booked"`
- Payment status: `"pending"`
- These can be updated by vendor/admin later

### 10. Background Process
- Savings calculation (if service has old_price)
- ServicesProfessional entries creation
- BookingService entries creation
- All handled automatically by the API

---

## Testing Checklist

- [ ] Basic booking creation works
- [ ] Date/time picker formats correctly
- [ ] Payment method selection works
- [ ] Loyalty points redemption works
- [ ] Deal inclusion works
- [ ] Service quantities work
- [ ] Service variations work
- [ ] Error messages display correctly
- [ ] Loading states show properly
- [ ] Success navigation works
- [ ] Profile incomplete error handled
- [ ] Token expiry handled
- [ ] Network errors handled
- [ ] Validation errors displayed

---

## Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.0.5  # or your preferred state management
  intl: ^0.18.0     # for date/time formatting
```

---

## Additional Resources

- [API Routes File](../routes/api.php)
- [Booking Controller](../app/Http/Controllers/Api/BookingController.php)
- [Booking Model](../app/Models/Booking.php)
- [Loyalty Points Documentation](./LOYALTY_POINTS.md)
- [Notification System](./NOTIFICATION_SYSTEM.md)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12-10 | Initial documentation |

---

## Support

For issues or questions:
1. Check the error message from API response
2. Verify payload format matches examples
3. Ensure authentication token is valid
4. Check user profile completion status
5. Review Laravel logs for server-side errors

---

**Last Updated**: December 10, 2025
