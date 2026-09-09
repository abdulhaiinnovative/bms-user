// // import 'package:app/constants.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shimmer/shimmer.dart';
// // import 'dart:developer' as developer;
// // import 'package:flutter/foundation.dart';
// // import '../../../../models/MyBookingResponse.dart';
// // import '../../../../presentation/viewmodels/bookings/bookings_view_model.dart';
// // import 'booking_details_screen.dart';
// // import '../../../auth/presentation/screens/auth/auth_screen.dart';

// // class MyBookings extends StatefulWidget {
// //   static const String routeName = "/my-bookings";
// //   const MyBookings({super.key});
// //   @override
// //   State<MyBookings> createState() => _MyBookingsState();
// // }

// // class _MyBookingsState extends State<MyBookings>
// //     with SingleTickerProviderStateMixin {
// //   late final TabController _tabController;
// //   late final ScrollController _allScrollController;
// //   late final ScrollController _upcomingScrollController;
// //   late final ScrollController _pastScrollController;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 3, vsync: this);
// //     _allScrollController = ScrollController();
// //     _upcomingScrollController = ScrollController();
// //     _pastScrollController = ScrollController();
// //     _allScrollController.addListener(_scrollListener);
// //     _upcomingScrollController.addListener(_scrollListener);
// //     _pastScrollController.addListener(_scrollListener);

