// import 'package:flutter/material.dart';
// import 'package:app/api_services/services_api.dart';
// import 'package:app/api_services/salon_detail_api.dart';
// import 'package:app/models/HomePageResponse.dart';
// import 'package:app/models/SalonDetailApiResponse.dart' as sd;
// import 'package:app/constants.dart';
// import 'package:provider/provider.dart';
// import '../../../../models/home/Professional.dart';
// import '../../../../providers/cart_provider.dart';
// import '../../../../components/cart_bottom_bar.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:intl/intl.dart';
//
// class ServiceDetailScreen extends StatefulWidget {
//   final int serviceId;
//
//   const ServiceDetailScreen({Key? key, required this.serviceId})
//       : super(key: key);
//
//   @override
//   State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
// }
//
// class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
//   late Future<Service> _serviceFuture;
//
//   // Reviews state
//   List<sd.Review> _reviews = [];
//   int _reviewsCurrentPage = 1;
//   int _reviewsLastPage = 1;
//   int _reviewsTotal = 0;
//   bool _reviewsLoading = false;
//   bool _reviewsLoaded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _serviceFuture = ServicesApi().fetchServiceById(widget.serviceId);
//   }
//
//   /// Fetch reviews from the API
//   Future<void> _fetchReviews(int salonId, {bool loadMore = false}) async {
//     if (_reviewsLoading) return;
//     setState(() => _reviewsLoading = true);
//
//     try {
//       final page = loadMore ? _reviewsCurrentPage + 1 : 1;
//       final result = await ServicesApi().fetchSalonReviews(
//         salonId: salonId,
//         page: page,
//       );
//
//       setState(() {
//         if (loadMore) {
//           _reviews.addAll(result['reviews'] as List<sd.Review>);
//         } else {
//           _reviews = result['reviews'] as List<sd.Review>;
//         }
//         _reviewsCurrentPage = result['current_page'] as int;
//         _reviewsLastPage = result['last_page'] as int;
//         _reviewsTotal = result['total'] as int;
//         _reviewsLoaded = true;
//         _reviewsLoading = false;
//       });
//     } catch (e) {
//       setState(() => _reviewsLoading = false);
//       debugPrint('Error fetching reviews: $e');
//     }
//   }
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Service>(
//       future: _serviceFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(color: kPrimaryColor),
//             ),
//           );
//         }
//
//         if (snapshot.hasError) {
//           return Scaffold(
//             body: Center(child: Text('Error: ${snapshot.error}')),
//           );
//         }
//
//         if (!snapshot.hasData) {
//           return const Scaffold(
//             body: Center(child: Text('No data')),
//           );
//         }
//
//         final service = snapshot.data!;
//
//         return Scaffold(
//           backgroundColor: kScreenBg,
//           appBar: AppBar(
//             title: const Text('Service Details'),
//             elevation: 0,
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             // actions: [
//             //   IconButton(
//             //     icon: const Icon(Icons.share_outlined),
//             //     onPressed: () {
//             //       final text =
//             //           'Check out ${service.name ?? "this service"} at ${service.salon?.name ?? "our salon"} for PKR ${service.price ?? 0}!\n\n'
//             //           'Book now on this app:\n'
//             //           'https://play.google.com/store/apps/details?id=com.BMS.app';
//             //       Share.share(text);
//             //
//             //     },
//             //   ),
//             // ],
//           ),
//
//           bottomNavigationBar: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//
//               const CartBottomBar(),
//               _buildBookButton(service),
//             ],
//           ),
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.only(bottom: 40),
//             child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (service.salon != null) _buildSalonSection(service.salon!),
//                     _buildDetailsCard(service),
//                     if (service.professionals != null && service.professionals!.isNotEmpty)
//                       _buildProfessionalsSection(service.professionals!),
//                     if (service.description?.isNotEmpty ?? false)
//                       _buildDescriptionSection(service.description!),
//                      
//                     if (service.salon != null) ...[
//                       if (service.salon!.about != null && service.salon!.about!.isNotEmpty)
//                         _buildInfoSection("Info", service.salon!.about!),
//                      
//                       if (service.salon!.address != null && service.salon!.address!.isNotEmpty)
//                         _buildAddressSection(service.salon!.address!),
//                        
//                       if (service.salon!.activeDays != null && service.salon!.activeDays!.isNotEmpty)
//                         _buildActiveDaysSection(service.salon!.activeDays!),
//                        
//                       if ((service.salon!.reviewCount ?? 0) > 0)
//                         _buildApiReviewsSection(service.salon!),
//                     ],
//                   ],
//                 ),
//               ),
//         );
//       },
//     );
//   }
//
//   /// 🔥 MAIN CARD (Best UI)
//   Widget _buildDetailsCard(Service service) {
//     final bool hasDiscount =
//         service.discountType != null && service.oldPrice != null;
//
//     return Container(
//       margin: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 25,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// 🔥 IMAGE (NO PADDING)
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(
//               top: Radius.circular(18),
//             ),
//             child: Image.network(
//               service.image ?? '',
//               width: double.infinity,
//               height: 150,
//               fit: BoxFit.cover,
//             ),
//           ),
//
//           /// 🔥 CONTENT WITH PADDING
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// ICON + NAME + DISCOUNT
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: kPrimaryColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       child: Icon(Icons.spa, color: kPrimaryColor),
//                     ),
//                     const SizedBox(width: 12),
//
//                     /// NAME + SHORT DESC
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             service.name ?? '',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           if (service.shortDescription != null &&
//                               service.shortDescription!.isNotEmpty)
//                             Text(
//                               service.shortDescription!,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: Colors.grey[600],
//                                 height: 1.3,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//
//                     /// DISCOUNT
//                     if (hasDiscount)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 5),
//                         decoration: BoxDecoration(
//                           color: Colors.red.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           '-${((service.oldPrice! - service.price!) / service.oldPrice! * 100).toStringAsFixed(0)}%',
//                           style: const TextStyle(
//                             color: Colors.red,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 10),
//
//                 /// PRICE
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       'PKR ${service.price ?? 0}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: kPrimaryColor,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     if (hasDiscount)
//                       Text(
//                         'PKR ${service.oldPrice}',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[500],
//                           decoration: TextDecoration.lineThrough,
//                         ),
//                       ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 18),
//
//                 /// CHIPS
//                 Wrap(
//                   spacing: 10,
//                   runSpacing: 10,
//                   children: [
//                     if (service.duration != null)
//                       _buildChip(Icons.access_time, service.duration!),
//                     if (service.gender != null)
//                       _buildChip(
//                         service.gender == 'male' ? Icons.male : Icons.female,
//                         service.gender!,
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildChip(IconData icon, String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//       decoration: BoxDecoration(
//         color: kPrimaryColor.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: kPrimaryColor),
//           const SizedBox(width: 6),
//           Text(
//             text,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: kPrimaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// 🔥 PROFESSIONALS
//   Widget _buildProfessionalsSection(List<Professional> professionals) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Professionals",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             height: 160,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: professionals.length,
//               itemBuilder: (_, i) {
//                 final p = professionals[i];
//
//                 return Container(
//                   width: 130,
//                   margin: EdgeInsets.only(
//                     right: i == professionals.length - 1 ? 0 : 12,
//                   ),
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: Colors.grey.withOpacity(0.15),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.03),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       )
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircleAvatar(
//                         radius: 30,
//                         backgroundColor: kPrimaryColor.withOpacity(0.1),
//                         backgroundImage: p.image != null && p.image!.isNotEmpty
//                             ? NetworkImage(p.image!)
//                             : null,
//                         child: (p.image == null || p.image!.isEmpty)
//                             ? Icon(Icons.person, color: kPrimaryColor)
//                             : null,
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         p.name ?? '',
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// 🔥 DESCRIPTION
//   Widget _buildDescriptionSection(String description) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Main Description",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: Colors.grey.withOpacity(0.15),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.03),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 )
//               ],
//             ),
//             child: Text(
//               description,
//               style: TextStyle(
//                 height: 1.6,
//                 color: Colors.grey[700],
//                 fontSize: 13,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// 🔥 SALON
//   Widget _buildSalonSection(Salon salon) {
//     return _sectionWrapper(
//       // title: "Salon",
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: (salon.logo != null && salon.logo!.isNotEmpty)
//                 ? Image.network(salon.logo!,
//                     width: 60, height: 60, fit: BoxFit.cover)
//                 : (salon.image != null && salon.image!.isNotEmpty)
//                     ? Image.network(salon.image!,
//                         width: 60, height: 60, fit: BoxFit.cover)
//                     : Container(
//                         width: 60,
//                         height: 60,
//                         color: Colors.grey[200],
//                         child: const Icon(Icons.store),
//                       ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   salon.name ?? '',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   salon.address ?? '',
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   /// 🔥 REUSABLE SECTION WRAPPER
//   Widget _sectionWrapper({String? title, required Widget child}) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 15,
//           )
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (title != null) ...[
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//           ],
//           // const SizedBox(height: 10),
//           child,
//         ],
//       ),
//     );
//   }
//
//   /// 🔥 NEW PREMIUM SECTIONS
//   Widget _buildInfoSection(String title, String content) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.white, Colors.grey.shade50],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: kPrimaryColor.withOpacity(0.1), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: kPrimaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(Icons.info_outline, color: kPrimaryColor, size: 20),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF2D2D2D),
//                   letterSpacing: -0.3,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             content,
//             style: TextStyle(
//               fontSize: 14,
//               height: 1.6,
//               color: Colors.grey[700],
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAddressSection(String address) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.white, Colors.grey.shade50],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.location_on_outlined, color: Colors.blue[700], size: 20),
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'Address',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF2D2D2D),
//                   letterSpacing: -0.3,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             address,
//             style: TextStyle(
//               fontSize: 14,
//               height: 1.6,
//               color: Colors.grey[700],
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActiveDaysSection(List<ActiveDay> days) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.white, Colors.grey.shade50],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.green.withOpacity(0.2), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.access_time, color: Colors.green[700], size: 20),
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'Opening Hours',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF2D2D2D),
//                   letterSpacing: -0.3,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ...days.map((d) {
//             final dayName = (d.day ?? '').isNotEmpty
//                 ? d.day![0].toUpperCase() + d.day!.substring(1)
//                 : 'Unknown';
//
//             // AM/PM formatted time
//             String formatTime(String? time) {
//               if (time == null || time.isEmpty) return 'N/A';
//               try {
//                 final parsed = DateFormat("HH:mm:ss").parse(time);
//                 return DateFormat("h:mm a").format(parsed);
//               } catch (e) {
//                 try {
//                   final parsed2 = DateFormat("HH:mm").parse(time);
//                   return DateFormat("h:mm a").format(parsed2);
//                 } catch(e) {
//                   return time;
//                 }
//               }
//             }
//
//             final time = '${formatTime(d.openingTime)} - ${formatTime(d.closingTime)}';
//             return Container(
//               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//               margin: const EdgeInsets.only(bottom: 8),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey[200]!, width: 1),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     dayName,
//                     style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)),
//                   ),
//                   Text(
//                     time,
//                     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }
//
//   /// Reviews section that fetches from API
//   Widget _buildApiReviewsSection(Salon salon) {
//
//     // Trigger initial fetch if not yet loaded
//     if (!_reviewsLoaded && !_reviewsLoading && salon.id != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _fetchReviews(salon.id!);
//       });
//     }
//     // print("SALON RESPONSE: ${salon}");
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.white, Colors.grey.shade50],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.purple.withOpacity(0.2), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'Reviews${_reviewsLoaded ? ' ($_reviewsTotal)' : ' (${salon.reviewCount ?? 0})'}',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2D2D2D),
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//               ),
//
//               if (salon.averageRating != null && salon.averageRating! > 0)
//
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: Colors.amber.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${salon.averageRating}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.amber,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//
//           // Loading state
//           if (_reviewsLoading && _reviews.isEmpty) ...[
//             const SizedBox(height: 20),
//             const Center(
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color: kPrimaryColor,
//               ),
//             ),
//           ],
//
//           // Reviews list
//           if (_reviews.isNotEmpty) ...[
//             const SizedBox(height: 16),
//             Divider(color: Colors.purple.withOpacity(0.3), thickness: 1),
//             const SizedBox(height: 12),
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: _reviews.length,
//               separatorBuilder: (context, index) => Divider(
//                 height: 24,
//                 color: Colors.grey[200],
//                 thickness: 1,
//               ),
//               itemBuilder: (context, index) {
//                 return ReviewItem(review: _reviews[index]);
//               },
//             ),
//
//             // Load more button
//             if (_reviewsCurrentPage < _reviewsLastPage) ...[
//               const SizedBox(height: 16),
//               Center(
//                 child: _reviewsLoading
//                     ? const SizedBox(
//                         width: 24,
//                         height: 24,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: kPrimaryColor,
//                         ),
//                       )
//                     : TextButton.icon(
//                         onPressed: () => _fetchReviews(salon.id!, loadMore: true),
//                         icon: const Icon(Icons.expand_more_rounded, color: kPrimaryColor),
//                         label: const Text(
//                           'Load More Reviews',
//                           style: TextStyle(
//                             color: kPrimaryColor,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//               ),
//             ],
//           ],
//
//           // Empty state
//           if (_reviewsLoaded && _reviews.isEmpty) ...[
//             const SizedBox(height: 16),
//             Center(
//               child: Text(
//                 'No reviews yet',
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.grey[500],
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   /// 🔥 BUTTON (BOTTOM)
//   /// 🔥 BUTTON (BOTTOM) - BOOK NOW with Cart Logic
//   Widget _buildBookButton(Service service) {
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         child: Consumer<CartProvider>(
//           builder: (context, cart, child) {
//             final isInCart = cart.isInCart(service);
//
//             return SizedBox(
//               height: 52,
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () async {
//                   final success = cart.toggleItem(service);
//
//                   if (!success && cart.isDifferentSalon(service)) {
//                     final shouldClear = await showDialog<bool>(
//                       context: context,
//                       builder: (context) {
//                         return AlertDialog(
//                           title: const Text("Change Salon?"),
//                           content: Text(
//                             "Your cart contains items from ${cart.salonName ?? "another salon"}. "
//                             "Adding this service will clear your current cart. Continue?",
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, false),
//                               child: const Text("Cancel"),
//                             ),
//                             ElevatedButton(
//                               onPressed: () => Navigator.pop(context, true),
//                               child: const Text("Clear & Continue"),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//
//                     if (shouldClear == true) {
//                       cart.toggleItem(service, forceClear: true);
//                       cart.setSalonInfo(
//                         // service.salon
//                         service.salon?.id,
//                         service.salon?.name,
//                       );
//                     }
//                   } else if (success) {
//                     cart.setSalonInfo(
//                       service.salon?.id,
//                       service.salon?.name,
//                     );
//                   }
//
//                   setState(() {});
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isInCart ? Colors.grey : kPrimaryColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 icon: Icon(
//                   isInCart ? Icons.check_circle : Icons.arrow_forward_rounded,
//                 ),
//                 label: Text(
//                   isInCart ? "Added" : "Book Now",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//
//
//
// }
//
// class ReviewItem extends StatefulWidget {
//   final sd.Review review;
//   const ReviewItem({Key? key, required this.review}) : super(key: key);
//
//   @override
//   State<ReviewItem> createState() => _ReviewItemState();
// }
//
// class _ReviewItemState extends State<ReviewItem> {
//   bool _isExpanded = false;
//
//   String formatReviewDate(String? dateStr) {
//     if (dateStr == null || dateStr.isEmpty) return '';
//     try {
//       final parsed = DateTime.parse(dateStr);
//       return DateFormat("dd MMM yyyy").format(parsed);
//     } catch (e) {
//       if (dateStr.contains('T')) {
//         return dateStr.split('T').first;
//       }
//       return dateStr;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final comment = widget.review.comment ?? '';
//     final isLong = comment.length > 120;
//     final displayText = isLong && !_isExpanded
//         ? "${comment.substring(0, 120)}..."
//         : comment;
//
//     final userName = widget.review.user.name ??
//         '${widget.review.user.firstName ?? ''} ${widget.review.user.lastName ?? ''}'.trim();
//     final displayName = userName.isNotEmpty ? userName : 'Spot User';
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Container(
//                 width: 40,
//                 height: 40,
//                 color: Colors.grey[200],
//                 child: (widget.review.user.image != null &&
//                         widget.review.user.image!.isNotEmpty)
//                     ? Image.network(
//                         widget.review.user.image!,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) =>
//                             const Icon(Icons.person, color: kPrimaryColor),
//                       )
//                     : const Icon(Icons.person, color: kPrimaryColor),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     displayName,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   if (widget.review.createdAt != null) ...[
//                     const SizedBox(height: 2),
//                     Text(
//                       formatReviewDate(widget.review.createdAt),
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.grey[500],
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             Row(
//               children: List.generate(5, (index) {
//                 return Icon(
//                   index < (widget.review.rating ?? 0)
//                       ? Icons.star_rounded
//                       : Icons.star_outline_rounded,
//                   color: Colors.amber,
//                   size: 16,
//                 );
//               }),
//             ),
//           ],
//         ),
//         if (comment.isNotEmpty) ...[
//           const SizedBox(height: 10),
//           Text(
//             displayText,
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.grey[700],
//               height: 1.5,
//             ),
//           ),
//           if (isLong)
//             GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _isExpanded = !_isExpanded;
//                 });
//               },
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 6.0),
//                 child: Text(
//                   _isExpanded ? "Show less" : "Read more",
//                   style: const TextStyle(
//                     color: kPrimaryColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:app/api_services/services_api.dart';
import 'package:app/api_services/salon_detail_api.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/models/SalonDetailApiResponse.dart' as sd;
import 'package:app/constants.dart';
import 'package:provider/provider.dart';
import '../../../../models/home/Professional.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../components/cart_bottom_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:app/features/auth/utils/auth_manager.dart';
import 'package:app/features/auth/presentation/screens/auth/auth_screen.dart';
import 'package:app/screens/test_scroll/select_professionals.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;

  const ServiceDetailScreen({Key? key, required this.serviceId})
      : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late Future<Service> _serviceFuture;

  List<sd.Review> _reviews = [];
  int _reviewsCurrentPage = 1;
  int _reviewsLastPage = 1;
  int _reviewsTotal = 0;
  bool _reviewsLoading = false;
  bool _reviewsLoaded = false;

  @override
  void initState() {
    super.initState();
    _serviceFuture = ServicesApi().fetchServiceById(widget.serviceId);
  }

  Future<void> _fetchReviews(int salonId, {bool loadMore = false}) async {
    if (_reviewsLoading) return;
    setState(() => _reviewsLoading = true);

    try {
      final page = loadMore ? _reviewsCurrentPage + 1 : 1;
      final result = await ServicesApi().fetchSalonReviews(
        salonId: salonId,
        page: page,
      );

      setState(() {
        if (loadMore) {
          _reviews.addAll(result['reviews'] as List<sd.Review>);
        } else {
          _reviews = result['reviews'] as List<sd.Review>;
        }
        _reviewsCurrentPage = result['current_page'] as int;
        _reviewsLastPage = result['last_page'] as int;
        _reviewsTotal = result['total'] as int;
        _reviewsLoaded = true;
        _reviewsLoading = false;
      });
    } catch (e) {
      setState(() => _reviewsLoading = false);
      debugPrint('Error fetching reviews: $e');
    }
  }

  Future<void> _proceedToBooking() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (cartProvider.itemCount == 0) return;

    final token = await AuthManager.getToken();
    if (token == null) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign In Required'),
            content: const Text(
              'Please sign in to proceed with booking.',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign In'),
              ),
            ],
          );
        },
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectProfessionals(),
        settings: RouteSettings(
          arguments: {
            'cartItems': cartProvider.items,
            'salonName': cartProvider.salonName,
            'salonId': cartProvider.salonId,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Service>(
      future: _serviceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('No data')),
          );
        }

        final service = snapshot.data!;

        return Scaffold(
          backgroundColor: kScreenBg,
          // ── AppBar: transparent over hero image ──────────────────────
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                radius: 18,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CartBottomBar(onProceed: _proceedToBooking, buttonText: 'View Cart', proceedButtonText: 'Proceed to Booking'),
              _buildBookButton(service),
            ],
          ),

          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Full-bleed hero + details card fused together ──
                _buildHeroCard(service),

                const SizedBox(height: 4),

                if (service.professionals != null &&
                    service.professionals!.isNotEmpty)
                  _buildProfessionalsSection(service.professionals!),

                if (service.description?.isNotEmpty ?? false)
                  _buildDescriptionSection(service.description!),

                if (service.salon != null) ...[
                  if (service.salon!.about != null &&
                      service.salon!.about!.isNotEmpty)
                    _buildInfoSection("About Salon", service.salon!.about!),

                  if (service.salon!.address != null &&
                      service.salon!.address!.isNotEmpty)
                    _buildAddressSection(service.salon!.address!),

                  if (service.salon!.activeDays != null &&
                      service.salon!.activeDays!.isNotEmpty)
                    _buildActiveDaysSection(service.salon!.activeDays!),

                  if ((service.salon!.reviewCount ?? 0) > 0)
                    _buildApiReviewsSection(service.salon!),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // HERO CARD  (image + salon row + name/price/chips — all in one)
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildHeroCard(Service service) {
    final bool hasDiscount =
        service.discountType != null && service.oldPrice != null;
    final salon = service.salon;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero image ──────────────────────────────────────────────
          Stack(
            children: [
              Image.network(
                service.image ?? '',
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 260,
                  color: Colors.grey[100],
                  child: const Icon(Icons.broken_image_outlined,
                      size: 48, color: Colors.grey),
                ),
              ),
              // gradient scrim at bottom of image
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // discount pill on image
              if (hasDiscount)
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '-${((service.oldPrice! - service.price!) / service.oldPrice! * 100).toStringAsFixed(0)}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── Salon row ───────────────────────────────────────────────
          if (salon != null)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (salon.logo != null && salon.logo!.isNotEmpty)
                        ? Image.network(salon.logo!,
                        width: 44, height: 44, fit: BoxFit.cover)
                        : (salon.image != null && salon.image!.isNotEmpty)
                        ? Image.network(salon.image!,
                        width: 44, height: 44, fit: BoxFit.cover)
                        : Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.store_rounded,
                          color: kPrimaryColor, size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salon.name ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        if (salon.address != null &&
                            salon.address!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  salon.address!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
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

          // ── Divider ─────────────────────────────────────────────────
          if (salon != null)
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[100],
              indent: 16,
              endIndent: 16,
            ),

          // ── Service name + price ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.spa_rounded, color: kPrimaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          height: 1.2,
                        ),
                      ),
                      if (service.shortDescription != null &&
                          service.shortDescription!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          service.shortDescription!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Price row ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'PKR ${service.price ?? 0}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kPrimaryColor,
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: 10),
                  Text(
                    'PKR ${service.oldPrice}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Chips ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (service.duration != null)
                  _buildChip(Icons.access_time_rounded, service.duration!),
                if (service.gender != null)
                  _buildChip(
                    service.gender == 'male'
                        ? Icons.male_rounded
                        : Icons.female_rounded,
                    service.gender == 'male' ? 'Male' : 'Female',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: kPrimaryColor.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: kPrimaryColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // PROFESSIONALS
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildProfessionalsSection(List<Professional> professionals) {
    return _sectionCard(
      title: "Professionals",
      icon: Icons.people_alt_rounded,
      child: SizedBox(
        height: 130,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 2, right: 2),
          itemCount: professionals.length,
          itemBuilder: (_, i) {
            final p = professionals[i];
            return Container(
              width: 90,
              margin: EdgeInsets.only(right: i == professionals.length - 1 ? 0 : 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: kPrimaryColor.withOpacity(0.08),
                    backgroundImage: (p.image != null && p.image!.isNotEmpty)
                        ? NetworkImage(p.image!)
                        : null,
                    child: (p.image == null || p.image!.isEmpty)
                        ? Icon(Icons.person_rounded,
                        color: kPrimaryColor, size: 28)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.name ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // DESCRIPTION
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildDescriptionSection(String description) {
    return _sectionCard(
      title: "Description",
      icon: Icons.article_outlined,
      child: Text(
        description,
        style: TextStyle(
          fontSize: 13.5,
          height: 1.7,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // REUSABLE SECTION CARD
  // ─────────────────────────────────────────────────────────────────────
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Color? accentColor,
  }) {
    final color = accentColor ?? kPrimaryColor;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(title, icon, color),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // INFO (ABOUT)
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildInfoSection(String title, String content) {
    return _sectionCard(
      title: title,
      icon: Icons.info_outline_rounded,
      child: Text(
        content,
        style: TextStyle(
          fontSize: 13.5,
          height: 1.7,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // ADDRESS
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildAddressSection(String address) {
    return _sectionCard(
      title: "Address",
      icon: Icons.location_on_rounded,
      accentColor: Colors.blue[700],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              address,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.7,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // OPENING HOURS
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildActiveDaysSection(List<ActiveDay> days) {
    String formatTime(String? time) {
      if (time == null || time.isEmpty) return 'N/A';
      try {
        return DateFormat("h:mm a").format(DateFormat("HH:mm:ss").parse(time));
      } catch (_) {
        try {
          return DateFormat("h:mm a").format(DateFormat("HH:mm").parse(time));
        } catch (_) {
          return time;
        }
      }
    }

    return _sectionCard(
      title: "Opening Hours",
      icon: Icons.schedule_rounded,
      accentColor: Colors.green[700],
      child: Column(
        children: days.map((d) {
          final dayName = (d.day ?? '').isNotEmpty
              ? d.day![0].toUpperCase() + d.day!.substring(1)
              : 'Unknown';
          final time =
              '${formatTime(d.openingTime)} – ${formatTime(d.closingTime)}';

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.18)),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // REVIEWS
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildApiReviewsSection(Salon salon) {
    if (!_reviewsLoaded && !_reviewsLoading && salon.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchReviews(salon.id!);
      });
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withOpacity(0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // HEADER ROW (Reviews + Rating)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _reviewsLoaded
                    ? 'Reviews ($_reviewsTotal)'
                    : 'Reviews (${salon.reviewCount ?? 0})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),

              if (salon.averageRating != null && salon.averageRating! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        '${salon.averageRating}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92600A),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // LOADING STATE
          if (_reviewsLoading && _reviews.isEmpty) ...[
            const SizedBox(height: 20),
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: kPrimaryColor,
              ),
            ),
          ],

          // REVIEWS LIST
          if (_reviews.isNotEmpty) ...[
            Divider(color: Colors.grey[100], thickness: 1, height: 1),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reviews.length,
              separatorBuilder: (_, __) => Divider(
                height: 20,
                color: Colors.grey[100],

                thickness: 1,
              ),
              itemBuilder: (_, i) => ReviewItem(review: _reviews[i]),
            ),

            // LOAD MORE
            if (_reviewsCurrentPage < _reviewsLastPage) ...[
              const SizedBox(height: 12),
              Center(
                child: _reviewsLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kPrimaryColor,
                  ),
                )
                    : OutlinedButton.icon(
                  onPressed: () =>
                      _fetchReviews(salon.id!, loadMore: true),
                  icon: const Icon(Icons.expand_more_rounded, size: 18),
                  label: const Text('Load More'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    side: BorderSide(
                        color: kPrimaryColor.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ],

          // EMPTY STATE
          if (_reviewsLoaded && _reviews.isEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No reviews yet',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // BOOK BUTTON
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildBookButton(Service service) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[100]!)),
        ),
        child: Consumer<CartProvider>(
          builder: (context, cart, child) {
            final isInCart = cart.isInCart(service);

            return SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = cart.toggleItem(service);

                  if (!success && cart.isDifferentSalon(service)) {
                    final shouldClear = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text("Change Salon?"),
                        content: Text(
                          "Your cart has items from ${cart.salonName ?? "another salon"}. "
                              "Adding this service will clear your cart. Continue?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor),
                            child: const Text("Clear & Add"),
                          ),
                        ],
                      ),
                    );

                    if (shouldClear == true) {
                      cart.toggleItem(service, forceClear: true);
                      cart.setSalonInfo(
                          service.salon?.id, service.salon?.name);
                    }
                  } else if (success) {
                    cart.setSalonInfo(
                        service.salon?.id, service.salon?.name);
                  }

                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart ? Colors.grey[300] : kPrimaryColor,
                  foregroundColor:
                  isInCart ? Colors.grey[700] : Colors.white,
                  elevation: isInCart ? 0 : 2,
                  shadowColor: kPrimaryColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isInCart
                          ? Icons.check_circle_rounded
                          : Icons.calendar_month_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isInCart ? "Added to Cart" : "Book Now",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// REVIEW ITEM
// ─────────────────────────────────────────────────────────────────────────
class ReviewItem extends StatefulWidget {
  final sd.Review review;
  const ReviewItem({Key? key, required this.review}) : super(key: key);

  @override
  State<ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  bool _isExpanded = false;

  String formatReviewDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr.contains('T') ? dateStr.split('T').first : dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.review.comment ?? '';
    final isLong = comment.length > 120;
    final displayText =
    isLong && !_isExpanded ? "${comment.substring(0, 120)}..." : comment;

    final userName = widget.review.user.name ??
        '${widget.review.user.firstName ?? ''} ${widget.review.user.lastName ?? ''}'
            .trim();
    final displayName = userName.isNotEmpty ? userName : 'Spot User';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 40,
                height: 40,
                color: kPrimaryColor.withOpacity(0.08),
                child: (widget.review.user.image != null &&
                    widget.review.user.image!.isNotEmpty)
                    ? Image.network(widget.review.user.image!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.person_rounded, color: kPrimaryColor))
                    : Icon(Icons.person_rounded, color: kPrimaryColor),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  if (widget.review.createdAt != null)
                    Text(
                      formatReviewDate(widget.review.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                ],
              ),
            ),
            // star rating
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                  const SizedBox(width: 3),
                  Text(
                    '${widget.review.rating ?? 0}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92600A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (comment.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          if (isLong)
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _isExpanded ? "Show less" : "Read more",
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ],


    );

  }
}