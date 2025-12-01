# Booking Create API - Flutter Implementation Guide

## Overview

This document provides a comprehensive guide for implementing the booking creation functionality in a Flutter application for the BookMySpot platform.

---

## API Endpoint

| Property       | Value                          |
|----------------|--------------------------------|
| **URL**        | `POST /api/create-booking`     |
| **Method**     | `POST`                         |
| **Auth**       | Required (Bearer Token)        |
| **Content-Type** | `application/json`           |

---

## Authentication

Include the Bearer token in the request headers:

```dart
headers: {
  'Authorization': 'Bearer $accessToken',
  'Content-Type': 'application/json',
  'Accept': 'application/json',
}
```

---

## Request Parameters

### Required Parameters

| Parameter       | Type       | Description                                          |
|-----------------|------------|------------------------------------------------------|
| `salon_id`      | `int`      | The ID of the salon where booking is made            |
| `time`          | `string`   | Time and date in format `'HH:mm, YYYY-MM-DD'`        |
| `total_price`   | `double`   | Total price of the booking                           |
| `payment_status`| `bool`     | `true` for cash, `false` for online payment          |

### Optional Parameters

| Parameter             | Type         | Description                                              |
|-----------------------|--------------|----------------------------------------------------------|
| `service_id`          | `List<int>`  | Array of service IDs to book                             |
| `profession_id`       | `List<int>`  | Array of professional/team IDs (matching service_id)     |
| `deal_id`             | `int/List<int>` | Deal ID(s) to include in booking                      |
| `loyalty_points_used` | `int`        | Number of loyalty points to redeem (default: 0)          |
| `booking_type`        | `string`     | Type of booking (default: `'appointment'`)               |
| `qty`                 | `Map<int, int>` | Map of service_id to quantity                         |
| `variation`           | `Map<int, int>` | Map of service_id to variation_id                     |

---

## Request Payload Examples

### Basic Booking with Services

```json
{
  "salon_id": 1,
  "time": "'10:30', '2024-12-15'",
  "total_price": 150.00,
  "payment_status": true,
  "service_id": [1, 2, 3],
  "profession_id": [5, 5, 6],
  "booking_type": "appointment"
}
```

### Booking with Loyalty Points

```json
{
  "salon_id": 1,
  "time": "'14:00', '2024-12-20'",
  "total_price": 200.00,
  "payment_status": false,
  "service_id": [4, 5],
  "profession_id": [7, 8],
  "loyalty_points_used": 50,
  "booking_type": "appointment"
}
```

### Booking with Deal

```json
{
  "salon_id": 1,
  "time": "'11:00', '2024-12-18'",
  "total_price": 99.00,
  "payment_status": true,
  "deal_id": 3
}
```

### Booking with Multiple Deals

```json
{
  "salon_id": 1,
  "time": "'16:30', '2024-12-22'",
  "total_price": 180.00,
  "payment_status": false,
  "deal_id": [1, 2]
}
```

### Booking with Services and Deal Combined

```json
{
  "salon_id": 1,
  "time": "'09:00', '2024-12-25'",
  "total_price": 250.00,
  "payment_status": true,
  "service_id": [1, 2],
  "profession_id": [3, 4],
  "deal_id": 5,
  "loyalty_points_used": 25
}
```

### Booking with Service Quantities and Variations

```json
{
  "salon_id": 1,
  "time": "'13:00', '2024-12-28'",
  "total_price": 300.00,
  "payment_status": true,
  "service_id": [1, 2],
  "profession_id": [3, 4],
  "qty": {
    "1": 2,
    "2": 1
  },
  "variation": {
    "1": 10,
    "2": null
  }
}
```

### Booking with No Specific Professional (Any Available)

```json
{
  "salon_id": 1,
  "time": "'15:00', '2024-12-30'",
  "total_price": 120.00,
  "payment_status": true,
  "service_id": [1, 2, 3],
  "profession_id": [0, 0, 0]
}
```

---

## Response Examples

### Success Response (200 OK)

```json
{
  "success": true,
  "message": "Booking created successfully!",
  "data": {
    "id": 123,
    "salon_id": 1,
    "user_id": 45,
    "team_id": 5,
    "date": "2024-12-15",
    "time": "10:30:00",
    "payment_method": "cash",
    "payment": 150.00,
    "payment_status": "pending",
    "status": "booked",
    "booking_type": "appointment",
    "commission": 15.00,
    "used_loyalty_points": false,
    "created_at": "2024-12-01T10:30:00.000000Z"
  }
}
```

### Error Responses

