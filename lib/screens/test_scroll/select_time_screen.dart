import 'dart:developer';

import 'package:app/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/models/HomePageResponse.dart';
import '../../models/home/Professional.dart';
import 'CustomAppBar.dart';
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
  String? _salonName;
  String? _salonAddress;
  Map<dynamic, int>? _cartItems;
  List<String> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
      if (arguments != null) {
        _cartItems = arguments['cartItems'] as Map<dynamic, int>?;
        _selectedDay = arguments['selectedDay'] as DateTime?;
        _selectedProfessionals = arguments['selectedProfessionals'] as List<Professional>? ?? [];
        _salonName = arguments['salonName'] as String?;
        _salonAddress = arguments['salonAddress'] as String?;
      } else {
        log('No arguments received in SelectTimeScreen');
      }

      setState(() {
        _timeSlots = _generateTimeSlots();
      });
    });
  }

  List<String> _generateTimeSlots() {
    if (_selectedDay == null) {
      log('Error: _selectedDay is null, cannot generate time slots');
      return [];
    }

    List<String> slots = [];
    DateTime startTime = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 11, 0);
    DateTime endTime = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 20, 0);

    while (startTime.isBefore(endTime) || startTime.isAtSameMomentAs(endTime)) {
      final hour = startTime.hour % 12 == 0 ? 12 : startTime.hour % 12;
      final period = startTime.hour < 12 ? 'AM' : 'PM';
      final timeString = '$hour:${startTime.minute.toString().padLeft(2, '0')} $period';
      slots.add(timeString);
      startTime = startTime.add(const Duration(minutes: 30));
    }
    log('Generated time slots: $slots');
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(salonName: _salonName, salonAddress: _salonAddress, salonImage: salonImage),
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          setState(() {
                            _selectedTime = time;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 48),
                          backgroundColor: _selectedTime == time ? kPrimaryDarkColor : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedTime == time ? Colors.white : Colors.black,
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
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
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48), // Full-width button
                  backgroundColor: _selectedTime != null ? kPrimaryDarkColor : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _selectedTime != null
                    ? () {
                  log('Navigating to ConfirmBookingScreen with:');
                  log('  cartItems: ${_cartItems?.keys.map((s) => s.name).toList()}');
                  log('  selectedDay: $_selectedDay');
                  log('  selectedTime: $_selectedTime');
                  log('  selectedProfessionals: ${_selectedProfessionals.map((p) => p.name).toList()}');
                  log('  salonName: $_salonName');
                  log('  salonAddress: $_salonAddress');

                  Navigator.pushNamed(
                    context,
                    ConfirmBookingScreen.routeName,
                    arguments: {
                      'cartItems': _cartItems,
                      'selectedDay': _selectedDay,
                      'selectedTime': _selectedTime,
                      'selectedProfessionals': _selectedProfessionals,
                      'salonName': _salonName,
                      'salonAddress': _salonAddress,
                    },
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
}