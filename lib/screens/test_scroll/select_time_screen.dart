import 'package:app/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../models/home/Professional.dart';
import 'package:app/models/salon_detail_models.dart';
import 'confirm_booking_screen.dart';

class SelectTimeScreen extends StatefulWidget {
  static const String routeName = '/select-time';

  const SelectTimeScreen({Key? key}) : super(key: key);

  @override
  _SelectTimeScreenState createState() => _SelectTimeScreenState();
}

class _SelectTimeScreenState extends State<SelectTimeScreen> {
  DateTime? _selectedDay;
  String? _selectedTime;
  List<Professional> _selectedProfessionals = [];
  List<Professional> _bookingProfessionals = [];
  String? _salonName;
  String? _salonAddress;
  SalonData? _salon;
  Map<dynamic, int>? _cartItems;
  List<String> _timeSlots = [];

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      developer.log('SelectTimeScreen.initState called', name: 'booking.flow');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map?;

      if (kDebugMode) {
        if (arguments == null) {
          developer.log('SelectTimeScreen: No arguments received!',
              name: 'booking.flow');
        } else {
          developer.log(
              'SelectTimeScreen: Received arguments | keys=${arguments.keys.toList()}',
              name: 'booking.flow');
        }
      }

      if (arguments != null) {
        _cartItems = arguments['cartItems'] as Map<dynamic, int>?;
        _selectedDay = arguments['selectedDay'] as DateTime?;
        _selectedProfessionals =
            arguments['selectedProfessionals'] as List<Professional>? ?? [];
        _bookingProfessionals =
            arguments['bookingProfessionals'] as List<Professional>? ??
                _selectedProfessionals;
        _salonName = arguments['salonName'] as String?;
        _salonAddress = arguments['salonAddress'] as String?;
        _salon = arguments['salon'] as SalonData?;
      }

      developer.log(
          'SelectTimeScreen: Arguments parsed | '
          'selectedDay=$_selectedDay | cartItems=${_cartItems?.length ?? 0} | '
          'professionals=${_selectedProfessionals.length} | salonName=$_salonName | '
          'salonIsNull=${_salon == null}',
          name: 'booking.flow');

      developer.log(
          'SelectTimeScreen: ========== SALON ACTIVE DAYS LOGGING START ==========',
          name: 'booking.flow');

      // Log salon active days information
      if (_salon == null) {
        developer.log(
            'SelectTimeScreen: ❌ Salon object is NULL - Cannot access activeDays!',
            name: 'booking.flow');
      } else {
        developer.log(
            'SelectTimeScreen: ✅ Salon object exists | '
            'salonId=${_salon!.id} | salonName=${_salon!.name}',
            name: 'booking.flow');

        if (_salon!.activeDays == null) {
          developer.log(
              'SelectTimeScreen: ❌ Salon activeDays property is NULL!',
              name: 'booking.flow');
        } else if (_salon!.activeDays!.isEmpty) {
          developer.log(
              'SelectTimeScreen: ⚠️ Salon activeDays exists but is EMPTY (no days defined)!',
              name: 'booking.flow');
        } else {
          developer.log(
              'SelectTimeScreen: ✅ Salon has ${_salon!.activeDays!.length} active days defined',
              name: 'booking.flow');

          int index = 0;
          for (var activeDay in _salon!.activeDays!) {
            index++;
            developer.log(
                'SelectTimeScreen: Active Day [$index/${_salon!.activeDays!.length}] | '
                'id=${activeDay.id} | '
                'salonId=${activeDay.salonId} | '
                'day="${activeDay.day}" | '
                'status=${activeDay.status} (${activeDay.status == 1 ? "OPEN" : "CLOSED"}) | '
                'openingTime="${activeDay.openingTime}" | '
                'closingTime="${activeDay.closingTime}"',
                name: 'booking.flow');
          }

          // Summary of active days
          List<String> openDays = [];
          List<String> closedDays = [];
          for (var activeDay in _salon!.activeDays!) {
            if (activeDay.status == 1) {
              openDays.add(activeDay.day ?? 'unknown');
            } else {
              closedDays.add(activeDay.day ?? 'unknown');
            }
          }

          developer.log(
              'SelectTimeScreen: SUMMARY | '
              'Open days: [${openDays.join(", ")}] | '
              'Closed days: [${closedDays.join(", ")}]',
              name: 'booking.flow');
        }
      }

