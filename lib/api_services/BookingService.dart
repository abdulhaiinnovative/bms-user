import 'dart:convert';
import 'dart:developer';
import 'package:app/screens/complete_profile/complete_profile_screen.dart';
import 'package:app/services/protected_http_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/home/Professional.dart';

class BookingService {
  Future<void> createBooking({
    required BuildContext context,
    required Map<dynamic, int>? cartItems,
    required DateTime? selectedDay,
    required String? selectedTime,
    required List<Professional> selectedProfessionals,
    required String? paymentMethod,
    required String bookingType, // "deal" or "appointment"
  }) async {
    // Log all relevant values
    log('BookingService - createBooking values:');
    log('  salon_id: 1');
    log('  profession_id: ${selectedProfessionals.isNotEmpty ? selectedProfessionals.map((p) => p.id ?? 0).toList() : [
        0
      ]}');
    log('  time: ${selectedTime != null && selectedDay != null ? "$selectedTime, ${DateFormat('yyyy-MM-dd').format(selectedDay)}" : "Not selected"}');
    log('  payment_status: ${paymentMethod == 'Cash' ? true : false}');
    log('  total_price: ${cartItems?.entries.fold<double>(0, (sum, entry) => sum + (entry.key.price ?? 0) * entry.value) ?? 0}');
    log('  booking_type: $bookingType');
    if (bookingType == 'appointment' && cartItems != null) {
      log('  service_id: ${cartItems.keys.map((s) => s.id ?? 0).toList()}');
      log('  qty: ${cartItems.map((s, q) => MapEntry(s.id.toString(), q))}');
    } else if (bookingType == 'deal') {
      log('  deal_id: 1');
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Processing booking...'),
          ],
        ),
      ),
    );

    try {
      // Prepare the payload

      final Map<String, dynamic> payload = {
        "salon_id": 1,
        "profession_id": selectedProfessionals.isNotEmpty
            ? selectedProfessionals.map((p) => p.id ?? 0).toList()
            : [0],
        "time": (selectedTime != null && selectedDay != null)
            ? "$selectedTime, ${DateFormat('yyyy-MM-dd').format(selectedDay)}"
            : null,
        "payment_status": paymentMethod == 'Cash',
        "total_price": cartItems?.entries.fold<double>(
              0,
              (sum, entry) => sum + (entry.key.price ?? 0) * entry.value,
            ) ??
            0,
        "booking_type": bookingType,
      };

      // Debugging
      print('====== cartItems?.length: ${cartItems?.length}');
      print(
          '====== bookingType == appointment: ${bookingType == 'appointment'}');
      print('====== cartItems != null: ${cartItems != null}');

      // Booking type specific fields
      if (bookingType == 'appointment' && cartItems != null) {
        payload["service_id"] =
            cartItems.keys.map((service) => service.id ?? 0).toList();

        payload["qty"] = cartItems.map(
            (service, qty) => MapEntry(service.id?.toString() ?? '0', qty));

        print('Appointment payload: $payload');
      } else if (bookingType == 'deal') {
        payload["deal_id"] = 1;
        print('Deal payload: $payload');
      }

      log('payload:: $payload');
      log('payload:jsonEncode: ${jsonEncode(payload)}');

      // Make the POST API call using ProtectedHttpClient
      final response = await ProtectedHttpClient.post(
        '/create-booking',
        body: payload,
      );

      // Close loading dialog
      Navigator.pop(context);

      // Handle response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          // Show success dialog
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success'),
              content: Text(
                  responseData['message'] ?? 'Booking created successfully!'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                    // Optionally navigate back
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        } else {
          // Show error dialog for unsuccessful status
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content:
                  Text(responseData['message'] ?? 'Failed to create booking.'),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      } else {
        // Show error dialog for non-200 status code

        if (response.statusCode == 422) {
          print(response.body);
          final responseData = jsonDecode(response.body);
          final message = responseData['message'] ?? 'Something went wrong.';

          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Oops!'),
              content: Text('Failed to create booking.\n$message'),
              actions: [
                TextButton(
                  child: const Text('No'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () => {
                    Navigator.pop(context),
                    Navigator.pushNamed(
                        context, CompleteProfileScreen.routeName)
                  },
                ),
              ],
            ),
          );
        } else {
          print(response.body);
          final responseData = jsonDecode(response.body);
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content:
                  Text(responseData['message'] ?? 'Failed to create booking.'),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error dialog for network or other errors
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred: $e'),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      log('Error in BookingService.createBooking: $e');
    }
  }
}
