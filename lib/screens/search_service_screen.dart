import 'package:app/components/book_now.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/SalonMain.dart';
import '../screens/search_final/search_provider_new.dart';
import 'services/services_header.dart';


class SearchServiceScreen extends StatefulWidget {
  const SearchServiceScreen({super.key});

  @override
  _SearchServiceScreenState createState() => _SearchServiceScreenState();
}

class _SearchServiceScreenState extends State<SearchServiceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProviderNew>(context);

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                surfaceTintColor: Colors.white,
                pinned: false,
                floating: true,
                snap: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ServicesHeader(tabController: _tabController),
                ),
                expandedHeight: 190,
                backgroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController, // Attach the controller
            children: [
              CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        if (searchProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (searchProvider.services.isEmpty) {
                          return const Center(child: Text("No services found"));
                        }
                        final service = searchProvider.services[index];
                        return Container(
                          padding: const EdgeInsets.fromLTRB(2, 2, 1, 1),
                          child: ServicesCard(
                            title: service.name ?? '',
                            price: (service.price ?? 0).toDouble(),
                            discountAmount: (service.discountAmount ?? 0).toDouble(),
                            discountType: service.discountType ?? "",
                            oldPrice: (service.oldPrice ?? 0).toDouble(),
                            gender: service.gender ?? '',
                            duration: service.duration ?? '',
                            salon: null, // Service model doesn't have SalonMain, it has Salon
                            desc: service.description ?? '',
                            press: () {
                              ///Navigator.pushNamed(context, ServicesScreen.routeName);
                            },
                          ),
                        );
                      },
                      childCount: searchProvider.services.length,
                    ),
                  ),
                ],
              ),
              CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        if (searchProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (searchProvider.salons.isEmpty) {
                          return const Center(child: Text("No salons found"));
                        }
                        final salon = searchProvider.salons[index];
                        return Container(
                          padding: const EdgeInsets.fromLTRB(2, 2, 1, 1),
                          child: SalonCard(
                            name: salon.name ?? '',
                            image: logo,
                            address: salon.address ?? '',
                            about: salon.about ?? '',
                            average_rating: (salon.averageRating ?? 0).toDouble(),
                            review_count: salon.reviewCount ?? 0,
                            is_favourite: salon.isFavourite ?? false,
                            press: () {
                              ///Navigator.pushNamed(context, ServicesScreen.routeName);
                            },
                          ),
                        );
                      },
                      childCount: searchProvider.salons.length,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SalonCard extends StatelessWidget {
  const SalonCard({
    Key? key,
    required this.name,
    required this.image,
    required this.address,
  required this.about,
  required this.average_rating,
  required this.review_count,
    required this.is_favourite,
    required this.press
  }) : super(key: key);

  final String name, image, address, about;
  final int  review_count;
  final double average_rating;
  final bool is_favourite;

  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 0, right: 10),
      child: Container(
        height: 180,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: kShadow,
              blurRadius: 0.0,
              offset: Offset(0.0, 0.0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: true // product.isFavourite
                          ? kPrimaryColor.withOpacity(0.15)
                          : kSecondaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/Heart Icon_2.svg",
                      colorFilter: const ColorFilter.mode(
                          true // product.isFavourite
                              ? Color(0xFFFF4848)
                              : Color(0xFFDBDEE4),
                          BlendMode.srcIn),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 5),
            Text(
              about,
              maxLines: 2,
              style: const TextStyle(
                color: kPrimaryColor,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              address,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            const Spacer(),
            Row(
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < average_rating ? Icons.star_rounded : Icons.star_border_rounded, // Filled or empty star
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(width: 15),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.reviews, color: kPrice, size: 20), // Review Icon
                    const SizedBox(width: 5), // Spacing
                    Text(
                      '$review_count Reviews', // Better formatting
                      style: const TextStyle(
                        color: kPrice,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ServicesCard extends StatelessWidget {
  const ServicesCard({
    Key? key,
    required this.title,
    required this.price,
    required this.discountAmount,
    required this.discountType,
    required this.oldPrice,
    required this.gender,
    required this.duration,
    required this.salon,
    required this.desc,
    required this.press,
  }) : super(key: key);

  final String title, gender, duration, discountType;
  final double price, discountAmount, oldPrice;
  final String desc;
  final SalonMain? salon;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 0, right: 10),
      child: Container(
        height: 180,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: kShadow,
              blurRadius: 0.0,
              offset: Offset(0.0, 0.0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: true // product.isFavourite
                          ? kPrimaryColor.withOpacity(0.15)
                          : kSecondaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/Heart Icon_2.svg",
                      colorFilter: const ColorFilter.mode(
                          true // product.isFavourite
                              ? Color(0xFFFF4848)
                              : Color(0xFFDBDEE4),
                          BlendMode.srcIn),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 5),
            Text(
              desc,
              style: const TextStyle(
                color: kPrimaryColor,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const Text(
              '30 min - 1 hr',
              style: TextStyle(
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(
                  Icons.cut_rounded,
                  color: Colors.black38,
                  size: 20,
                ),
                SizedBox(width: 5),
                Text(
                  '------',
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  'Rs: $price',
                  style: const TextStyle(
                      color: kPrice, fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 15),
                const Text(
                  'Rs: ----',
                  style: TextStyle(
                    color: kBeforeDiscount,
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                const BookNow()
                ///SalePercentage(off: 18, type: '',),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
