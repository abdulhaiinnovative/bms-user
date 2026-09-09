// import 'package:flutter/material.dart';
// import 'dart:developer' as developer;
// import 'package:flutter/foundation.dart';
// import 'package:intl/intl.dart';
// import '../../../../constants.dart';
// import '../../data/models/booking_detail_response.dart';
// import '../../data/services/booking_detail_api.dart';
// import '../../../../api_services/review_api.dart';
// import '../../../../api_services/MyBookingsAPI.dart';
// import '../../../auth/utils/auth_manager.dart';

// class BookingDetailsScreen extends StatefulWidget {
//   final int bookingId;

//   const BookingDetailsScreen({super.key, required this.bookingId});

//   @override
//   State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
// }

// class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
//   final BookingDetailAPI _api = BookingDetailAPI();
//   BookingDetail? _bookingData;
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     if (kDebugMode) {
//       developer.log(
//           'BookingDetailsScreen.initState | bookingId=${widget.bookingId}',
//           name: 'booking.screen');
//     }
//     _fetchBookingDetail();
//   }

//   Future<void> _fetchBookingDetail() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });

//       if (kDebugMode) {
//         developer.log(
//             'BookingDetailsScreen._fetchBookingDetail started | bookingId=${widget.bookingId}',
//             name: 'booking.screen');

//         // DEBUG: Print auth token and booking ID for diagnostic script
//         AuthManager.getToken().then((token) {
//           print('\n╔═══════════════════════════════════════════════════════════════╗');
//           print('║ 🔍 DEBUG INFO FOR DIAGNOSTIC SCRIPT                           ║');
//           print('╠═══════════════════════════════════════════════════════════════╣');
//           print('║ Booking ID: ${widget.bookingId}');
//           print('║ Auth Token: ${token ?? "NOT FOUND"}');
//           print('╠═══════════════════════════════════════════════════════════════╣');
//           print('║ Run this command to fetch API data:                          ║');
//           print('║ dart run scripts/fetch_booking_detail.dart ${widget.bookingId} ${token ?? "YOUR_TOKEN"}');
//           print('╚═══════════════════════════════════════════════════════════════╝\n');
//         });
//       }

//       final response = await _api.getBookingDetail(widget.bookingId);

//       if (response.status) {
//         setState(() {
//           _bookingData = response.response.data;
//           _isLoading = false;
//         });
//         if (kDebugMode) {
//           developer.log(
//               'BookingDetailsScreen._fetchBookingDetail success | bookingId=${widget.bookingId}',
//               name: 'booking.screen');

//           // DEBUG: Log staff information for each service
//           print('\n╔═══════════════════════════════════════════════════════════════╗');
//           print('║ 📋 SERVICES & STAFF DATA RECEIVED                             ║');
//           print('╠═══════════════════════════════════════════════════════════════╣');
//           if (_bookingData?.services != null && _bookingData!.services.isNotEmpty) {
//             for (var i = 0; i < _bookingData!.services.length; i++) {
//               final service = _bookingData!.services[i];
//               print('║ Service ${i + 1}: ${service.name}');
//               print('║   Has staff: ${service.selectedProfessional != null}');
//               if (service.selectedProfessional != null) {
//                 print('║   Staff name: ${service.selectedProfessional!.displayName}');
//                 print('║   Staff ID: ${service.selectedProfessional!.id}');
//               } else {
//                 print('║   ⚠️  WARNING: Staff is NULL for this service!');
//               }
//               print('║');
//             }
//           } else {
//             print('║ ⚠️  WARNING: No services found in booking!');
//           }
//           print('╚═══════════════════════════════════════════════════════════════╝\n');
//         }
//       } else {
//         setState(() {
//           _error = response.message;
//           _isLoading = false;
//         });
//         if (kDebugMode) {
//           developer.log(
//               'BookingDetailsScreen._fetchBookingDetail api error | bookingId=${widget.bookingId} | message=${response.message}',
//               name: 'booking.screen');
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         developer.log(
//             'BookingDetailsScreen._fetchBookingDetail exception | bookingId=${widget.bookingId} | error=$e',
//             name: 'booking.screen');
//       }
//       setState(() {
//         _error = 'Failed to load booking details: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _cancelBooking(BuildContext context) async {
//     try {
//       // Show loading indicator
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(child: CircularProgressIndicator()),
//       );

//       final success = await MyBookingsAPI().cancelBooking(widget.bookingId);

//       // Hide loading indicator
//       if (mounted) Navigator.pop(context);

//       if (success && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Booking cancelled successfully'),
//             backgroundColor: Colors.green,
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//         Navigator.pop(context, true);
//       }
//     } catch (e) {
//       // Hide loading indicator if showing
//       if (mounted) Navigator.pop(context);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to cancel booking: $e'),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _showReviewDialog(BuildContext context) async {
//     int rating = 1;
//     final commentController = TextEditingController();
//     bool isSubmitting = false;

//     await showDialog(
//       context: context,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (context, setState) => AlertDialog(
//           title: const Text(
//             'Write a Review',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Rating',
//                   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(5, (index) {
//                     return InkWell(
//                       onTap: isSubmitting
//                           ? null
//                           : () => setState(() => rating = index + 1),
//                       borderRadius: BorderRadius.circular(20),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 2),
//                         child: Icon(
//                           index < rating ? Icons.star : Icons.star_border,
//                           color: Colors.amber,
//                           size: 28,
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Comment',
//                   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: commentController,
//                   enabled: !isSubmitting,
//                   maxLines: 4,
//                   decoration: InputDecoration(
//                     hintText: 'Share your experience...',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     contentPadding: const EdgeInsets.all(12),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: isSubmitting
//                   ? null
//                   : () => Navigator.of(dialogContext).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: isSubmitting
//                   ? null
//                   : () async {
//                       if (commentController.text.trim().isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Please write a comment'),
//                             backgroundColor: Colors.orange,
//                           ),
//                         );
//                         return;
//                       }

//                       setState(() => isSubmitting = true);

//                       try {
//                         final api = ReviewAPI();
//                         await api.createReview(
//                           bookingId: widget.bookingId,
//                           rating: rating,
//                           comment: commentController.text.trim(),
//                         );

//                         if (mounted) {
//                           Navigator.of(dialogContext).pop();
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Review submitted successfully'),
//                               backgroundColor: Colors.green,
//                               behavior: SnackBarBehavior.floating,
//                             ),
//                           );
//                           // Refresh booking details to show new review
//                           _fetchBookingDetail();
//                         }
//                       } catch (e) {
//                         setState(() => isSubmitting = false);
//                         if (mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text('Failed to submit review: $e'),
//                               backgroundColor: Colors.red,
//                               behavior: SnackBarBehavior.floating,
//                             ),
//                           );
//                         }
//                       }
//                     },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kPrimaryColor,
//                 foregroundColor: Colors.white,
//               ),
//               child: isSubmitting
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation(Colors.white),
//                       ),
//                     )
//                   : const Text('Submit'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kCardBG,
//       appBar: AppBar(
//         title: const Text(
//           'Booking Details',
//           style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _error != null
//               ? _buildErrorWidget()
//               : _buildContent(),
//     );
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             Text(
//               _error ?? 'Something went wrong',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey[600], fontSize: 16),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _fetchBookingDetail,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContent() {
//     if (_bookingData == null) {
//       return const Center(child: Text('No booking data available'));
//     }

//     final booking = _bookingData!;
//     final date = DateTime.tryParse(booking.date ?? '');
//     final formattedDate =
//         date != null ? DateFormat('MMM dd, yyyy').format(date) : 'N/A';
//     final formattedTime = booking.time != null
//         ? DateFormat('hh:mm a')
//             .format(DateFormat('HH:mm:ss').parse(booking.time!))
//         : 'N/A';
//     final professionalAssignments = _collectProfessionals(booking.services);

//     return Column(
//       children: [
//         Expanded(
//           child: RefreshIndicator(
//             onRefresh: _fetchBookingDetail,
//             child: SingleChildScrollView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Salon Header
//                     _buildSalonHeader(booking),
//                     const SizedBox(height: 24),

//                     // Booking Info Card
//                     _buildInfoCard(
//                       title: 'Booking Information',
//                       children: [
//                         _buildDetailRow(
//                             Icons.calendar_today, 'Date', formattedDate),
//                         const SizedBox(height: 12),
//                         _buildDetailRow(
//                             Icons.access_time, 'Time', formattedTime),
//                         const SizedBox(height: 12),
//                         _buildDetailRow(Icons.check_circle, 'Status',
//                             _capitalizeFirst(booking.status ?? 'N/A')),
//                         const SizedBox(height: 12),
//                         _buildDetailRow(Icons.category, 'Type',
//                             _capitalizeFirst(booking.bookingType ?? 'N/A')),
//                         const SizedBox(height: 12),
//                         _buildDetailRow(Icons.payment, 'Payment Method',
//                             _capitalizeFirst(booking.paymentMethod ?? 'N/A')),
//                         // Only show payment status if booking is not cancelled
//                         if (!(booking.status
//                                 ?.toLowerCase()
//                                 .contains('cancel') ==
//                             true)) ...[
//                           const SizedBox(height: 12),
//                           _buildDetailRow(Icons.receipt, 'Payment Status',
//                               _capitalizeFirst(booking.paymentStatus ?? 'N/A')),
//                         ],
//                         const SizedBox(height: 12),
//                         // Calculate original price before discount
//                         _buildDetailRow(
//                             Icons.receipt_long,
//                             'Subtotal',
//                             'PKR ${((booking.payment ?? 0) + (booking.additionalDiscount ?? 0)).toStringAsFixed(0)}'),
//                         // Always show additional discount (0 if null)
//                         if (booking.additionalDiscount != null && booking.additionalDiscount! > 0) ...[
//                           const SizedBox(height: 12),
//                           _buildDetailRow(
//                               Icons.discount,
//                               'Discount',
//                               '- PKR ${booking.additionalDiscount}'),
//                         ],
//                         const SizedBox(height: 12),
//                         _buildDetailRow(Icons.monetization_on, 'Total Amount',
//                             'PKR ${booking.payment?.toStringAsFixed(0) ?? '0'}'),
//                       ],
//                     ),

//                     // Services Section
//                     if (booking.services.isNotEmpty) ...[
//                       const SizedBox(height: 20),
//                       _buildServicesSection(booking.services),
//                     ],

//                     // Professionals Section
//                     if (professionalAssignments.isNotEmpty) ...[
//                       const SizedBox(height: 20),
//                       _buildProfessionalsSection(professionalAssignments),
//                     ],

//                     // Deal Section
//                     if (booking.deal.isNotEmpty) ...[
//                       const SizedBox(height: 20),
//                       _buildDealsSection(booking.deal),
//                     ],

//                     // Membership Section
//                     if (booking.membership.isNotEmpty) ...[
//                       const SizedBox(height: 20),
//                       _buildMembershipSection(booking.membership),
//                     ],

//                     // Review Section
//                     if (booking.review.isNotEmpty) ...[
//                       const SizedBox(height: 20),
//                       _buildReviewsSection(booking.review),
//                     ],

//                     // Add Review Button (only if completed and no review yet)
//                     if (booking.status?.toLowerCase() == 'completed' &&
//                         booking.review.isEmpty) ...[
//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: () => _showReviewDialog(context),
//                           icon: const Icon(Icons.rate_review),
//                           label: const Text('Write a Review'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: kPrimaryColor,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],

//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         // Cancel Button
//         if (!(booking.status?.toLowerCase().contains('cancelled') == true ||
//             booking.status?.toLowerCase().contains('completed') == true))
//           Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
//             child: SizedBox(
//               width: double.infinity,
//               child: SafeArea(
//                 child: ElevatedButton(
//                   onPressed: () => _cancelBooking(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.redAccent,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: const Text(
//                     'Cancel Booking',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildSalonHeader(BookingDetail booking) {
//     final salon = booking.salon;
//     return Center(
//       child: Column(
//         children: [
//           Hero(
//             tag: 'salon-logo-${booking.id}',
//             child: Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.grey[200],
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.3),
//                     spreadRadius: 2,
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//                 image: salon?.logo != null && salon!.logo!.isNotEmpty
//                     ? DecorationImage(
//                         image: NetworkImage(salon.logo!),
//                         fit: BoxFit.cover,
//                       )
//                     : null,
//               ),
//               child: salon?.logo == null || salon!.logo!.isEmpty
//                   ? Icon(Icons.store, size: 60, color: Colors.grey[600])
//                   : null,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             salon?.name ?? 'Unknown Salon',
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           if (salon?.address != null && salon!.address!.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
//                 const SizedBox(width: 4),
//                 Flexible(
//                   child: Text(
//                     salon.address!,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoCard(
//       {required String title, required List<Widget> children}) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildServicesSection(List<BookingService> services) {
//     return _buildInfoCard(
//       title: 'Services',
//       children: services.map((service) {
//         // Debug logging
//         if (kDebugMode) {
//           developer.log(
//             'Service: ${service.name} | Has staff: ${service.selectedProfessional != null} | Staff name: ${service.selectedProfessional?.displayName}',
//             name: 'booking.screen',
//           );
//         }

//         return Padding(
//           padding: EdgeInsets.only(bottom: services.last == service ? 0 : 16),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey[200]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         service.name ?? 'Service',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       'PKR ${service.price?.toStringAsFixed(0) ?? '0'}',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: kPrimaryDarkColor,
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (service.duration != null) ...[
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(Icons.timer, size: 14, color: Colors.grey[600]),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${service.duration} mins',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//                 // Show professional section only if staff exists
//                 if (service.selectedProfessional != null) ...[
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: kPrimaryColor.withValues(alpha: 0.05),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: kPrimaryColor.withValues(alpha: 0.2),
//                         width: 1,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 20,
//                           backgroundColor: Colors.grey[300],
//                           backgroundImage: service.selectedProfessional!.image !=
//                                       null &&
//                                   service.selectedProfessional!.image!.isNotEmpty
//                               ? NetworkImage(service.selectedProfessional!.image!)
//                               : null,
//                           child: service.selectedProfessional!.image == null ||
//                                   service.selectedProfessional!.image!.isEmpty
//                               ? Icon(Icons.person,
//                                   size: 20, color: Colors.grey[600])
//                               : null,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 service.selectedProfessional!.displayName,
//                                 style: const TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               if (service.selectedProfessional!.phone != null &&
//                                   service.selectedProfessional!.phone!
//                                       .isNotEmpty) ...[
//                                 const SizedBox(height: 2),
//                                 Row(
//                                   children: [
//                                     Icon(Icons.phone,
//                                         size: 12, color: Colors.grey[600]),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       service.selectedProfessional!.phone!,
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey[700],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ]
//               ],),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildDealsSection(List<dynamic> deals) {
//     return _buildInfoCard(
//       title: 'Deals',
//       children: deals.map((deal) {
//         final dealData = deal as Map<String, dynamic>? ?? {};
//         return Padding(
//           padding: EdgeInsets.only(bottom: deals.last == deal ? 0 : 16),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.orange[50],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.orange[200]!),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.local_offer, color: Colors.orange[700]),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         dealData['name'] ?? 'Deal',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       if (dealData['description'] != null)
//                         Text(
//                           dealData['description'],
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 if (dealData['price'] != null)
//                   Text(
//                     'PKR ${dealData['price']}',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.orange[700],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildMembershipSection(List<dynamic> memberships) {
//     return _buildInfoCard(
//       title: 'Memberships',
//       children: memberships.map((membership) {
//         final membershipData = membership as Map<String, dynamic>? ?? {};
//         return Padding(
//           padding:
//               EdgeInsets.only(bottom: memberships.last == membership ? 0 : 16),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.purple[50],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.purple[200]!),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.card_membership, color: Colors.purple[700]),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         membershipData['name'] ?? 'Membership',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       if (membershipData['description'] != null)
//                         Text(
//                           membershipData['description'],
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 if (membershipData['price'] != null)
//                   Text(
//                     'PKR ${membershipData['price']}',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.purple[700],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildReviewsSection(List<BookingReview> reviews) {
//     return _buildInfoCard(
//       title: 'Reviews',
//       children: reviews.map((review) {
//         return Padding(
//           padding: EdgeInsets.only(bottom: reviews.last == review ? 0 : 16),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.blue[200]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     if (review.user != null) ...[
//                       CircleAvatar(
//                         radius: 16,
//                         backgroundColor: Colors.grey[300],
//                         backgroundImage: review.user!.image != null
//                             ? NetworkImage(review.user!.image!)
//                             : null,
//                         child: review.user!.image == null
//                             ? Icon(Icons.person,
//                                 size: 16, color: Colors.grey[600])
//                             : null,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           review.user!.name ?? 'User',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                     Row(
//                       children: List.generate(5, (index) {
//                         return Icon(
//                           index < (review.rating ?? 0)
//                               ? Icons.star
//                               : Icons.star_border,
//                           size: 16,
//                           color: Colors.amber,
//                         );
//                       }),
//                     ),
//                   ],
//                 ),
//                 if (review.comment != null && review.comment!.isNotEmpty) ...[
//                   const SizedBox(height: 8),
//                   Text(
//                     review.comment!,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildProfessionalsSection(
//       List<_ProfessionalAssignment> assignments) {
//     return _buildInfoCard(
//       title: 'Professionals',
//       children: assignments.map((assignment) {
//         final professional = assignment.professional;
//         final displayName = _formatProfessionalName(professional);

//         return Padding(
//           padding:
//               EdgeInsets.only(bottom: assignments.last == assignment ? 0 : 16),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey[200]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 18,
//                       backgroundColor: Colors.grey[300],
//                       backgroundImage: professional.image != null &&
//                               professional.image!.isNotEmpty
//                           ? NetworkImage(professional.image!)
//                           : null,
//                       child: professional.image == null ||
//                               professional.image!.isEmpty
//                           ? Icon(Icons.person, size: 18, color: Colors.grey[600])
//                           : null,
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             displayName,
//                             style: const TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           if (professional.experience != null &&
//                               professional.experience!.isNotEmpty)
//                             Text(
//                               professional.experience!,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           if (professional.phone != null &&
//                               professional.phone!.isNotEmpty)
//                             Row(
//                               children: [
//                                 Icon(Icons.phone,
//                                     size: 14, color: Colors.grey[600]),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   professional.phone!,
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (assignment.services.isNotEmpty) ...[
//                   const SizedBox(height: 10),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 6,
//                     children: assignment.services
//                         .map(
//                           (serviceName) => Chip(
//                             label: Text(
//                               serviceName,
//                               style: const TextStyle(fontSize: 12),
//                             ),
//                             backgroundColor: Colors.grey[100],
//                             side: BorderSide(color: Colors.grey[200]!),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildDetailRow(IconData icon, String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 20, color: kPrimaryDarkColor),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   String _capitalizeFirst(String text) {
//     if (text.isEmpty) return text;
//     return text[0].toUpperCase() + text.substring(1);
//   }

//   List<_ProfessionalAssignment> _collectProfessionals(
//       List<BookingService> services) {
//     final map = <int, _ProfessionalAssignment>{};

//     for (final service in services) {
//       final professional = service.selectedProfessional;
//       if (professional == null) continue;

//       final id = professional.id;
//       map.putIfAbsent(
//         id,
//         () => _ProfessionalAssignment(
//           professional: professional,
//           services: [],
//         ),
//       );

//       final name = (service.name ?? '').trim();
//       if (name.isNotEmpty && !map[id]!.services.contains(name)) {
//         map[id]!.services.add(name);
//       }
//     }

//     return map.values.toList();
//   }

//   String _formatProfessionalName(ServiceProfessional professional) {
//     final fullName =
//         '${professional.firstName ?? ''} ${professional.lastName ?? ''}'.trim();
//     if (fullName.isNotEmpty) return fullName;
//     if ((professional.name ?? '').isNotEmpty) return professional.name!;
//     return 'Professional';
//   }
// }

// class _ProfessionalAssignment {
//   final ServiceProfessional professional;
//   final List<String> services;

//   _ProfessionalAssignment({
//     required this.professional,
//     required this.services,
//   });
// }

import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../../constants.dart';
import '../../data/models/booking_detail_response.dart';
import '../../data/services/booking_detail_api.dart';
import '../../../../api_services/review_api.dart';
import '../../../../api_services/MyBookingsAPI.dart';
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
        AuthManager.getToken().then((token) {
          print('\n╔═══════════════════════════════════════════════════════════════╗');
          print('║ 🔍 DEBUG INFO FOR DIAGNOSTIC SCRIPT                           ║');
          print('╠═══════════════════════════════════════════════════════════════╣');
          print('║ Booking ID: ${widget.bookingId}');
          print('║ Auth Token: ${token ?? "NOT FOUND"}');
          print('╚═══════════════════════════════════════════════════════════════╝\n');
        });
      }

      final response = await _api.getBookingDetail(widget.bookingId);

      if (response.status) {
        setState(() {
          _bookingData = response.response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load booking details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelBooking(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        content: const Text(
          'Are you sure you want to cancel this booking?',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, keep it'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await MyBookingsAPI().cancelBooking(widget.bookingId);
      if (mounted) Navigator.pop(context);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Booking cancelled successfully'),
            ]),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel booking: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _showReviewDialog(BuildContext context) async {
  int rating = 0;
  final commentController = TextEditingController();
  bool isSubmitting = false;

  await showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.rate_review_outlined,
                        color: kPrimaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Write a Review',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Your rating',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54)),
              const SizedBox(height: 12),

              // ★★★★★ Stars Row - FIXED
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: isSubmitting
                        ? null
                        : () => setDState(() => rating = index + 1), // ← Fixed here
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        
                        index < rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: index < rating
                            ? const Color(0xFFF59E0B)
                            : Colors.grey[500],
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              const Text('Comment',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54)),
              const SizedBox(height: 8),

              TextField(
                controller: commentController,
                enabled: !isSubmitting,
                maxLines: 4,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kPrimaryColor, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (isSubmitting || rating < 1)
                          ? null
                          : () async {
                              if (commentController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Please write a comment'),
                                    backgroundColor: Colors.orange[700],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                                return;
                              }

                              setDState(() => isSubmitting = true);

                              print('--- Submit button pressed for Review ---');
                              print('BookingID: ${widget.bookingId}');
                              print('Rating: $rating');
                              print('Comment: ${commentController.text.trim()}');

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
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.white, size: 18),
                                          SizedBox(width: 8),
                                          Text('Review submitted successfully!'),
                                        ],
                                      ),
                                      backgroundColor: Colors.green[700],
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );

                                  _fetchBookingDetail(); // Refresh details
                                }
                              } catch (e) {
                                setDState(() => isSubmitting = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to submit review: $e'),
                                      backgroundColor: Colors.red[700],
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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
                          : const Text('Submit',
                              style: TextStyle(fontWeight: FontWeight.w600)),
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
}

  // ── STATUS HELPERS ─────────────────────────────────────────────────────────

  bool get _isCancelled =>
      _bookingData?.status?.toLowerCase().contains('cancel') == true;
  bool get _isCompleted =>
      _bookingData?.status?.toLowerCase() == 'completed';

  Color _statusColor(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s.contains('cancel')) return Colors.red;
    if (s == 'completed') return Colors.green[700]!;
    if (s == 'pending') return Colors.orange[700]!;
    return kPrimaryColor;
  }

  Color _statusBg(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s.contains('cancel')) return Colors.red.withOpacity(0.1);
    if (s == 'completed') return Colors.green.withOpacity(0.1);
    if (s == 'pending') return Colors.orange.withOpacity(0.1);
    return kPrimaryColor.withOpacity(0.1);
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: Colors.black87),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.black54, size: 22),
            onPressed: _fetchBookingDetail,
            tooltip: 'Refresh',
          ),
        ],
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.wifi_off_rounded, size: 36, color: Colors.redAccent),
            ),
            const SizedBox(height: 20),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchBookingDetail,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
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
            color: kPrimaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // ── Salon Header ──────────────────────────────────────────
                  _buildSalonHeader(booking),

                  const SizedBox(height: 8),

                  // ── Booking Info ──────────────────────────────────────────
                  _buildSection(
                    title: 'BOOKING INFO',
                    child: Column(
                      children: [
                        // Date + Time row
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                  child: _buildInfoTile(
                                      Icons.calendar_today_outlined,
                                      'Date',
                                      formattedDate)),
                              VerticalDivider(
                                  width: 1,
                                  color: Colors.grey[200],
                                  thickness: 1),
                              Expanded(
                                  child: _buildInfoTile(
                                      Icons.access_time_rounded,
                                      'Time',
                                      formattedTime)),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey[200]),
                        // Type + Status row
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                  child: _buildInfoTile(
                                      Icons.category_outlined,
                                      'Type',
                                      _capitalizeFirst(
                                          booking.bookingType ?? 'N/A'))),
                              VerticalDivider(
                                  width: 1,
                                  color: Colors.grey[200],
                                  thickness: 1),
                              Expanded(
                                child: _buildStatusTile(booking.status),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Payment ───────────────────────────────────────────────
                  _buildSection(
                    title: 'PAYMENT',
                    child: Column(
                      children: [
                        _buildPaymentRow(
                            Icons.payment_outlined,
                            'Method',
                            _capitalizeFirst(booking.paymentMethod ?? 'N/A'),
                            null),
                        if (!_isCancelled) ...[
                          Divider(height: 1, color: Colors.grey[200]),
                          _buildPaymentRow(
                              Icons.receipt_outlined,
                              'Status',
                              _capitalizeFirst(booking.paymentStatus ?? 'N/A'),
                              null),
                        ],
                        Divider(height: 1, color: Colors.grey[200]),
                        _buildPaymentRow(
                            Icons.receipt_long_outlined,
                            'Subtotal',
                            'PKR ${((booking.payment ?? 0) + (booking.additionalDiscount ?? 0)).toStringAsFixed(0)}',
                            null),
                        if (booking.additionalDiscount != null &&
                            booking.additionalDiscount! > 0) ...[
                          Divider(height: 1, color: Colors.grey[200]),
                          _buildPaymentRow(
                              Icons.discount_outlined,
                              'Discount',
                              '- PKR ${booking.additionalDiscount}',
                              Colors.green[700]),
                        ],
                        Divider(height: 1, color: Colors.grey[200]),
                        _buildTotalRow(
                            'PKR ${booking.payment?.toStringAsFixed(0) ?? '0'}'),
                      ],
                    ),
                  ),

                  // ── Services ──────────────────────────────────────────────
                  if (booking.services.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildSection(
                      title: 'SERVICES',
                      child: Column(
                        children: booking.services
                            .asMap()
                            .entries
                            .map((e) => Column(
                                  children: [
                                    if (e.key != 0)
                                      Divider(
                                          height: 1, color: Colors.grey[200]),
                                    _buildServiceItem(e.value),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ],

                  // ── Professionals ─────────────────────────────────────────
                  // if (professionalAssignments.isNotEmpty) ...[
                  //   const SizedBox(height: 8),
                  //   _buildSection(
                  //     title: 'PROFESSIONALS',
                  //     child: Column(
                  //       children: professionalAssignments
                  //           .asMap()
                  //           .entries
                  //           .map((e) => Column(
                  //                 children: [
                  //                   if (e.key != 0)
                  //                     Divider(
                  //                         height: 1, color: Colors.grey[200]),
                  //                   _buildProfessionalItem(e.value),
                  //                 ],
                  //               ))
                  //           .toList(),
                  //     ),
                  //   ),
                  // ],

                  // ── Deals ─────────────────────────────────────────────────
                  if (booking.deal.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildSection(
                      title: 'DEALS',
                      child: Column(
                        children: booking.deal
                            .asMap()
                            .entries
                            .map((e) => Column(
                                  children: [
                                    if (e.key != 0)
                                      Divider(
                                          height: 1, color: Colors.grey[200]),
                                    _buildDealItem(
                                        e.value as Map<String, dynamic>? ?? {}),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ],

                  // ── Memberships ───────────────────────────────────────────
                  if (booking.membership.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildSection(
                      title: 'MEMBERSHIPS',
                      child: Column(
                        children: booking.membership
                            .asMap()
                            .entries
                            .map((e) => Column(
                                  children: [
                                    if (e.key != 0)
                                      Divider(
                                          height: 1, color: Colors.grey[200]),
                                    _buildMembershipItem(
                                        e.value as Map<String, dynamic>? ?? {}),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ],

                  // ── Reviews ───────────────────────────────────────────────
                  if (booking.review.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildSection(
                      title: 'REVIEWS',
                      child: Column(
                        children: booking.review
                            .asMap()
                            .entries
                            .map((e) => Column(
                                  children: [
                                    if (e.key != 0)
                                      Divider(
                                          height: 1, color: Colors.grey[200]),
                                    _buildReviewItem(e.value),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),

        // ── Bottom Action Bar ───────────────────────────────────────────────
        _buildBottomBar(booking),
      ],
    );
  }

  // ── SALON HEADER ────────────────────────────────────────────────────────────

  Widget _buildSalonHeader(BookingDetail booking) {
    final salon = booking.salon;
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
            ),
            child: ClipOval(
              child: salon?.logo != null && salon!.logo!.isNotEmpty
                  ? Image.network(salon.logo!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.store_rounded, size: 36, color: Colors.grey[400]))
                  : Icon(Icons.store_rounded, size: 36, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 14),

          // Salon name
          Text(
            salon?.name ?? 'Unknown Salon',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
            textAlign: TextAlign.center,
          ),

          // Address
          if (salon?.address != null && salon!.address!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    salon.address!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _statusBg(_bookingData?.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _statusColor(_bookingData?.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  _capitalizeFirst(_bookingData?.status ?? 'N/A'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(_bookingData?.status),
                  ),
                ),
              ],
            ),
          ),

          // Booking ID
          const SizedBox(height: 8),
          Text(
            '#${widget.bookingId}',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ── SECTION WRAPPER ──────────────────────────────────────────────────────────

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.8),
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          child,
        ],
      ),
    );
  }

  // ── INFO TILES ───────────────────────────────────────────────────────────────

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: kPrimaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile(String? status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _statusBg(status),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.info_outline_rounded,
                size: 16, color: _statusColor(status)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 3),
                Text(
                  _capitalizeFirst(status ?? 'N/A'),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(status)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PAYMENT ROWS ─────────────────────────────────────────────────────────────

  Widget _buildPaymentRow(
      IconData icon, String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.monetization_on_outlined,
              size: 18, color: Colors.black87),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Total Amount',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
          ),
          Text(
            total,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kPrimaryDarkColor),
          ),
        ],
      ),
    );
  }

  // ── SERVICE ITEM ─────────────────────────────────────────────────────────────

  Widget _buildServiceItem(BookingService service) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  service.name ?? 'Service',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PKR ${service.price?.toStringAsFixed(0) ?? '0'}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kPrimaryDarkColor),
                ),
              ),
            ],
          ),
          if (service.duration != null) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 13, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${service.duration} mins',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
          if (service.selectedProfessional != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  _buildAvatarCircle(
                    image: service.selectedProfessional!.image,
                    name: service.selectedProfessional!.displayName,
                    radius: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.selectedProfessional!.displayName,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                        if (service.selectedProfessional!.phone != null &&
                            service.selectedProfessional!.phone!.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.phone_outlined,
                                  size: 11, color: Colors.grey[500]),
                              const SizedBox(width: 3),
                              Text(
                                service.selectedProfessional!.phone!,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Assigned',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: kPrimaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── PROFESSIONAL ITEM ────────────────────────────────────────────────────────

  Widget _buildProfessionalItem(_ProfessionalAssignment assignment) {
    final p = assignment.professional;
    final fullName = _formatProfessionalName(p);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatarCircle(image: p.image, name: fullName, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fullName,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    if (p.experience != null && p.experience!.isNotEmpty)
                      Text(p.experience!,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[500])),
                    if (p.phone != null && p.phone!.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.phone_outlined,
                              size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 3),
                          Text(p.phone!,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500])),
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
              spacing: 6,
              runSpacing: 6,
              children: assignment.services
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(s,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[700])),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ── DEAL ITEM ────────────────────────────────────────────────────────────────

  Widget _buildDealItem(Map<String, dynamic> deal) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.local_offer_outlined,
                color: Colors.orange[700], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deal['name'] ?? 'Deal',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                if (deal['description'] != null)
                  Text(deal['description'],
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          if (deal['price'] != null)
            Text('PKR ${deal['price']}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange[700])),
        ],
      ),
    );
  }

  // ── MEMBERSHIP ITEM ──────────────────────────────────────────────────────────

  Widget _buildMembershipItem(Map<String, dynamic> membership) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.card_membership_outlined,
                color: Colors.purple[700], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(membership['name'] ?? 'Membership',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                if (membership['description'] != null)
                  Text(membership['description'],
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          if (membership['price'] != null)
            Text('PKR ${membership['price']}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.purple[700])),
        ],
      ),
    );
  }

  // ── REVIEW ITEM ──────────────────────────────────────────────────────────────

  Widget _buildReviewItem(BookingReview review) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (review.user != null) ...[
                _buildAvatarCircle(
                    image: review.user!.image,
                    name: review.user!.name ?? 'U',
                    radius: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.user!.name ?? 'User',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < (review.rating ?? 0)
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: i < (review.rating ?? 0)
                              ? const Color(0xFFF59E0B)
                              : Colors.grey[300],
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                review.comment!,
                style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── BOTTOM BAR ───────────────────────────────────────────────────────────────

  Widget _buildBottomBar(BookingDetail booking) {
    final showCancel = !_isCancelled && !_isCompleted;
    final showReview = _isCompleted && booking.review.isEmpty;

    if (!showCancel && !showReview) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 0.8)),
      ),
      child: Row(
        children: [
          if (showReview) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showReviewDialog(context),
                icon: const Icon(Icons.star_outline_rounded, size: 18),
                label: const Text('Write Review'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimaryColor,
                  side: BorderSide(color: kPrimaryColor, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (showCancel) const SizedBox(width: 10),
          ],
          if (showCancel)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _cancelBooking(context),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Cancel Booking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red[700],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red[200]!),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────────

  Widget _buildAvatarCircle({
    required String? image,
    required String name,
    required double radius,
  }) {
    final hasImage = image != null && image.isNotEmpty;
    final initials = _getInitials(name);
    return CircleAvatar(
      radius: radius,
      backgroundColor: kPrimaryColor.withOpacity(0.15),
      backgroundImage: hasImage ? NetworkImage(image) : null,
      child: hasImage
          ? null
          : Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.6,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor,
              ),
            ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return '?';
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
        () => _ProfessionalAssignment(professional: professional, services: []),
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