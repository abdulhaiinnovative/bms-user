import 'dart:developer';

import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/HomePageResponse.dart';
import 'package:app/features/home/presentation/widgets/deals_dashboard.dart';
import '../products/products_screen.dart';
import '../salon/salon_screen.dart';

class ScrollSyncTabs extends StatefulWidget {
  const ScrollSyncTabs({super.key});

  static String routeName = "/scroll_sync";

  @override
  _ScrollSyncTabsState createState() => _ScrollSyncTabsState();
}

class _ScrollSyncTabsState extends State<ScrollSyncTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _scrollController = ScrollController();

    // Add listeners to synchronize the TabController with ScrollController
    _tabController.addListener(_handleTabSelection);
    _scrollController.addListener(_handleScroll);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _scrollToPosition(_tabController.index);
    }
  }

  void _handleScroll() {
    double position = _scrollController.position.pixels;
    // Assuming each tab's height is equal and is 500 pixels for simplicity
    double tabHeight = 500.0;
    int tabIndex = (position / tabHeight).round();
    if (_tabController.index != tabIndex &&
        _scrollController.position.isScrollingNotifier.value) {
      _tabController.animateTo(tabIndex);
    }
  }

  void _scrollToPosition(int index) {
    // Assuming each tab's height is equal and is 500 pixels for simplicity
    double tabHeight = 500.0;
    double targetPosition = index * tabHeight;
    _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _scrollController.removeListener(_handleScroll);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
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
                            'https://instagram.fkhi10-1.fna.fbcdn.net/v/t51.2885-19/220734747_957601724809525_2985971095560812685_n.jpg?stp=dst-jpg_s150x150&_nc_ht=instagram.fkhi10-1.fna.fbcdn.net&_nc_cat=101&_nc_ohc=tKckjIPA7hIQ7kNvgHfRjSq&edm=AEhyXUkBAAAA&ccb=7-5&oh=00_AYAE4ZsR91gi_5ZCRezfoY2laD0w3sBnwQneFgS32LOp6Q&oe=66BBF0CC&_nc_sid=8f1549'),
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
                controller: _tabController,
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
                  controller: _tabController,
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
      controller: _scrollController, // Attach ScrollController here
      scrollDirection: Axis.vertical,
      itemCount: 50,
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
        controller: _scrollController, // Attach ScrollController here
        itemCount: SalonScreen.imageUrls.length,
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
              SalonScreen.imageUrls[index],
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

  Widget _buildFacebookTab() {
    return ListView.builder(
      controller: _scrollController, // Attach ScrollController here
      itemCount: SalonScreen.facebookPosts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage(SalonScreen.facebookPosts[index]['imageUrl']!),
              ),
              title: Text(SalonScreen.facebookPosts[index]['title']!),
              subtitle: Text(SalonScreen.facebookPosts[index]['date']!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return ListView.builder(
      controller: _scrollController, // Attach ScrollController here
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return const ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text('User =='),
          subtitle: Text('Excellent service and friendly staff.'),
        );
      },
    );
  }
}
