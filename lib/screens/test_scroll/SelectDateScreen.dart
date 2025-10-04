import 'dart:developer';

import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/home/Professional.dart';
import '../../models/home/ServiceData.dart';
import 'package:app/models/HomePageResponse.dart';

import 'CartSummarySection.dart';
import 'CustomAppBar.dart';
import 'select_time_screen.dart';

class SelectDateScreen extends StatefulWidget {
  static const String routeName = '/select-date';

  const SelectDateScreen({Key? key}) : super(key: key);

  @override
  _SelectDateScreenState createState() => _SelectDateScreenState();
}

class _SelectDateScreenState extends State<SelectDateScreen> {
  DateTime _currentDate = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _availableDates = [];
  List<Professional> _selectedProfessionals = [];
  String? _salonName;
  String? _salonAddress;
  String? _salonImage;

  Map<dynamic, int>? _cartItems;

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

        final selectedProfessionals = arguments['selectedProfessionals'] as Map<dynamic, String?>?;
        if (selectedProfessionals != null) {
          for (var entry in selectedProfessionals.entries) {
            if (entry.key is Service) {
              final service = entry.key as Service;
              final professionalName = entry.value;
              if (professionalName != null && professionalName != 'Any' && service.professionals != null) {
                final professional = service.professionals!.firstWhere(
                      (p) => p.name == professionalName,
                  orElse: () => Professional(name: 'Unknown'),
                );
                if (professional.name != 'Unknown') {
                  _selectedProfessionals.add(professional);
                }
              }
            }
          }
        }
      } else {
        _selectedProfessionals = [];
        _salonName = null;
        _salonAddress = null;
        _cartItems = null;
      }

      setState(() {
        _availableDates = _calculateAvailableDates();
      });
    });
  }

  List<DateTime> _calculateAvailableDates() {
    final now = DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    final endDate = DateTime.now().add(Duration(days: 60));
    List<DateTime> availableDates = [];

    if (_selectedProfessionals.isNotEmpty) {
      for (DateTime date = now; date.isBefore(endDate) || date.isAtSameMomentAs(endDate); date = date.add(const Duration(days: 1))) {
        bool isAvailable = true;
        for (var professional in _selectedProfessionals) {
          if (!_isProfessionalAvailableOnDate(professional, date)) {
            isAvailable = false;
            break;
          }
        }
        if (isAvailable) {
          availableDates.add(DateTime(date.year, date.month, date.day));
        }
      }
    } else {
      for (DateTime date = now; date.isBefore(endDate) || date.isAtSameMomentAs(endDate); date = date.add(const Duration(days: 1))) {
        availableDates.add(DateTime(date.year, date.month, date.day));
      }
    }

    return availableDates;
  }

  bool _isProfessionalAvailableOnDate(Professional professional, DateTime date) {
    final startDate = professional.start_date != null ? DateTime.parse(professional.start_date!) : null;
    final endDate = professional.end_date != null ? DateTime.parse(professional.end_date!) : null;
    if (startDate != null && date.isBefore(startDate)) return false;
    if (endDate != null && date.isAfter(endDate)) return false;

    switch (date.weekday) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(salonName: _salonName, salonAddress: _salonAddress, salonImage: _salonImage),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TableCalendar(
                  firstDay: _currentDate,
                  lastDay: DateTime.now().add(Duration(days: 60)),
                  focusedDay: _currentDate,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (_availableDates.any((d) => isSameDay(d, selectedDay))) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _currentDate = focusedDay; // Update focused day
                      });
                    }
                  },
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: kPrimaryDarkColor,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.black),
                    weekendStyle: TextStyle(color: Colors.black),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  enabledDayPredicate: (date) {
                    return _availableDates.any((d) => isSameDay(d, date));
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (_availableDates.any((d) => isSameDay(d, date))) {
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: kPrimaryDarkColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ),
              if (_selectedDay != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Selected Date: ${_selectedDay!.toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 80), // Space for the positioned button
            ],
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
                  minimumSize: const Size(double.infinity, 48), // Full-width button
                  backgroundColor: _selectedDay != null ? kPrimaryDarkColor : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _selectedDay != null
                    ? () {
                  Navigator.pushNamed(
                    context,
                    SelectTimeScreen.routeName,
                    arguments: {
                      'cartItems': _cartItems,
                      'selectedDay': _selectedDay,
                      'selectedProfessionals': _selectedProfessionals,
                      'salonName': _salonName,
                      'salonAddress': _salonAddress,
                    },
                  );
                }
                    : null,
                child: const Text(
                  'Confirm Date',
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
}