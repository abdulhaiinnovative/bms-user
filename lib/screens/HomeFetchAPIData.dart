import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/viewmodels/home/home_view_model.dart';

class HomeFetchAPIData extends StatefulWidget {
  static String routeName = "/home_screen";

  const HomeFetchAPIData({super.key});

  @override
  _HomeFetchAPIDataState createState() => _HomeFetchAPIDataState();
}

class _HomeFetchAPIDataState extends State<HomeFetchAPIData> {
  @override
  void initState() {
    super.initState();
    // Load home data using ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home Page.'),
            backgroundColor: Colors.blueAccent,
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.isError
                  ? Center(
                      child:
                          Text(viewModel.errorMessage ?? 'An error occurred'))
                  : _buildContent(viewModel),
        );
      },
    );
  }

  Widget _buildContent(HomeViewModel viewModel) {
    final type_1 = viewModel.sliders;
    final type_2 = viewModel.categories;
    final type_3 = viewModel.salons;
    final type_4 = viewModel.deals;
    final type_5 = viewModel.services;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Refresh Button
          Center(
            child: ElevatedButton.icon(
              onPressed: () => viewModel.loadHomeData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Data'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sliders (type_1)

          if (type_1?.isNotEmpty ?? false)
            if (type_1![0].data?.isNotEmpty ?? false)
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
                  ...type_1![0].data.map((slider) {
                    if (slider.image == null || slider.image!.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    log('Rendering slider image: ${slider.image}');
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          slider.image!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            log('Failed to load slider image: ${slider.image}, error: $error');
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
                      if (salon.id == null) {
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
                            'Location: ${salon.address ?? 'N/A'}\nRating: ${salon.averageRating ?? 0} (${salon.reviewCount ?? 0} reviews)',
                          ),
                          trailing: Icon(
                            salon.isFavourite ?? false
                                ? Icons.favorite
                                : Icons.favorite_border,
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
                      log('Deal: $deal'); // Debug log
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(deal.name ?? 'No Deal Name'),
                          subtitle: Text(
                            'Price: ${deal.price ?? deal.totalPrice ?? 'N/A'}\nValid: ${deal.startDate ?? 'N/A'} to ${deal.endDate ?? 'N/A'}',
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
                            service.discountType != null ? 'Discounted' : '',
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
    );
  }
}
