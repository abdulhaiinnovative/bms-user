import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/HomePageResponse.dart'; // For Service
import 'package:app/features/home/presentation/widgets/section_title.dart';
import 'package:app/features/home/presentation/widgets/services_dashboard.dart'; // For ServicesCard
import 'package:app/features/search/presentation/screens/search_service_screen_new.dart';

class FeaturedServicesDashboard extends StatelessWidget {
  final List<Service> services;

  const FeaturedServicesDashboard({Key? key, required this.services}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 340,
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: SectionTitle(
              title: "Featured Services",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchServiceScreenNew(),
                    settings: const RouteSettings(
                      arguments: {'initialTab': 0},
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: services.length,
              itemBuilder: (BuildContext context, int index) {
                final item = services[index];

                return ServicesCard(
                  service: item,
                  title: item.name ?? 'No Title',
                  image: item.image?.trim() ?? "", 
                  salon: item.salon,
                  desc: item.shortDescription ?? item.name ?? '',
                  width: 180,
                  isFeatured: true, // Show featured badge
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
