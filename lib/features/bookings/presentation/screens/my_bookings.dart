import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../../../../models/MyBookingResponse.dart';
import '../../../../presentation/viewmodels/bookings/bookings_view_model.dart';
import 'booking_details_screen.dart';
import '../../../auth/presentation/screens/auth/auth_screen.dart';

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
      if (kDebugMode) {
        developer.log('MyBookings.initState: loading bookings (refresh=true)',
            name: 'booking.screen');
      }
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

    if (viewModel.isLoading ||
        viewModel.isLoadingMore ||
        !viewModel.hasMorePages) {
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
      if (kDebugMode) {
        developer.log(
            'MyBookings._scrollListener: requesting loadNextPage | tab=${_tabController.index}',
            name: 'booking.screen');
      }
      viewModel.loadNextPage();
    }
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 80,
                color: kPrimaryColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Bookings Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t made any salon bookings.\nExplore salons and book your first appointment!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to home screen (first tab)
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Explore Salons',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BookingsViewModel viewModel) {
    final errorMessage =
        viewModel.errorMessage ?? 'Unable to load your bookings right now';
    final isAuthError =
        errorMessage.contains('login') || errorMessage.contains('Unauthorized');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isAuthError
                    ? kPrimaryColor.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAuthError ? Icons.lock_outline : Icons.cloud_off_outlined,
                size: 64,
                color: isAuthError ? kPrimaryColor : Colors.orange[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isAuthError
                  ? 'Authentication Required'
                  : 'Oops! Something went wrong',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                if (isAuthError) {
                  // Navigate to login screen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                } else {
                  // Try again
                  viewModel.refresh();
                }
              },
              icon: Icon(isAuthError ? Icons.login : Icons.refresh,
                  color: Colors.white),
              label: Text(
                isAuthError ? 'Login' : 'Try Again',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(BookingsViewModel viewModel, List<Booking> bookings,
      ScrollController controller) {
    if (viewModel.isLoading && !viewModel.isLoadingMore) {
      return _buildShimmer();
    }
    if (viewModel.isError) {
      return _buildErrorState(viewModel);
    }
    if (bookings.isEmpty && !viewModel.isLoading && !viewModel.isLoadingMore) {
      return _buildEmptyState();
    }
    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: ListView.builder(
        controller: controller,
        itemCount: bookings.length + (viewModel.hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= bookings.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final booking = bookings[index];
          final date = DateTime.tryParse(booking.date ?? '');
          // Format: Dec 24, 2025 (full month abbreviation, day, year)
          final formattedDate =
              date != null ? DateFormat('MMM d, y').format(date) : 'N/A';
          String formattedTime = 'N/A';
          String title = booking.title ?? '-';
          if (booking.time != null) {
            try {
              final time = DateFormat('HH:mm:ss').parse(booking.time!);
              formattedTime = DateFormat('h:mm a').format(time);
            } catch (e) {
              // ignore parse error
            }
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              elevation: 0,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
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
                            BookingDetailsScreen(bookingId: booking.id ?? 0),
                      ),
                    );
                    if (result == true) {
                      viewModel.refresh();
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section with Salon Info
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withValues(alpha: 0.05),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Salon Logo
                            Hero(
                              tag: 'salon-logo-${booking.id ?? 'unknown'}',
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: booking.salon?.logo != null
                                      ? Image.network(
                                          booking.salon!.logo!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stack) =>
                                                  Container(
                                            color: Colors.grey[50],
                                            child: Icon(Icons.store_rounded,
                                                size: 24,
                                                color: Colors.grey[400]),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey[50],
                                          child: Icon(Icons.store_rounded,
                                              size: 24,
                                              color: Colors.grey[400]),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Salon Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.salon?.name ?? 'Unknown Salon',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_rounded,
                                          size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          booking.salon?.address ??
                                              'Unknown Address',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            height: 1.3,
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
                          ],
                        ),
                      ),

                      // Status Badge Row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _getStatusColor(booking.status),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getStatusColor(booking.status)
                                        .withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    (booking.status ?? 'N/A').toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'ID: #${booking.id ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Service Title Section
                      if (title != '-')
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.cut_rounded,
                                      size: 14, color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Service Booked',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                          letterSpacing: -0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      // Show professional name if available
                                      if (_getFirstProfessionalName(booking) !=
                                          null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.person,
                                                size: 12,
                                                color: kPrimaryDarkColor),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                _getFirstProfessionalName(
                                                        booking) ??
                                                    '',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: kPrimaryDarkColor,
                                                  letterSpacing: -0.1,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                        ),

                      // Main Info Grid
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            // Date & Time Row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernInfoCard(
                                    icon: Icons.calendar_month_rounded,
                                    label: 'DATE',
                                    value: formattedDate,
                                    cardColor: const Color(0xFF3B82F6),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildModernInfoCard(
                                    icon: Icons.schedule_rounded,
                                    label: 'TIME',
                                    value: formattedTime,
                                    cardColor: const Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Payment & Type Row
                            Row(
                              children: [
                                // Hide payment status if booking is cancelled
                                if (!(booking.status
                                        ?.toLowerCase()
                                        .contains('cancel') ??
                                    false))
                                  Expanded(
                                    child: _buildModernInfoCard(
                                      icon: Icons.payments_rounded,
                                      label: 'PAYMENT',
                                      value: booking.paymentStatus ?? 'N/A',
                                      cardColor: const Color(0xFF10B981),
                                    ),
                                  ),
                                if (!(booking.status
                                        ?.toLowerCase()
                                        .contains('cancel') ??
                                    false))
                                  const SizedBox(width: 8),
                                Expanded(
                                  child: _buildModernInfoCard(
                                    icon: Icons.category_rounded,
                                    label: 'TYPE',
                                    value: booking.bookingType ?? 'N/A',
                                    cardColor: kPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Professionals Section (if available)
                      if (booking.services != null &&
                          booking.services!
                              .any((s) => s.selectedProfessional != null))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: kPrimaryColor.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color:
                                        kPrimaryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.person_rounded,
                                      size: 14, color: kPrimaryDarkColor),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Professional${_getProfessionalsCount(booking) > 1 ? 's' : ''}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _getProfessionalsNames(booking),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                          letterSpacing: -0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Footer with Price & Action
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Price Section - Hide if cancelled
                            if (!(booking.status
                                    ?.toLowerCase()
                                    .contains('cancel') ??
                                false))
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Amount',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Text(
                                          'PKR ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          '${booking.payment ?? 0}',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: kPrimaryDarkColor,
                                            letterSpacing: -0.5,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            // View Details Button
                            Container(
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: kPrimaryColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BookingDetailsScreen(
                                                bookingId: booking.id ?? 0),
                                      ),
                                    );
                                    if (result == true) {
                                      viewModel.refresh();
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'View Details',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.arrow_forward_rounded,
                                            color: Colors.white, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildModernInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with solid background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: cardColor.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.2,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  int _getProfessionalsCount(Booking booking) {
    if (booking.services == null) return 0;
    final professionals = <int>{};
    for (final service in booking.services!) {
      if (service.selectedProfessional?.id != null) {
        professionals.add(service.selectedProfessional!.id!);
      }
    }
    return professionals.length;
  }

  String _getProfessionalsNames(Booking booking) {
    if (booking.services == null) return 'N/A';

    final professionalMap = <int, String>{};
    for (final service in booking.services!) {
      final professional = service.selectedProfessional;
      if (professional?.id != null) {
        professionalMap[professional!.id!] = professional.displayName;
      }
    }

    if (professionalMap.isEmpty) return 'N/A';

    final names = professionalMap.values.toList();
    if (names.length == 1) return names[0];
    if (names.length == 2) return '${names[0]} & ${names[1]}';
    return '${names[0]} +${names.length - 1} more';
  }

  String? _getFirstProfessionalName(Booking booking) {
    if (booking.services == null || booking.services!.isEmpty) return null;

    for (final service in booking.services!) {
      if (service.selectedProfessional != null) {
        return service.selectedProfessional!.displayName;
      }
    }

    return null;
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
            backgroundColor: kPrimaryColor,
            actions: [
              // Show refresh indicator when loading but has data (refetching)
              if (viewModel.isLoading &&
                  (viewModel.allBookings.isNotEmpty ||
                      viewModel.upcomingBookings.isNotEmpty ||
                      viewModel.pastBookings.isNotEmpty))
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
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
              _buildBookingList(
                  viewModel, viewModel.allBookings, _allScrollController),
              _buildBookingList(viewModel, viewModel.upcomingBookings,
                  _upcomingScrollController),
              _buildBookingList(
                  viewModel, viewModel.pastBookings, _pastScrollController),
            ],
          ),
        );
      },
    );
  }
}
