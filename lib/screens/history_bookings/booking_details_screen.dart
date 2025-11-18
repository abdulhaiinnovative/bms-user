import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Adjust path based on your project structure
import '../../models/MyBookingResponse.dart'; // Adjust path based on your project structure
import '../../constants.dart'; // Adjust path for your constants file

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  Future<void> _cancelBooking(BuildContext context) async {
    try {
      // TODO: Implement with BookingsViewModel.cancelBooking()
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
      // Navigate back with a result indicating cancellation
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel booking: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(booking.date ?? '');
    final formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : 'N/A';
    final formattedTime = booking.time != null
        ? DateFormat('hh:mm a').format(DateFormat('HH:mm:ss').parse(booking.time!))
        : 'N/A';

    return Scaffold(
      backgroundColor: kCardBG,
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Hero(
                        tag: 'salon-logo-${booking.id}',
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          // backgroundImage: booking.salon?.logo != null ? NetworkImage(booking.salon!.logo!) : null,
                          // child: booking.salon?.logo == null
                          //     ? Icon(Icons.store, size: 60, color: Colors.grey[600])
                          //     : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        // booking.salon?.name ??
                            'Unknown Salon',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Ensure white background
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2), // Softer shadow color
                            spreadRadius: 1, // Low spread for softness
                            blurRadius: 8, // Higher blur for soft effect
                            offset: const Offset(0, 4), // Vertical offset for elevation
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 0, // Disable Card's shadow to avoid overlap
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(Icons.calendar_today, 'Date', formattedDate),
                              const SizedBox(height: 12),
                              _buildDetailRow(Icons.access_time, 'Time', formattedTime),
                              const SizedBox(height: 12),
                              _buildDetailRow(Icons.check_circle, 'Status', booking.status ?? 'N/A'),
                              const SizedBox(height: 12),
                              _buildDetailRow(Icons.category, 'Type', booking.bookingType ?? 'N/A'),
                              const SizedBox(height: 12),
                              _buildDetailRow(Icons.payment, 'Payment', booking.paymentStatus ?? 'N/A'),
                              const SizedBox(height: 12),
                              _buildDetailRow(Icons.group, 'Team ID', booking.teamId.toString() ?? 'N/A'),
                              const SizedBox(height: 12),
                              _buildDetailRow(Icons.monetization_on, 'Amount', 'PKR ${booking.payment ?? 0}'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
            
            if (!(booking.status?.toLowerCase().contains('cancelled') == true || booking.status?.toLowerCase().contains('completed') == true))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: () => _cancelBooking(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Cancel Booking',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: kPrimaryDarkColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}