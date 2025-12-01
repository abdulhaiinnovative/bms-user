/// ═══════════════════════════════════════════════════════════════════════════
/// SELECT PROFESSIONALS SCREEN - REDESIGNED PROFESSIONAL FILTER
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Purpose: Allows users to select professionals for their booked services
///
/// Key Features:
/// ✅ Auto-selects "Any Professional" for all services (hidden from user)
/// ✅ Professional availability validation before navigation
/// ✅ Blocks navigation if any professional has zero working days
/// ✅ Comprehensive logging for debugging
/// ✅ Clean UI with cart summary
///
/// Professional Filter Logic:
/// • Checks each professional's weekday flags (monday, tuesday, etc.)
/// • A professional is "available" if ANY day flag == 1
/// • Blocks booking if professional has all days == 0
/// • "Any" professional selection always passes validation
///
/// Validation Rules:
/// 1. If "Any" selected → Always valid ✅
/// 2. If specific professional → Must have at least 1 working day ✅
/// 3. If professional not found → Skip validation (treat as "Any") ⚠️
/// 4. If no professionals list → Treat as "Any" ⚠️
///
/// TODO: [FEATURE] Add visual indicators for professional availability (busy/free)
/// TODO: [FEATURE] Implement professional rating/review display
/// TODO: [FEATURE] Add filter by professional specialty/skills
/// TODO: [FEATURE] Show professional working hours preview
/// TODO: [FEATURE] Add "Recommend Professional" feature based on service type
/// TODO: [FEATURE] Add professional profile view (bio, experience, photos)
/// TODO: [ENHANCEMENT] Show professional's average rating badge
/// TODO: [ENHANCEMENT] Display professional's years of experience
/// TODO: [UX] Add ability to request specific professional
/// TODO: [UX] Show professional's next available slot
/// TODO: [OPTIMIZATION] Cache professional availability data
///
/// Dependencies:
/// • Cart items with services/deals
/// • Salon object with basic info
/// • Professional data from services
///
/// Navigation Flow:
/// Previous: salon_category_and_services_list.dart
/// Next: SelectDateScreen.dart
///
/// ═══════════════════════════════════════════════════════════════════════════

import 'dart:developer';

import 'package:app/models/HomePageResponse.dart';
import 'package:app/models/home/Professional.dart';
import 'package:flutter/material.dart';
// import 'package:app/screens/test_scroll/jewellery_repository.dart';
import '../../constants.dart';
import 'CartSummarySection.dart';
import 'SelectDateScreen.dart';

class SelectProfessionals extends StatefulWidget {
  static String routeName = "/select_professionals";

  const SelectProfessionals({Key? key}) : super(key: key);

  @override
  _SelectProfessionalsState createState() => _SelectProfessionalsState();
}

