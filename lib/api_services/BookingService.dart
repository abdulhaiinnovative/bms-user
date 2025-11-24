import 'dart:convert';
import 'dart:developer';
import 'package:app/features/auth/presentation/screens/complete_profile/complete_profile_screen.dart';
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
    log('════════════════════════════════════════════════════════');
    log('🔄 BOOKING SERVICE - CREATE BOOKING API CALL');
    log('════════════════════════════════════════════════════════');
    log('📤 Preparing API payload...');
    log('');
    log('🏢 Basic Details:');
    log('   salon_id: 1');
    log('   booking_type: $bookingType');
    log('   payment_status: ${paymentMethod == 'Cash'}');
    log('   payment_method: $paymentMethod');
    log('');
    log('👨‍⚕️ Professionals:');
    log('   profession_id: ${selectedProfessionals.isNotEmpty ? selectedProfessionals.map((p) => p.id ?? 0).toList() : [0]}');
    selectedProfessionals.forEach((prof) {
      log('   - ${prof.name} (ID: ${prof.id})');
    });
    log('');
    log('📅 Booking Time:');
    final formattedTime = selectedTime != null && selectedDay != null 
        ? "$selectedTime, ${DateFormat('yyyy-MM-dd').format(selectedDay)}" 
        : "Not selected";
    log('   time: $formattedTime');
    log('   date: ${selectedDay != null ? DateFormat('yyyy-MM-dd').format(selectedDay) : "Not selected"}');
    log('   time_slot: ${selectedTime ?? "Not selected"}');
    log('');
    
    final totalPrice = cartItems?.entries.fold<double>(
      0, 
      (sum, entry) => sum + (entry.key.price ?? 0) * entry.value
    ) ?? 0;
    log('💰 Pricing:');
    log('   total_price: PKR $totalPrice');
    log('');
    
    if (bookingType == 'appointment' && cartItems != null) {
      log('📦 Services (Appointment):');
      final serviceIds = cartItems.keys.map((s) => s.id ?? 0).toList();
      final quantities = cartItems.map((s, q) => MapEntry(s.id.toString(), q));
      log('   service_id: $serviceIds');
      log('   qty: $quantities');
      cartItems.forEach((key, value) {
        log('   - Service ID: ${key.id}, Name: ${key.name}, Qty: $value, Price: PKR ${key.price}');
      });
    } else if (bookingType == 'deal') {
      log('🎁 Deal:');
      log('   deal_id: 1');
    }
    log('════════════════════════════════════════════════════════');

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

      log('');
      log('📋 FINAL REQUEST PAYLOAD:');
      log('────────────────────────────────────────────────────────');
      
      // Pretty print request JSON
      final prettyRequestJson = JsonEncoder.withIndent('  ').convert(payload);
      log(prettyRequestJson);
      
      log('────────────────────────────────────────────────────────');
      log('════════════════════════════════════════════════════════');
      log('');
      log('🌐 Making POST request to /create-booking...');

      // Make the POST API call using ProtectedHttpClient
      final response = await ProtectedHttpClient.post(
        '/create-booking',
        body: payload,
      );

      log('');
      log('════════════════════════════════════════════════════════');
      log('📥 CREATE BOOKING API - RAW RESPONSE');
      log('════════════════════════════════════════════════════════');
      log('Status Code: ${response.statusCode}');
      log('');
      log('📄 RAW JSON RESPONSE:');
      log('────────────────────────────────────────────────────────');
      
      try {
        // Pretty print response JSON
        final responseJson = jsonDecode(response.body);
        final prettyResponseJson = JsonEncoder.withIndent('  ').convert(responseJson);
        log(prettyResponseJson);
      } catch (e) {
        // If JSON parsing fails, log raw body
        log(response.body);
      }
      
      log('────────────────────────────────────────────────────────');
      log('════════════════════════════════════════════════════════');

      // Close loading dialog
      Navigator.pop(context);

      // Handle response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('');
        log('✅ SUCCESS - Booking Created (200)');
        log('   Status: ${responseData['status']}');
        log('   Message: ${responseData['message'] ?? 'Booking created successfully!'}');
        log('   Data: ${responseData['data']}');
        log('════════════════════════════════════════════════════════');
        
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
          log('');
          log('❌ ERROR - Booking Failed (status: false)');
          log('   Message: ${responseData['message']}');
          log('════════════════════════════════════════════════════════');
          
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
        log('');
        log('❌ ERROR - HTTP ${response.statusCode}');
        log('   Response: ${response.body}');
        log('════════════════════════════════════════════════════════');
        
        // Show error dialog for non-200 status code
        if (response.statusCode == 422) {
          final responseData = jsonDecode(response.body);
          final message = responseData['message'] ?? 'Something went wrong.';
          
          log('🔴 422 Unprocessable Entity - Validation Error');
          log('   Message: $message');
          log('   Errors: ${responseData['errors']}');
          log('════════════════════════════════════════════════════════');

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
          final responseData = jsonDecode(response.body);
          
          log('🔴 HTTP Error ${response.statusCode}');
          log('   Message: ${responseData['message']}');
          log('════════════════════════════════════════════════════════');
          
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
    } catch (e, stackTrace) {
      log('');
      log('💥 EXCEPTION OCCURRED');
      log('   Error: $e');
      log('   Stack Trace: $stackTrace');
      log('════════════════════════════════════════════════════════');
      
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
