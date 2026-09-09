import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:app/features/auth/presentation/screens/complete_profile/complete_profile_screen.dart';
import 'package:app/providers/cart_provider.dart';
import 'package:app/services/protected_http_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
    if (kDebugMode) {
      developer.log(
          '═══════════════════════════════════════════════════════════════',
          name: 'booking.service');
      developer.log('🚀 BOOKING SERVICE - CREATE BOOKING REQUEST',
          name: 'booking.service');
      developer.log(
          '═══════════════════════════════════════════════════════════════',
          name: 'booking.service');
      developer.log('┌─ Basic Information:', name: 'booking.service');
      developer.log('│  ├─ Salon ID: $salonId', name: 'booking.service');
      developer.log('│  ├─ Cart Items Count: ${cartItems?.length ?? 0}',
          name: 'booking.service');
      developer.log('│  ├─ Selected Day: $selectedDay',
          name: 'booking.service');
      developer.log('│  ├─ Selected Time: $selectedTime',
          name: 'booking.service');
      developer.log('│  ├─ Payment Method: $paymentMethod',
          name: 'booking.service');
      developer.log('│  └─ Booking Type: $bookingType',
          name: 'booking.service');
      developer.log('│', name: 'booking.service');
      developer.log('├─ Cart Items Details:', name: 'booking.service');
      if (cartItems != null && cartItems.isNotEmpty) {
        cartItems.forEach((item, quantity) {
          if (item is Service) {
            developer.log(
                '│  ├─ SERVICE: ${item.name ?? "Unknown"} (ID: ${item.id}) | Qty: $quantity | Price: ${item.price}',
                name: 'booking.service');
          } else if (item is Deal) {
            developer.log(
                '│  ├─ DEAL: ${item.name ?? "Unknown"} (ID: ${item.id}) | Qty: $quantity | Total Price: ${item.totalPrice}',
                name: 'booking.service');
          } else {
            developer.log('│  ├─ UNKNOWN ITEM TYPE: $item | Qty: $quantity',
                name: 'booking.service');
          }
        });
      } else {
        developer.log('│  └─ No items in cart', name: 'booking.service');
      }
      developer.log('│', name: 'booking.service');
      developer.log(
          '├─ Selected Professionals (${selectedProfessionals.length}):',
          name: 'booking.service');
      if (selectedProfessionals.isNotEmpty) {
        for (var prof in selectedProfessionals) {
          developer.log('│  ├─ ${prof.name ?? "Unknown"} (ID: ${prof.id})',
              name: 'booking.service');
        }
      } else {
        developer.log(
            '│  └─ No specific professionals selected (will use "Any")',
            name: 'booking.service');
      }
      developer.log(
          '└─────────────────────────────────────────────────────────────',
          name: 'booking.service');
    }

    final navigator = Navigator.of(context);

    // Show loading dialog
    showDialog(
      context: context,
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
          }
        }
      }

      if (formattedTime.isEmpty) {
        if (kDebugMode) {
          developer.log('❌ ERROR: Failed to format time',
              name: 'booking.service');
          developer.log('   ├─ selectedTime input: $selectedTime',
              name: 'booking.service');
          developer.log('   └─ selectedDay input: $selectedDay',
              name: 'booking.service');
        }
        throw Exception('Failed to format time');
      }

      if (kDebugMode) {
        developer.log('', name: 'booking.service');
        developer.log('✅ TIME FORMATTED SUCCESSFULLY:',
            name: 'booking.service');
        developer.log(
            '   ├─ Input: selectedTime="$selectedTime", selectedDay=$selectedDay',
            name: 'booking.service');
        developer.log('   └─ Output: $formattedTime', name: 'booking.service');
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

      if (kDebugMode) {
        developer.log('', name: 'booking.service');
        developer.log('📦 PAYLOAD CONSTRUCTION (REQUIRED FIELDS):',
            name: 'booking.service');
        developer.log('   ├─ salon_id: $salonId (${salonId.runtimeType})',
            name: 'booking.service');
        developer.log(
            '   ├─ time: $formattedTime (${formattedTime.runtimeType})',
            name: 'booking.service');
        developer.log(
            '   ├─ total_price: $totalPrice (${totalPrice.runtimeType})',
            name: 'booking.service');
        developer.log(
            '   ├─ payment_status: ${paymentMethod == 'Cash'} (${(paymentMethod == 'Cash').runtimeType}) | Method=$paymentMethod',
            name: 'booking.service');
        developer.log(
            '   └─ Total Price Calculation: ${cartItems?.length ?? 0} items = $totalPrice',
            name: 'booking.service');
      }

      // Optional: booking_type (defaults to 'appointment')
      payload['booking_type'] = bookingType;

      if (kDebugMode) {
        developer.log(
            '   ├─ booking_type: $bookingType (${bookingType.runtimeType})',
            name: 'booking.service');
      }

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

        if (kDebugMode) {
          developer.log('', name: 'booking.service');
          developer.log('📦 PAYLOAD CONSTRUCTION (OPTIONAL FIELDS):',
              name: 'booking.service');
          developer.log('   ├─ Services Found: ${serviceIds.length}',
              name: 'booking.service');
          if (serviceIds.isNotEmpty) {
            developer.log('   │  └─ Service IDs: $serviceIds',
                name: 'booking.service');
          }
          developer.log('   ├─ Deals Found: ${dealIds.length}',
              name: 'booking.service');
          if (dealIds.isNotEmpty) {
            developer.log('   │  └─ Deal IDs: $dealIds',
                name: 'booking.service');
          }
          developer.log('   ├─ Quantity Map: $qtyMap', name: 'booking.service');
        }

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

          if (kDebugMode) {
            developer.log(
                '   ├─ service_id: $serviceIds (${serviceIds.runtimeType})',
                name: 'booking.service');
            developer.log(
                '   ├─ profession_id: $professionIds (${professionIds.runtimeType})',
                name: 'booking.service');
            developer.log(
                '   │  └─ Length Check: service_id=${serviceIds.length}, profession_id=${professionIds.length}',
                name: 'booking.service');
          }

          // qty (Map<int, int>) - service_id to quantity mapping
          if (qtyMap.isNotEmpty) {
            payload['qty'] = qtyMap;
            if (kDebugMode) {
              developer.log('   ├─ qty: $qtyMap (${qtyMap.runtimeType})',
                  name: 'booking.service');
            }
          }
        }

        // Add deal_id if there are deals
        if (dealIds.isNotEmpty) {
          // API accepts single int or List<int> for deal_id
          payload['deal_id'] = dealIds.length == 1 ? dealIds.first : dealIds;
          if (kDebugMode) {
            developer.log(
                '   └─ deal_id: ${payload['deal_id']} (${payload['deal_id'].runtimeType})',
                name: 'booking.service');
          }
        }
      }

      // ═══════════════════════════════════════════════════════
      // STEP 3: Make API call
      // POST /api/create-booking
      // Headers: Authorization: Bearer <token>, Content-Type: application/json
      // ═══════════════════════════════════════════════════════

      if (kDebugMode) {
        developer.log('', name: 'booking.service');
        developer.log(
            '═══════════════════════════════════════════════════════════════',
            name: 'booking.service');
        developer.log('🌐 MAKING API REQUEST', name: 'booking.service');
        developer.log(
            '═══════════════════════════════════════════════════════════════',
            name: 'booking.service');
        developer.log('Endpoint: POST /api/create-booking',
            name: 'booking.service');
        developer.log('', name: 'booking.service');
        developer.log('📤 COMPLETE PAYLOAD BEING SENT:',
            name: 'booking.service');
        developer.log(jsonEncode(payload), name: 'booking.service');
        developer.log('', name: 'booking.service');
        developer.log('Waiting for response...', name: 'booking.service');
      }

      final response = await ProtectedHttpClient.post(
        '/create-booking',
        body: payload,
      );

      if (kDebugMode) {
        developer.log('', name: 'booking.service');
        developer.log(
            '═══════════════════════════════════════════════════════════════',
            name: 'booking.service');
        developer.log('📥 API RESPONSE RECEIVED', name: 'booking.service');
        developer.log(
            '═══════════════════════════════════════════════════════════════',
            name: 'booking.service');
        developer.log('Status Code: ${response.statusCode}',
            name: 'booking.service');
        developer.log(
            'Status: ${response.statusCode == 200 ? "✅ SUCCESS" : response.statusCode == 422 ? "⚠️ VALIDATION ERROR" : "❌ ERROR"}',
            name: 'booking.service');
        developer.log('', name: 'booking.service');
        developer.log('📄 RAW RESPONSE BODY:', name: 'booking.service');
        developer.log(response.body, name: 'booking.service');
        developer.log('', name: 'booking.service');
        try {
          final decodedBody = jsonDecode(response.body);
          developer.log('📋 PARSED RESPONSE (JSON):', name: 'booking.service');
          developer.log(jsonEncode(decodedBody), name: 'booking.service');
        } catch (e) {
          developer.log('⚠️ Could not parse response as JSON: $e',
              name: 'booking.service');
        }
        developer.log(
            '═══════════════════════════════════════════════════════════════',
            name: 'booking.service');
      }

      // Close loading dialog
      if (navigator.mounted) navigator.pop();

      // ═══════════════════════════════════════════════════════
      // STEP 4: Handle response according to API documentation
      // ═══════════════════════════════════════════════════════

      if (response.statusCode == 200) {
        // Success response (200 OK)
        final responseData = jsonDecode(response.body);

        // Clear the global cart only after a successful booking.
        try {
          Provider.of<CartProvider>(context, listen: false).clearCart();
        } catch (e) {
          if (kDebugMode) {
            developer.log(
              'BookingService.createBooking: CartProvider not available to clear cart | error=$e',
              name: 'booking.service',
            );
          }
        }

        // Success: Booking created
        final message = responseData['message'] ??
            'Your appointment has been booked successfully!';

        await showDialog(
          context: context,
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
        Map<String, dynamic>? responseData;

        try {
          responseData = jsonDecode(response.body);
          errorMessage = responseData?['message'] ?? errorMessage;

          // Check if it's a profile completion issue
          if (errorMessage.toLowerCase().contains('profile') ||
              errorMessage.toLowerCase().contains('complete')) {
            isProfileIssue = true;
          }
        } catch (e) {
          // ignore parse error
        }

        if (kDebugMode) {
          developer.log('', name: 'booking.service');
          developer.log('⚠️⚠️⚠️ 422 VALIDATION ERROR DETAILS ⚠️⚠️⚠️',
              name: 'booking.service');
          developer.log(
              '═══════════════════════════════════════════════════════════════',
              name: 'booking.service');
          developer.log('Error Message: $errorMessage',
              name: 'booking.service');
          developer.log('Is Profile Issue: $isProfileIssue',
              name: 'booking.service');
          developer.log('', name: 'booking.service');
          if (responseData != null) {
            developer.log('Complete Response Data:', name: 'booking.service');
            responseData.forEach((key, value) {
              developer.log('  ├─ $key: $value', name: 'booking.service');
            });

            // Check for validation errors field
            if (responseData.containsKey('errors')) {
              developer.log('', name: 'booking.service');
              developer.log('🔍 VALIDATION ERRORS:', name: 'booking.service');
              final errors = responseData['errors'];
              if (errors is Map) {
                errors.forEach((field, messages) {
                  developer.log('  ├─ Field: $field', name: 'booking.service');
                  if (messages is List) {
                    for (var msg in messages) {
                      developer.log('  │  └─ $msg', name: 'booking.service');
                    }
                  } else {
                    developer.log('  │  └─ $messages', name: 'booking.service');
                  }
                });
              } else {
                developer.log('  └─ $errors', name: 'booking.service');
              }
            }
          }
          developer.log(
              '═══════════════════════════════════════════════════════════════',
              name: 'booking.service');
        }

        if (isProfileIssue) {
          // Profile completion required - show dialog with action button
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => _buildProfileIncompleteDialog(
              errorMessage,
              () {
                // Close dialog
                Navigator.of(dialogContext).pop();
                // Navigate to complete profile screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const CompleteProfileScreen()),
                );
              },
              () {
                // Just close dialog
                Navigator.of(dialogContext).pop();
              },
            ),
          );
        } else {
          // Other validation errors - show simple error dialog
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => _buildErrorDialog(
              'Booking Error',
              errorMessage,
              () {
                Navigator.of(dialogContext).pop();
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

        if (kDebugMode) {
          developer.log('', name: 'booking.service');
          developer.log('❌ HTTP ERROR ${response.statusCode}',
              name: 'booking.service');
          developer.log(
              '═══════════════════════════════════════════════════════════════',
              name: 'booking.service');
          developer.log('Status Code: ${response.statusCode}',
              name: 'booking.service');
          developer.log('Raw Body: ${response.body}', name: 'booking.service');
        }

        try {
          final responseData = jsonDecode(response.body);
          errorMessage = responseData['message'] ?? errorMessage;

          if (kDebugMode) {
            developer.log('Parsed Response:', name: 'booking.service');
            responseData.forEach((key, value) {
              developer.log('  ├─ $key: $value', name: 'booking.service');
            });
          }
        } catch (e) {
          if (kDebugMode) {
            developer.log('Could not parse response as JSON: $e',
                name: 'booking.service');
          }
        }

        if (kDebugMode) {
          developer.log(
              '═══════════════════════════════════════════════════════════════',
              name: 'booking.service');
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

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => _buildErrorDialog(
            errorTitle,
            errorMessage,
            () {
              Navigator.of(dialogContext).pop();
            },
          ),
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        developer.log('', name: 'booking.service');
        developer.log('💥💥💥 EXCEPTION CAUGHT 💥💥💥',
            name: 'booking.service');
        developer.log(
            '═══════════════════════════════════════════════════════════════',
            name: 'booking.service');
        developer.log('Exception Type: ${e.runtimeType}',
            name: 'booking.service');
        developer.log('Exception Message: $e', name: 'booking.service');
        developer.log('', name: 'booking.service');
        developer.log('Stack Trace:', name: 'booking.service');
        developer.log('$stackTrace', name: 'booking.service');
        developer.log(
            '═══════════════════════════════════════════════════════════════',
            name: 'booking.service');
      }
      // Close loading dialog
      if (navigator.mounted) navigator.pop();

      // Show error dialog for network or other errors
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _buildErrorDialog(
          'Connection Error',
          'An error occurred while processing your booking. Please check your internet connection and try again.',
          () {
            Navigator.of(dialogContext).pop();
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

  /// Beautiful Profile Incomplete Dialog with Action Button
  Widget _buildProfileIncompleteDialog(
      String message, VoidCallback onComplete, VoidCallback onCancel) {
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
            // Warning icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF9800),
                    Color(0xFFFFB74D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_circle_outlined,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Profile Incomplete',
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
            // Complete Profile button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onComplete,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Complete Profile',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Cancel button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onCancel,
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
                      'Maybe Later',
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
