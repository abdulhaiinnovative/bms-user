import 'dart:developer';
import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../api_services/MyBookingsAPI.dart';
import '../../models/MyBookingResponse.dart';
import 'booking_details_screen.dart';

class MyBookings extends StatefulWidget {
  static const String routeName = "/my-bookings";
  const MyBookings({super.key});
  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _allScrollController;
  late final ScrollController _upcomingScrollController;
  late final ScrollController _pastScrollController;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isFetchingMore = false;
  String? _errorMessage;
  String? _nextPageUrl;
  final List<Booking> allBookings = [];
  final List<Booking> upcomingBookings = [];
  final List<Booking> pastBookings = [];
  static const String _sortOrder = 'Date Descending';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _allScrollController = ScrollController();
    _upcomingScrollController = ScrollController();
    _pastScrollController = ScrollController();
    _allScrollController.addListener(_scrollListener);
    _upcomingScrollController.addListener(_scrollListener);
    _pastScrollController.addListener(_scrollListener);
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _allScrollController.dispose();
    _upcomingScrollController.dispose();
    _pastScrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_isLoading || _isLoadingMore || _nextPageUrl == null || _isFetchingMore) {
      return;
    }
    final controller = _tabController.index == 0
        ? _allScrollController
        : _tabController.index == 1
            ? _upcomingScrollController
            : _pastScrollController;
    if (controller.hasClients &&
        controller.position.pixels >=
            controller.position.maxScrollExtent * 0.9) {
      log('Scroll reached 90% of max extent, fetching more data');
      _isFetchingMore = true;
      _fetchBookings(loadMore: true).then((_) => _isFetchingMore = false);
    }
  }

  Future<void> _fetchBookings({bool loadMore = false}) async {
    if (loadMore && _nextPageUrl == null) {
      log('No next page URL, stopping pagination');
      return;
    }
    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _errorMessage = null;
        _nextPageUrl = null;
      }
    });
    try {
      log('Fetching bookings, loadMore: $loadMore, URL: ${_nextPageUrl ?? "initial"}');
      final bookingResponse =
          await MyBookingsAPI().getBooking(url: loadMore ? _nextPageUrl : null);
      if (bookingResponse == null) {
        log('Received null booking response');
        setState(() {
          _errorMessage = 'Failed to fetch bookings: No response from server';
          _isLoading = false;
          _isLoadingMore = false;
        });
        return;
      }
      log('Raw API response booking count: ${bookingResponse.response?.data?.data?.length ?? 0}');
      setState(() {
        final newBookings = bookingResponse.response?.data?.data ?? [];
        log('Received ${newBookings.length} new bookings, IDs: ${newBookings.map((b) => b.id).toList()}');
        _nextPageUrl = bookingResponse.response?.data?.nextPageUrl;
        log('Next page URL: $_nextPageUrl, Total: ${bookingResponse.response?.data?.total}, Page: ${bookingResponse.response?.data?.currentPage}');
        if (!loadMore) {
          log('Clearing allBookings for initial fetch');
          allBookings.clear();
        }
        allBookings.addAll(newBookings);
        log('All booking IDs after append: ${allBookings.map((b) => b.id).toList()}');
        _filterBookings();
        log('All booking IDs after filtering: ${allBookings.map((b) => b.id).toList()}');
        log('Upcoming booking IDs: ${upcomingBookings.map((b) => b.id).toList()}');
        log('Past booking IDs: ${pastBookings.map((b) => b.id).toList()}');

        // Clear error message if we successfully fetched (even if empty)
        _errorMessage = null;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e, stackTrace) {
      // Only show error for actual errors, not for empty booking responses
      final errorString = e.toString();
      if (!errorString.contains('404') &&
          !errorString.contains('No bookings found')) {
        setState(() {
          _errorMessage = 'Failed to fetch bookings: $e';
          _isLoading = false;
          _isLoadingMore = false;
        });
        log('Error in MyBookings._fetchBookings: $e\nStack: $stackTrace');
      } else {
        // 404 means no bookings, which is a valid state, not an error
        log('No bookings found (empty state), clearing error');
        setState(() {
          _errorMessage = null;
          _isLoading = false;
          _isLoadingMore = false;
          if (!loadMore) {
            allBookings.clear();
          }
          _filterBookings();
        });
      }
    }
  }

  void _filterBookings() {
    final now = DateTime.now();
    log('Filtering bookings, current time: $now');
    upcomingBookings.clear();
    pastBookings.clear();
    for (var booking in allBookings) {
      if (booking.date == null) {
        log('Skipping booking ID ${booking.id} with null date');
        continue;
      }
      DateTime? bookingDateTime;
      try {
        final date = DateTime.tryParse(booking.date!);
        if (date == null) {
          log('Invalid date for booking ID ${booking.id}: ${booking.date}');
          continue;
        }
        final time = booking.time != null
            ? DateFormat('HH:mm:ss').parse(booking.time!).toLocal()
            : DateTime(1970, 1, 1, 0, 0);
        log('Parsed time for booking ID ${booking.id}: ${booking.time} -> ${time.hour}:${time.minute}, Date: ${booking.date}, Status: ${booking.status}');
        bookingDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        log('Booking ID ${booking.id} dateTime: $bookingDateTime, isBefore now: ${bookingDateTime.isBefore(now)}');
      } catch (e, stackTrace) {
        log('Error parsing date/time for booking ID ${booking.id}: $e\nStack: $stackTrace');
        continue;
      }
      if (booking.status == 'booked' && !bookingDateTime.isBefore(now)) {
        upcomingBookings.add(booking);
        log('Added booking ID ${booking.id} to upcomingBookings');
      } else if (booking.status != 'booked' && bookingDateTime.isBefore(now)) {
        pastBookings.add(booking);
        log('Added booking ID ${booking.id} to pastBookings');
      } else {
        log('Booking ID ${booking.id} excluded from both tabs: status=${booking.status}, dateTime=$bookingDateTime');
      }
    }
    log('Upcoming bookings: ${upcomingBookings.length}, IDs: ${upcomingBookings.map((b) => b.id).toList()}');
    log('Past bookings: ${pastBookings.length}, IDs: ${pastBookings.map((b) => b.id).toList()}');
    _sortBookingsList(allBookings);
    _sortBookingsList(upcomingBookings);
    _sortBookingsList(pastBookings);
  }

  void _sortBookingsList(List<Booking> bookings) {
    bookings.sort((a, b) {
      DateTime? dateA, dateB;
      try {
        dateA = a.date != null ? DateTime.parse(a.date!) : null;
        dateB = b.date != null ? DateTime.parse(b.date!) : null;
        if (dateA != null && a.time != null) {
          final timeA = DateFormat('HH:mm:ss').parse(a.time!).toLocal();
          dateA = DateTime(
              dateA.year, dateA.month, dateA.day, timeA.hour, timeA.minute);
        }
        if (dateB != null && b.time != null) {
          final timeB = DateFormat('HH:mm:ss').parse(b.time!).toLocal();
          dateB = DateTime(
              dateB.year, dateB.month, dateB.day, timeB.hour, timeB.minute);
        }
      } catch (e, stackTrace) {
        log('Error parsing date/time for sorting booking IDs ${a.id} vs ${b.id}: $e\nStack: $stackTrace');
      }
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA); // Descending order
    });
    log('Sorted booking IDs: ${bookings.map((b) => b.id).join(', ')}');
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No appointments booked yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Book your next salon visit now!",
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.red[400],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchBookings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Retry",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(
      List<Booking> bookings, ScrollController controller) {
    if (_isLoading && !_isLoadingMore) {
      log('Showing shimmer for initial loading');
      return _buildShimmer();
    }
    if (_errorMessage != null) {
      log('Showing error state: $_errorMessage');
      return _buildErrorState();
    }
    if (bookings.isEmpty && !_isLoading && !_isLoadingMore) {
      log('Showing empty state');
      return _buildEmptyState();
    }
    log('Building booking list with ${bookings.length} items, IDs: ${bookings.map((b) => b.id).toList()}');
    return RefreshIndicator(
      onRefresh: () => _fetchBookings(),
      child: ListView.builder(
        controller: controller,
        itemCount: bookings.length + (_nextPageUrl != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= bookings.length) {
            log('Rendering pagination loader');
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final booking = bookings[index];
          log('Rendering booking ID: ${booking.id}');
          final date = DateTime.tryParse(booking.date ?? '');
          final formattedDate =
              date != null ? DateFormat('MMM dd, yyyy').format(date) : 'N/A';
          String formattedTime = 'N/A';
          String title = booking.title ?? '-';
          if (booking.time != null) {
            try {
              final time = DateFormat('HH:mm:ss').parse(booking.time!);
              formattedTime = DateFormat('hh:mm a').format(time);
            } catch (e, stackTrace) {
              log('Error parsing time for booking ID ${booking.id}: $e\nStack: $stackTrace');
            }
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey.shade50],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingDetailsScreen(booking: booking),
                    ),
                  );
                  if (result == true) {
                    _fetchBookings();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with salon info
                      Row(
                        children: [
                          Hero(
                            tag: 'salon-logo-${booking.id ?? 'unknown'}',
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: booking.salon?.logo != null
                                    ? Image.network(
                                        booking.salon!.logo!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) =>
                                            Container(
                                          color: Colors.grey[200],
                                          child: Icon(Icons.store,
                                              size: 28, color: Colors.grey[600]),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey[200],
                                        child: Icon(Icons.store,
                                            size: 28, color: Colors.grey[600]),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.salon?.name ?? 'Unknown Salon',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        booking.salon?.address ?? 'Unknown Address',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(booking.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(booking.status),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              (booking.status ?? 'N/A').toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(booking.status),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      Divider(height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      
                      // Booking details
                      if (title != '-')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.description_outlined,
                                    size: 18, color: kPrimaryColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Service',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Date and Time row
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              Icons.calendar_today_outlined,
                              'Date',
                              formattedDate,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              Icons.access_time_outlined,
                              'Time',
                              formattedTime,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Payment and Type row
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              Icons.payment_outlined,
                              'Payment',
                              booking.paymentStatus ?? 'N/A',
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              Icons.category_outlined,
                              'Type',
                              booking.bookingType ?? 'N/A',
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      Divider(height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      
                      // Price and action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PKR ${booking.payment ?? 0}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryDarkColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [kPrimaryColor, kPrimaryDarkColor],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'View Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'booked':
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScreenBg,
      appBar: AppBar(
        title: const Text(
          "My Bookings",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryDarkColor, kPrice],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Upcoming"),
            Tab(text: "Past"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(allBookings, _allScrollController),
          _buildBookingList(upcomingBookings, _upcomingScrollController),
          _buildBookingList(pastBookings, _pastScrollController),
        ],
      ),
    );
  }
}