class _SelectProfessionalsState extends State<SelectProfessionals> {
  Map<dynamic, String?> selectedProfessionals = {};
  Map<dynamic, int>? cartItems;
  String? salonName;
  String? salonImage;
  String? salonAddress;
  Salon? salon; // Add salon object

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map) {
        setState(() {
          cartItems = arguments['cartItems'] as Map<dynamic, int>? ?? {};
          salonName = arguments['salonName'] as String?;
          salonImage = arguments['salonImage'] as String?;
          salonAddress = arguments['salonAddress'] as String?;
          salon = arguments['salon'] as Salon?; // Receive salon object

          log('════════════════════════════════════════');
          log('👨‍⚕️ SELECT PROFESSIONALS SCREEN - INIT');
          log('════════════════════════════════════════');
          log('Cart Items Count: ${cartItems?.length ?? 0}');
          log('Salon Name: $salonName');
          log('Salon ID: ${salon?.id}');
          log('Salon Image: $salonImage');
          log('Salon Address: $salonAddress');
          log('Salon Active Days: ${salon?.activeDays?.length ?? 0} days configured');
          if (salon?.activeDays != null) {
            for (var day in salon!.activeDays!) {
              log('   ${day.day}: status=${day.status} (${day.openingTime}-${day.closingTime})');
            }
          }
          log('Cart Items:');
          cartItems?.forEach((key, value) {
            if (key is Service) {
              log('  - Service: ${key.name} (ID: ${key.id})');
              log('    Professionals: ${key.professionals?.map((p) => p.name).toList() ?? [
                    "None"
                  ]}');
            } else if (key is Deal) {
              log('  - Deal: ${key.name} (ID: ${key.id})');
            }
          });
          log('════════════════════════════════════════');

          // Initialize selectedProfessionals with "Any" for all services
          // Professional names are hidden, so always use "Any"
          cartItems?.forEach((service, _) {
            selectedProfessionals[service] = 'Any';
          });

          log('Auto-selected "Any" for all ${cartItems?.length ?? 0} services');
          log('════════════════════════════════════════');
        });
      } else {
        log('⚠️ No valid arguments passed to SelectProfessionals');
        setState(() {
          cartItems = {};
        });
      }
    });
  }

  Widget _buildProfessionalSelector(Service service) {
    final professionals = service.professionals ?? [];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(right: 12, left: 12, top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service name
          Text(
            service.name ?? 'Service',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),

          // Professional selection chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // "Any Professional" option
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedProfessionals[service] = 'Any';
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedProfessionals[service] == 'Any'
                        ? kPrimaryColor
                        : kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: kPrimaryColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedProfessionals[service] == 'Any')
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      Text(
                        'Any Professional',
                        style: TextStyle(
                          color: selectedProfessionals[service] == 'Any'
                              ? Colors.white
                              : kPrimaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Individual professional chips
              ...professionals.map((professional) {
                final isSelected =
                    selectedProfessionals[service] == professional.name;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedProfessionals[service] = professional.name;
                    });
                    log('Selected professional: ${professional.name} for service: ${service.name}');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kPrimaryColor
                          : kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: kPrimaryColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        Text(
                          professional.name ?? 'Professional',
                          style: TextStyle(
                            color: isSelected ? Colors.white : kPrimaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDealItem(dynamic deal) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(right: 12, left: 12, top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              deal.name ?? 'Deal',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: RawChip(
              label: const Text(
                'Any',
                style: TextStyle(color: Colors.white),
              ),
              selected: true,
              selectedColor: kPrimaryDarkColor,
              avatar: const Icon(
                Icons.check,
                color: Colors.white,
                size: 18,
              ),
              shape: const StadiumBorder(),
              onSelected: (_) {},
            ),
          )
        ],
      ),
    );
  }

  /// AppBar - Modern redesigned to match salon category screen
  AppBar _buildAppBar() {
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
                    salonName ?? 'Select Professionals',
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
            if (salonImage != null && salonImage!.isNotEmpty)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: kPrimaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    salonImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: kPrimaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: kPrimaryColor,
                        size: 24,
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

  @override
  Widget build(BuildContext context) {
    bool canProceed = selectedProfessionals.entries
        .where((entry) => entry.key is Service)
        .every((entry) => entry.value != null);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              color: kScreenBg,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (cartItems == null || cartItems!.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No services in cart. Please add services to continue.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ...cartItems!.keys.map((item) {
                        if (item is Service) {
                          return _buildProfessionalSelector(item);
                        } else {
                          return _buildDealItem(item);
                        }
                      }).toList(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                child: CartSummarySection(
                  totalItems: cartItems?.length ?? 0,
                  totalAmount: cartItems?.entries.fold<double>(
                        0.0,
                        (sum, entry) {
                          final item = entry.key;
                          final quantity = entry.value;
                          final price = _getItemPrice(item);
                          return sum + (price * quantity);
                        },
                      ) ??
                      0.0,
                  buttonColor: canProceed ? kPrimaryDarkColor : Colors.grey,
                  onContinue: () {
                    if (canProceed) {
                      // Validate if selected professionals have any available days
                      bool hasAvailableDays =
                          _validateProfessionalAvailability();

                      if (!hasAvailableDays) {
                        // Show error dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('❌ No Available Dates'),
                              content: const Text(
                                'The selected professional(s) have no available working days set in their schedule. '
                                'Please contact the salon or select a different professional.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );

                        log('⚠️ Navigation blocked: No available dates for selected professionals');
                        return;
                      }

                      log('════════════════════════════════════════');
                      log('📍 NAVIGATING TO SELECT DATE SCREEN');
                      log('════════════════════════════════════════');
                      log('Selected Professionals:');
                      selectedProfessionals.forEach((key, value) {
                        if (key is Service) {
                          log('  - Service: ${key.name} → Professional: ${value ?? "Any"}');
                        }
                      });
                      log('Cart Items Count: ${cartItems?.length ?? 0}');
                      log('Salon: $salonName');
                      log('════════════════════════════════════════');

                      Navigator.pushNamed(
                        context,
                        SelectDateScreen.routeName,
                        arguments: {
                          'selectedProfessionals': selectedProfessionals,
                          'cartItems': cartItems,
                          'salonName': salonName,
                          'salonImage': salonImage,
                          'salonAddress': salonAddress,
                          'salon': salon, // Pass salon object
                        },
                      );
                    }
                  },
                )),
          ),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// PROFESSIONAL AVAILABILITY FILTER - Redesigned from Scratch
  /// ═══════════════════════════════════════════════════════════════════════
  /// Purpose: Validates that selected professionals have at least one working day
  /// Logic: Check each professional's weekday flags (monday=1, tuesday=1, etc.)
  ///        Block navigation if ANY professional has zero working days
  ///
  /// TODO: Add support for checking if professional days overlap with salon days
  /// TODO: Consider validating against specific date ranges (vacations, etc.)
  /// TODO: Add caching of professional availability for performance
  /// ═══════════════════════════════════════════════════════════════════════
  bool _validateProfessionalAvailability() {
    log('');
    log('═══════════════════════════════════════════════════════════════');
    log('🔍 [PROFESSIONAL FILTER] Starting Validation');
    log('═══════════════════════════════════════════════════════════════');
    log('Total Services to Check: ${selectedProfessionals.length}');

    // ─────────────────────────────────────────────────────────────────────
    // STEP 1: Validate input data exists
    // ─────────────────────────────────────────────────────────────────────
    if (selectedProfessionals.isEmpty) {
      log('⚠️ [PROFESSIONAL FILTER] No professionals selected');
      return true; // No selections to validate
    }

    // ─────────────────────────────────────────────────────────────────────
    // STEP 2: Iterate through each selected professional
    // ─────────────────────────────────────────────────────────────────────
    int serviceIndex = 0;

    for (var entry in selectedProfessionals.entries) {
      serviceIndex++;
      log('');
      log('───────────────────────────────────────────────────────────────');
      log('📋 [PROFESSIONAL FILTER] Checking Service $serviceIndex');
      log('───────────────────────────────────────────────────────────────');

      // ─────────────────────────────────────────────────────────────────
      // STEP 2.1: Validate entry is a Service
      // ─────────────────────────────────────────────────────────────────
      if (entry.key is! Service) {
        log('⚠️ [PROFESSIONAL FILTER] Entry is not a Service - skipping');
        continue;
      }

      final service = entry.key as Service;
      final professionalName = entry.value;

      log('Service Name: "${service.name}"');
      log('Selected Professional: "${professionalName ?? "NULL"}"');

      // ─────────────────────────────────────────────────────────────────
      // STEP 2.2: Handle "Any" professional selection
      // ─────────────────────────────────────────────────────────────────
      if (professionalName == null || professionalName == 'Any') {
        log('✅ [PROFESSIONAL FILTER] "Any" selected → VALIDATION PASSED');
        log('   Reason: Any professional can be assigned');
        continue;
      }

      // ─────────────────────────────────────────────────────────────────
      // STEP 2.3: Validate professionals list exists
      // ─────────────────────────────────────────────────────────────────
      if (service.professionals == null || service.professionals!.isEmpty) {
        log('⚠️ [PROFESSIONAL FILTER] No professionals available for this service');
        log('   Action: Treating as "Any" - VALIDATION PASSED');
        continue;
      }

      log('Available Professionals: ${service.professionals!.length}');

      // ─────────────────────────────────────────────────────────────────
      // STEP 2.4: Find the selected professional object
      // ─────────────────────────────────────────────────────────────────
      Professional? professional;

      try {
        professional = service.professionals!.firstWhere(
          (p) => p.name?.trim() == professionalName.trim(),
        );
        log('✓ Professional found: "${professional.name}"');
      } catch (e) {
        log('❌ [PROFESSIONAL FILTER] Professional "$professionalName" NOT FOUND');
        log('   Available: ${service.professionals!.map((p) => p.name).join(", ")}');
        log('   Action: Skipping validation for this service');
        continue;
      }

      // ─────────────────────────────────────────────────────────────────
      // STEP 2.5: Check working days availability
      // ─────────────────────────────────────────────────────────────────
      log('');
      log('📅 Checking Working Days:');
      log('   Monday:    ${professional.monday == 1 ? "✅" : "❌"} (${professional.monday})');
      log('   Tuesday:   ${professional.tuesday == 1 ? "✅" : "❌"} (${professional.tuesday})');
      log('   Wednesday: ${professional.wednesday == 1 ? "✅" : "❌"} (${professional.wednesday})');
      log('   Thursday:  ${professional.thursday == 1 ? "✅" : "❌"} (${professional.thursday})');
      log('   Friday:    ${professional.friday == 1 ? "✅" : "❌"} (${professional.friday})');
      log('   Saturday:  ${professional.saturday == 1 ? "✅" : "❌"} (${professional.saturday})');
      log('   Sunday:    ${professional.sunday == 1 ? "✅" : "❌"} (${professional.sunday})');

      // Count working days (defensive null check)
      final workingDays = [
        professional.monday == 1,
        professional.tuesday == 1,
        professional.wednesday == 1,
        professional.thursday == 1,
        professional.friday == 1,
        professional.saturday == 1,
        professional.sunday == 1,
      ].where((day) => day == true).length;

      log('');
      log('📊 Total Working Days: $workingDays');

      // ─────────────────────────────────────────────────────────────────
      // STEP 2.6: Determine if professional has availability
      // ─────────────────────────────────────────────────────────────────
      if (workingDays == 0) {
        log('');
        log('❌❌❌ [PROFESSIONAL FILTER] VALIDATION FAILED ❌❌❌');
        log('Professional "${professional.name}" has ZERO working days!');
        log('This professional cannot accept any bookings.');
        log('═══════════════════════════════════════════════════════════════');
        return false; // BLOCK navigation
      }

      log('✅ [PROFESSIONAL FILTER] Professional has $workingDays working days - OK');
    }

    // ─────────────────────────────────────────────────────────────────────
    // STEP 3: All professionals validated successfully
    // ─────────────────────────────────────────────────────────────────────
    log('');
    log('═══════════════════════════════════════════════════════════════');
    log('✅✅✅ [PROFESSIONAL FILTER] ALL VALIDATIONS PASSED ✅✅✅');
    log('═══════════════════════════════════════════════════════════════');
    log('');

    return true;
  }

  double _getItemPrice(dynamic item) {
    if (item is Service) return (item.price ?? 0).toDouble();
    if (item is Deal) return (item.totalPrice ?? 0).toDouble();
    return 0.0;
  }
}