#### Invalid Salon (422)

```json
{
  "success": false,
  "message": "Invalid salon",
  "data": []
}
```

#### Invalid Vendor (422)

```json
{
  "success": false,
  "message": "Invalid vendor",
  "data": []
}
```

#### Incomplete Profile (422)

```json
{
  "success": false,
  "message": "Please complete your profile before booking.\nWould you like to complete it now?",
  "data": []
}
```

#### Profession/Service Mismatch (422)

```json
{
  "success": false,
  "message": "Profession and service count mismatch!",
  "data": []
}
```

#### Internal Server Error (500)

```json
{
  "success": false,
  "message": "Error message details",
  "data": []
}
```

---

## Flutter Implementation

### 1. Models

#### Booking Request Model

```dart
class BookingRequest {
  final int salonId;
  final String time;
  final double totalPrice;
  final bool paymentStatus;
  final List<int>? serviceId;
  final List<int>? professionId;
  final dynamic dealId; // Can be int or List<int>
  final int? loyaltyPointsUsed;
  final String? bookingType;
  final Map<int, int>? qty;
  final Map<int, int?>? variation;

  BookingRequest({
    required this.salonId,
    required this.time,
    required this.totalPrice,
    required this.paymentStatus,
    this.serviceId,
    this.professionId,
    this.dealId,
    this.loyaltyPointsUsed,
    this.bookingType,
    this.qty,
    this.variation,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'salon_id': salonId,
      'time': time,
      'total_price': totalPrice,
      'payment_status': paymentStatus,
    };

    if (serviceId != null && serviceId!.isNotEmpty) {
      data['service_id'] = serviceId;
    }

    if (professionId != null && professionId!.isNotEmpty) {
      data['profession_id'] = professionId;
    }

    if (dealId != null) {
      data['deal_id'] = dealId;
    }

    if (loyaltyPointsUsed != null && loyaltyPointsUsed! > 0) {
      data['loyalty_points_used'] = loyaltyPointsUsed;
    }

    if (bookingType != null) {
      data['booking_type'] = bookingType;
    }

    if (qty != null && qty!.isNotEmpty) {
      data['qty'] = qty!.map((key, value) => MapEntry(key.toString(), value));
    }

    if (variation != null && variation!.isNotEmpty) {
      data['variation'] = variation!.map((key, value) => MapEntry(key.toString(), value));
    }

    return data;
  }
}
```

#### Booking Response Model

```dart
class BookingResponse {
  final int id;
  final int salonId;
  final int userId;
  final int teamId;
  final String date;
  final String time;
  final String paymentMethod;
  final double payment;
  final String paymentStatus;
  final String status;
  final String bookingType;
  final double commission;
  final bool usedLoyaltyPoints;
  final DateTime createdAt;

  BookingResponse({
    required this.id,
    required this.salonId,
    required this.userId,
    required this.teamId,
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
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      id: json['id'] ?? 0,
      salonId: json['salon_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      teamId: json['team_id'] ?? 0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      payment: (json['payment'] ?? 0).toDouble(),
      paymentStatus: json['payment_status'] ?? '',
      status: json['status'] ?? '',
      bookingType: json['booking_type'] ?? '',
      commission: (json['commission'] ?? 0).toDouble(),
      usedLoyaltyPoints: json['used_loyalty_points'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
```

#### API Response Wrapper

```dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}
```

### 2. API Service

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingService {
  final String baseUrl;
  final String? authToken;

  BookingService({required this.baseUrl, this.authToken});

  Future<ApiResponse<BookingResponse>> createBooking(BookingRequest request) async {
    try {
      final url = Uri.parse('$baseUrl/api/create-booking');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<BookingResponse>.fromJson(
          jsonResponse,
          (data) => BookingResponse.fromJson(data),
        );
      } else {
        return ApiResponse<BookingResponse>(
          success: false,
          message: jsonResponse['message'] ?? 'Booking failed',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<BookingResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
        data: null,
      );
    }
  }
}
```

### 3. Using with Dio (Alternative)

```dart
import 'package:dio/dio.dart';

class BookingRepository {
  final Dio _dio;
  
  BookingRepository(this._dio);

  Future<ApiResponse<BookingResponse>> createBooking(BookingRequest request) async {
    try {
      final response = await _dio.post(
        '/api/create-booking',
        data: request.toJson(),
      );

      return ApiResponse<BookingResponse>.fromJson(
        response.data,
        (data) => BookingResponse.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<BookingResponse>(
        success: false,
        message: e.response?.data['message'] ?? 'Booking failed',
        data: null,
      );
    }
  }
}
```

### 4. Helper Function for Time Formatting

```dart
class BookingHelper {
  /// Formats DateTime to the required API format
  /// Returns format: "'HH:mm', 'YYYY-MM-DD'"
  static String formatBookingTime(DateTime dateTime) {
    final time = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    final date = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    return "'$time', '$date'";
  }

