import 'dart:convert';
import 'dart:developer';
import 'package:app/features/auth/presentation/screens/complete_profile/complete_profile_screen.dart';
import 'package:app/services/protected_http_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/home/Professional.dart';
import '../models/HomePageResponse.dart';

class BookingService {
  /// Creates a new booking according to API documentation
  /// Format: "'HH:mm', 'YYYY-MM-DD'" as per BOOKING_CREATE_API.md
  Future<void> createBooking({
    required BuildContext context,
    required int salonId,
    required Map<dynamic, int>? cartItems,
    required DateTime? selectedDay,
    required String? selectedTime,
    required List<Professional> selectedProfessionals,
    required String? paymentMethod,
    required String bookingType, // "deal" or "appointment"
  }) async {
    log('════════════════════════════════════════════════════════');
    log('🔄 CREATE BOOKING - API CALL');
    log('════════════════════════════════════════════════════════');

    // Capture navigator to avoid BuildContext issues after async
    final navigator = Navigator.of(context);

    // Show loading dialog
    showDialog(
      context: navigator.context,
      barrierDismissible: false,
      builder: (context) => _buildLoadingDialog(),
    );

    try {
      // ═══════════════════════════════════════════════════════
      // STEP 1: Format Time according to API documentation
      // Format: "'HH:mm', 'YYYY-MM-DD'"
      // Example: "'10:30', '2024-12-15'"
      // ═══════════════════════════════════════════════════════

      String formattedTime = '';

      if (selectedTime != null && selectedDay != null) {
        // Parse 12-hour time format (e.g., "10:30 AM" or "2:30 PM")
        final timeParts = selectedTime.trim().split(' ');

        if (timeParts.length == 2) {
          final timeComponent = timeParts[0]; // "10:30"
          final periodComponent = timeParts[1].toUpperCase(); // "AM" or "PM"
          final timeSplit = timeComponent.split(':');

          if (timeSplit.length == 2) {
            int hour = int.parse(timeSplit[0]);
            String minute = timeSplit[1].padLeft(2, '0');

            // Convert to 24-hour format
            if (periodComponent == 'PM' && hour != 12) {
              hour += 12;
            } else if (periodComponent == 'AM' && hour == 12) {
              hour = 0;
            }

            String hour24 = hour.toString().padLeft(2, '0');

            // Format date as YYYY-MM-DD
            String dateFormatted = DateFormat('yyyy-MM-dd').format(selectedDay);

            // Build final time string exactly as per documentation
            // "'HH:mm', 'YYYY-MM-DD'"
            formattedTime = "'$hour24:$minute', '$dateFormatted'";

            log('✅ Time formatted: "$selectedTime" → "$formattedTime"');
          }
        }
      }

      if (formattedTime.isEmpty) {
        throw Exception('Failed to format time');
      }

      // ═══════════════════════════════════════════════════════
      // STEP 2: Build payload according to API documentation
      // ═══════════════════════════════════════════════════════

      // Calculate total price from cart items
      double totalPrice = 0.0;
      if (cartItems != null) {
        cartItems.forEach((item, quantity) {
          if (item is Service) {
            totalPrice += (item.price ?? 0.0) * quantity;
          } else if (item is Deal) {
            totalPrice += (item.totalPrice ?? 0) * quantity;
          }
        });
      }

      // Required parameters (as per documentation)
      final Map<String, dynamic> payload = {
        'salon_id': salonId, // Required: int
        'time':
            formattedTime, // Required: string in format "'HH:mm', 'YYYY-MM-DD'"
        'total_price': totalPrice, // Required: double
        'payment_status': paymentMethod ==
            'Cash', // Required: bool (true = cash, false = online)
      };

      // Optional: booking_type (defaults to 'appointment')
      payload['booking_type'] = bookingType;

      // Separate services and deals from cart
      if (cartItems != null) {
        final List<int> serviceIds = [];
        final List<int> dealIds = [];
        final Map<String, int> qtyMap = {};

        cartItems.forEach((item, quantity) {
          if (item is Service) {
            serviceIds.add(item.id ?? 0);
            if (item.id != null) {
              qtyMap[item.id.toString()] = quantity;
            }
          } else if (item is Deal) {
            dealIds.add(item.id ?? 0);
          }
        });

        // Add service_id if there are services
        if (serviceIds.isNotEmpty) {
          payload['service_id'] = serviceIds;

          // profession_id (List<int>) - must match service_id length
          // API: 1 = "Any Professional", 2+ = specific professional IDs
          final professionIds = selectedProfessionals.isNotEmpty
              ? selectedProfessionals.map((p) => p.id ?? 1).toList()
              : List.filled(
                  serviceIds.length, 1); // Use 1 for "any professional"
          payload['profession_id'] = professionIds;

          // qty (Map<int, int>) - service_id to quantity mapping
          if (qtyMap.isNotEmpty) {
            payload['qty'] = qtyMap;
          }
        }

        // Add deal_id if there are deals
        if (dealIds.isNotEmpty) {
          // API accepts single int or List<int> for deal_id
          payload['deal_id'] = dealIds.length == 1 ? dealIds.first : dealIds;
        }
      }

      // Log the complete payload
      log('📤 Request Payload:');
      log(const JsonEncoder.withIndent('  ').convert(payload));
      log('════════════════════════════════════════════════════════');

      // ═══════════════════════════════════════════════════════
      // STEP 3: Make API call
      // POST /api/create-booking
      // Headers: Authorization: Bearer <token>, Content-Type: application/json
      // ═══════════════════════════════════════════════════════

      final response = await ProtectedHttpClient.post(
        '/create-booking',
        body: payload,
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📥 Response Body:');
      try {
        final bodyJson = jsonDecode(response.body);
        log(const JsonEncoder.withIndent('  ').convert(bodyJson));
      } catch (e) {
        log('Raw Response: ${response.body}');
      }

      // Close loading dialog
      if (navigator.mounted) navigator.pop();

      // ═══════════════════════════════════════════════════════
      // STEP 4: Handle response according to API documentation
      // ═══════════════════════════════════════════════════════

      if (response.statusCode == 200) {
        // Success response (200 OK)
        final responseData = jsonDecode(response.body);

        log('✅ Response Data:');
        log(const JsonEncoder.withIndent('  ').convert(responseData));
      
          // Success: Booking created
          final message =
              responseData['message'] ?? 'Your appointment has been booked successfully!';

          await showDialog(
            context: navigator.context,
            barrierDismissible: false,
            builder: (context) => _buildSuccessDialog(
              message,
              () {
                // Close the dialog first
                Navigator.of(context).pop();
                // Navigate to the initial/home screen
                navigator.popUntil((route) => route.isFirst);
              },
            ),
          );
      
      } else if (response.statusCode == 422) {
        // ═══════════════════════════════════════════════════════
        // 422 Validation Error (as per API documentation)
        // Possible errors:
        // - Invalid salon
        // - Invalid vendor
        // - Incomplete profile
        // - Profession/Service mismatch
        // ═══════════════════════════════════════════════════════

        String errorMessage = 'Validation error occurred.';
        bool isProfileIssue = false;

        try {
          final responseData = jsonDecode(response.body);
          errorMessage = responseData['message'] ?? errorMessage;

          // Check if it's a profile completion issue
          if (errorMessage.toLowerCase().contains('profile') ||
              errorMessage.toLowerCase().contains('complete')) {
            isProfileIssue = true;
          }

          log('❌ 422 Validation Error: $errorMessage');
        } catch (e) {
          log('❌ 422 Error (failed to parse response)');
        }

        if (isProfileIssue) {
          // Profile completion required
          await showDialog(
            context: navigator.context,
            barrierDismissible: false,
            builder: (context) => _buildErrorDialog(
              'Profile Incomplete',
              '$errorMessage\n\nWould you like to complete your profile now?',
              () {
                if (navigator.mounted) navigator.pop();
                navigator.pushNamed(CompleteProfileScreen.routeName);
              },
            ),
          );
        } else {
          // Other validation errors
          await showDialog(
            context: navigator.context,
            barrierDismissible: false,
            builder: (context) => _buildErrorDialog(
              'Validation Error',
              errorMessage,
              () {
                if (navigator.mounted) navigator.pop();
              },
            ),
          );
        }
      } else {
        // ═══════════════════════════════════════════════════════
        // Other HTTP errors
        // ═══════════════════════════════════════════════════════

        String errorTitle = 'Error ${response.statusCode}';
        String errorMessage = 'An error occurred.';

        try {
          final responseData = jsonDecode(response.body);
          errorMessage = responseData['message'] ?? errorMessage;
        } catch (e) {
          // Could not parse response
          log('Failed to parse error response: $e');
        }

        // Set error title based on status code
        switch (response.statusCode) {
          case 400:
            errorTitle = 'Bad Request';
            break;
          case 401:
            errorTitle = 'Unauthorized';
            break;
          case 403:
            errorTitle = 'Access Denied';
            break;
          case 404:
            errorTitle = 'Not Found';
            break;
          case 500:
            errorTitle = 'Server Error';
            break;
          case 502:
            errorTitle = 'Bad Gateway';
            break;
          case 503:
            errorTitle = 'Service Unavailable';
            break;
          default:
            errorTitle = 'Error ${response.statusCode}';
        }

        log('❌ HTTP ${response.statusCode}: $errorMessage');

        await showDialog(
          context: navigator.context,
          barrierDismissible: false,
          builder: (context) => _buildErrorDialog(
            errorTitle,
            errorMessage,
            () {
              if (navigator.mounted) navigator.pop();
            },
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (navigator.mounted) navigator.pop();

      // Show error dialog for network or other errors
      await showDialog(
        context: navigator.context,
        barrierDismissible: false,
        builder: (context) => _buildErrorDialog(
          'Connection Error',
          'An error occurred while processing your booking. Please check your internet connection and try again.',
          () {
            if (navigator.mounted) navigator.pop();
          },
        ),
      );
    }
  }

  /// Beautiful Loading Dialog
  Widget _buildLoadingDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated loading indicator
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer circle with gradient
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF73308B).withOpacity(0.2),
                        const Color(0xFF73308B).withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
                // Loading indicator
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF73308B),
                    ),
                  ),
                ),
                // Center icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF73308B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF73308B),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Processing Booking',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D2D2D),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we confirm your appointment...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Beautiful Success Dialog
  Widget _buildSuccessDialog(String message, VoidCallback onClose) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success animation container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF66BB6A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D2D2D),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Success button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF73308B),
                        Color(0xFF8B44A3),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF73308B).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Beautiful Error Dialog
  Widget _buildErrorDialog(String title, String message, VoidCallback onClose) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF44336),
                    Color(0xFFE57373),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF44336).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D2D2D),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Close button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
