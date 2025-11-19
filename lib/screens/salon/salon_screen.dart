import 'dart:developer';

import 'package:app/models/HomePageResponse.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import 'package:app/features/home/presentation/widgets/deals_dashboard.dart';
import '../products/products_screen.dart';

class SalonScreen extends StatelessWidget {
  const SalonScreen({super.key});

  static String routeName = "/salon";

  static const List<String> imageUrls = [
    'https://i.pinimg.com/564x/33/5d/60/335d60b4559e4623f2406bc3b0e30ffd.jpg',
    'https://i.pinimg.com/564x/a8/cf/11/a8cf11b19d30ada3f35c0535aa420853.jpg',
    'https://i.pinimg.com/564x/41/6d/4a/416d4aacc7593be30c5ea16d0bc7c954.jpg',
    'https://i.pinimg.com/564x/8a/06/ca/8a06ca8250e77b8923b98fe7ee4105c7.jpg',
    'https://i.pinimg.com/564x/cd/54/60/cd54605d5052021a7c32fb93cef760ce.jpg',
    'https://i.pinimg.com/564x/e0/d0/f0/e0d0f07e31eff2bd54321503eb18a885.jpg',
    'https://i.pinimg.com/564x/33/5d/60/335d60b4559e4623f2406bc3b0e30ffd.jpg',
    'https://i.pinimg.com/564x/a8/cf/11/a8cf11b19d30ada3f35c0535aa420853.jpg',
    'https://i.pinimg.com/564x/8a/06/ca/8a06ca8250e77b8923b98fe7ee4105c7.jpg',
    'https://i.pinimg.com/564x/e0/d0/f0/e0d0f07e31eff2bd54321503eb18a885.jpg',
    'https://i.pinimg.com/564x/41/6d/4a/416d4aacc7593be30c5ea16d0bc7c954.jpg',
    'https://i.pinimg.com/564x/33/5d/60/335d60b4559e4623f2406bc3b0e30ffd.jpg',
  ];

  // Dummy Data for Reviews
  static const List<Map<String, dynamic>> reviews = [
    {
      'username': 'John Doe',
      'rating': 5,
      'review':
          'Amazing service! The staff was very friendly and professional. Highly recommended!',
      'date': 'August 5, 2024',
    },
    {
      'username': 'Jane Smith',
      'rating': 4,
      'review': 'Great experience, but the waiting time was a bit long.',
      'date': 'August 3, 2024',
    },
    {
      'username': 'Alice Brown',
      'rating': 4.5,
      'review': 'Loved the ambiance and the haircut was perfect!',
      'date': 'July 29, 2024',
    },
    {
      'username': 'Bob Johnson',
      'rating': 5,
      'review': 'Best salon in town. Will definitely be coming back.',
      'date': 'July 20, 2024',
    },
  ];

  static const List<Map<String, String>> facebookPosts = [
    {
      'imageUrl':
          'https://i.pinimg.com/564x/33/5d/60/335d60b4559e4623f2406bc3b0e30ffd.jpg',
      'caption': 'Check out our latest styles and services!',
    },
    {
      'imageUrl':
          'https://i.pinimg.com/564x/a8/cf/11/a8cf11b19d30ada3f35c0535aa420853.jpg',
      'caption': 'Our team at work making magic happen.',
    },
    {
      'imageUrl':
          'https://i.pinimg.com/564x/41/6d/4a/416d4aacc7593be30c5ea16d0bc7c954.jpg',
      'caption': 'Another happy client! See you soon.',
    },
    {
      'imageUrl':
          'https://i.pinimg.com/564x/8a/06/ca/8a06ca8250e77b8923b98fe7ee4105c7.jpg',
      'caption': 'Special offer on all spa services this week!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6, // Number of tabs
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar with Back Button and Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Salon Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Image and Title Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    // Profile Image
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                            'https://instagram.fkhi10-1.fna.fbcdn.net/v/t51.2885-19/220734747_957601724809525_2985971095560812685_n.jpg?stp=dst-jpg_s150x150&_nc_ht=instagram.fkhi10-1.fna.fbcdn.net&_nc_cat=101&_nc_ohc=tKckjIPA7hIQ7kNvgHfRjSq&edm=AEhyXUkBAAAA&ccb=7-5&oh=00_AYAE4ZsR91gi_5ZCRezfoY2laD0w3sBnwQneFgS32LOp6Q&oe=66BBF0CC&_nc_sid=8f1549'), // Replace with your image URL
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and Subtitle
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Glamour Salon & Spa',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Best Salon in the City',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Rating Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.star, color: kPrimaryColor),
                    Icon(Icons.star, color: kPrimaryColor),
                    Icon(Icons.star, color: kPrimaryColor),
                    Icon(Icons.star, color: kPrimaryColor),
                    Icon(Icons.star_half, color: kPrimaryColor),
                    SizedBox(width: 8),
                    Text('4.5'),
                    SizedBox(width: 8),
                    Text("( 230 reviews )")
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // TabBar Section
              TabBar(
                isScrollable: true, // Makes the TabBar scrollable
                indicator: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(
                      40.0), // Rounded corners for the indicator
                ),
                indicatorPadding:
                    const EdgeInsets.only(left: -16.0, right: -16.0),
                labelColor: Colors.white, // Color of the active tab text
                unselectedLabelColor:
                    Colors.black, // Color of the inactive tab text
                tabs: const [
                  Tab(text: 'Our Services'),
                  Tab(text: 'Top Services'),
                  Tab(text: 'Instagram'),
                  Tab(text: 'Facebook'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'About Us'),
                ],
              ),
              const SizedBox(height: 8),

              // TabBarView for content sections
              Expanded(
                child: TabBarView(
                  children: [
                    // Our Services Tab
                    _buildServicesTab(),
                    // Top Services Tab
                    _buildServicesTab(),
                    // Instagram Tab
                    _buildInstagramTab(),
                    // Facebook Tab
                    _buildFacebookTab(),
                    // Reviews Tab
                    _buildReviewsTab(),
                    // About Us Tab
                    _buildAboutUsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesTab() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: DealsCard(
            title: 'Low Lights',
            image: logo,
            salon: Salon(),
            deal: null,
            services: 'Damage Free Procedure',
            price: 1000,
            discountValue: 500,
            discountType: '---',
            press: () {
              Navigator.pushNamed(context, ProductsScreen.routeName);
              log('==== $index');
            },
          ),
        );
      },
    );
  }

  Widget _buildInstagramTab() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: imageUrls.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of images per row
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius:
                BorderRadius.circular(8.0), // Rounded corners for images
            child: Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAboutUsTab() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'We offer a wide range of beauty services including haircuts, styling, manicures, pedicures, facials, and more.',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  // Removed unused _buildPlaceholderTab method
  /*
  Widget _buildPlaceholderTab(String content) {
    return Center(
      child: Text(content),
    );
  }
  */

  Widget _buildFacebookTab() {
    return ListView.builder(
      itemCount: facebookPosts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 3.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                  child: Image.network(
                    facebookPosts[index]['imageUrl']!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    facebookPosts[index]['caption']!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 3.0,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_circle,
                          size: 40, color: Colors.grey),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reviews[index]['username']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(
                              reviews[index]['rating'].round(),
                              (starIndex) =>
                                  Icon(Icons.star, color: Colors.yellow[700]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reviews[index]['review']!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reviews[index]['date']!,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ServiceTile extends StatelessWidget {
  final String serviceName;

  const ServiceTile({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text(serviceName, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  final String username;
  final String comment;

  const CommentTile({super.key, required this.username, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(comment),
        ],
      ),
    );
  }
}
