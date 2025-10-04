import 'dart:developer';

import 'package:app/models/home/DealData.dart';
import 'package:app/models/home/SalonData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api_services/homes_detail_api.dart';
import '../api_services/salons_detail_api.dart';
import '../models/home/Type1.dart';
import '../models/home/Type2.dart';
import '../models/home/Type3.dart';
import '../models/home/Type4.dart';
import '../models/home/Type5.dart';



class HomeFetchAPIData extends StatefulWidget {
  static String routeName = "/home_screen";

  const HomeFetchAPIData({super.key});

  @override
  _HomeFetchAPIDataState createState() => _HomeFetchAPIDataState();
}

class _HomeFetchAPIDataState extends State<HomeFetchAPIData> {
  final HomesDetailAPI _apiService = HomesDetailAPI();
  late final List<Type1>? type_1;
  late final List<Type2>? type_2;
  late final List<Type3>? type_3;
  late final List<Type4>? type_4;
  late final List<Type5>? type_5;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _apiService.fetchHomePageData();

    setState(() {
      _isLoading = false;
      if (response == null || response.response?.data == null) {
        _errorMessage = 'Failed to load data';
      } else {
        type_1 = response.response!.data!.type_1;
        type_2 = response.response!.data!.type_2;
        type_3 = response.response!.data!.type_3;
        type_4 = response.response!.data!.type_4;
        type_5 = response.response!.data!.type_5;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page.'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Refresh Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _fetchData,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),




            // Sliders (type_1)

            if (type_1?.isNotEmpty ?? false)
              if (type_1![0].data?.isNotEmpty ?? false)
                if (type_1![0].data![0].images?.isNotEmpty ?? false)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Slider Images',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...type_1![0].data![0].images!.map((imageUrl) {
                        log('Rendering image: $imageUrl');
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrl,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                log('Failed to load image: $imageUrl, error: $error');
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
            if (type_1?.isEmpty ?? true)
              const Text(
                'No slider images available',
                style: TextStyle(color: Colors.grey),
              ),

            const SizedBox(height: 20),







            // type_ 2 (Placeholder, as JSON is empty)
            if (type_2 != null && type_2!.isNotEmpty)
              ...type_2!.map((section) {
                log('Rendering type_2 section: ${section.heading}'); // Debug log
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.heading ?? 'type_ 2',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (section.data != null && section.data!.isNotEmpty)
                      ...section.data!.map((item) {
                        log('type_2 item: $item'); // Debug log
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text('Item: ${item.toString()}'),
                            subtitle: const Text('No specific data available'),
                          ),
                        );
                      }),
                    const SizedBox(height: 20),
                  ],
                );
              }),

            // Top Salons (type__3)
            if (type_3 != null && type_3!.isNotEmpty)
              ...type_3!.map((section) {
                log('Rendering Top Salons section: ${section.heading}'); // Debug log
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.heading ?? 'Top Salons..',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (section.data != null && section.data!.isNotEmpty)
                      ...section.data!.map((salon) {
                        if (salon is! SalonData || salon.id == null) {
                          log('Invalid Salon: $salon');
                          return const SizedBox.shrink();
                        }
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: salon.image != null
                                ? Image.network(
                              salon.image!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.store),
                            )
                                : const Icon(Icons.store),
                            title: Text(salon.name ?? 'N/A'),
                            subtitle: Text(
                              'Location: ${salon.address ?? 'N/A'}\nRating: ${salon.average_rating ?? 0} (${salon.review_count ?? 0} reviews)',
                            ),
                            trailing: Icon(
                              salon.is_favourite ?? false ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 20),
                  ],
                );
              }),

            // Deals (type__4)
            if (type_4 != null && type_4!.isNotEmpty)
              ...type_4!.map((section) {
                log('Rendering Deals section: ${section.heading}'); // Debug log
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.heading ?? 'Deals',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (section.data != null && section.data!.isNotEmpty)
                      ...section.data!.map((deal) {
                        if (deal is! DealData) {
                          log('Invalid Deal: $deal');
                          return const SizedBox.shrink();
                        }
                        log('Deal: $deal'); // Debug log
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(deal.name ?? 'No Deal Name'),
                            subtitle: Text(
                              'Price: ${deal.price ?? deal.total_price ?? 'N/A'}\nValid: ${deal.start_date ?? 'N/A'} to ${deal.end_date ?? 'N/A'}',
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 20),
                  ],
                );
              }),



            if (type_5?.isNotEmpty ?? false)
              ...type_5!.map((section) {
                log('Rendering Services section: ${section.heading}');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.heading ?? 'Services',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (section.data?.isNotEmpty ?? false)
                      ...section.data!.map((service) {
                        if (service.id == null) {
                          log('Invalid Service: $service');
                          return const SizedBox.shrink();
                        }
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(service.name ?? 'N/A'),
                            subtitle: Text(
                              'Price: ${service.price ?? 'N/A'}\n'
                                  'Duration: ${service.duration ?? 'N/A'}\n'
                                  'Salon: ${service.salon?.name ?? 'N/A'}',
                            ),
                            trailing: Text(
                              service.discount_type != null ? 'Discounted' : '',
                            ),
                          ),
                        );
                      }).toList(),
                    if (section.data?.isEmpty ?? true)
                      const Text(
                        'No services available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),


            if (type_5?.isEmpty ?? true)
              const Text(
                'No service sections available',
                style: TextStyle(color: Colors.grey),
              ),



          ],
        ),
      ),
    );
  }
}