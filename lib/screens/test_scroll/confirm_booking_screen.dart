import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../api_services/BookingService.dart';
import '../../models/home/Professional.dart';
import '../../models/salon_detail_models.dart' as salon_models;
import '../../models/HomePageResponse.dart' as home_models;
import 'package:app/constants.dart';
import 'package:app/utils/restriction_handler.dart';
import 'package:app/features/auth/utils/auth_manager.dart';
import 'package:app/features/auth/presentation/screens/auth/auth_screen.dart';

// TODO: [FEATURE] Add promo code/discount code input field
// TODO: [FEATURE] Add ability to edit cart from confirmation screen
// TODO: [FEATURE] Implement service add-ons selection
// TODO: [ENHANCEMENT] Add estimated service duration display
// TODO: [ENHANCEMENT] Show expected end time based on service duration
// TODO: [UX] Add "Save as favorite booking" option
// TODO: [UX] Implement booking modification before confirmation
// TODO: [VALIDATION] Add real-time validation for special notes character limit
// TODO: [ACCESSIBILITY] Add screen reader support for all interactive elements

class ConfirmBookingScreen extends StatefulWidget {
  static const String routeName = '/confirm-booking';

  const ConfirmBookingScreen({Key? key}) : super(key: key);

  @override
  _ConfirmBookingScreenState createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  DateTime? _selectedDay;
  String? _selectedTime;
  List<Professional> _selectedProfessionals = [];
  // Professionals aligned to booking service_id order.
  // This list may include an "Any" placeholder (id=1) per service.
  List<Professional> _bookingProfessionals = [];
  String? _salonName;
  String? _salonAddress;
  String? _salonImage;
  int? _salonId;
  Map<dynamic, int>? _cartItems;
  String? _paymentMethod = 'Cash';
  final TextEditingController _notesController = TextEditingController();