// //     // Load bookings using ViewModel
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (kDebugMode) {
// //         developer.log('MyBookings.initState: loading bookings (refresh=true)',
// //             name: 'booking.screen');
// //       }
// //       context.read<BookingsViewModel>().loadBookings(refresh: true);
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     _allScrollController.dispose();
// //     _upcomingScrollController.dispose();
// //     _pastScrollController.dispose();
// //     super.dispose();
// //   }

// //   void _scrollListener() {
// //     final viewModel = context.read<BookingsViewModel>();

// //     if (viewModel.isLoading ||
// //         viewModel.isLoadingMore ||
// //         !viewModel.hasMorePages) {
// //       return;
// //     }

// //     final controller = _tabController.index == 0
// //         ? _allScrollController
// //         : _tabController.index == 1
// //             ? _upcomingScrollController
// //             : _pastScrollController;

// //     if (controller.hasClients &&
// //         controller.position.pixels >=
// //             controller.position.maxScrollExtent * 0.9) {
// //       if (kDebugMode) {
// //         developer.log(
// //             'MyBookings._scrollListener: requesting loadNextPage | tab=${_tabController.index}',
// //             name: 'booking.screen');
// //       }
// //       viewModel.loadNextPage();
// //     }
// //   }

// //   Widget _buildShimmer() {
// //     return ListView.builder(
// //       padding: const EdgeInsets.all(16),
// //       itemCount: 5,
// //       itemBuilder: (_, __) => Shimmer.fromColors(
// //         baseColor: Colors.grey[300]!,
// //         highlightColor: Colors.grey[100]!,
// //         child: Container(
// //           margin: const EdgeInsets.only(bottom: 16),
// //           height: 140,
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildEmptyState() {
// //     return Center(
// //       child: Padding(
// //         padding: const EdgeInsets.all(24),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               padding: const EdgeInsets.all(24),
// //               decoration: BoxDecoration(
// //                 color: kPrimaryColor.withOpacity(0.1),
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 Icons.calendar_today_outlined,
// //                 size: 80,
// //                 color: kPrimaryColor.withOpacity(0.6),
// //               ),
// //             ),
// //             const SizedBox(height: 24),
// //             const Text(
// //               'No Bookings Yet',
// //               style: TextStyle(
// //                 fontSize: 22,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.black87,
// //               ),
// //             ),
// //             const SizedBox(height: 12),
// //             Text(
// //               'You haven\'t made any salon bookings.\nExplore salons and book your first appointment!',
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 fontSize: 15,
// //                 color: Colors.grey[600],
// //                 height: 1.5,
// //               ),
// //             ),
// //             const SizedBox(height: 24),
// //             ElevatedButton(
// //               onPressed: () {
// //                 // Switch to home tab (index 0)
// //                 // Find InitScreen state in the widget tree
// //                 State? initScreenState;
// //                 context.visitAncestorElements((ancestor) {
// //                   if (ancestor is StatefulElement) {
// //                     final state = ancestor.state;
// //                     // Check if this is the InitScreen state
// //                     if (state.runtimeType.toString() == '_InitScreenState') {
// //                       initScreenState = state;
// //                       return false; // Stop searching
// //                     }
// //                   }
// //                   return true; // Continue visiting ancestors
// //                 });

// //                 // Call updateCurrentIndex if found
// //                 if (initScreenState != null) {
// //                   (initScreenState as dynamic).updateCurrentIndex(0);
// //                 }
// //               },
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: kPrimaryColor,
// //                 padding:
// //                     const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(20),
// //                 ),
// //               ),
// //               child: const Text(
// //                 'Explore Salons',
// //                 style: TextStyle(
// //                   fontSize: 16,
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildErrorState(BookingsViewModel viewModel) {
// //     final errorMessage =
// //         viewModel.errorMessage ?? 'Unable to load your bookings right now';
// //     final isAuthError =
// //         errorMessage.contains('login') || errorMessage.contains('Unauthorized');

// //     return Center(
// //       child: Padding(
// //         padding: const EdgeInsets.all(24),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               padding: const EdgeInsets.all(20),
// //               decoration: BoxDecoration(
// //                 color: isAuthError
// //                     ? kPrimaryColor.withOpacity(0.1)
// //                     : Colors.orange.withOpacity(0.1),
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 isAuthError ? Icons.lock_outline : Icons.cloud_off_outlined,
// //                 size: 64,
// //                 color: isAuthError ? kPrimaryColor : Colors.orange[700],
// //               ),
// //             ),
// //             const SizedBox(height: 24),
// //             Text(
// //               isAuthError
// //                   ? 'Authentication Required'
// //                   : 'Oops! Something went wrong',
// //               style: const TextStyle(
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.black87,
// //               ),
// //             ),
// //             const SizedBox(height: 12),
// //             Text(
// //               errorMessage,
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 fontSize: 15,
// //                 color: Colors.grey[600],
// //                 height: 1.5,
// //               ),
// //             ),
// //             const SizedBox(height: 28),
// //             ElevatedButton.icon(
// //               onPressed: () {
// //                 if (isAuthError) {
// //                   // Navigate to login screen
// //                   Navigator.of(context).pushAndRemoveUntil(
// //                     MaterialPageRoute(builder: (context) => const AuthScreen()),
// //                     (route) => false,
// //                   );
// //                 } else {
// //                   // Try again
// //                   viewModel.refresh();
// //                 }
// //               },
// //               icon: Icon(isAuthError ? Icons.login : Icons.refresh,
// //                   color: Colors.white),
// //               label: Text(
// //                 isAuthError ? 'Login' : 'Try Again',
// //                 style: const TextStyle(
// //                   fontSize: 16,
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: kPrimaryColor,
// //                 padding:
// //                     const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(25),
// //                 ),
// //                 elevation: 2,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildBookingList(BookingsViewModel viewModel, List<Booking> bookings,
// //       ScrollController controller) {
// //     if (viewModel.isLoading && !viewModel.isLoadingMore) {
// //       return _buildShimmer();
// //     }
// //     if (viewModel.isError) {
// //       return _buildErrorState(viewModel);
// //     }
// //     if (bookings.isEmpty && !viewModel.isLoading && !viewModel.isLoadingMore) {
// //       return _buildEmptyState();
// //     }
// //     return RefreshIndicator(
// //       onRefresh: () => viewModel.refresh(),
// //       child: ListView.builder(
// //         controller: controller,
// //         itemCount: bookings.length + (viewModel.hasMorePages ? 1 : 0),
// //         itemBuilder: (context, index) {
// //           if (index >= bookings.length) {
// //             return const Padding(
// //               padding: EdgeInsets.all(16.0),
// //               child: Center(child: CircularProgressIndicator()),
// //             );
// //           }
// //           final booking = bookings[index];
// //           final date = DateTime.tryParse(booking.date ?? '');
// //           // Format: Dec 24, 2025 (full month abbreviation, day, year)
// //           final formattedDate =
// //               date != null ? DateFormat('MMM d, y').format(date) : 'N/A';
// //           String formattedTime = 'N/A';
// //           String title = booking.title ?? '-';
// //           if (booking.time != null) {
// //             try {
// //               final time = DateFormat('HH:mm:ss').parse(booking.time!);
// //               formattedTime = DateFormat('h:mm a').format(time);
// //             } catch (e) {
// //               // ignore parse error
// //             }
// //           }
// //           return Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //             child: Material(
// //               elevation: 0,
// //               color: Colors.transparent,
// //               child: Container(
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(16),
// //                   border: Border.all(
// //                     color: Colors.grey.shade200,
// //                     width: 1,
// //                   ),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black.withValues(alpha: 0.04),
// //                       blurRadius: 12,
// //                       offset: const Offset(0, 4),
// //                       spreadRadius: 0,
// //                     ),
// //                   ],
// //                 ),
                
// //                 child: InkWell(
// //                   borderRadius: BorderRadius.circular(16),
// //                   onTap: () async {
// //                     final result = await Navigator.push(
// //                       context,
// //                       MaterialPageRoute(
// //                         builder: (context) =>
// //                             BookingDetailsScreen(bookingId: booking.id ?? 0),
// //                       ),
// //                     );
// //                     if (result == true) {
// //                       viewModel.refresh();
// //                     }
// //                   },
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       // Header Section with Salon Info
// //                       Container(
// //                         padding: const EdgeInsets.all(14),
// //                         decoration: BoxDecoration(
// //                           color: kPrimaryColor.withValues(alpha: 0.05),
// //                           borderRadius: const BorderRadius.only(
// //                             topLeft: Radius.circular(16),
// //                             topRight: Radius.circular(16),
// //                           ),
// //                         ),
// //                         child: Row(
// //                           children: [
// //                             // Salon Logo
// //                             Hero(
// //                               tag: 'salon-logo-${booking.id ?? 'unknown'}',
// //                               child: Container(
// //                                 width: 52,
// //                                 height: 52,
// //                                 decoration: BoxDecoration(
// //                                   borderRadius: BorderRadius.circular(12),
// //                                   color: Colors.white,
// //                                   border: Border.all(
// //                                     color: Colors.grey.shade200,
// //                                     width: 1.5,
// //                                   ),
// //                                   boxShadow: [
// //                                     BoxShadow(
// //                                       color:
// //                                           Colors.black.withValues(alpha: 0.06),
// //                                       blurRadius: 8,
// //                                       offset: const Offset(0, 2),
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 child: ClipRRect(
// //                                   borderRadius: BorderRadius.circular(10),
// //                                   child: booking.salon?.logo != null
// //                                       ? Image.network(
// //                                           booking.salon!.logo!,
// //                                           fit: BoxFit.cover,
// //                                           errorBuilder:
// //                                               (context, error, stack) =>
// //                                                   Container(
// //                                             color: Colors.grey[50],
// //                                             child: Icon(Icons.store_rounded,
// //                                                 size: 24,
// //                                                 color: Colors.grey[400]),
// //                                           ),
// //                                         )
// //                                       : Container(
// //                                           color: Colors.grey[50],
// //                                           child: Icon(Icons.store_rounded,
// //                                               size: 24,
// //                                               color: Colors.grey[400]),
// //                                         ),
// //                                 ),
// //                               ),
// //                             ),
// //                             const SizedBox(width: 12),
// //                             // Salon Details
// //                             Expanded(
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Text(
// //                                     booking.salon?.name ?? 'Unknown Salon',
// //                                     style: const TextStyle(
// //                                       fontSize: 15,
// //                                       fontWeight: FontWeight.w700,
// //                                       color: Colors.black87,
// //                                       letterSpacing: -0.3,
// //                                     ),
// //                                     maxLines: 1,
// //                                     overflow: TextOverflow.ellipsis,
// //                                   ),
// //                                   const SizedBox(height: 4),
// //                                   Row(
// //                                     children: [
// //                                       Icon(Icons.location_on_rounded,
// //                                           size: 14, color: Colors.grey[500]),
// //                                       const SizedBox(width: 3),
// //                                       Expanded(
// //                                         child: Text(
// //                                           booking.salon?.address ??
// //                                               'Unknown Address',
// //                                           style: TextStyle(
// //                                             fontSize: 12,
// //                                             color: Colors.grey[600],
// //                                             height: 1.3,
// //                                           ),
// //                                           maxLines: 1,
// //                                           overflow: TextOverflow.ellipsis,
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),

// //                       // Status Badge Row
// //                       Padding(
// //                         padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
// //                         child: Row(
// //                           children: [
// //                             Container(
// //                               padding: const EdgeInsets.symmetric(
// //                                   horizontal: 10, vertical: 5),
// //                               decoration: BoxDecoration(
// //                                 color: _getStatusColor(booking.status),
// //                                 borderRadius: BorderRadius.circular(8),
// //                                 boxShadow: [
// //                                   BoxShadow(
// //                                     color: _getStatusColor(booking.status)
// //                                         .withValues(alpha: 0.2),
// //                                     blurRadius: 4,
// //                                     offset: const Offset(0, 2),
// //                                   ),
// //                                 ],
// //                               ),
// //                               child: Row(
// //                                 mainAxisSize: MainAxisSize.min,
// //                                 children: [
// //                                   Container(
// //                                     width: 6,
// //                                     height: 6,
// //                                     decoration: const BoxDecoration(
// //                                       color: Colors.white,
// //                                       shape: BoxShape.circle,
// //                                     ),
// //                                   ),
// //                                   const SizedBox(width: 6),
// //                                   Text(
// //                                     (booking.status ?? 'N/A').toUpperCase(),
// //                                     style: const TextStyle(
// //                                       fontSize: 10,
// //                                       fontWeight: FontWeight.w700,
// //                                       color: Colors.white,
// //                                       letterSpacing: 0.8,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                             const Spacer(),
// //                             Text(
// //                               'ID: #${booking.id ?? 'N/A'}',
// //                               style: TextStyle(
// //                                 fontSize: 11,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: Colors.grey[600],
// //                                 letterSpacing: 0.3,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),

// //                       // Service Title Section
// //                       if (title != '-')
// //                         Padding(
// //                           padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
// //                           child: Container(
// //                             padding: const EdgeInsets.all(10),
// //                             decoration: BoxDecoration(
// //                               color: Colors.grey[50],
// //                               borderRadius: BorderRadius.circular(10),
// //                               border: Border.all(
// //                                 color: Colors.grey.shade200,
// //                                 width: 1,
// //                               ),
// //                             ),
// //                             child: Row(
// //                               children: [
// //                                 Container(
// //                                   padding: const EdgeInsets.all(6),
// //                                   decoration: BoxDecoration(
// //                                     color: kPrimaryColor,
// //                                     borderRadius: BorderRadius.circular(6),
// //                                   ),
// //                                   child: const Icon(Icons.cut_rounded,
// //                                       size: 14, color: Colors.white),
// //                                 ),
// //                                 const SizedBox(width: 10),
// //                                 Expanded(
// //                                   child: Column(
// //                                     crossAxisAlignment:
// //                                         CrossAxisAlignment.start,
// //                                     children: [
// //                                       Text(
// //                                         'Service Booked',
// //                                         style: TextStyle(
// //                                           fontSize: 9,
// //                                           color: Colors.grey[600],
// //                                           fontWeight: FontWeight.w600,
// //                                           letterSpacing: 0.4,
// //                                         ),
// //                                       ),
// //                                       const SizedBox(height: 2),
// //                                       Text(
// //                                         title,
// //                                         style: const TextStyle(
// //                                           fontSize: 13,
// //                                           fontWeight: FontWeight.w700,
// //                                           color: Colors.black87,
// //                                           letterSpacing: -0.2,
// //                                         ),
// //                                         maxLines: 1,
// //                                         overflow: TextOverflow.ellipsis,
// //                                       ),
// //                                       // Show professional name if available
// //                                       if (_getFirstProfessionalName(booking) !=
// //                                           null) ...[
// //                                         const SizedBox(height: 4),
// //                                         Row(
// //                                           children: [
// //                                             const Icon(Icons.person,
// //                                                 size: 12,
// //                                                 color: kPrimaryDarkColor),
// //                                             const SizedBox(width: 4),
// //                                             Expanded(
// //                                               child: Text(
// //                                                 _getFirstProfessionalName(
// //                                                         booking) ??
// //                                                     '',
// //                                                 style: const TextStyle(
// //                                                   fontSize: 11,
// //                                                   fontWeight: FontWeight.w600,
// //                                                   color: kPrimaryDarkColor,
// //                                                   letterSpacing: -0.1,
// //                                                 ),
// //                                                 maxLines: 1,
// //                                                 overflow: TextOverflow.ellipsis,
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ],
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),

// //                       // Main Info Grid
// //                       Padding(
// //                         padding: const EdgeInsets.all(14),
// //                         child: Column(
// //                           children: [
// //                             // Date & Time Row
// //                             Row(
// //                               children: [
// //                                 Expanded(
// //                                   child: _buildModernInfoCard(
// //                                     icon: Icons.calendar_month_rounded,
// //                                     label: 'DATE',
// //                                     value: formattedDate,
// //                                     cardColor: const Color(0xFF3B82F6),
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 8),
// //                                 Expanded(
// //                                   child: _buildModernInfoCard(
// //                                     icon: Icons.schedule_rounded,
// //                                     label: 'TIME',
// //                                     value: formattedTime,
// //                                     cardColor: const Color(0xFFF59E0B),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             const SizedBox(height: 8),
// //                             // Payment & Type Row
// //                             Row(
// //                               children: [
// //                                 // Hide payment status if booking is cancelled
// //                                 if (!(booking.status
// //                                         ?.toLowerCase()
// //                                         .contains('cancel') ??
// //                                     false))
// //                                   Expanded(
// //                                     child: _buildModernInfoCard(
// //                                       icon: Icons.payments_rounded,
// //                                       label: 'PAYMENT',
// //                                       value: booking.paymentStatus ?? 'N/A',
// //                                       cardColor: const Color(0xFF10B981),
// //                                     ),
// //                                   ),
// //                                 if (!(booking.status
// //                                         ?.toLowerCase()
// //                                         .contains('cancel') ??
// //                                     false))
// //                                   const SizedBox(width: 8),
// //                                 Expanded(
// //                                   child: _buildModernInfoCard(
// //                                     icon: Icons.category_rounded,
// //                                     label: 'TYPE',
// //                                     value: booking.bookingType ?? 'N/A',
// //                                     cardColor: kPrimaryColor,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ],
// //                         ),
// //                       ),

// //                       // Professionals Section (if available)
// //                       if (booking.services != null &&
// //                           booking.services!
// //                               .any((s) => s.selectedProfessional != null))
// //                         Padding(
// //                           padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
// //                           child: Container(
// //                             padding: const EdgeInsets.all(10),
// //                             decoration: BoxDecoration(
// //                               color: kPrimaryColor.withValues(alpha: 0.05),
// //                               borderRadius: BorderRadius.circular(10),
// //                               border: Border.all(
// //                                 color: kPrimaryColor.withValues(alpha: 0.2),
// //                                 width: 1,
// //                               ),
// //                             ),
// //                             child: Row(
// //                               children: [
// //                                 Container(
// //                                   padding: const EdgeInsets.all(6),
// //                                   decoration: BoxDecoration(
// //                                     color:
// //                                         kPrimaryColor.withValues(alpha: 0.15),
// //                                     borderRadius: BorderRadius.circular(6),
// //                                   ),
// //                                   child: const Icon(Icons.person_rounded,
// //                                       size: 14, color: kPrimaryDarkColor),
// //                                 ),
// //                                 const SizedBox(width: 10),
// //                                 Expanded(
// //                                   child: Column(
// //                                     crossAxisAlignment:
// //                                         CrossAxisAlignment.start,
// //                                     children: [
// //                                       Text(
// //                                         'Professional${_getProfessionalsCount(booking) > 1 ? 's' : ''}',
// //                                         style: TextStyle(
// //                                           fontSize: 9,
// //                                           color: Colors.grey[600],
// //                                           fontWeight: FontWeight.w600,
// //                                           letterSpacing: 0.4,
// //                                         ),
// //                                       ),
// //                                       const SizedBox(height: 2),
// //                                       Text(
// //                                         _getProfessionalsNames(booking),
// //                                         style: const TextStyle(
// //                                           fontSize: 13,
// //                                           fontWeight: FontWeight.w700,
// //                                           color: Colors.black87,
// //                                           letterSpacing: -0.2,
// //                                         ),
// //                                         maxLines: 1,
// //                                         overflow: TextOverflow.ellipsis,
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),