      developer.log(
          'SelectTimeScreen: ========== SALON ACTIVE DAYS LOGGING END ==========',
          name: 'booking.flow');

      setState(() {
        _timeSlots = _generateTimeSlots();

        if (kDebugMode) {
          developer.log(
              'SelectTimeScreen: Time slots generated | count=${_timeSlots.length}',
              name: 'booking.flow');
        }
      });
    });
  }

  List<String> _generateTimeSlots() {
    if (_selectedDay == null) {
      if (kDebugMode) {
        developer.log('SelectTimeScreen._generateTimeSlots: No selected day',
            name: 'booking.flow');
      }
      return [];
    }

    if (_salon == null ||
        _salon!.activeDays == null ||
        _salon!.activeDays!.isEmpty) {
      if (kDebugMode) {
        developer.log(
            'SelectTimeScreen._generateTimeSlots: No salon or activeDays available',
            name: 'booking.flow');
      }
      return [];
    }

    // Get the day name from selected date (e.g., "monday", "tuesday")
    List<String> dayNames = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    String selectedDayName =
        dayNames[_selectedDay!.weekday - 1]; // weekday is 1-7 (Monday-Sunday)

    if (kDebugMode) {
      developer.log(
          'SelectTimeScreen._generateTimeSlots: Selected date=${_selectedDay!.toString().split(' ')[0]} | '
          'weekday=${_selectedDay!.weekday} | dayName=$selectedDayName',
          name: 'booking.flow');
    }

    // Find the matching active day from salon's activeDays
    SalonActiveDay? matchedActiveDay;
    for (var activeDay in _salon!.activeDays!) {
      if (activeDay.day?.toLowerCase() == selectedDayName) {
        matchedActiveDay = activeDay;
        break;
      }
    }

    if (matchedActiveDay == null) {
      if (kDebugMode) {
        developer.log(
            'SelectTimeScreen._generateTimeSlots: ❌ No matching active day found for $selectedDayName',
            name: 'booking.flow');
      }
      return [];
    }

    if (kDebugMode) {
      developer.log(
          'SelectTimeScreen._generateTimeSlots: ✅ Found matching active day | '
          'day=${matchedActiveDay.day} | status=${matchedActiveDay.status} | '
          'openingTime=${matchedActiveDay.openingTime} | closingTime=${matchedActiveDay.closingTime}',
          name: 'booking.flow');
    }

    // Check if the day is open
    if (matchedActiveDay.status != 1) {
      if (kDebugMode) {
        developer.log(
            'SelectTimeScreen._generateTimeSlots: ⚠️ Selected day is CLOSED (status=${matchedActiveDay.status})',
            name: 'booking.flow');
      }
      return [];
    }

    // Parse opening and closing times
    int startHour = 8;
    int startMinute = 0;
    int endHour = 23;
    int endMinute = 0;

    try {
      if (matchedActiveDay.openingTime != null &&
          matchedActiveDay.openingTime!.isNotEmpty) {
        List<String> openParts = matchedActiveDay.openingTime!.split(':');
        if (openParts.length >= 2) {
          startHour = int.parse(openParts[0]);
          startMinute = int.parse(openParts[1]);
        }
      }

      if (matchedActiveDay.closingTime != null &&
          matchedActiveDay.closingTime!.isNotEmpty &&
          matchedActiveDay.closingTime != '00:00:00') {
        List<String> closeParts = matchedActiveDay.closingTime!.split(':');
        if (closeParts.length >= 2) {
          endHour = int.parse(closeParts[0]);
          endMinute = int.parse(closeParts[1]);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
            'SelectTimeScreen._generateTimeSlots: ❌ Error parsing times | error=$e',
            name: 'booking.flow');
      }
      // Use default times if parsing fails
    }

    if (kDebugMode) {
      developer.log(
          'SelectTimeScreen._generateTimeSlots: Time range parsed | '
          'startTime=$startHour:${startMinute.toString().padLeft(2, '0')} | '
          'endTime=$endHour:${endMinute.toString().padLeft(2, '0')}',
          name: 'booking.flow');
    }

    List<String> slots = [];
    DateTime startTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      startHour,
      startMinute,
    );
    DateTime endTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      endHour,
      endMinute,
    );

    // Generate time slots in 15-minute intervals
    while (startTime.isBefore(endTime)) {
      final hour = startTime.hour % 12 == 0 ? 12 : startTime.hour % 12;
      final period = startTime.hour < 12 ? 'AM' : 'PM';
      final timeString =
          '$hour:${startTime.minute.toString().padLeft(2, '0')} $period';
      slots.add(timeString);

      startTime = startTime.add(const Duration(minutes: 15));
    }

    if (kDebugMode) {
      developer.log(
          'SelectTimeScreen._generateTimeSlots: ✅ Generated ${slots.length} time slots',
          name: 'booking.flow');
      if (slots.isNotEmpty) {
        developer.log(
            'SelectTimeScreen._generateTimeSlots: First slot: ${slots.first} | Last slot: ${slots.last}',
            name: 'booking.flow');
      }
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            color: kScreenBg,
            child: Column(
              children: [
                if (_selectedDay != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Selected Date: ${_selectedDay!.toString().split(' ')[0]}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Error: No date selected',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                Expanded(
                  child: _timeSlots.isEmpty
                      ? const Center(
                          child: Text(
                            'No time slots available. Please select a valid date.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 36.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 3.5,
                          ),
                          itemCount: _timeSlots.length,
                          itemBuilder: (context, index) {
                            final time = _timeSlots[index];
                            return ElevatedButton(
                              onPressed: () {
                                if (kDebugMode) {
                                  developer.log(
                                      'SelectTimeScreen: Time slot selected | time=$time',
                                      name: 'booking.flow');
                                }
                                setState(() {
                                  _selectedTime = time;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(120, 48),
                                backgroundColor: _selectedTime == time
                                    ? kPrimaryDarkColor
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: Text(
                                time,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedTime == time
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (_selectedTime != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Selected Time: $_selectedTime',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 120),
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
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor:
                      _selectedTime != null ? kPrimaryDarkColor : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _selectedTime != null
                    ? () {
                        if (kDebugMode) {
                          developer.log(
                              'SelectTimeScreen: Navigating to ConfirmBookingScreen | '
                              'selectedDay=$_selectedDay | selectedTime=$_selectedTime | '
                              'cartItems=${_cartItems?.length ?? 0} | professionals=${_selectedProfessionals.length} | '
                              'salonId=${_salon?.id}',
                              name: 'booking.flow');
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConfirmBookingScreen(),
                            settings: RouteSettings(
                              arguments: {
                                'cartItems': _cartItems,
                                'selectedDay': _selectedDay,
                                'selectedTime': _selectedTime,
                                'selectedProfessionals': _selectedProfessionals,
                                'bookingProfessionals': _bookingProfessionals,
                                'salonName': _salonName,
                                'salonAddress': _salonAddress,
                                'salonId': _salon?.id,
                              },
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  'Confirm Time',
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
    );
  }

  /// AppBar - Modern redesigned to match confirm booking screen
  AppBar _buildAppBar() {
    final List<String>? salonImages = _salon?.images;

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
                    _salonName ?? 'Select Time',
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
            if (salonImages != null && salonImages.isNotEmpty)
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
                    salonImages.first,
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
}
