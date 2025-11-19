import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../api_services/salon_detail_api.dart';
import '../models/SalonDetailApiResponse.dart';
import '../models/home/ServiceData.dart';
import '../models/home/DealData.dart';
import '../models/salon/ReviewData.dart';
import '../models/home/Professional.dart';
import '../models/salon/AboutData.dart';

class SalonFetchAPIData extends StatefulWidget {
  static const String routeName = '/salon_fetch_api_data';

  const SalonFetchAPIData({super.key});

  @override
  _SalonFetchAPIDataState createState() => _SalonFetchAPIDataState();
}

class _SalonFetchAPIDataState extends State<SalonFetchAPIData> {
  final SalonDetailAPI _apiService = SalonDetailAPI();
  int? _salonId;
  late Future<SalonData?> _salonDataFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _salonId = ModalRoute.of(context)?.settings.arguments as int? ?? 1;
    _salonDataFuture = _apiService.fetchSalonDetailData(_salonId.toString());
  }

  void _refreshData() {
    setState(() {
      _salonDataFuture = _apiService.fetchSalonDetailData(_salonId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salon Details'),
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        tooltip: 'Refresh Data',
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.refresh),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<SalonData?>(
          future: _salonDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              developer.log('Snapshot error: ${snapshot.error}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load data'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.data == null) {
              developer.log('Snapshot data is null');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No response data available'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final salonData = snapshot.data;
            if (salonData == null) {
              developer.log('SalonData is null');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No salon data available'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salon Images
                if (salonData.images.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Salon Images',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...salonData.images.map((imageUrl) {
                        developer.log('Rendering salon image: $imageUrl');
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                developer.log(
                                    'Failed to load image: $imageUrl, error: $error');
                                return const Text(
                                  'Failed to load image',
                                  style: TextStyle(color: Colors.red),
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                // Salon Header
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salonData.name ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${salonData.star ?? 0} Stars',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gender: ${salonData.gender ?? 'N/A'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Location: ${salonData.location?.address ?? 'N/A'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Sections
                if (salonData.sections?.isNotEmpty ?? false)
                  ...salonData.sections!.map((section) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (section.data?.isNotEmpty ?? false)
                          ...section.data!.map((item) {
                            // Services (type: 2)
                            if (section.type == '2' && item is ServiceData) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(item.name ?? 'N/A'),
                                  subtitle: Text(
                                    'Price: ${item.price ?? 'N/A'}\n'
                                    'Duration: ${item.duration ?? 'N/A'}',
                                  ),
                                  trailing: Text(item.discount_type ?? ''),
                                ),
                              );
                            }
                            // Deals (type: 6)
                            else if (section.type == '6' && item is DealData) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(item.name ?? 'N/A'),
                                  subtitle: Text(
                                    'Total Price: ${item.total_price?.toStringAsFixed(2) ?? 'N/A'}\n'
                                    'Valid: ${item.start_date ?? 'N/A'} to ${item.end_date ?? 'N/A'}',
                                  ),
                                  trailing: Text(item.discount_type ?? ''),
                                ),
                              );
                            }
                            // Reviews (type: 3)
                            else if (section.type == '3' &&
                                item is ReviewData) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(item.user?.name ?? 'Anonymous'),
                                  subtitle: Text(item.comment ?? 'No comment'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      item.rating ?? 0,
                                      (index) => const Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                    ),
                                  ),
                                ),
                              );
                            }
                            // Staff (type: 4)
                            else if (section.type == '4' &&
                                item is Professional) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(item.name ?? 'N/A'),
                                  subtitle: Text(
                                      'Experience: ${item.experience ?? 'N/A'}'),
                                  leading: item.image != null
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(item.image!),
                                          onBackgroundImageError:
                                              (error, stackTrace) {
                                            developer.log(
                                                'Failed to load staff image: ${item.image}, error: $error');
                                          },
                                        )
                                      : const CircleAvatar(
                                          child: Icon(Icons.person)),
                                ),
                              );
                            }
                            // About (type: 5)
                            else if (section.type == '5' && item is AboutData) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Address: ${item.address ?? 'N/A'}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      if (item.opening_timings?.isNotEmpty ??
                                          false) ...[
                                        const Text(
                                          'Opening Hours:',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        ...item.opening_timings!
                                            .map((timing) => Text(
                                                  '${timing.day?.capitalize() ?? 'N/A'}: '
                                                  '${timing.opening_time ?? 'N/A'} - ${timing.closing_time ?? 'N/A'}',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                )),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }
                            developer.log(
                                'Unknown section item: $item, type: ${section.type}');
                            return const SizedBox.shrink();
                          }).toList(),
                        if (section.data?.isEmpty ?? true)
                          const Text(
                            'No section data available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                if (salonData.sections?.isEmpty ?? true)
                  const Text(
                    'No sections available',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Extension to capitalize string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