  final double kPadding = 16.0;
  final double kPaddingHeight = 5.0;
  final double kCardRadius = 12.0;
  final double kSectionSpacing = 10.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
      if (arguments != null) {
        _cartItems = arguments['cartItems'] as Map<dynamic, int>?;
        _selectedDay = arguments['selectedDay'] as DateTime?;
        _selectedTime = arguments['selectedTime'] as String?;
        _selectedProfessionals =
            arguments['selectedProfessionals'] as List<Professional>? ?? [];

        // Prefer booking-aligned list if provided; otherwise fall back.
        _bookingProfessionals =
            arguments['bookingProfessionals'] as List<Professional>? ??
                _selectedProfessionals;
        _salonName = arguments['salonName'] as String?;
        _salonImage = arguments['salonImage'] as String?;
        _salonAddress = arguments['salonAddress'] as String?;
        _salonId = arguments['salonId'] as int?;

        // Fallback: Extract salonId from cart items if not passed directly
        if (_salonId == null && _cartItems != null && _cartItems!.isNotEmpty) {
          final firstItem = _cartItems!.keys.first;
          if (firstItem is salon_models.Service) {
            _salonId = firstItem.salonId;
          } else if (firstItem is salon_models.Deal) {
            _salonId = firstItem.salonId;
          } else if (firstItem is home_models.Service) {
            _salonId = firstItem.salonId;
          } else if (firstItem is home_models.Deal) {
            _salonId = firstItem.salonId;
          }
        }

        setState(() {});
        if (kDebugMode) {
          developer.log(
              'ConfirmBookingScreen: init arguments parsed | salonId=$_salonId | items=${_cartItems?.length ?? 0} | selectedDay=$_selectedDay | selectedTime=$_selectedTime',
              name: 'booking.screen');
        }
      } else {
        // No arguments received in ConfirmBookingScreen
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGridUnselected,
      appBar: _buildAppBar(),
      body: Container(
        color: kScreenBg,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(kPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    icon: Icons.storefront,
                    imageUrl: _salonImage,
                    title: '$_salonName',
                    children: [
                      _buildDetailRow(Icons.location_on,
                          _salonAddress ?? 'Address not available'),
                    ],
                  ),
                  SizedBox(height: kSectionSpacing),
                  _buildSectionCard(
                    icon: Icons.calendar_today,
                    title: 'Booking Details',
                    children: [
                      _buildDetailRow(
                          Icons.date_range,
                          _selectedDay != null
                              ? DateFormat('EEE, MMM d').format(_selectedDay!)
                              : 'Date not selected'),
                      _buildDetailRow(Icons.access_time,
                          _selectedTime ?? 'Time not selected'),
                    ],
                  ),
                  SizedBox(height: kSectionSpacing),
                  _buildSectionCard(
                    icon: Icons.spa,
                    title: 'Selected Items (${_cartItems?.length ?? 0})',
                    children: _cartItems?.entries
                            .map((entry) => _buildDynamicItem(entry))
                            .toList() ??
                        [
                          _buildEmptyState(
                              'No items selected', Icons.warning_amber)
                        ],
                  ),
                  SizedBox(height: kSectionSpacing),
                  _buildSectionCard(
                    icon: Icons.people_alt_rounded,
                    title: 'Professionals',
                    children: _bookingProfessionals.isNotEmpty
                        ? [
                            Column(
                              children: List.generate(
                                  _bookingProfessionals.length, (index) {
                                final prof = _bookingProfessionals[index];

                                // Try to get matching service name (based on same index from cart)
                                String serviceName = 'Service';
                                if (_cartItems != null &&
                                    index < _cartItems!.keys.length) {
                                  final item =
                                      _cartItems!.keys.elementAt(index);

                                  if (item is salon_models.Service ||
                                      item is home_models.Service) {
                                    serviceName = item.name ?? 'Service';
                                  } else if (item is salon_models.Deal ||
                                      item is home_models.Deal) {
                                    serviceName = item.name ?? 'Deal';
                                  }
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: kPrimaryColor.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Professional image
                                      CircleAvatar(
                                        backgroundImage: prof.image != null &&
                                                prof.image!.isNotEmpty
                                            ? NetworkImage(prof.image!)
                                            : null,
                                        backgroundColor:
                                            kPrimaryColor.withOpacity(0.2),
                                        radius: 16,
                                        child: prof.image == null ||
                                                prof.image!.isEmpty
                                            ? const Icon(Icons.person,
                                                size: 18, color: kPrimaryColor)
                                            : null,
                                      ),

                                      const SizedBox(width: 10),

                                      // 👇 SERVICE + PROFESSIONAL INFO
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (prof.name != null &&
                                                      prof.name!
                                                              .toLowerCase() ==
                                                          "any")
                                                  ? "Any Professional"
                                                  : (prof.name ?? "Unknown"),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),

                                            const SizedBox(height: 2),

                                            // 👉 NEW: Service name below professional
                                            Text(
                                              "For: $serviceName",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            )
                          ]
                        : [
                            _buildEmptyState(
                                'Any professional', Icons.person_outline)
                          ],
                  ),
                  SizedBox(height: kSectionSpacing),
                  _buildSectionCard(
                    icon: Icons.payment,
                    title: 'Payment Method',
                    children: [
                      // _buildPaymentOption(context,
                      //     title: 'Credit/Debit Card',
                      //     icon: Icons.credit_card,
                      //     value: 'Card'),
                      _buildPaymentOption(context,
                          title: 'Cash at Salon',
                          icon: Icons.money,
                          value: 'Cash'),
                    ],
                  ),
                  SizedBox(height: kSectionSpacing),
                  _buildNotesCard(),
                  SizedBox(height: kSectionSpacing * 1.5),
                  const SizedBox(
                      height: 120), // Space for the positioned button
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Total amount display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B6B6B),
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'PKR ${_calculateTotalPrice().toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: kPrice,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Confirm button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: (_paymentMethod != null &&
                                _calculateTotalPrice() > 0)
                            ? _confirmBooking
                            : () {
                                if (_calculateTotalPrice() <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Cannot complete booking: Total price is zero. Please add services or deals with valid prices.'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          height: 45,
                          decoration: BoxDecoration(
                            gradient: (_paymentMethod != null &&
                                    _calculateTotalPrice() > 0)
                                ? const LinearGradient(
                                    colors: [
                                      kPrimaryColor,
                                      Color(0xFF8B44A3),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : null,
                            color: (_paymentMethod == null ||
                                    _calculateTotalPrice() <= 0)
                                ? Colors.grey[400]
                                : null,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: (_paymentMethod != null &&
                                    _calculateTotalPrice() > 0)
                                ? [
                                    BoxShadow(
                                      color: kPrimaryColor.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : null,
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'CONFIRM BOOKING',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicItem(MapEntry<dynamic, int> entry) {
    final item = entry.key;
    final qty = entry.value;

    String? name;
    String? description;
    double? price;
    double? oldPrice;

    // Detect type and extract data
    // Handle salon_detail_models.Deal
    if (item is salon_models.Deal) {
      name = item.name;
      description =
          item.services?.map((s) => s.name).join(', ') ?? 'No services listed';
      final totalPrice = item.totalPrice ?? 0.0;
      final itemPrice = item.price ?? 0.0;
      price = totalPrice > 0 ? totalPrice : itemPrice;
      oldPrice = item.price;
    }
    // Handle HomePageResponse.Deal
    else if (item is home_models.Deal) {
      name = item.name;
      description =
          item.services?.map((s) => s.name).join(', ') ?? 'No services listed';
      final totalPrice = (item.totalPrice ?? 0).toDouble();
      final itemPrice = (item.price ?? 0).toDouble();
      price = totalPrice > 0 ? totalPrice : itemPrice;
      oldPrice = itemPrice;
    }
    // Handle salon_detail_models.Service
    else if (item is salon_models.Service) {
      name = item.name;
      description = item.description;
      price = item.price;
      oldPrice = item.oldPrice;
    }
    // Handle HomePageResponse.Service
    else if (item is home_models.Service) {
      name = item.name;
      description = item.description;
      price = (item.price ?? 0).toDouble();
      oldPrice = item.oldPrice != null ? item.oldPrice!.toDouble() : null;
    } else {
      // fallback for unknown type
      try {
        name = item.name;
      } catch (_) {}
      try {
        description = item.description;
      } catch (_) {}
      try {
        price = item.price;
      } catch (_) {}
      try {
        oldPrice = item.old_price;
      } catch (_) {}
    }

    final hasDiscount = oldPrice != null && oldPrice > (price ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: kPrimaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '×$qty',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? "Unnamed Item",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2D2D),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description != null && description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PKR ${price?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: kPrice,
                  letterSpacing: -0.5,
                ),
              ),
              if (hasDiscount)
                Text(
                  'PKR ${oldPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    String? imageUrl,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: kPrimaryColor.withOpacity(0.12),
                  ),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                icon ?? Icons.storefront,
                                color: kPrimaryColor,
                                size: 22,
                              );
                            },
                          ),
                        )
                      : Icon(
                          icon ?? Icons.storefront,
                          color: kPrimaryColor,
                          size: 22,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D2D2D),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
            if (children.isNotEmpty) const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A4A4A),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _paymentMethod == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _paymentMethod = value),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color:
                isSelected ? kPrimaryColor.withOpacity(0.08) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? kPrimaryColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? kPrimaryColor.withOpacity(0.15)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? kPrimaryColor : Colors.grey[600],
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color:
                        isSelected ? const Color(0xFF2D2D2D) : Colors.grey[700],
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? kPrimaryColor : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected ? kPrimaryColor : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: kPrimaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Booking Notes',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D2D2D),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Add any special requests or notes...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// AppBar - Modern redesigned to match salon category screen
  AppBar _buildAppBar() {
    // Get salon image from passed argument or cart items if available
    String? salonImageUrl = _salonImage;
    if ((salonImageUrl == null || salonImageUrl.isEmpty) &&
        _cartItems != null &&
        _cartItems!.isNotEmpty) {
      final firstItem = _cartItems!.keys.first;
      // Service/Deal no longer embed a Salon object in the new models; prefer passed-in salon image
      if ((firstItem is salon_models.Service ||
          firstItem is home_models.Service)) {
        // no direct image available from Service; keep salonImageUrl from args
      } else if ((firstItem is salon_models.Deal ||
          firstItem is home_models.Deal)) {
        // no direct image available from Deal; keep salonImageUrl from args
      }
    }

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            // Modern back button
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: kPrimaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: kPrimaryColor,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Salon info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Confirm Booking',
                    style: const TextStyle(
                      color: Color(0xFF2D2D2D),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Salon image
            // if (salonImageUrl != null && salonImageUrl.isNotEmpty)
            //   Container(
            //     width: 48,
            //     height: 48,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(12),
            //       border: Border.all(
            //         color: kPrimaryColor.withOpacity(0.3),
            //         width: 2,
            //       ),
            //       boxShadow: [
            //         BoxShadow(
            //           color: kPrimaryColor.withOpacity(0.2),
            //           blurRadius: 8,
            //           offset: const Offset(0, 3),
            //         ),
            //       ],
            //     ),
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(10),
            //       child: Image.network(
            //         salonImageUrl,
            //         fit: BoxFit.cover,
            //         errorBuilder: (context, error, stackTrace) => Container(
            //           color: kPrimaryColor.withOpacity(0.1),
            //           child: const Icon(
            //             Icons.storefront_rounded,
            //             color: kPrimaryColor,
            //             size: 24,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalPrice() {
    return _cartItems?.entries.fold<double>(
          0.0,
          (sum, entry) {
            final item = entry.key;
            final qty = entry.value;

            // Handle salon_detail_models.Service (double? price)
            if (item is salon_models.Service) {
              final price = item.price ?? 0.0;
              return sum + (price * qty);
            }
            // Handle HomePageResponse.Service (int? price)
            if (item is home_models.Service) {
              final price = (item.price ?? 0).toDouble();
              return sum + (price * qty);
            }
            // Handle salon_detail_models.Deal (double? totalPrice, double? price)
            if (item is salon_models.Deal) {
              final totalPrice = item.totalPrice ?? 0.0;
              final price = item.price ?? 0.0;
              final effectivePrice = totalPrice > 0 ? totalPrice : price;
              return sum + (effectivePrice * qty);
            }
            // Handle HomePageResponse.Deal (int? totalPrice, int? price)
            if (item is home_models.Deal) {
              final totalPrice = (item.totalPrice ?? 0).toDouble();
              final price = (item.price ?? 0).toDouble();
              final effectivePrice = totalPrice > 0 ? totalPrice : price;
              return sum + (effectivePrice * qty);
            }

            return sum;
          },
        ) ??
        0.0;
  }

  Future<void> _confirmBooking() async {
    // Check if user is authenticated first
    final token = await AuthManager.getToken();
    if (token == null) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign In Required'),
            content: const Text(
              'Please sign in to proceed with booking.',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign In'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Check user status and restriction before booking
    try {
      final userData = await AuthManager.getUserData();
      if (userData != null) {
        final canBook = await RestrictionHandler.canUserBook(
          completeStatus: userData.completeStatus,
          isRestricted: userData.isRestricted,
          status: userData.status,
          context: context,
        );

        if (!canBook) {
          // User is restricted or inactive, handler already showed dialog
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'ConfirmBookingScreen: Error checking user status | error=$e',
          name: 'booking.screen',
        );
      }
    }

    // Validate salon ID before making API call
    if (_salonId == null || _salonId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Invalid salon. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Call your API
    if (kDebugMode) {
      developer.log(
          'ConfirmBookingScreen._confirmBooking called | salonId=$_salonId | items=${_cartItems?.length ?? 0} | selectedDay=$_selectedDay | selectedTime=$_selectedTime | payment=$_paymentMethod',
          name: 'booking.screen');
    }

    try {
      await BookingService().createBooking(
        context: context,
        salonId: _salonId!,
        cartItems: _cartItems,
        selectedDay: _selectedDay,
        selectedTime: _selectedTime,
        // Important: booking requires profession_id length == service_id length.
        selectedProfessionals: _bookingProfessionals,
        paymentMethod: _paymentMethod,
        bookingType: 'appointment', // can adjust dynamically
      );
      if (kDebugMode) {
        developer.log(
            'ConfirmBookingScreen._confirmBooking completed (BookingService returned)',
            name: 'booking.screen');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
            'ConfirmBookingScreen._confirmBooking exception | error=$e',
            name: 'booking.screen');
      }
    }
  }
}