  /// Alternative: Format from separate TimeOfDay and DateTime
  static String formatBookingTimeFromParts(TimeOfDay time, DateTime date) {
    final timeStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return "'$timeStr', '$dateStr'";
  }
}
```

### 5. Complete Usage Example

```dart
class BookingScreen extends StatefulWidget {
  final int salonId;
  final List<ServiceItem> selectedServices;
  final List<int> selectedProfessionals;
  final DealItem? selectedDeal;
  final double totalPrice;
  final int loyaltyPoints;

  const BookingScreen({
    Key? key,
    required this.salonId,
    required this.selectedServices,
    required this.selectedProfessionals,
    this.selectedDeal,
    required this.totalPrice,
    this.loyaltyPoints = 0,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isCashPayment = true;
  bool isLoading = false;

  Future<void> createBooking() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final bookingService = BookingService(
        baseUrl: 'https://your-api-base-url.com',
        authToken: await getAuthToken(), // Get from your auth service
      );

      final request = BookingRequest(
        salonId: widget.salonId,
        time: BookingHelper.formatBookingTimeFromParts(selectedTime!, selectedDate!),
        totalPrice: widget.totalPrice,
        paymentStatus: isCashPayment,
        serviceId: widget.selectedServices.map((s) => s.id).toList(),
        professionId: widget.selectedProfessionals,
        dealId: widget.selectedDeal?.id,
        loyaltyPointsUsed: widget.loyaltyPoints,
        bookingType: 'appointment',
      );

      final response = await bookingService.createBooking(request);

      if (response.success && response.data != null) {
        // Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingSuccessScreen(booking: response.data!),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );

        // Handle specific error cases
        if (response.message.contains('complete your profile')) {
          _showCompleteProfileDialog();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showCompleteProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Incomplete Profile'),
        content: const Text('Please complete your profile before booking. Would you like to complete it now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: const Text('Complete Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Your UI implementation
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Column(
        children: [
          // Date picker, time picker, payment method selection, etc.
          // ...
          ElevatedButton(
            onPressed: isLoading ? null : createBooking,
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }
}
```

---

## Important Notes

### Time Format
The `time` parameter must be in the format: `'HH:mm', 'YYYY-MM-DD'`
- Include single quotes around time and date
- Separate with comma and space

### Profession ID Rules
- If `profession_id` array contains all zeros (e.g., `[0, 0, 0]`), it means "any available professional"
- The `profession_id` array must match the length of `service_id` array, unless all are `0`

### Payment Status
- `true` = Cash payment
- `false` = Online payment

### Loyalty Points
- User must have sufficient loyalty points (`user.loyalty >= loyalty_points_used`)
- Points are deducted immediately upon booking creation

### Profile Completion
- User must have `complete_status >= 100` to create a booking
- If incomplete, redirect user to profile completion screen

### Booking Status Flow
```
booked → confirmed → in_progress → complete
                  ↘ cancelled by customer
                  ↘ cancelled by vendor
```

---

## Error Handling Checklist

1. ✅ Check for network connectivity before API call
2. ✅ Validate required fields before sending request
3. ✅ Handle authentication errors (401)
4. ✅ Handle validation errors (422)
5. ✅ Handle server errors (500)
6. ✅ Show appropriate user feedback for each error type
7. ✅ Handle profile completion requirement
8. ✅ Validate profession/service count match

---

## Testing Scenarios

| Scenario | Expected Result |
|----------|-----------------|
| Valid booking with services | Success, booking created |
| Valid booking with deal | Success, booking created |
| Invalid salon_id | 422 - Invalid salon |
| Incomplete user profile | 422 - Profile completion required |
| Mismatched profession/service arrays | 422 - Mismatch error |
| Insufficient loyalty points | Points not deducted, booking proceeds |
| No auth token | 401 - Unauthorized |

---

## Related Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/appointments` | GET | Get user's bookings |
| `/api/booking-detail/{id}` | GET | Get booking details |
| `/api/cancel-booking` | POST | Cancel a booking |
| `/api/apply-voucher` | POST | Apply voucher to booking |
| `/api/create-review` | POST | Create review for booking |

---

*Last Updated: November 30, 2025*
