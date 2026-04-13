import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../../constants.dart';
import '../../data/models/booking_detail_response.dart';
import '../../data/services/booking_detail_api.dart';
import '../../../../api_services/review_api.dart';
import '../../../auth/utils/auth_manager.dart';

class BookingDetailsScreen extends StatefulWidget {
  final int bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final BookingDetailAPI _api = BookingDetailAPI();
  BookingDetail? _bookingData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      developer.log(
          'BookingDetailsScreen.initState | bookingId=${widget.bookingId}',
          name: 'booking.screen');
    }
    _fetchBookingDetail();
  }

  Future<void> _fetchBookingDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      if (kDebugMode) {
        developer.log(
            'BookingDetailsScreen._fetchBookingDetail started | bookingId=${widget.bookingId}',
            name: 'booking.screen');
        
        // DEBUG: Print auth token and booking ID for diagnostic script
        AuthManager.getToken().then((token) {
          print('\n╔═══════════════════════════════════════════════════════════════╗');
          print('║ 🔍 DEBUG INFO FOR DIAGNOSTIC SCRIPT                           ║');
          print('╠═══════════════════════════════════════════════════════════════╣');
          print('║ Booking ID: ${widget.bookingId}');
          print('║ Auth Token: ${token ?? "NOT FOUND"}');
          print('╠═══════════════════════════════════════════════════════════════╣');
          print('║ Run this command to fetch API data:                          ║');
          print('║ dart run scripts/fetch_booking_detail.dart ${widget.bookingId} ${token ?? "YOUR_TOKEN"}');
          print('╚═══════════════════════════════════════════════════════════════╝\n');
        });
      }

      final response = await _api.getBookingDetail(widget.bookingId);

      if (response.status) {
        setState(() {
          _bookingData = response.response.data;
          _isLoading = false;
        });
        if (kDebugMode) {
          developer.log(
              'BookingDetailsScreen._fetchBookingDetail success | bookingId=${widget.bookingId}',
              name: 'booking.screen');
          
          // DEBUG: Log staff information for each service
          print('\n╔═══════════════════════════════════════════════════════════════╗');
          print('║ 📋 SERVICES & STAFF DATA RECEIVED                             ║');
          print('╠═══════════════════════════════════════════════════════════════╣');
          if (_bookingData?.services != null && _bookingData!.services.isNotEmpty) {
            for (var i = 0; i < _bookingData!.services.length; i++) {
              final service = _bookingData!.services[i];
              print('║ Service ${i + 1}: ${service.name}');
              print('║   Has staff: ${service.selectedProfessional != null}');
              if (service.selectedProfessional != null) {
                print('║   Staff name: ${service.selectedProfessional!.displayName}');
                print('║   Staff ID: ${service.selectedProfessional!.id}');
              } else {
                print('║   ⚠️  WARNING: Staff is NULL for this service!');
              }
              print('║');
            }
          } else {
            print('║ ⚠️  WARNING: No services found in booking!');
          }
          print('╚═══════════════════════════════════════════════════════════════╝\n');
        }
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
        if (kDebugMode) {
          developer.log(
              'BookingDetailsScreen._fetchBookingDetail api error | bookingId=${widget.bookingId} | message=${response.message}',
              name: 'booking.screen');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
            'BookingDetailsScreen._fetchBookingDetail exception | bookingId=${widget.bookingId} | error=$e',
            name: 'booking.screen');
      }
      setState(() {
        _error = 'Failed to load booking details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelBooking(BuildContext context) async {
    try {
      // Uncomment when API is implemented
      // await MyBookingsAPI().cancelBooking(widget.bookingId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
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

  Future<void> _showReviewDialog(BuildContext context) async {
    int rating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Write a Review',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rating',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: isSubmitting
                          ? null
                          : () => setState(() => rating = index + 1),
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Comment',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  enabled: !isSubmitting,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Share your experience...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (commentController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please write a comment'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      setState(() => isSubmitting = true);

                      try {
                        final api = ReviewAPI();
                        await api.createReview(
                          bookingId: widget.bookingId,
                          rating: rating,
                          comment: commentController.text.trim(),
                        );

                        if (mounted) {
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Review submitted successfully'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          // Refresh booking details to show new review
                          _fetchBookingDetail();
                        }
                      } catch (e) {
                        setState(() => isSubmitting = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to submit review: $e'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardBG,
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBookingDetail,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_bookingData == null) {
      return const Center(child: Text('No booking data available'));
    }

    final booking = _bookingData!;
    final date = DateTime.tryParse(booking.date ?? '');
    final formattedDate =
        date != null ? DateFormat('MMM dd, yyyy').format(date) : 'N/A';
    final formattedTime = booking.time != null
        ? DateFormat('hh:mm a')
            .format(DateFormat('HH:mm:ss').parse(booking.time!))
        : 'N/A';
    final professionalAssignments = _collectProfessionals(booking.services);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchBookingDetail,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Salon Header
                    _buildSalonHeader(booking),
                    const SizedBox(height: 24),

                    // Booking Info Card
                    _buildInfoCard(
                      title: 'Booking Information',
                      children: [
                        _buildDetailRow(
                            Icons.calendar_today, 'Date', formattedDate),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                            Icons.access_time, 'Time', formattedTime),
                        const SizedBox(height: 12),
                        _buildDetailRow(Icons.check_circle, 'Status',
                            _capitalizeFirst(booking.status ?? 'N/A')),
                        const SizedBox(height: 12),
                        _buildDetailRow(Icons.category, 'Type',
                            _capitalizeFirst(booking.bookingType ?? 'N/A')),
                        const SizedBox(height: 12),
                        _buildDetailRow(Icons.payment, 'Payment Method',
                            _capitalizeFirst(booking.paymentMethod ?? 'N/A')),
                        // Only show payment status if booking is not cancelled
                        if (!(booking.status
                                ?.toLowerCase()
                                .contains('cancel') ==
                            true)) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(Icons.receipt, 'Payment Status',
                              _capitalizeFirst(booking.paymentStatus ?? 'N/A')),
                        ],
                        const SizedBox(height: 12),
                        // Calculate original price before discount
                        _buildDetailRow(
                            Icons.receipt_long,
                            'Subtotal',
                            'PKR ${((booking.payment ?? 0) + (booking.additionalDiscount ?? 0)).toStringAsFixed(0)}'),
                        // Always show additional discount (0 if null)
                        if (booking.additionalDiscount != null && booking.additionalDiscount! > 0) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                              Icons.discount,
                              'Discount',
                              '- PKR ${booking.additionalDiscount}'),
                        ],
                        const SizedBox(height: 12),
                        _buildDetailRow(Icons.monetization_on, 'Total Amount',
                            'PKR ${booking.payment?.toStringAsFixed(0) ?? '0'}'),
                      ],
                    ),

                    // Services Section
                    if (booking.services.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildServicesSection(booking.services),
                    ],

                    // Professionals Section
                    if (professionalAssignments.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildProfessionalsSection(professionalAssignments),
                    ],

                    // Deal Section
                    if (booking.deal.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildDealsSection(booking.deal),
                    ],

                    // Membership Section
                    if (booking.membership.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildMembershipSection(booking.membership),
                    ],

                    // Review Section
                    if (booking.review.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildReviewsSection(booking.review),
                    ],

                    // Add Review Button (only if completed and no review yet)
                    if (booking.status?.toLowerCase() == 'completed' &&
                        booking.review.isEmpty) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showReviewDialog(context),
                          icon: const Icon(Icons.rate_review),
                          label: const Text('Write a Review'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Cancel Button
        if (!(booking.status?.toLowerCase().contains('cancelled') == true ||
            booking.status?.toLowerCase().contains('completed') == true))
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
    );
  }

  Widget _buildSalonHeader(BookingDetail booking) {
    final salon = booking.salon;
    return Center(
      child: Column(
        children: [
          Hero(
            tag: 'salon-logo-${booking.id}',
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: salon?.logo != null && salon!.logo!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(salon.logo!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: salon?.logo == null || salon!.logo!.isEmpty
                  ? Icon(Icons.store, size: 60, color: Colors.grey[600])
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            salon?.name ?? 'Unknown Salon',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (salon?.address != null && salon!.address!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    salon.address!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(List<BookingService> services) {
    return _buildInfoCard(
      title: 'Services',
      children: services.map((service) {
        // Debug logging
        if (kDebugMode) {
          developer.log(
            'Service: ${service.name} | Has staff: ${service.selectedProfessional != null} | Staff name: ${service.selectedProfessional?.displayName}',
            name: 'booking.screen',
          );
        }
        
        return Padding(
          padding: EdgeInsets.only(bottom: services.last == service ? 0 : 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.name ?? 'Service',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      'PKR ${service.price?.toStringAsFixed(0) ?? '0'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryDarkColor,
                      ),
                    ),
                  ],
                ),
                if (service.duration != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${service.duration} mins',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
                // Show professional section only if staff exists
                if (service.selectedProfessional != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: kPrimaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: service.selectedProfessional!.image !=
                                      null &&
                                  service.selectedProfessional!.image!.isNotEmpty
                              ? NetworkImage(service.selectedProfessional!.image!)
                              : null,
                          child: service.selectedProfessional!.image == null ||
                                  service.selectedProfessional!.image!.isEmpty
                              ? Icon(Icons.person,
                                  size: 20, color: Colors.grey[600])
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.selectedProfessional!.displayName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              if (service.selectedProfessional!.phone != null &&
                                  service.selectedProfessional!.phone!
                                      .isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.phone,
                                        size: 12, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      service.selectedProfessional!.phone!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              ],),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDealsSection(List<dynamic> deals) {
    return _buildInfoCard(
      title: 'Deals',
      children: deals.map((deal) {
        final dealData = deal as Map<String, dynamic>? ?? {};
        return Padding(
          padding: EdgeInsets.only(bottom: deals.last == deal ? 0 : 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dealData['name'] ?? 'Deal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (dealData['description'] != null)
                        Text(
                          dealData['description'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (dealData['price'] != null)
                  Text(
                    'PKR ${dealData['price']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMembershipSection(List<dynamic> memberships) {
    return _buildInfoCard(
      title: 'Memberships',
      children: memberships.map((membership) {
        final membershipData = membership as Map<String, dynamic>? ?? {};
        return Padding(
          padding:
              EdgeInsets.only(bottom: memberships.last == membership ? 0 : 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.card_membership, color: Colors.purple[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        membershipData['name'] ?? 'Membership',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (membershipData['description'] != null)
                        Text(
                          membershipData['description'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (membershipData['price'] != null)
                  Text(
                    'PKR ${membershipData['price']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewsSection(List<BookingReview> reviews) {
    return _buildInfoCard(
      title: 'Reviews',
      children: reviews.map((review) {
        return Padding(
          padding: EdgeInsets.only(bottom: reviews.last == review ? 0 : 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (review.user != null) ...[
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: review.user!.image != null
                            ? NetworkImage(review.user!.image!)
                            : null,
                        child: review.user!.image == null
                            ? Icon(Icons.person,
                                size: 16, color: Colors.grey[600])
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          review.user!.name ?? 'User',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (review.rating ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
                if (review.comment != null && review.comment!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    review.comment!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProfessionalsSection(
      List<_ProfessionalAssignment> assignments) {
    return _buildInfoCard(
      title: 'Professionals',
      children: assignments.map((assignment) {
        final professional = assignment.professional;
        final displayName = _formatProfessionalName(professional);

        return Padding(
          padding:
              EdgeInsets.only(bottom: assignments.last == assignment ? 0 : 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: professional.image != null &&
                              professional.image!.isNotEmpty
                          ? NetworkImage(professional.image!)
                          : null,
                      child: professional.image == null ||
                              professional.image!.isEmpty
                          ? Icon(Icons.person, size: 18, color: Colors.grey[600])
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          if (professional.experience != null &&
                              professional.experience!.isNotEmpty)
                            Text(
                              professional.experience!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (professional.phone != null &&
                              professional.phone!.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.phone,
                                    size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  professional.phone!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (assignment.services.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: assignment.services
                        .map(
                          (serviceName) => Chip(
                            label: Text(
                              serviceName,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.grey[100],
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
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

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  List<_ProfessionalAssignment> _collectProfessionals(
      List<BookingService> services) {
    final map = <int, _ProfessionalAssignment>{};

    for (final service in services) {
      final professional = service.selectedProfessional;
      if (professional == null) continue;

      final id = professional.id;
      map.putIfAbsent(
        id,
        () => _ProfessionalAssignment(
          professional: professional,
          services: [],
        ),
      );

      final name = (service.name ?? '').trim();
      if (name.isNotEmpty && !map[id]!.services.contains(name)) {
        map[id]!.services.add(name);
      }
    }

    return map.values.toList();
  }

  String _formatProfessionalName(ServiceProfessional professional) {
    final fullName =
        '${professional.firstName ?? ''} ${professional.lastName ?? ''}'.trim();
    if (fullName.isNotEmpty) return fullName;
    if ((professional.name ?? '').isNotEmpty) return professional.name!;
    return 'Professional';
  }
}

class _ProfessionalAssignment {
  final ServiceProfessional professional;
  final List<String> services;

  _ProfessionalAssignment({
    required this.professional,
    required this.services,
  });
}
