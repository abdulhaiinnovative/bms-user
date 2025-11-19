import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api_services/BookingService.dart';
import '../../models/home/Professional.dart';
import '../../models/HomePageResponse.dart';
import 'CustomAppBar.dart';
import 'package:app/constants.dart';

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
  String? _salonName;
  String? _salonAddress;
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
        _selectedProfessionals = arguments['selectedProfessionals'] as List<Professional>? ?? [];
        _salonName = arguments['salonName'] as String?;
        _salonAddress = arguments['salonAddress'] as String?;

        log('ConfirmBookingScreen received arguments:');
        log('  cartItems: ${_cartItems?.keys.map((s) => s.toString()).toList()}');
        log('  selectedDay: $_selectedDay');
        log('  selectedTime: $_selectedTime');
        log('  selectedProfessionals: ${_selectedProfessionals.map((p) => p.name).toList()}');
        log('  salonName: $_salonName');
        log('  salonAddress: $_salonAddress');

        setState(() {});
      } else {
        log('No arguments received in ConfirmBookingScreen');
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: kGridUnselected,
      appBar: CustomAppBar(
        salonName: _salonName,
        salonAddress: _salonAddress,
        salonImage: salonImage,
      ),
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
                    title: '$_salonName',
                    children: [
                      _buildDetailRow(Icons.location_on, _salonAddress ?? 'Address not available'),
                    ],
                  ),
                  SizedBox(height: kSectionSpacing),
                  _buildSectionCard(
                    icon: Icons.calendar_today,
                    title: 'Booking Details',
                    children: [
                      _buildDetailRow(Icons.date_range,
                          _selectedDay != null
                              ? DateFormat('EEE, MMM d').format(_selectedDay!)
                              : 'Date not selected'),
                      _buildDetailRow(Icons.access_time, _selectedTime ?? 'Time not selected'),
                    ],
                  ),
                  SizedBox(height: kSectionSpacing),
                  _buildSectionCard(
                    icon: Icons.spa,
                    title: 'Selected Items (${_cartItems?.length ?? 0})',
                    children: _cartItems?.entries.map((entry) => _buildDynamicItem(entry)).toList()
                        ?? [_buildEmptyState('No items selected', Icons.warning_amber)],
                  ),
                  SizedBox(height: kSectionSpacing),
                  _buildSectionCard(
                    icon: Icons.people_alt,
                    title: 'Professionals',
                    children: _selectedProfessionals.isNotEmpty
                        ? [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedProfessionals.map((prof) => Chip(
                          avatar: CircleAvatar(
                            backgroundImage: prof.image != null && prof.image!.isNotEmpty
                                ? NetworkImage(prof.image!)
                                : null,
                            backgroundColor: prof.image != null && prof.image!.isNotEmpty
                                ? null
                                : Theme.of(context).colorScheme.surface,
                            radius: 16,
                          ),
                          label: Text(
                            prof.name ?? "Unknown",
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: kCardBG,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          elevation: 2,
                          shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
                        )).toList(),
                      )
                    ]
                        : [_buildEmptyState('Any professional', Icons.person_outline)],
                  ),
                  SizedBox(height: kSectionSpacing),
                  _buildSectionCard(
                    icon: Icons.payment,
                    title: 'Payment Method',
                    children: [
                      _buildPaymentOption(context, title: 'Credit/Debit Card', icon: Icons.credit_card, value: 'Card'),
                      _buildPaymentOption(context, title: 'Cash at Salon', icon: Icons.money, value: 'Cash'),
                    ],
                  ),
                  SizedBox(height: kSectionSpacing),
                  _buildNotesCard(),
                  SizedBox(height: kSectionSpacing * 1.5),
                  const SizedBox(height: 120), // Space for the positioned button
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 42),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ElevatedButton(
                  onPressed: _paymentMethod != null ? _confirmBooking : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48), // Full-width button
                    backgroundColor: _selectedTime != null ? kPrimaryDarkColor : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'CONFIRM BOOKING',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDynamicItem(MapEntry<dynamic, int> entry) {
    final item = entry.key;
    final qty = entry.value;

    String? name;
    String? description;
    int? price;
    int? discountedPrice;

    // Detect type and extract data
    if (item is Deal) {
      name = item.name;
      description = item.services?.map((s) => s.name).join(', ') ?? 'No services listed';
      price = item.price;
      discountedPrice = item.discountValue;
    } else if (item is Service) {
      name = item.name;
      description = item.description;
      price = item.price;
      discountedPrice = item.discountAmount;
    } else {
      // fallback for unknown type
      try { name = item.name; } catch (_) {}
      try { description = item.description; } catch (_) {}
      try { price = item.price; } catch (_) {}
      try { discountedPrice = item.discounted_price; } catch (_) {}
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('×$qty',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            )),
      ),
      title: Text(name ?? "Unnamed Item"),
      subtitle: Text(
        description ?? 'No description',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: discountedPrice != null && discountedPrice < item.price
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$${price?.toStringAsFixed(0) ?? '0'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            '\$${discountedPrice.toString()}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      )
          : Text(
        '\$${price?.toStringAsFixed(0) ?? '0'}',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBG,
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(kPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimaryDarkColor,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              title: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              minLeadingWidth: 6,
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
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
    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      borderRadius: BorderRadius.circular(kCardRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(kCardRadius),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        padding: EdgeInsets.all(kPadding),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _paymentMethod,
              toggleable: true,
              onChanged: (v) => setState(() => _paymentMethod = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: kCardBG,
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(kPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.edit_note, color: colorScheme.primary),
              title: Text('Booking Notes', style: textTheme.titleMedium),
            ),

            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                filled: true,
                hintText: 'Special requests, notes...',
                contentPadding: EdgeInsets.all(16)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 12),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  void _confirmBooking() {
    log('Confirm booking tapped');
    // Call your API

    BookingService().createBooking(
      context: context,
      cartItems: _cartItems,
      selectedDay: _selectedDay,
      selectedTime: _selectedTime,
      selectedProfessionals: _selectedProfessionals,
      paymentMethod: _paymentMethod,
      bookingType: 'appointment', // can adjust dynamically
    );


  }
}