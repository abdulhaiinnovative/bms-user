import 'dart:convert';
import 'dart:developer';

import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../models/home/Professional.dart';
import 'package:app/models/salon_detail_models.dart';
import 'package:app/models/HomePageResponse.dart' as home_models;
import 'confirm_booking_screen.dart';

class SelectDateScreen extends StatefulWidget {
  static const String routeName = '/select-date';
  const SelectDateScreen({
    Key? key,
  }) : super(key: key);

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
  SalonData? _salon;
  Map<dynamic, int>? _cartItems;
  int monday = 0;
  int tuesday = 0;
  int wednesday = 0;
  int thursday = 0;
  int friday = 0;
  int saturday = 0;
  int sunday = 0;
  final List<Professional> _selectedProfessionals = [];
  // Professionals aligned 1:1 with service_id order for booking payload.
  // Includes an "Any" placeholder (id=1) when user didn't choose a specific pro.
  final List<Professional> _bookingProfessionals = [];

  int? _inferSalonIdFromCartItems(Map<dynamic, int>? cartItems) {
    if (cartItems == null || cartItems.isEmpty) return null;
    for (final item in cartItems.keys) {
      if (item is Service) return item.salonId;
      if (item is Deal) return item.salonId;
      if (item is home_models.Service) return item.salonId;
      if (item is home_models.Deal) return item.salonId;
    }
    return null;
  }

  Future<SalonData?> _fetchSalonDetailAsLocalModel(int salonId) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/salons/$salonId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return null;

      final responseObj = decoded['response'];
      if (responseObj is! Map) return null;

      final data = responseObj['data'];
      if (data is! Map) return null;

