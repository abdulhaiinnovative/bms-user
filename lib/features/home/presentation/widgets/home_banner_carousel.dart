// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../../../../constants.dart';
// import '../viewmodels/home_slider_response.dart';

// class HomeCarouselSlider extends StatefulWidget {
//   final List<SliderImageItem> images;
//   final Function(int id)? onImageTap;

//   const HomeCarouselSlider({super.key, required this.images, this.onImageTap});

//   @override
//   State<HomeCarouselSlider> createState() => _HomeCarouselSliderState();
// }

// class _HomeCarouselSliderState extends State<HomeCarouselSlider> {
//   int activeIndex = 0;

//   void _openLink(String? url) async {
//     if (url == null || url.isEmpty) return;

//     final uri = Uri.parse(url);
//     print("PRINT API ${uri.toString()}");
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         CarouselSlider.builder(
//           itemCount: widget.images.length,
//           itemBuilder: (context, index, realIndex) {
//             final item = widget.images[index];

//             return GestureDetector(
//               onTap: () {
//                 if (widget.onImageTap != null &&
//                     item.id != null &&
//                     item.link != null) {
//                   widget.onImageTap!(item.id!);
//                 }
//                 _openLink(item.link);
//               },
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child:
//                     item.imageUrl.isNotEmpty && item.imageUrl.startsWith('http')
//                         ? Image.network(
//                             item.imageUrl,
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                             loadingBuilder: (context, child, progress) {
//                               if (progress == null) return child;
//                               return const Center(
//                                   child: CircularProgressIndicator());
//                             },
//                             errorBuilder: (context, error, stackTrace) {
//                               return Container(
//                                 color: Colors.grey[200],
//                                 child: const Icon(Icons.broken_image),
//                               );
//                             },
//                           )
//                         : Container(
//                             color: Colors.grey[200],
//                             child: const Icon(Icons.image_not_supported),
//                           ),
//               ),
//             );
//           },
//           options: CarouselOptions(
//             height: 180,
//             autoPlay: true,
//             enlargeCenterPage: true,
//             viewportFraction: 0.9,
//             onPageChanged: (index, reason) {
//               setState(() => activeIndex = index);
//             },
//           ),
//         ),
//         const SizedBox(height: 10),
//         AnimatedSmoothIndicator(
//           activeIndex: activeIndex,
//           count: widget.images.length,
//           effect: ExpandingDotsEffect(
//             dotHeight: 6,
//             dotWidth: 6,
//             activeDotColor: kPrimaryColor,
//             dotColor: Colors.grey.shade300,
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants.dart';
import '../viewmodels/home_slider_response.dart';

class HomeCarouselSlider extends StatefulWidget {
  final List<SliderImageItem> images;
  final Function(int id)? onImageTap;

  const HomeCarouselSlider({super.key, required this.images, this.onImageTap});

  @override
  State<HomeCarouselSlider> createState() => _HomeCarouselSliderState();
}

class _HomeCarouselSliderState extends State<HomeCarouselSlider> {
  int activeIndex = 0;

  void _openLink(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.images.length,
          itemBuilder: (context, index, realIndex) {
            final item = widget.images[index];

            return GestureDetector(
              onTap: () {
                if (widget.onImageTap != null &&
                    item.id != null &&
                    item.link != null) {
                  widget.onImageTap!(item.id!);
                }
                _openLink(item.link);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // Subtle shadow under each banner card
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: item.imageUrl.isNotEmpty &&
                          item.imageUrl.startsWith('http')
                      ? Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: kPrimaryColor,
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 160,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            autoPlayCurve: Curves.easeInOut,
            enlargeCenterPage: true,
            enlargeFactor: 0.12,
            viewportFraction: 0.88,
            onPageChanged: (index, reason) {
              setState(() => activeIndex = index);
            },
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSmoothIndicator(
          activeIndex: activeIndex,
          count: widget.images.length,
          effect: ExpandingDotsEffect(
            dotHeight: 5,
            dotWidth: 5,
            expansionFactor: 3,
            spacing: 5,
            activeDotColor: kPrimaryColor,
            dotColor: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(Icons.image_outlined, size: 36, color: Colors.grey[300]),
      ),
    );
  }
}