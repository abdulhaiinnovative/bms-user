import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import '../../models/home/Professional.dart';
import '../../models/HomePageResponse.dart';
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
  Salon? _salon;
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
        _selectedProfessionals =
            arguments['selectedProfessionals'] as List<Professional>? ?? [];
        _salonName = arguments['salonName'] as String?;
        _salonAddress = arguments['salonAddress'] as String?;
        _salon = arguments['salon'] as Salon?;
      }

      setState(() {
        _timeSlots = _generateTimeSlots();
      });
    });
  }

  List<String> _generateTimeSlots() {
    if (_selectedDay == null) {
      return [];
    }

    int startHour = 8;
    int startMinute = 0;
    int endHour = 23;
    int endMinute = 0;

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
                            'salonId': _salon?.id,
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
            if (_salon?.image != null && _salon!.image!.isNotEmpty)
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
                    _salon!.image!,
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
