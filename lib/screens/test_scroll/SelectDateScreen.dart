import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/home/Professional.dart';
import 'package:app/models/HomePageResponse.dart';
import 'confirm_booking_screen.dart';

class SelectDateScreen extends StatefulWidget {
  static const String routeName = '/select-date';

  const SelectDateScreen({Key? key}) : super(key: key);

  @override
  _SelectDateScreenState createState() => _SelectDateScreenState();
}

class _SelectDateScreenState extends State<SelectDateScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;
  List<String> _availableTimeSlots = [];

  String? _salonName;
  String? _salonAddress;
  String? _salonImage;
  Salon? _salon;
  Map<dynamic, int>? _cartItems;
  final List<Professional> _selectedProfessionals = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Map) {
        _cartItems = arguments['cartItems'] as Map<dynamic, int>? ?? {};
        _salonName = arguments['salonName'] as String?;
        _salonAddress = arguments['salonAddress'] as String?;
        _salonImage = arguments['salonImage'] as String?;
        _salon = arguments['salon'] as Salon?;

        final selectedProfessionals =
            arguments['selectedProfessionals'] as Map<dynamic, String?>?;
        if (selectedProfessionals != null) {
          for (var entry in selectedProfessionals.entries) {
            if (entry.key is Service &&
                entry.value != null &&
                entry.value != 'Any') {
              final service = entry.key as Service;
              if (service.professionals != null) {
                try {
                  final professional = service.professionals!.firstWhere(
                    (p) => p.name == entry.value,
                  );
                  _selectedProfessionals.add(professional);
                } catch (e) {}
              }
            }
          }
        }
      }
    });
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    const int defaultMaxDays = 30;
    int maxBookingDays = defaultMaxDays;

    if (_salon == null) {
      // use default
    } else if (_salon!.maxBookingTime == null) {
      // use default
    } else if (_salon!.maxBookingTime!.isEmpty) {
      // use default
    } else {
      try {
        maxBookingDays = int.parse(_salon!.maxBookingTime!);
        if (maxBookingDays < 1) {
          maxBookingDays = defaultMaxDays;
        } else if (maxBookingDays > 365) {
          maxBookingDays = 365;
        }
      } catch (e) {
        maxBookingDays = defaultMaxDays;
      }
    }

    final lastDay = today.add(Duration(days: maxBookingDays));

    DateTime initialDateToUse = _selectedDate ?? today;
    if (!_isSalonOpenOnDate(initialDateToUse)) {
      for (int i = 0; i <= maxBookingDays; i++) {
        final testDate = today.add(Duration(days: i));
        if (_isSalonOpenOnDate(testDate)) {
          initialDateToUse = testDate;
          break;
        }
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDateToUse,
      firstDate: today,
      lastDate: lastDay,
      selectableDayPredicate: (DateTime date) {
        final isOpen = _isSalonOpenOnDate(date);
        return isOpen;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryDarkColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
        _availableTimeSlots = _generateTimeSlots(picked);
      });
    }
  }

  bool _isSalonOpenOnDate(DateTime date) {
    if (_salon == null) {
      return false;
    }

    if (_salon!.activeDays == null) {
      return false;
    }

    if (_salon!.activeDays!.isEmpty) {
      return false;
    }

    final dayName = _getDayName(date.weekday);
    if (dayName.isEmpty) {
      return false;
    }

    ActiveDay? matchingDay;

    for (var activeDay in _salon!.activeDays!) {
      if (activeDay.day != null &&
          activeDay.day!.toLowerCase().trim() == dayName.toLowerCase().trim()) {
        matchingDay = activeDay;
        break;
      }
    }

    if (matchingDay == null) {
      return false;
    }

    if (matchingDay.status == null) {
      return false;
    }

    final isOpen = matchingDay.status == 1;
    return isOpen;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return '';
    }
  }

  String _getClosedDaysMessage() {
    if (_salon?.activeDays == null || _salon!.activeDays!.isEmpty) {
      return 'Salon schedule information unavailable';
    }

    final closedDays = _salon!.activeDays!
        .where((day) => day.status == 0)
        .map((day) => _capitalizeFirstLetter(day.day ?? ''))
        .where((day) => day.isNotEmpty)
        .toList();

    if (closedDays.isEmpty) {
      return 'Salon is open all days of the week';
    } else if (closedDays.length == 7) {
      return 'Salon is currently closed';
    } else if (closedDays.length == 1) {
      return 'Closed on ${closedDays[0]}s. These days are disabled in the calendar.';
    } else if (closedDays.length == 2) {
      return 'Closed on ${closedDays[0]}s & ${closedDays[1]}s. These days are disabled in the calendar.';
    } else {
      final lastDay = closedDays.removeLast();
      return 'Closed on ${closedDays.join(', ')} & $lastDay. These days are disabled in the calendar.';
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  List<String> _generateTimeSlots(DateTime date) {
    List<String> slots = [];

    String? openingTime;
    String? closingTime;

    if (_salon?.activeDays != null) {
      final dayName = _getDayName(date.weekday);
      try {
        final activeDay = _salon!.activeDays!.firstWhere(
          (ad) => ad.day?.toLowerCase() == dayName.toLowerCase(),
        );
        openingTime = activeDay.openingTime;
        closingTime = activeDay.closingTime;
      } catch (e) {}
    }

    int startHour = 8;
    int startMinute = 0;
    int endHour = 23;
    int endMinute = 0;

    if (openingTime != null && openingTime.isNotEmpty) {
      try {
        final parts = openingTime.split(':');
        startHour = int.parse(parts[0]);
        startMinute = int.parse(parts[1]);
      } catch (e) {}
    }

    if (closingTime != null &&
        closingTime.isNotEmpty &&
        closingTime != '00:00:00') {
      try {
        final parts = closingTime.split(':');
        endHour = int.parse(parts[0]);
        endMinute = int.parse(parts[1]);
      } catch (e) {}
    }

    DateTime startTime =
        DateTime(date.year, date.month, date.day, startHour, startMinute);
    DateTime endTime =
        DateTime(date.year, date.month, date.day, endHour, endMinute);

    while (startTime.isBefore(endTime) || startTime.isAtSameMomentAs(endTime)) {
      final hour = startTime.hour % 12 == 0 ? 12 : startTime.hour % 12;
      final period = startTime.hour < 12 ? 'AM' : 'PM';
      final timeString =
          '$hour:${startTime.minute.toString().padLeft(2, '0')} $period';
      slots.add(timeString);
      startTime = startTime.add(const Duration(minutes: 15));
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        color: kScreenBg,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kPrimaryDarkColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: kPrimaryDarkColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Date',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDate != null
                                  ? DateFormat('EEEE, MMMM d, yyyy')
                                      .format(_selectedDate!)
                                  : 'Tap to choose a date',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _selectedDate != null
                                    ? Colors.black
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_salon?.activeDays != null && _salon!.activeDays!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.blue.shade100,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getClosedDaysMessage(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_selectedDate != null) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _availableTimeSlots.isEmpty
                    ? Center(
                        child: Text(
                          'No time slots available for this date',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: _availableTimeSlots.length,
                        itemBuilder: (context, index) {
                          final time = _availableTimeSlots[index];
                          final isSelected = _selectedTime == time;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedTime = time;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? kPrimaryDarkColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? kPrimaryDarkColor
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  time,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Please select a date first',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    backgroundColor:
                        (_selectedDate != null && _selectedTime != null)
                            ? kPrimaryDarkColor
                            : Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: (_selectedDate != null && _selectedTime != null)
                      ? () {
                          Navigator.pushNamed(
                            context,
                            ConfirmBookingScreen.routeName,
                            arguments: {
                              'cartItems': _cartItems,
                              'selectedDay': _selectedDate,
                              'selectedTime': _selectedTime,
                              'selectedProfessionals': _selectedProfessionals,
                              'salonName': _salonName,
                              'salonAddress': _salonAddress,
                              'salonImage': _salonImage,
                              'salonId': _salon?.id,
                            },
                          );
                        }
                      : null,
                  child: Text(
                    'Continue to Booking',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: (_selectedDate != null && _selectedTime != null)
                          ? Colors.white
                          : Colors.grey.shade500,
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

  /// AppBar - Modern redesigned to match confirm booking screen
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
                    _salonName ?? 'Select Date',
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
            if (_salonImage != null && _salonImage!.isNotEmpty)
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
                    _salonImage!,
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