// //                       // Footer with Price & Action
// //                       Container(
// //                         padding: const EdgeInsets.all(14),
// //                         decoration: BoxDecoration(
// //                           color: Colors.grey[50],
// //                           borderRadius: const BorderRadius.only(
// //                             bottomLeft: Radius.circular(16),
// //                             bottomRight: Radius.circular(16),
// //                           ),
// //                           border: Border(
// //                             top: BorderSide(
// //                               color: Colors.grey.shade200,
// //                               width: 1,
// //                             ),
// //                           ),
// //                         ),
// //                         child: Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             // Price Section - Hide if cancelled
// //                             if (!(booking.status
// //                                     ?.toLowerCase()
// //                                     .contains('cancel') ??
// //                                 false))
// //                               Expanded(
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     Text(
// //                                       'Total Amount',
// //                                       style: TextStyle(
// //                                         fontSize: 10,
// //                                         color: Colors.grey[600],
// //                                         fontWeight: FontWeight.w600,
// //                                         letterSpacing: 0.4,
// //                                       ),
// //                                     ),
// //                                     const SizedBox(height: 2),
// //                                     Row(
// //                                       children: [
// //                                         const Text(
// //                                           'PKR ',
// //                                           style: TextStyle(
// //                                             fontSize: 13,
// //                                             fontWeight: FontWeight.w600,
// //                                             color: Colors.black54,
// //                                           ),
// //                                         ),
// //                                         Text(
// //                                           '${booking.payment ?? 0}',
// //                                           style: const TextStyle(
// //                                             fontSize: 22,
// //                                             fontWeight: FontWeight.w800,
// //                                             color: kPrimaryDarkColor,
// //                                             letterSpacing: -0.5,
// //                                             height: 1.2,
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             // View Details Button
// //                             Container(
// //                               decoration: BoxDecoration(
// //                                 color: kPrimaryColor,
// //                                 borderRadius: BorderRadius.circular(10),
// //                                 boxShadow: [
// //                                   BoxShadow(
// //                                     color: kPrimaryColor.withValues(alpha: 0.3),
// //                                     blurRadius: 8,
// //                                     offset: const Offset(0, 3),
// //                                   ),
// //                                 ],
// //                               ),
// //                               child: Material(
// //                                 color: Colors.transparent,
// //                                 child: InkWell(
// //                                   borderRadius: BorderRadius.circular(10),
// //                                   onTap: () async {
// //                                     final result = await Navigator.push(
// //                                       context,
// //                                       MaterialPageRoute(
// //                                         builder: (context) =>
// //                                             BookingDetailsScreen(
// //                                                 bookingId: booking.id ?? 0),
// //                                       ),
// //                                     );
// //                                     if (result == true) {
// //                                       viewModel.refresh();
// //                                     }
// //                                   },
// //                                   child: const Padding(
// //                                     padding: EdgeInsets.symmetric(
// //                                         horizontal: 16, vertical: 10),
// //                                     child: Row(
// //                                       mainAxisSize: MainAxisSize.min,
// //                                       children: [
// //                                         Text(
// //                                           'View Details',
// //                                           style: TextStyle(
// //                                             color: Colors.white,
// //                                             fontSize: 12,
// //                                             fontWeight: FontWeight.w700,
// //                                             letterSpacing: 0.2,
// //                                           ),
// //                                         ),
// //                                         SizedBox(width: 4),
// //                                         Icon(Icons.arrow_forward_rounded,
// //                                             color: Colors.white, size: 16),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Color _getStatusColor(String? status) {
// //     switch (status?.toLowerCase()) {
// //       case 'booked':
// //       case 'confirmed':
// //         return Colors.green;
// //       case 'completed':
// //         return Colors.blue;
// //       case 'cancelled':
// //         return Colors.red;
// //       case 'pending':
// //         return Colors.orange;
// //       default:
// //         return Colors.grey;
// //     }
// //   }

// //   Widget _buildModernInfoCard({
// //     required IconData icon,
// //     required String label,
// //     required String value,
// //     required Color cardColor,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(
// //           color: cardColor.withValues(alpha: 0.2),
// //           width: 1,
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: cardColor.withValues(alpha: 0.1),
// //             blurRadius: 6,
// //             offset: const Offset(0, 3),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Icon with solid background
// //           Container(
// //             padding: const EdgeInsets.all(8),
// //             decoration: BoxDecoration(
// //               color: cardColor,
// //               borderRadius: BorderRadius.circular(8),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: cardColor.withValues(alpha: 0.3),
// //                   blurRadius: 6,
// //                   offset: const Offset(0, 2),
// //                 ),
// //               ],
// //             ),
// //             child: Icon(icon, size: 16, color: Colors.white),
// //           ),
// //           const SizedBox(height: 8),
// //           // Label
// //           Text(
// //             label,
// //             style: TextStyle(
// //               fontSize: 9,
// //               color: Colors.grey[600],
// //               fontWeight: FontWeight.w700,
// //               letterSpacing: 0.8,
// //             ),
// //           ),
// //           const SizedBox(height: 2),
// //           // Value
// //           Text(
// //             value,
// //             style: const TextStyle(
// //               fontSize: 13,
// //               fontWeight: FontWeight.w700,
// //               color: Colors.black87,
// //               letterSpacing: -0.2,
// //               height: 1.2,
// //             ),
// //             maxLines: 2,
// //             overflow: TextOverflow.ellipsis,
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   int _getProfessionalsCount(Booking booking) {
// //     if (booking.services == null) return 0;
// //     final professionals = <int>{};
// //     for (final service in booking.services!) {
// //       if (service.selectedProfessional?.id != null) {
// //         professionals.add(service.selectedProfessional!.id!);
// //       }
// //     }
// //     return professionals.length;
// //   }

// //   String _getProfessionalsNames(Booking booking) {
// //     if (booking.services == null) return 'N/A';

// //     final professionalMap = <int, String>{};
// //     for (final service in booking.services!) {
// //       final professional = service.selectedProfessional;
// //       if (professional?.id != null) {
// //         professionalMap[professional!.id!] = professional.displayName;
// //       }
// //     }

// //     if (professionalMap.isEmpty) return 'N/A';

// //     final names = professionalMap.values.toList();
// //     if (names.length == 1) return names[0];
// //     if (names.length == 2) return '${names[0]} & ${names[1]}';
// //     return '${names[0]} +${names.length - 1} more';
// //   }

// //   String? _getFirstProfessionalName(Booking booking) {
// //     if (booking.services == null || booking.services!.isEmpty) return null;

// //     for (final service in booking.services!) {
// //       if (service.selectedProfessional != null) {
// //         return service.selectedProfessional!.displayName;
// //       }
// //     }

// //     return null;
// //   }

// //   @override
// //   @override
// //   Widget build(BuildContext context) {
// //     return Consumer<BookingsViewModel>(
// //       builder: (context, viewModel, child) {
// //         return Scaffold(
// //           backgroundColor: kScreenBg,
// //           appBar: AppBar(
// //             title: const Text(
// //               "My Bookings",
// //               style: TextStyle(
// //                 fontSize: 22,
// //                 fontWeight: FontWeight.w600,
// //                 color: Colors.white,
// //               ),
// //             ),
// //             backgroundColor: kPrimaryColor,
// //             actions: [
// //               // Show refresh indicator when loading but has data (refetching)
// //               if (viewModel.isLoading &&
// //                   (viewModel.allBookings.isNotEmpty ||
// //                       viewModel.upcomingBookings.isNotEmpty ||
// //                       viewModel.pastBookings.isNotEmpty))
// //                 const Padding(
// //                   padding: EdgeInsets.symmetric(horizontal: 16),
// //                   child: Center(
// //                     child: SizedBox(
// //                       width: 20,
// //                       height: 20,
// //                       child: CircularProgressIndicator(
// //                         strokeWidth: 2,
// //                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //             bottom: TabBar(
// //               controller: _tabController,
// //               indicatorColor: Colors.white,
// //               labelColor: Colors.white,
// //               unselectedLabelColor: Colors.white70,
// //               labelStyle:
// //                   const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
// //               unselectedLabelStyle:
// //                   const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
// //               tabs: const [
// //                 Tab(text: "All"),
// //                 Tab(text: "Upcoming"),
// //                 Tab(text: "Past"),
// //               ],
// //             ),
// //           ),
// //           body: TabBarView(
// //             controller: _tabController,
// //             children: [
// //               _buildBookingList(
// //                   viewModel, viewModel.allBookings, _allScrollController),
// //               _buildBookingList(viewModel, viewModel.upcomingBookings,
// //                   _upcomingScrollController),
// //               _buildBookingList(
// //                   viewModel, viewModel.pastBookings, _pastScrollController),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// import 'package:app/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';
// import 'dart:developer' as developer;
// import 'package:flutter/foundation.dart';
// import '../../../../models/MyBookingResponse.dart';
// import '../../../../presentation/viewmodels/bookings/bookings_view_model.dart';
// import 'booking_details_screen.dart';
// import '../../../auth/presentation/screens/auth/auth_screen.dart';

// class MyBookings extends StatefulWidget {
//   static const String routeName = "/my-bookings";
//   const MyBookings({super.key});
//   @override
//   State<MyBookings> createState() => _MyBookingsState();
// }

// class _MyBookingsState extends State<MyBookings>
//     with SingleTickerProviderStateMixin {
//   static const List<Map<String, String>> _tabs = [
//     {'label': 'All', 'status': 'all'},
//     {'label': 'Pending', 'status': 'booked'},
//     // {'label': 'Pending', 'status': 'pending'},
//     {'label': 'Confirmed', 'status': 'confirmed'},
//     {'label': 'Completed', 'status': 'completed'},
//     {'label': 'Cancelled by Customer', 'status': 'cancelled by customer'},
//     {'label': 'Cancelled by Salon', 'status': 'cancelled by salon'},
//     {'label': 'No Show', 'status': 'no show'},
//   ];

//   late final TabController _tabController;
//   late final List<ScrollController> _scrollControllers;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _tabs.length, vsync: this);
//     _scrollControllers = List.generate(_tabs.length, (_) {
//       final controller = ScrollController();
//       controller.addListener(_scrollListener);
//       return controller;
//     });

//     _tabController.addListener(_handleTabSelection);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadCurrentTab();
//     });
//   }

//   void _handleTabSelection() {
//     if (_tabController.indexIsChanging) {
//       _loadCurrentTab();
//     }
//   }

//   void _loadCurrentTab() {
//     final status = _tabs[_tabController.index]['status']!;
//     final viewModel = context.read<BookingsViewModel>();
//     final tabState = viewModel.getTabState(status);
//     if (tabState.isFirstLoad && tabState.bookings.isEmpty) {
//       viewModel.loadBookings(status, refresh: true);
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     for (var controller in _scrollControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   void _scrollListener() {
//     final viewModel = context.read<BookingsViewModel>();
//     final index = _tabController.index;
//     final status = _tabs[index]['status']!;
//     final tabState = viewModel.getTabState(status);

//     if (viewModel.isLoading || tabState.isLoadingMore || !tabState.hasMorePages) return;
    
//     final controller = _scrollControllers[index];
//     if (controller.hasClients &&
//         controller.position.pixels >= controller.position.maxScrollExtent * 0.9) {
//       viewModel.loadNextPage(status);
//     }
//   }

//   // ─── STATUS HELPERS ──────────────────────────────────────────────────
//   Color _statusColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'booked':
//       case 'confirmed': return const Color(0xFF3B6D11);
//       case 'completed': return const Color(0xFF185FA5);
//       case 'cancelled': return const Color(0xFFA32D2D);
//       case 'pending': return const Color(0xFF854F0B);
//       default: return const Color(0xFF5F5E5A);
//     }
//   }

//   Color _statusBg(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'booked':
//       case 'confirmed': return const Color(0xFFEAF3DE);
//       case 'completed': return const Color(0xFFE6F1FB);
//       case 'cancelled': return const Color(0xFFFCEBEB);
//       case 'pending': return const Color(0xFFFAEEDA);
//       default: return const Color(0xFFF1EFE8);
//     }
//   }

//   Color _headerBg(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'booked':
//       case 'confirmed': return const Color(0xFFF4FAF0);
//       case 'completed': return const Color(0xFFF0F7FF);
//       case 'cancelled': return const Color(0xFFFEF3F3);
//       case 'pending': return const Color(0xFFFEF8EE);
//       default: return const Color(0xFFF8F8F7);
//     }
//   }

//   Color _accentColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'booked':
//       case 'confirmed': return const Color(0xFF639922);
//       case 'completed': return const Color(0xFF378ADD);
//       case 'cancelled': return const Color(0xFFE24B4A);
//       case 'pending': return const Color(0xFFEF9F27);
//       default: return const Color(0xFF888780);
//     }
//   }

//   // ─── SHIMMER ─────────────────────────────────────────────────────────
//   Widget _buildShimmer() {
//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
//       itemCount: 5,
//       itemBuilder: (_, __) => Shimmer.fromColors(
//         baseColor: Colors.grey[200]!,
//         highlightColor: Colors.grey[50]!,
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           height: 140,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//           ),
//         ),
//       ),
//     );
//   }

//   // ─── EMPTY STATE ─────────────────────────────────────────────────────
//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(36),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: kPrimaryColor.withOpacity(0.08),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.calendar_today_outlined, size: 36, color: kPrimaryColor.withOpacity(0.6)),
//             ),
//             const SizedBox(height: 20),
//             const Text('No bookings yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
//             const SizedBox(height: 8),
//             Text(
//               'Explore salons and book\nyour first appointment!',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.6),
//             ),
//             const SizedBox(height: 24),
//             TextButton(
//               onPressed: () {
//                 State? initScreenState;
//                 context.visitAncestorElements((ancestor) {
//                   if (ancestor is StatefulElement) {
//                     final state = ancestor.state;
//                     if (state.runtimeType.toString() == '_InitScreenState') {
//                       initScreenState = state;
//                       return false;
//                     }
//                   }
//                   return true;
//                 });
//                 if (initScreenState != null) {
//                   (initScreenState as dynamic).updateCurrentIndex(0);
//                 }
//               },
//               style: TextButton.styleFrom(
//                 backgroundColor: kPrimaryColor,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               child: const Text('Explore salons', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ─── ERROR STATE ──────────────────────────────────────────────────────
//   Widget _buildErrorState(BookingsViewModel viewModel, String status) {
//     final tabState = viewModel.getTabState(status);
//     final errorMessage = tabState.errorMessage ?? 'Unable to load your bookings right now';
//     final isAuthError = errorMessage.contains('login') || errorMessage.contains('Unauthorized');

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(36),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: (isAuthError ? kPrimaryColor : Colors.orange).withOpacity(0.08),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isAuthError ? Icons.lock_outline_rounded : Icons.cloud_off_outlined,
//                 size: 36,
//                 color: isAuthError ? kPrimaryColor : Colors.orange[700],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               isAuthError ? 'Sign in required' : 'Something went wrong',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               isAuthError ? 'Please sign in to view your bookings.' : 'We couldn\'t load your bookings.\nPlease try again.',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.6),
//             ),
//             const SizedBox(height: 24),
//             TextButton(
//               onPressed: () {
//                 if (isAuthError) {
//                   Navigator.of(context).pushAndRemoveUntil(
//                     MaterialPageRoute(builder: (context) => const AuthScreen()),
//                     (route) => false,
//                   );
//                 } else {
//                   viewModel.refreshStatus(status);
//                 }
//               },
//               style: TextButton.styleFrom(
//                 backgroundColor: kPrimaryColor,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               child: Text(isAuthError ? 'Sign in' : 'Try again', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ─── BOOKING LIST ─────────────────────────────────────────────────────
//   Widget _buildBookingList(BookingsViewModel viewModel, String status, ScrollController controller) {
//     final tabState = viewModel.getTabState(status);

//     if (viewModel.isLoading && !tabState.isLoadingMore && tabState.isFirstLoad) return _buildShimmer();
//     if (tabState.hasError) return _buildErrorState(viewModel, status);
//     if (tabState.bookings.isEmpty && !viewModel.isLoading && !tabState.isLoadingMore) return _buildEmptyState();

//     return RefreshIndicator(
//       color: kPrimaryColor,
//       onRefresh: () => viewModel.refreshStatus(status),
//       child: ListView.builder(
//         controller: controller,
//         padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
//         itemCount: tabState.bookings.length + (tabState.hasMorePages ? 1 : 0),
//         itemBuilder: (context, index) {
//           if (index >= tabState.bookings.length) {
//             return const Padding(
//               padding: EdgeInsets.all(20),
//               child: Center(child: CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 2)),
//             );
//           }
//           final booking = tabState.bookings[index];
//           return _BookingCard(
//             booking: booking,
//             statusColor: _statusColor(booking.status),
//             statusBg: _statusBg(booking.status),
//             headerBg: _headerBg(booking.status),
//             accentColor: _accentColor(booking.status),
//             onTap: () async {
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => BookingDetailsScreen(bookingId: booking.id ?? 0),
//                 ),
//               );
//               if (result == true) viewModel.refreshStatus(status);
//             },
//           );
//         },
//       ),
//     );
//   }

//   // ─── BUILD ────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<BookingsViewModel>(
//       builder: (context, viewModel, child) {
//         return Scaffold(
//           backgroundColor: kScreenBg,
//           appBar: AppBar(
//             title: const Text(
//               'My Bookings',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
//             ),
//             backgroundColor: kPrimaryColor,
//             elevation: 0,
//             actions: [
//               if (viewModel.isLoading || viewModel.isRefreshing)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   child: Center(
//                     child: SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//             bottom: TabBar(
//               isScrollable: true,   
//               controller: _tabController,
//               indicatorColor: Colors.white,
//               indicatorWeight: 2,
//               labelColor: Colors.white,
//               unselectedLabelColor: Colors.white54,
//               labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//               unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
//               tabs: _tabs.map((t) => Tab(text: t['label'])).toList(),
//             ),
//           ),
//           body: TabBarView(
//             controller: _tabController,
//             children: _tabs.asMap().entries.map((entry) {
//               final index = entry.key;
//               final status = entry.value['status']!;
//               return _buildBookingList(viewModel, status, _scrollControllers[index]);
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // BOOKING CARD — separate StatelessWidget for clarity
// // ─────────────────────────────────────────────────────────────────────────────
// class _BookingCard extends StatelessWidget {
//   final Booking booking;
//   final Color statusColor;
//   final Color statusBg;
//   final Color headerBg;
//   final Color accentColor;
//   final VoidCallback onTap;

//   const _BookingCard({
//     required this.booking,
//     required this.statusColor,
//     required this.statusBg,
//     required this.headerBg,
//     required this.accentColor,
//     required this.onTap,
//   });

//   String get _formattedDate {
//     final date = DateTime.tryParse(booking.date ?? '');
//     return date != null ? DateFormat('MMM d, y').format(date) : 'N/A';
//   }

//   String get _formattedTime {
//     if (booking.time == null) return 'N/A';
//     try {
//       return DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(booking.time!));
//     } catch (_) { return 'N/A'; }
//   }

//   bool get _isCancelled => booking.status?.toLowerCase().contains('cancel') ?? false;

//   String? get _professionalName {
//     if (booking.services == null) return null;
//     for (final s in booking.services!) {
//       if (s.selectedProfessional != null) return s.selectedProfessional!.displayName;
//     }
//     return null;
//   }

//   String get _displayTitle {
//     if (booking.title != null && booking.title!.isNotEmpty) {
//       String rawTitle = booking.title!;
//       // The backend returns a multiline string like "\nServices:\nName\nDeals:\nName"
//       rawTitle = rawTitle.replaceAll('Services:', '').replaceAll('Deals:', '');
//       final List<String> lines = rawTitle
//           .split('\n')
//           .map((e) => e.trim())
//           .where((e) => e.isNotEmpty)
//           .toList();
//       if (lines.isNotEmpty) {
//         return lines.join(', ');
//       }
//     }

//     final List<String> names = [];

//     if (booking.deal != null && booking.deal!.isNotEmpty) {
//       for (final d in booking.deal!) {
//         if (d is Map<String, dynamic> && d['name'] != null) {
//           final name = d['name'].toString().trim();
//           if (name.isNotEmpty) names.add(name);
//         }
//       }
//     }

//     if (booking.services != null && booking.services!.isNotEmpty) {
//       final serviceNames = booking.services!
//           .map((s) => s.name)
//           .where((n) => n != null && n.trim().isNotEmpty)
//           .cast<String>();
//       names.addAll(serviceNames);
//     }

//     if (names.isNotEmpty) {
//       return names.join(', ');
//     }

//     return 'Booking';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Material(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         clipBehavior: Clip.antiAlias,
//         child: InkWell(
//           onTap: onTap,
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade100),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ── HEADER: Salon + Status ─────────────────────────────
//                 Container(
//                   color: headerBg,
//                   padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
//                   child: Row(
//                     children: [
//                       // Salon logo
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: booking.salon?.logo != null
//                               ? Image.network(
//                                   booking.salon!.logo!,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (_, __, ___) => Icon(Icons.store_rounded, size: 18, color: accentColor),
//                                 )
//                               : Icon(Icons.store_rounded, size: 18, color: accentColor),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       // Salon info
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               booking.salon?.name ?? 'Unknown Salon',
//                               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.2),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 2),
//                             Row(
//                               children: [
//                                 Icon(Icons.location_on_rounded, size: 11, color: Colors.grey[500]),
//                                 const SizedBox(width: 2),
//                                 Expanded(
//                                   child: Text(
//                                     booking.salon?.address ?? 'Unknown Address',
//                                     style: TextStyle(fontSize: 11, color: Colors.grey[500]),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       // Status badge
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: statusBg,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           _capitalise(booking.status ?? 'N/A'),
//                           style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // ── BODY: Service + Date/Time ───────────────────────────
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // Service icon
//                       Container(
//                         width: 34,
//                         height: 34,
//                         decoration: BoxDecoration(
//                           color: accentColor.withOpacity(0.1),

//                           borderRadius: BorderRadius.circular(9),
//                         ),
//                         child: Icon(Icons.content_cut_rounded, size: 16, color: accentColor),
//                       ),
//                       const SizedBox(width: 10),
//                       // Service name + professional
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               _displayTitle,
//                               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
//                               // maxLines: 1,
//                               overflow: TextOverflow.visible,
//                             ),
//                             if (_professionalName != null) ...[
//                               const SizedBox(height: 2),
//                               Row(
//                                 children: [
//                                   Icon(Icons.person_rounded, size: 11, color: Colors.grey[500]),
//                                   const SizedBox(width: 3),
//                                   Expanded(
//                                     child: Text(
//                                       _professionalName!,
//                                       style: TextStyle(fontSize: 11, color: Colors.grey[500]),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       // Date + Time column
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           _dateTimePill(Icons.calendar_month_rounded, _formattedDate),
//                           const SizedBox(height: 4),
//                           _dateTimePill(Icons.schedule_rounded, _formattedTime),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 // ── FOOTER: Price + Button ─────────────────────────────
//                 Container(
//                   padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     border: Border(top: BorderSide(color: Colors.grey.shade100)),
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // Booking ID
//                       Text(
//                         '#${booking.id ?? '—'}',
//                         style: TextStyle(fontSize: 11, color: Colors.grey[400]),
//                       ),
//                       // Payment status pill
//                       if (!_isCancelled && booking.paymentStatus != null) ...[
//                         const SizedBox(width: 6),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.green.withOpacity(0.08),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             booking.paymentStatus!,
//                             style: const TextStyle(fontSize: 10, color: Color(0xFF3B6D11), fontWeight: FontWeight.w500),
//                           ),
//                         ),
//                       ],
//                       const Spacer(),
//                       // Price
//                       if (!_isCancelled) ...[
//                         RichText(
//                           text: TextSpan(
//                             children: [
//                               TextSpan(
//                                 text: 'PKR ',
//                                 style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w400),
//                               ),
//                               TextSpan(
//                                 text: '${booking.payment ?? 0}',
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontWeight: FontWeight.w700,
//                                   color: kPrimaryDarkColor,
//                                   letterSpacing: -0.5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                       ],
//                       // View Details button
//                       GestureDetector(
//                         onTap: onTap,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                           decoration: BoxDecoration(
//                             color: kPrimaryColor,
//                             borderRadius: BorderRadius.circular(9),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Text('Details', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
//                               const SizedBox(width: 4),
//                               const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 10),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _dateTimePill(IconData icon, String text) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 11, color: Colors.grey[500]),
//         const SizedBox(width: 3),
//         Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
//       ],
//     );
//   }

//   String _capitalise(String s) {
//     if (s.isEmpty) return s;
//     return s[0].toUpperCase() + s.substring(1).toLowerCase();
//   }
// }

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
  static const List<Map<String, String>> _tabs = [
    {'label': 'All', 'status': 'all'},
    {'label': 'Pending', 'status': 'booked'},
    {'label': 'Confirmed', 'status': 'confirmed'},
    {'label': 'Completed', 'status': 'completed'},
    {'label': 'Cancelled by Customer', 'status': 'cancelled by customer'},
    {'label': 'Cancelled by Salon', 'status': 'cancelled by salon'},
    {'label': 'No Show', 'status': 'no show'},
  ];

  late final TabController _tabController;
  late final List<ScrollController> _scrollControllers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _scrollControllers = List.generate(_tabs.length, (_) {
      final c = ScrollController();
      c.addListener(_scrollListener);
      return c;
    });
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrentTab());
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) _loadCurrentTab();
  }

  void _loadCurrentTab() {
    final status = _tabs[_tabController.index]['status']!;
    final vm = context.read<BookingsViewModel>();
    final tabState = vm.getTabState(status);
    if (tabState.isFirstLoad && tabState.bookings.isEmpty) {
      vm.loadBookings(status, refresh: true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _scrollControllers) c.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final vm = context.read<BookingsViewModel>();
    final index = _tabController.index;
    final status = _tabs[index]['status']!;
    final tabState = vm.getTabState(status);
    if (vm.isLoading || tabState.isLoadingMore || !tabState.hasMorePages) return;
    final controller = _scrollControllers[index];
    if (controller.hasClients &&
        controller.position.pixels >= controller.position.maxScrollExtent * 0.9) {
      vm.loadNextPage(status);
    }
  }

  // ── STATUS THEMING ────────────────────────────────────────────────────
  // ── STATUS THEMING ────────────────────────────────────────────────────
_StatusTheme _theme(String? status) {
  final s = status?.toLowerCase().trim() ?? '';

  // Cancelled variants
  if (s.contains('cancel')) {
    return const _StatusTheme(
      label: 'Cancelled',
      pill: Color(0xFFFCEBEB),
      pillText: Color(0xFFA32D2D),
      strip: Color(0xFFFEF3F3),
      accent: Color(0xFFE24B4A),
      icon: Color(0xFFE24B4A),
    );
  }

  switch (s) {
    case 'confirmed':
    case 'booked':
      return const _StatusTheme(
        label: 'Confirmed',
        pill: Color(0xFFEAF3DE),
        pillText: Color(0xFF3B6D11),
        strip: Color(0xFFF4FAF0),
        accent: Color(0xFF639922),
        icon: Color(0xFF639922),
      );

    case 'completed':
      return const _StatusTheme(
        label: 'Completed',
        pill: Color(0xFFE6F1FB),
        pillText: Color(0xFF185FA5),
        strip: Color(0xFFF0F7FF),
        accent: Color(0xFF378ADD),
        icon: Color(0xFF378ADD),
      );

    case 'pending':
      return const _StatusTheme(
        label: 'Pending',
        pill: Color(0xFFFAEEDA),
        pillText: Color(0xFF854F0B),
        strip: Color(0xFFFEF8EE),
        accent: Color(0xFFEF9F27),
        icon: Color(0xFFEF9F27),
      );

    case 'no show':
    case 'no_show':
      return const _StatusTheme(
        label: 'No Show',
        pill: Color(0xFFF1EFE8),
        pillText: Color(0xFF5F5E5A),
        strip: Color(0xFFF8F8F7),
        accent: Color(0xFF888780),
        icon: Color(0xFF888780),
      );

    default:
      // Fallback for unknown statuses
      return _StatusTheme(
        label: status?.isNotEmpty == true ? _capitalise(status!) : 'Booking',
        pill: Colors.grey.shade100,
        pillText: Colors.grey.shade700,
        strip: Colors.grey.shade50,
        accent: Colors.grey.shade600,
        icon: Colors.grey.shade600,
      );
  }
}

// Helper for fallback
String _capitalise(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1).toLowerCase();
}

  // ── SHIMMER ───────────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[50]!,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_today_outlined, size: 32, color: kPrimaryColor.withOpacity(0.55)),
          ),
          const SizedBox(height: 18),
          const Text('No bookings yet',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 6),
          Text(
            'Book your first appointment\nand it will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.6),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: () {
              State? init;
              context.visitAncestorElements((el) {
                if (el is StatefulElement && el.state.runtimeType.toString() == '_InitScreenState') {
                  init = el.state;
                  return false;
                }
                return true;
              });
              (init as dynamic?)?.updateCurrentIndex(0);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Explore salons',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ── ERROR STATE ───────────────────────────────────────────────────────
  Widget _buildErrorState(BookingsViewModel vm, String status) {
    final ts = vm.getTabState(status);
    final msg = ts.errorMessage ?? 'Unable to load bookings right now';
    final isAuth = msg.contains('login') || msg.contains('Unauthorized');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: (isAuth ? kPrimaryColor : Colors.orange).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAuth ? Icons.lock_outline_rounded : Icons.cloud_off_outlined,
                size: 32,
                color: isAuth ? kPrimaryColor : Colors.orange[700],
              ),
            ),
            const SizedBox(height: 18),
            Text(isAuth ? 'Sign in required' : 'Something went wrong',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 6),
            Text(
              isAuth ? 'Please sign in to view your bookings.' : 'We couldn\'t load your bookings.\nPlease try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.6),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: () {
                if (isAuth) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthScreen()), (r) => false);
                } else {
                  vm.refreshStatus(status);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(10)),
                child: Text(isAuth ? 'Sign in' : 'Try again',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BOOKING LIST ──────────────────────────────────────────────────────
  Widget _buildList(BookingsViewModel vm, String status, ScrollController ctrl) {
    final ts = vm.getTabState(status);
    if (ts.isFirstLoad && ts.bookings.isEmpty) return _buildShimmer();
    if (ts.hasError) return _buildErrorState(vm, status);
    if (ts.bookings.isEmpty && !vm.isLoading && !ts.isLoadingMore) return _buildEmptyState();

    return RefreshIndicator(
      color: kPrimaryColor,
      onRefresh: () => vm.refreshStatus(status),
      child: ListView.builder(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        itemCount: ts.bookings.length + (ts.hasMorePages ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i >= ts.bookings.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 2)),
            );
          }
          final b = ts.bookings[i];
          return _BookingCard(
            booking: b,
            theme: _theme(b.status),
            onTap: () async {
              final res = await Navigator.push(ctx,
                  MaterialPageRoute(builder: (_) => BookingDetailsScreen(bookingId: b.id ?? 0)));
              if (res == true) vm.refreshStatus(status);
            },
          );
        },
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<BookingsViewModel>(
      builder: (ctx, vm, _) {
        return Scaffold(
          backgroundColor: kScreenBg,
          appBar: AppBar(
            title: const Text('My Bookings',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white)),
            backgroundColor: kPrimaryColor,
            elevation: 0,
            actions: [
              if (vm.isLoading || vm.isRefreshing)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    ),
                  ),
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              tabs: _tabs.map((t) => Tab(text: t['label'])).toList(),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: _tabs.asMap().entries.map((e) {
              return _buildList(vm, e.value['status']!, _scrollControllers[e.key]);
            }).toList(),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS THEME MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _StatusTheme {
  final String label;
  final Color pill;
  final Color pillText;
  final Color strip;
  final Color accent;
  final Color icon;

  const _StatusTheme({
    required this.label,
    required this.pill,
    required this.pillText,
    required this.strip,
    required this.accent,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOKING CARD
// ─────────────────────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final Booking booking;
  final _StatusTheme theme;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.theme,
    required this.onTap,
  });

  // ── HELPERS ───────────────────────────────────────────────────────────
  String get _date {
    final d = DateTime.tryParse(booking.date ?? '');
    return d != null ? DateFormat('MMM d, y').format(d) : 'N/A';
  }

  String get _time {
    if (booking.time == null) return 'N/A';
    try {
      return DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(booking.time!));
    } catch (_) {
      return 'N/A';
    }
  }

  bool get _isCancelled => booking.status?.toLowerCase().contains('cancel') ?? false;

  String? get _professional {
    if (booking.services == null) return null;
    for (final s in booking.services!) {
      if (s.selectedProfessional != null) return s.selectedProfessional!.displayName;
    }
    return null;
  }

  String get _title {
    if (booking.title != null && booking.title!.isNotEmpty) {
      final cleaned = booking.title!
          .replaceAll('Services:', '')
          .replaceAll('Deals:', '')
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .join(', ');
      if (cleaned.isNotEmpty) return cleaned;
    }

    final names = <String>[];
    if (booking.deal != null) {
      for (final d in booking.deal!) {
        if (d is Map<String, dynamic> && d['name'] != null) {
          final n = d['name'].toString().trim();
          if (n.isNotEmpty) names.add(n);
        }
      }
    }
    if (booking.services != null) {
      names.addAll(booking.services!
          .map((s) => s.name?.trim() ?? '')
          .where((n) => n.isNotEmpty));
    }
    return names.isNotEmpty ? names.join(', ') : 'Booking';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEEEEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── SALON STRIP ────────────────────────────────────────
                Container(
                  color: theme.strip,
                  padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                  child: Row(
                    children: [
                      // Logo
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: booking.salon?.logo != null
                              ? Image.network(booking.salon!.logo!, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Icon(Icons.store_rounded, size: 20, color: theme.icon))
                              : Icon(Icons.store_rounded, size: 20, color: theme.icon),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Salon name + address
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.salon?.name ?? 'Unknown Salon',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87, height: 1.2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (booking.salon?.address != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.location_on_rounded, size: 11, color: Colors.grey[400]),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      booking.salon!.address!,
                                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
                      const SizedBox(width: 8),

                      // Status pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.pill,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          theme.label,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.pillText),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── SERVICE ROW ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon badge
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.content_cut_rounded, size: 17, color: theme.icon),
                      ),
                      const SizedBox(width: 10),

                      // Service name + professional
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _title,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4),
                              overflow: TextOverflow.visible,
                            ),
                            if (_professional != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.person_rounded, size: 11, color: Colors.grey[400]),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      _professional!,
                                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
                      const SizedBox(width: 10),

                      // Date + time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _infoRow(Icons.calendar_month_rounded, _date),
                          const SizedBox(height: 5),
                          _infoRow(Icons.schedule_rounded, _time),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── DIVIDER ────────────────────────────────────────────
                Container(height: 1, color: const Color(0xFFF2F2F2)),

                // ── FOOTER ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Booking ID
                      Text(
                        '#${booking.id ?? '—'}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
                      ),

                      // Payment pill
                      if (!_isCancelled && booking.paymentStatus != null) ...[
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF3DE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            booking.paymentStatus!,
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF3B6D11), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Price
                      if (!_isCancelled) ...[
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'PKR ',
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFF999999), fontWeight: FontWeight.w400),
                              ),
                              TextSpan(
                                text: '${booking.payment ?? 0}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: kPrimaryDarkColor,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Details button
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text('Details',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 10),
                            ],
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
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: const Color(0xFFAAAAAA)),
        const SizedBox(width: 3),
        Text(text,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF888888), fontWeight: FontWeight.w500)),
      ],
    );
  }
}