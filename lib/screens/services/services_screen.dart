import 'dart:convert';
import 'dart:developer';

//import 'package:anim_search_bar/anim_search_bar.dart';

import 'package:app/components/book_now.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:app/components/product_card.dart';
import 'package:app/models/Product.dart';
import 'package:app/screens/service_details/service_details.dart';
import 'package:app/screens/services/services_header.dart';

import '../../components/sale_percentage.dart';
import '../../constants.dart';
import '../details/details_screen.dart';
import '../home/components/home_header.dart';
import '../home/components/salon_dashboard.dart';
import '../products/products_screen.dart';
import '../search_header_test.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static String routeName = "/services";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: kScreenBg,
          //color: Colors.grey[100], // Set the background color for the entire screen
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                surfaceTintColor: Colors.white,
                pinned: false,
                floating: true,
                snap: true,
                flexibleSpace: FlexibleSpaceBar(
                  // background: ServicesHeader(),
                  background: ServicesHeaderTest(),
                ),
                expandedHeight: 125,
                backgroundColor: Colors.white, // Set background to transparent
                elevation: 0, // Remove shadow
                automaticallyImplyLeading: false, // Hide the back button
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);



                  },
                ),
              ),


              SliverList(
                delegate: SliverChildListDelegate(
                  [

                    ServicesCard(
                      title: 'Shampoo & Blow-dry',
                      image: logo,
                      desc: 'Professional hair wash followed by blow-dry for smooth, styled hair.',
                      press: (){
                        Navigator.pushNamed(context, ProductsScreen.routeName);
                        log('==== ${0}');
                      },),
                    ServicesCard(
                      title: 'Hair Coloring ',
                      image: logo,
                      desc: 'Full head or root touch-up color',
                      press: (){
                        Navigator.pushNamed(context, ProductsScreen.routeName);
                        log('==== ${0}');
                      },),
                    ServicesCard(
                      title: 'Highlights (Full/Partial)',
                      image: logo,
                      desc: 'Brighten hair with partial or full streaks of lighter shades',
                      press: (){
                        Navigator.pushNamed(context, ProductsScreen.routeName);
                        log('==== ${0}');
                      },),
                    ServicesCard(
                      title: 'Keratin Treatment',
                      image: logo,
                      desc: 'A smoothing treatment to eliminate frizz and add shine.',
                      press: (){
                        Navigator.pushNamed(context, ProductsScreen.routeName);
                        log('==== ${0}');
                      },),
                    ServicesCard(
                      title: 'Hair Straightening  ',
                      image: logo,
                      desc: 'Chemical treatment to permanently straighten hair.',
                      press: (){
                        Navigator.pushNamed(context, ProductsScreen.routeName);
                        log('==== ${0}');
                      },),


                    ServicesCard(
                      title: '11111  ',
                      image: logo,
                      desc: '',
                      press: (){
                        Navigator.pushNamed(context, ProductsScreen.routeName);
                        log('==== ${0}');
                      },),


                    ServicesCard(
                      title: '11111  ',
                      image: logo,
                      desc: '',
                      press: (){
                        Navigator.pushNamed(context, ProductsScreen.routeName);
                        log('==== ${0}');
                      },),
                    ServicesCard(
                      title: '11111  ',
                      image: logo,
                      desc: '',
                      press: (){
                        Navigator.pushNamed(context, ProductsScreen.routeName);
                        log('==== ${0}');
                      },),
                    ServicesCard(
                      title: '11111  ',
                      image: logo,
                      desc: '',
                      press: (){
                        Navigator.pushNamed(context, ProductsScreen.routeName);
                        log('==== ${0}');
                      },),
                    ServicesCard(
                      title: '11111  ',
                      image: logo,
                      desc: '',
                      press: (){
                        Navigator.pushNamed(context, ProductsScreen.routeName);
                        print('==== ${0}');
                      },),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ServicesCard extends StatelessWidget {
  const ServicesCard({
    Key? key,
    required this.title,
    required this.image,
    required this.desc,
    required this.press,
  }) : super(key: key);

  final String title, image;
  final String desc;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 0, right: 10),
      child: Container(
        //width: 320,
        height: 180,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
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
                  onTap: () {

                     Navigator.pushNamed(context, ProductsScreen.routeName);
                    //Navigator.pushNamed(context, ServiceDetailsScreen.routeName);

                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: true//product.isFavourite
                          ? kPrimaryColor.withOpacity(0.15)
                          : kSecondaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/Heart Icon_2.svg",
                      colorFilter: ColorFilter.mode(
                          true//product.isFavourite
                              ? const Color(0xFFFF4848)
                              : const Color(0xFFDBDEE4),
                          BlendMode.srcIn),
                    ),
                  ),
                ),
              ],
            ),





            SizedBox(width: 5),
            Text(
              desc,
              style: const TextStyle(
                color: kPrimaryColor,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '30 min - 1 hr',
              style: const TextStyle(
                color: Colors.black,

              ),
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.cut_rounded,
                  color: Colors.black38,
                  size: 20,
                ),
                SizedBox(width: 5),
                Text(
                  '------',
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Spacer(),



            Row(
              children: [
                Text(
                  'Rs: 1200',
                  style: const TextStyle(
                      color: kPrice,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(width: 15),

                Text(
                  'Rs: 2000',
                  style: const TextStyle(
                    color: kBeforeDiscount,
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),



                Spacer(),
                BookNow()
                ///SalePercentage(off: 18, type: '',),
              ],
            ),


          ],
        ),
      ),
    );
  }
}