      return SalonData.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromArguments();
    });
  }

  Future<void> _initializeFromArguments() async {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final args = arguments is Map
        ? Map<String, dynamic>.from(arguments)
        : <String, dynamic>{};

    _cartItems = args['cartItems'] as Map<dynamic, int>? ?? {};
    _salonName = args['salonName'] as String?;
    _salonAddress = args['salonAddress'] as String?;
    _salonImage = args['salonImage'] as String?;

    // Prefer salon passed from previous screen.
    SalonData? salon = args['salon'] as SalonData?;

    // If not provided, infer salonId and fetch full salon schedule.
    if (salon == null) {
      final dynamic rawSalonId = args['salonId'];
      final int? salonIdFromArgs = rawSalonId is int
          ? rawSalonId
          : (rawSalonId is String ? int.tryParse(rawSalonId) : null);
      final int? inferredSalonId =
          salonIdFromArgs ?? _inferSalonIdFromCartItems(_cartItems);

      if (inferredSalonId != null) {
        salon = await _fetchSalonDetailAsLocalModel(inferredSalonId);
      }
    }

    if (!mounted) return;

    if (salon == null) {
      // If we can't load the salon schedule, this screen can't function.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load salon schedule. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    _salon = salon;

    // Build booking professionals aligned to service order.
    // NOTE: The booking API expects profession_id length == service_id length.
    _bookingProfessionals.clear();
    final selectedProfessionalsByService =
        args['selectedProfessionals'] as Map<dynamic, String?>?;
    if (_cartItems != null && _cartItems!.isNotEmpty) {
      for (final entry in _cartItems!.entries) {
        final item = entry.key;
        if (item is Service || item is home_models.Service) {
          final selectedName = selectedProfessionalsByService?[item];
          if (selectedName == null || selectedName == 'Any') {
            _bookingProfessionals.add(
              Professional(id: 1, name: 'Any'),
            );
            continue;
          }

          final profs = (item as dynamic).professionals as List<Professional>?;
          if (profs == null || profs.isEmpty) {
            _bookingProfessionals.add(
              Professional(id: 1, name: 'Any'),
            );
            continue;
          }

          try {
            final professional = profs.firstWhere(
              (p) => (p.name ?? '').trim() == selectedName.trim(),
            );
            _bookingProfessionals.add(professional);
          } catch (_) {
            _bookingProfessionals.add(
              Professional(id: 1, name: 'Any'),
            );
          }
        }
      }
    }

    _selectedProfessionals.clear();
    final selectedProfessionalsList =
        args['selectedProfessionalsList'] as List<Professional>?;

    if (selectedProfessionalsList != null &&
        selectedProfessionalsList.isNotEmpty) {
      _selectedProfessionals.addAll(selectedProfessionalsList);
    } else {
      final selectedProfessionals =
          args['selectedProfessionals'] as Map<dynamic, String?>?;
      if (selectedProfessionals != null) {
        for (var entry in selectedProfessionals.entries) {
          if (entry.value == null || entry.value == 'Any') continue;
          final key = entry.key;
          if (key is Service || key is home_models.Service) {
            final profs = (key as dynamic).professionals as List<Professional>?;
            if (profs != null) {
              try {
                final professional = profs.firstWhere(
                  (p) => p.name == entry.value,
                );
                _selectedProfessionals.add(professional);
              } catch (e) {}
            }
          }
        }
      }
    }

    if (_selectedProfessionals.isNotEmpty) {
      monday = _selectedProfessionals.every((p) => p.monday == 1) ? 1 : 0;
      tuesday = _selectedProfessionals.every((p) => p.tuesday == 1) ? 1 : 0;
      wednesday = _selectedProfessionals.every((p) => p.wednesday == 1) ? 1 : 0;
      thursday = _selectedProfessionals.every((p) => p.thursday == 1) ? 1 : 0;
      friday = _selectedProfessionals.every((p) => p.friday == 1) ? 1 : 0;
      saturday = _selectedProfessionals.every((p) => p.saturday == 1) ? 1 : 0;
      sunday = _selectedProfessionals.every((p) => p.sunday == 1) ? 1 : 0;
    }

    // Log calendar availability calculation
    _logCalendarAvailability();

    final activeDays = _salon?.activeDays ?? <ActiveDay>[];
    for (var idx = 0; idx < activeDays.length; idx++) {
      final ad = activeDays[idx];
      final id = ad.id?.toString() ?? 'null';
      final day = ad.day?.toString() ?? 'null';
      final salonId = ad.salonId?.toString() ?? 'null';
      final openingTime = ad.openingTime?.toString() ?? 'null';
      final closingTime = ad.closingTime?.toString() ?? 'null';
      final statusRaw = ad.status?.toString() ?? 'null';
      final statusText = ad.status == 1
          ? 'OPEN'
          : ad.status == 0
              ? 'CLOSED'
              : 'UNKNOWN';

      log(
        'ActiveDay[$idx] {\n'
        '  id         : $id\n'
        '  day        : $day\n'
        '  salonId    : $salonId\n'
        '  openingTime: $openingTime\n'
        '  closingTime: $closingTime\n'
        '  status     : $statusRaw ($statusText)\n'
        '}',
        name: 'SelectDateScreen.initState',
      );
    }

    setState(() {});
  }

  Future<void> _selectDate() async {
    if (_selectedProfessionals.isEmpty) {
      // Allow proceeding even when no professionals are selected
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Parse min and max booking time from salon (in DAYS)
    int minBookingDays = 0;
    int maxBookingDays = 30;

    if (_salon?.minBookingTime != null && _salon!.minBookingTime!.isNotEmpty) {
      try {
        minBookingDays = int.parse(_salon!.minBookingTime!);
        if (minBookingDays < 0) {
          minBookingDays = 0;
        }
      } catch (e) {
        minBookingDays = 0;
      }
    }

    if (_salon?.maxBookingTime != null && _salon!.maxBookingTime!.isNotEmpty) {
      try {
        maxBookingDays = int.parse(_salon!.maxBookingTime!);
        if (maxBookingDays < 1) {
          maxBookingDays = 30;
        } else if (maxBookingDays > 365) {
          maxBookingDays = 365;
        }
      } catch (e) {
        maxBookingDays = 30;
      }
    }

    // Calculate first and last selectable dates
    final firstDay = today.add(Duration(days: minBookingDays));
    final lastDay = today.add(Duration(days: maxBookingDays));

    // Validate configuration
    if (firstDay.isAfter(lastDay)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Invalid booking configuration: Minimum booking time is greater than maximum.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Log booking window calculation
    _logBookingWindow(today, minBookingDays, maxBookingDays, firstDay, lastDay);

    DateTime initialDateToUse = _selectedDate ?? firstDay;

    // Ensure initial date is within range
    if (initialDateToUse.isBefore(firstDay)) {
      initialDateToUse = firstDay;
    } else if (initialDateToUse.isAfter(lastDay)) {
      initialDateToUse = firstDay;
    }

    bool isInitialDateValid = _isSalonOpenOnDate(initialDateToUse) &&
        _areProfessionalsAvailableOnDate(initialDateToUse);

    if (!isInitialDateValid) {
      bool foundValidDate = false;
      final daysInRange = lastDay.difference(firstDay).inDays;
      for (int i = 0; i <= daysInRange; i++) {
        final testDate = firstDay.add(Duration(days: i));
        if (_isSalonOpenOnDate(testDate) &&
            _areProfessionalsAvailableOnDate(testDate)) {
          initialDateToUse = testDate;
          foundValidDate = true;
          break;
        }
      }

      if (!foundValidDate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No available dates found. The selected professionals may not have any common available days within the booking window.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDateToUse,
      firstDate: firstDay,
      lastDate: lastDay,
      selectableDayPredicate: (DateTime date) {
        final isOpen = _isSalonOpenOnDate(date);
        final professionalsAvailable = _areProfessionalsAvailableOnDate(date);
        return isOpen && professionalsAvailable;
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

  bool _areProfessionalsAvailableOnDate(DateTime date) {
    if (_selectedProfessionals.isEmpty) {
      return true;
    }

    for (var professional in _selectedProfessionals) {
      if (!_isProfessionalAvailableOnDay(professional, date.weekday)) {
        return false;
      }
    }

    return true;
  }

  bool _isProfessionalAvailableOnDay(Professional professional, int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return professional.monday == 1;
      case DateTime.tuesday:
        return professional.tuesday == 1;
      case DateTime.wednesday:
        return professional.wednesday == 1;
      case DateTime.thursday:
        return professional.thursday == 1;
      case DateTime.friday:
        return professional.friday == 1;
      case DateTime.saturday:
        return professional.saturday == 1;
      case DateTime.sunday:
        return professional.sunday == 1;
      default:
        return false;
    }
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

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  /// Logs comprehensive calendar availability calculation based on professional selections
  void _logCalendarAvailability() {
    log("═══════════════════════════════════════════════════════════════",
        name: "Calendar Availability");
    log("📅 CALENDAR AVAILABILITY CALCULATION", name: "Calendar Availability");
    log("═══════════════════════════════════════════════════════════════",
        name: "Calendar Availability");

    // Scenario 1: No specific professionals selected (all "Any")
    if (_selectedProfessionals.isEmpty) {
      log("\n🔄 SCENARIO 1: All professionals set to 'Any'",
          name: "Calendar Availability");
      log("  ➜ Strategy: Show ALL salon open days",
          name: "Calendar Availability");

      if (_salon?.activeDays != null) {
        final salonOpenDays = _salon!.activeDays!
            .where((day) => day.status == 1)
            .map((day) => day.day ?? 'Unknown')
            .toList();
        log("  ➜ Salon Open Days (${salonOpenDays.length}): ${salonOpenDays.join(', ')}",
            name: "Calendar Availability");
        log("  ✅ Result: Calendar shows ALL ${salonOpenDays.length} salon open days",
            name: "Calendar Availability");
      } else {
        log("  ⚠️ Warning: No salon active days configured",
            name: "Calendar Availability");
      }
    }
    // Scenario 2 & 3: One or more specific professionals selected
    else {
      final profCount = _selectedProfessionals.length;
      if (profCount == 1) {
        log("\n🎯 SCENARIO 2: ONE specific professional selected",
            name: "Calendar Availability");
      } else {
        log("\n🎯 SCENARIO 3: MULTIPLE professionals selected ($profCount)",
            name: "Calendar Availability");
      }

      log("  ➜ Strategy: Show intersection of professional(s) available days ∩ salon open days",
          name: "Calendar Availability");
      log("\n  📋 Selected Professionals:", name: "Calendar Availability");

      // Log each professional's availability
      for (int i = 0; i < _selectedProfessionals.length; i++) {
        final prof = _selectedProfessionals[i];
        final availableDays = <String>[];

        if (prof.monday == 1) availableDays.add('Mon');
        if (prof.tuesday == 1) availableDays.add('Tue');
        if (prof.wednesday == 1) availableDays.add('Wed');
        if (prof.thursday == 1) availableDays.add('Thu');
        if (prof.friday == 1) availableDays.add('Fri');
        if (prof.saturday == 1) availableDays.add('Sat');
        if (prof.sunday == 1) availableDays.add('Sun');

        log("  ${i + 1}. ${prof.name ?? 'Unknown'}",
            name: "Calendar Availability");
        log("     ├─ Available Days: ${availableDays.join(', ')}",
            name: "Calendar Availability");
        log("     └─ Raw: Mon=${prof.monday}, Tue=${prof.tuesday}, Wed=${prof.wednesday}, Thu=${prof.thursday}, Fri=${prof.friday}, Sat=${prof.saturday}, Sun=${prof.sunday}",
            name: "Calendar Availability");
      }

      // Calculate intersection
      log("\n  🔍 Calculating Intersection:", name: "Calendar Availability");

      final intersectionDays = <String>[];
      final intersectionWeekdays = <int>[];

      // Check each day of the week
      for (int weekday = DateTime.monday;
          weekday <= DateTime.sunday;
          weekday++) {
        bool allProfessionalsAvailable = true;

        for (var prof in _selectedProfessionals) {
          if (!_isProfessionalAvailableOnDay(prof, weekday)) {
            allProfessionalsAvailable = false;
            break;
          }
        }

        if (allProfessionalsAvailable) {
          intersectionWeekdays.add(weekday);
          intersectionDays.add(_getWeekdayName(weekday));
        }
      }

      if (profCount > 1) {
        // Show detailed intersection calculation
        log("  ├─ Step 1: Find days where ALL professionals available",
            name: "Calendar Availability");
        for (int weekday = DateTime.monday;
            weekday <= DateTime.sunday;
            weekday++) {
          final dayName = _getWeekdayName(weekday);
          final availableProfs = <String>[];

          for (var prof in _selectedProfessionals) {
            if (_isProfessionalAvailableOnDay(prof, weekday)) {
              availableProfs.add(prof.name ?? 'Unknown');
            }
          }

          final allAvailable = availableProfs.length == profCount;
          final icon = allAvailable ? '✓' : '✗';
          log("  │  $icon $dayName: ${availableProfs.length}/$profCount available ${allAvailable ? '(INCLUDED)' : '(excluded)'}",
              name: "Calendar Availability");
        }
      }

      log("  ├─ Intersection Result: ${intersectionDays.join(', ')}",
          name: "Calendar Availability");

      // Intersect with salon days
      if (_salon?.activeDays != null) {
        final salonOpenDays = <String>[];
        for (var activeDay in _salon!.activeDays!) {
          if (activeDay.status == 1 && activeDay.day != null) {
            salonOpenDays.add(activeDay.day!);
          }
        }

        log("  ├─ Step 2: Intersect with salon open days",
            name: "Calendar Availability");
        log("  │  Salon Days: ${salonOpenDays.join(', ')}",
            name: "Calendar Availability");

        // Calculate final intersection
        final finalDays = <String>[];
        for (int weekday in intersectionWeekdays) {
          final dayName = _getDayName(weekday);
          if (salonOpenDays.contains(dayName)) {
            finalDays.add(_getWeekdayName(weekday));
          }
        }

        log("  └─ Final Intersection: ${finalDays.join(', ')}",
            name: "Calendar Availability");

        if (finalDays.isEmpty) {
          log("\n  ❌ ERROR: No common available days found!",
              name: "Calendar Availability");
          log("  ➜ Selected professionals have no overlapping availability with salon schedule",
              name: "Calendar Availability");
        } else {
          log("\n  ✅ Result: Calendar will show only ${finalDays.length} day(s): ${finalDays.join(', ')}",
              name: "Calendar Availability");
        }
      }

      // Log the calculated availability flags
      log("\n  📊 Calculated Availability Flags:",
          name: "Calendar Availability");
      log("  ├─ Monday: ${monday == 1 ? '✓ Available' : '✗ Not Available'}",
          name: "Calendar Availability");
      log("  ├─ Tuesday: ${tuesday == 1 ? '✓ Available' : '✗ Not Available'}",
          name: "Calendar Availability");
      log("  ├─ Wednesday: ${wednesday == 1 ? '✓ Available' : '✗ Not Available'}",
          name: "Calendar Availability");
      log("  ├─ Thursday: ${thursday == 1 ? '✓ Available' : '✗ Not Available'}",
          name: "Calendar Availability");
      log("  ├─ Friday: ${friday == 1 ? '✓ Available' : '✗ Not Available'}",
          name: "Calendar Availability");
      log("  ├─ Saturday: ${saturday == 1 ? '✓ Available' : '✗ Not Available'}",
          name: "Calendar Availability");
      log("  └─ Sunday: ${sunday == 1 ? '✓ Available' : '✗ Not Available'}",
          name: "Calendar Availability");
    }

    log("═══════════════════════════════════════════════════════════════",
        name: "Calendar Availability");
    log("✅ Calendar Availability Calculation Complete",
        name: "Calendar Availability");
    log("═══════════════════════════════════════════════════════════════\n",
        name: "Calendar Availability");
  }

  /// Logs booking window calculation with min/max booking days
  void _logBookingWindow(DateTime today, int minDays, int maxDays,
      DateTime firstDate, DateTime lastDate) {
    log("═══════════════════════════════════════════════════════════════",
        name: "Booking Window");
    log("📅 CALENDAR BOOKING WINDOW CALCULATION", name: "Booking Window");
    log("═══════════════════════════════════════════════════════════════",
        name: "Booking Window");

    final dateFormat = DateFormat('yyyy-MM-dd');
    log("Current Date: ${dateFormat.format(today)}", name: "Booking Window");
    log("Min Booking Time: $minDays days", name: "Booking Window");
    log("Max Booking Time: $maxDays days", name: "Booking Window");
    log("", name: "Booking Window");

    log("Calculation:", name: "Booking Window");
    log("  ├─ Min Available: ${dateFormat.format(today)} + $minDays days = ${dateFormat.format(firstDate)}",
        name: "Booking Window");
    log("  │  └─ First Selectable Date: ${dateFormat.format(firstDate)}",
        name: "Booking Window");
    log("  ├─ Max Available: ${dateFormat.format(today)} + $maxDays days = ${dateFormat.format(lastDate)}",
        name: "Booking Window");
    log("  │  └─ Last Selectable Date: ${dateFormat.format(lastDate)}",
        name: "Booking Window");
    log("", name: "Booking Window");

    final daysDiff = lastDate.difference(firstDate).inDays + 1;
    final firstFormatted = DateFormat('MMM d, yyyy').format(firstDate);
    final lastFormatted = DateFormat('MMM d, yyyy').format(lastDate);

    log("✅ Calendar Range: $firstFormatted → $lastFormatted ($daysDiff days)",
        name: "Booking Window");
    log("═══════════════════════════════════════════════════════════════",
        name: "Booking Window");
  }

  /// Check if the given date is today
  bool _isDateToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Calculate the next available 15-minute slot after current time
  DateTime _getNextAvailableSlot(DateTime currentTime) {
    int minutes = currentTime.minute;
    int roundedMinutes = ((minutes / 15).ceil()) * 15;

    if (roundedMinutes == 60) {
      return DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        currentTime.hour + 1,
        0,
      );
    }

    return DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      currentTime.hour,
      roundedMinutes,
    );
  }

  /// Logs time slot generation for selected date
  void _logTimeSlotGeneration(DateTime date, String dayName,
      String? openingTime, String? closingTime, int totalSlots) {
    log("═══════════════════════════════════════════════════════════════",
        name: "Time Slots");
    log("🕐 TIME SLOT GENERATION", name: "Time Slots");
    log("═══════════════════════════════════════════════════════════════",
        name: "Time Slots");

    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    log("Selected Date: ${dateFormat.format(date)}", name: "Time Slots");
    log("", name: "Time Slots");

    final dayCapitalized = dayName[0].toUpperCase() + dayName.substring(1);
    log("Salon Hours for $dayCapitalized:", name: "Time Slots");
    log("  ├─ Opening Time: ${openingTime ?? 'N/A'}", name: "Time Slots");

    if (closingTime == '00:00:00') {
      log("  └─ Closing Time: 00:00:00 (midnight → 23:45)", name: "Time Slots");
    } else {
      log("  └─ Closing Time: ${closingTime ?? 'N/A'}", name: "Time Slots");
    }

    log("", name: "Time Slots");
    log("✅ Total Slots Available: $totalSlots (15-minute intervals)",
        name: "Time Slots");
    log("═══════════════════════════════════════════════════════════════",
        name: "Time Slots");
  }

  List<String> _generateTimeSlots(DateTime date) {
    List<String> slots = [];

    String? openingTime;
    String? closingTime;
    final dayName = _getDayName(date.weekday);

    if (_salon?.activeDays != null) {
      try {
        final activeDay = _salon!.activeDays!.firstWhere(
          (ad) => ad.day?.toLowerCase() == dayName.toLowerCase(),
        );
        openingTime = activeDay.openingTime;
        closingTime = activeDay.closingTime;
      } catch (e) {
        // Day not found in salon schedule
      }
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
      } catch (e) {
        // Use default opening time
      }
    }

    if (closingTime != null && closingTime.isNotEmpty) {
      try {
        final parts = closingTime.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        // Special case: 00:00:00 means midnight (end of day)
        if (hour == 0 && minute == 0) {
          endHour = 23;
          endMinute = 45; // Last slot at 11:45 PM
        } else {
          endHour = hour;
          endMinute = minute;
        }
      } catch (e) {
        // Use default closing time
      }
    }

    // Check if selected date is today and adjust start time accordingly
    bool isToday = _isDateToday(date);
    if (isToday) {
      DateTime now = DateTime.now();
      DateTime nextSlot = _getNextAvailableSlot(now);

      DateTime proposedStart = DateTime(
        date.year,
        date.month,
        date.day,
        startHour,
        startMinute,
      );

      // If next available slot is after the salon's opening time, use it
      if (nextSlot.isAfter(proposedStart)) {
        startHour = nextSlot.hour;
        startMinute = nextSlot.minute;

        // Log current time adjustment
        log("🕐 Selected date is TODAY - adjusting for current time",
            name: "Time Slots");
        log("  Current Time: ${DateFormat('h:mm a').format(now)}",
            name: "Time Slots");
        log("  Next Available Slot: ${DateFormat('h:mm a').format(nextSlot)}",
            name: "Time Slots");
        log("  Adjusted Start Time: $startHour:${startMinute.toString().padLeft(2, '0')}",
            name: "Time Slots");
        log("", name: "Time Slots");
      }
    }

    DateTime startTime =
        DateTime(date.year, date.month, date.day, startHour, startMinute);
    DateTime endTime =
        DateTime(date.year, date.month, date.day, endHour, endMinute);

    // If start time is after or equal to end time, no slots available
    if (startTime.isAfter(endTime) || startTime.isAtSameMomentAs(endTime)) {
      if (isToday) {
        log("⚠️ No slots available: Current time is at or past closing time",
            name: "Time Slots");
      }
      _logTimeSlotGeneration(date, dayName, openingTime, closingTime, 0);
      return slots;
    }

    while (startTime.isBefore(endTime) || startTime.isAtSameMomentAs(endTime)) {
      final hour = startTime.hour % 12 == 0 ? 12 : startTime.hour % 12;
      final period = startTime.hour < 12 ? 'AM' : 'PM';
      final timeString =
          '$hour:${startTime.minute.toString().padLeft(2, '0')} $period';
      slots.add(timeString);
      startTime = startTime.add(const Duration(minutes: 15));
    }

    // Log time slot generation
    _logTimeSlotGeneration(
        date, dayName, openingTime, closingTime, slots.length);

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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ConfirmBookingScreen(),
                              settings: RouteSettings(
                                arguments: {
                                  'cartItems': _cartItems,
                                  'selectedDay': _selectedDate,
                                  'selectedTime': _selectedTime,
                                  // For UI/availability (can be empty = Any).
                                  'selectedProfessionals':
                                      _selectedProfessionals,
                                  // For booking payload (always matches service count).
                                  'bookingProfessionals': _bookingProfessionals,
                                  'salonName': _salonName,
                                  'salonAddress': _salonAddress,
                                  'salonImage': _salonImage,
                                  'salonId': _salon?.id,
                                },
                              ),
                            ),
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
