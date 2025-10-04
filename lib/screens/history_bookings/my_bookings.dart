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

class _MyBookingsState extends State<MyBookings> with SingleTickerProviderStateMixin {
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
    if (_isLoading || _isLoadingMore || _nextPageUrl == null || _isFetchingMore) return;
    final controller = _tabController.index == 0
        ? _allScrollController
        : _tabController.index == 1
        ? _upcomingScrollController
        : _pastScrollController;
    if (controller.hasClients && controller.position.pixels >= controller.position.maxScrollExtent * 0.9) {
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
      final bookingResponse = await MyBookingsAPI().getBooking(url: loadMore ? _nextPageUrl : null);
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
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'Failed to fetch bookings: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
      log('Error in MyBookings._fetchBookings: $e\nStack: $stackTrace');
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
          dateA = DateTime(dateA.year, dateA.month, dateA.day, timeA.hour, timeA.minute);
        }
        if (dateB != null && b.time != null) {
          final timeB = DateFormat('HH:mm:ss').parse(b.time!).toLocal();
          dateB = DateTime(dateB.year, dateB.month, dateB.day, timeB.hour, timeB.minute);
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

  Widget _buildBookingList(List<Booking> bookings, ScrollController controller) {
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
          final formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : 'N/A';
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
                color: kCardBG,
                borderRadius: BorderRadius.circular(kRadius),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Hero(
                          tag: 'salon-logo-${booking.id ?? 'unknown'}',
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: booking.salon?.logo != null
                                ? NetworkImage(booking.salon!.logo!)
                                : null,
                            child: booking.salon?.logo == null
                                ? Icon(Icons.store, size: 24, color: Colors.grey[600])
                                : null,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.salon?.name ?? 'Unknown Salon',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                booking.salon?.address ?? 'Unknown Address',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8,),

                    Divider(color: kScreenBg,),

                    SizedBox(height: 8,),

                    _buildDetailText('Title', title),
                    _buildDetailText('Date', formattedDate),
                    _buildDetailText('Time', formattedTime),
                    _buildDetailText('Status', booking.status ?? 'N/A'),
                    _buildDetailText('Type', booking.bookingType ?? 'N/A'),
                    _buildDetailText('Payment', booking.paymentStatus ?? 'N/A'),
                    _buildDetailText('Team ID', booking.id?.toString() ?? 'N/A'),

                    Container(
                      child: Text(
                      'PKR ${booking.payment ?? 0}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryDarkColor,
                      ),
                     ),
                    ),





                  ],
                ),

                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailsScreen(booking: booking),
                    ),
                  );
                  if (result == true) {
                    _fetchBookings();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              //overflow: TextOverflow.ellipsis,
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
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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