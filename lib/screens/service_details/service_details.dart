import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants.dart';
import '../cart/cart_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  static String routeName = "/service_details";

  final Map<String, dynamic> serviceData = {
    "id": 1,
    "salon_id": 1,
    "name": "Men's Haircut",
    "short_description": "Men's Haircut",
    "duration": "30 minutes",
    "description": "Basic men's haircut",
    "price": "15.00",
    "old_price": "15.00",
    "gender": "male",
  };

   ServiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              // Navigator.pushNamed(context, ProductsScreen.routeName);
              Navigator.pushNamed(context, ServiceDetailsScreen.routeName);
            },
            child: Visibility(
              visible: false,
              child: Container(
                padding: const EdgeInsets.all(6),
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: true //product.isFavourite
                      ? kPrimaryColor.withOpacity(0.15)
                      : kSecondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  "assets/icons/Heart Icon_2.svg",
                  colorFilter: const ColorFilter.mode(
                      true //product.isFavourite
                          ? Color(0xFFFF4848)
                          : Color(0xFFDBDEE4),
                      BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              serviceData['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              serviceData['short_description'],
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              "Duration: ${serviceData['duration']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Price: \$${serviceData['price']}",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 16),
            const Text(
              "Description",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              serviceData['description'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 36),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Instructions",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "- Arrive 10 minutes early for your appointment.\n- Inform the stylist of any specific requests.\n- Maintain hygiene and follow salon guidelines.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, CartScreen.routeName);
                    },
                    child: const Text("Add To Cart"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
