import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/screens/test/salon_details_scrolling_tabs_effect_b.dart';
import '../screens/top_salons_screen.dart';
import '../../../../api_services/salon_detail_api.dart';
import '../../../../features/auth/utils/auth_manager.dart';
import '../../../search/presentation/screens/search_service_screen_new.dart';

import 'section_title.dart';

class SalonDashboard extends StatelessWidget {
  final List<TopSalonSection> type3;

  const SalonDashboard({
    Key? key,
    required this.type3,
  }) : super(key: key);

  /// Determine the salon filter mode from the section heading
  String? _getSalonFilterFromHeading(String heading) {
    final lower = heading.toLowerCase();
    if (lower.contains('popular')) return 'popular';
    if (lower.contains('top')) return 'top_rated';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: type3.map((section) {
        print("SECTION: ${section.heading}");
        return Container(
          height: 280,
          margin: const EdgeInsets.only(bottom: 15),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: SectionTitle(
                  title: section.heading,
                  press: () {
                    final salonFilter = _getSalonFilterFromHeading(section.heading);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchServiceScreenNew(),
                        settings: RouteSettings(
                          arguments: {
                            'initialTab': 2, // Salon tab
                            'salonFilter': salonFilter,
                          },
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
                  itemCount: section.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = section.data[index];
                    return SalonCard(
                      id: item.id.toString(),
                      isFavourite: item.isFavourite ?? false,
                      title: item.name ?? 'No Name',
                      image: item.image ?? item.image ?? salonImage,
                      desc: item.about ?? 'No description available',
                      address: item.address ?? "",
                      area: item.area ?? "",
                      rating: item.averageRating ?? 0,
                      reviews: item.reviewCount ?? 0,
                      logo: item.logo ?? '',
                      onFavChanged: (bool newFavStatus) {
                        item.isFavourite = newFavStatus;
                      },
                      press: () {
                        //working
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SalonDetailsScrollingTabsEffectB(),
                            settings: RouteSettings(arguments: '${item.id}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class FavoriteHeartWidget extends StatefulWidget {
  final String salonId;
  final bool initialIsFavourite;
  final double top;
  final double left;
  final double? right;
  final ValueChanged<bool>? onFavChanged;

  const FavoriteHeartWidget({
    Key? key,
    required this.salonId,
    required this.initialIsFavourite,
    this.top = 10,
    this.left = 10,
    this.right,
    this.onFavChanged,
  }) : super(key: key);

  @override
  State<FavoriteHeartWidget> createState() => _FavoriteHeartWidgetState();
}

class _FavoriteHeartWidgetState extends State<FavoriteHeartWidget> {
  late bool isFavourite;
  bool isToggling = false;

  @override
  void initState() {
    super.initState();
    isFavourite = widget.initialIsFavourite;
  }

  @override
  void didUpdateWidget(covariant FavoriteHeartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIsFavourite != oldWidget.initialIsFavourite) {
      isFavourite = widget.initialIsFavourite;
    }
  }

  Future<void> _toggleFavourite() async {
    if (isToggling) return;
    final previousStatus = isFavourite;
    setState(() => isToggling = true);
    try {
      final token = await AuthManager.getToken();
      final salonApi = SalonDetailAPI();
      final newStatus = await salonApi.toggleFavorite(
          int.parse(widget.salonId), token);

      if (newStatus != null) {
        setState(() {
          isFavourite = newStatus;
        });
        widget.onFavChanged?.call(newStatus);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  newStatus ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  newStatus ? 'Added to favorites' : 'Removed from favorites',
                ),
              ],
            ),
            backgroundColor: newStatus ? Colors.green : Colors.grey[700],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          isFavourite = previousStatus;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to update favorite status'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      setState(() {
        isFavourite = previousStatus;
      });
    } finally {
      if (mounted) setState(() => isToggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.right == null ? widget.left : null,
      right: widget.right,
      child: GestureDetector(
        onTap: _toggleFavourite,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.purple.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isToggling
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                )
              : Icon(
                  isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFavourite ? Colors.red : Colors.purple.withOpacity(0.5),
                  size: 14,
                ),
        ),
      ),
    );
  }
}

class SalonCard extends StatelessWidget {
  const SalonCard({
    Key? key,
    required this.id,
    required this.isFavourite,
    required this.title,
    required this.image,
    required this.desc,
    required this.address,
    required this.area,
    required this.rating,
    required this.reviews,
    required this.press, required this.logo,
    this.onFavChanged,
  }) : super(key: key);

  final String id;
  final bool isFavourite;
  final ValueChanged<bool>? onFavChanged;

  final String title, image, address, area,logo;
  final String desc;
  final int rating, reviews;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 4, bottom: 8),
      child: GestureDetector(
        onTap: press,
        child: Container(
          width: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: kPrimaryColor.withOpacity(0.15),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 120,
                      child: image.isNotEmpty
                          ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.store,
                              size: 45,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                          : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.store,
                          size: 45,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  // Floating Rating Badge Overlay (Top Right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFB800),
                            size: 13,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (reviews > 0) ...[
                            const SizedBox(width: 2),
                            Text(
                              '($reviews)',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  // Favorite Heart Button (Top Left)
                  FavoriteHeartWidget(
                    salonId: id,
                    initialIsFavourite: isFavourite,
                    top: 10,
                    left: 10,
                    onFavChanged: onFavChanged,
                  ),
                ],
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Salon Name with Logo
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            // shape: BoxShape.circle,
                            border: Border.all(
                              color: kPrimaryColor.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                            child: Builder(builder: (context) {
                              final String salonLogoUrl =
                              logo.isNotEmpty ? logo : image;

                              if (salonLogoUrl.isNotEmpty) {
                                return Image.network(
                                  salonLogoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return const Icon(Icons.store,
                                        size: 14, color: Colors.grey);
                                  },
                                );
                              }

                              return const Icon(Icons.store,
                                  size: 14, color: Colors.grey);
                            }),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A1A),
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (area.isNotEmpty) ...[
                                const SizedBox(height: 1),
                                Text(
                                  area,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Address with Location Icon inside rounded grey container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: kPrimaryColor.withOpacity(0.85),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address.isNotEmpty ? address : "No address listed",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ), // End Content Section
            ], // End outer Column's children (Stack and Content)
          ), // End outer Column
        ), // End Container
      ), // End GestureDetector
    ); // End Padding and return
  }
}
