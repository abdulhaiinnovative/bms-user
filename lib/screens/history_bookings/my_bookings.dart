import 'dart:developer';
import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/MyBookingResponse.dart';
import '../../presentation/viewmodels/bookings/bookings_view_model.dart';
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
    
    // Load bookings using ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingsViewModel>().loadBookings(refresh: true);
    });
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
    final viewModel = context.read<BookingsViewModel>();
    
    if (viewModel.isLoading || viewModel.isLoadingMore || !viewModel.hasMorePages) {
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
      viewModel.loadNextPage();
    }
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

  Widget _buildErrorState(BookingsViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage ?? 'Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.red[400],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.refresh(),
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
      BookingsViewModel viewModel, List<Booking> bookings, ScrollController controller) {
    if (viewModel.isLoading && !viewModel.isLoadingMore) {
      log('Showing shimmer for initial loading');
      return _buildShimmer();
    }
    if (viewModel.isError) {
      log('Showing error state: ${viewModel.errorMessage}');
      return _buildErrorState(viewModel);
    }
    if (bookings.isEmpty && !viewModel.isLoading && !viewModel.isLoadingMore) {
      log('Showing empty state');
      return _buildEmptyState();
    }
    log('Building booking list with ${bookings.length} items, IDs: ${bookings.map((b) => b.id).toList()}');
    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: ListView.builder(
        controller: controller,
        itemCount: bookings.length + (viewModel.hasMorePages ? 1 : 0),
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
                    viewModel.refresh();
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
  @override
  Widget build(BuildContext context) {
    return Consumer<BookingsViewModel>(
      builder: (context, viewModel, child) {
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
              _buildBookingList(viewModel, viewModel.allBookings, _allScrollController),
              _buildBookingList(viewModel, viewModel.upcomingBookings, _upcomingScrollController),
              _buildBookingList(viewModel, viewModel.pastBookings, _pastScrollController),
            ],
          ),
        );
      },
    );
  }
}
