import 'dart:developer';

import 'package:app/models/HomePageResponse.dart';
import 'package:app/screens/test_scroll/CustomAppBar.dart';
import 'package:flutter/material.dart';
// import 'package:app/screens/test_scroll/jewellery_repository.dart';
import '../../constants.dart';
import 'CartSummarySection.dart';
import 'SelectDateScreen.dart';

class SelectProfessionals extends StatefulWidget {
  static String routeName = "/select_professionals";

  const SelectProfessionals({Key? key}) : super(key: key);

  @override
  _SelectProfessionalsState createState() => _SelectProfessionalsState();
}

class _SelectProfessionalsState extends State<SelectProfessionals> {
  Map<dynamic, String?> selectedProfessionals = {};
  Map<dynamic, int>? cartItems;
  String? salonName;
  String? salonImage;
  String? salonAddress;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map) {
        setState(() {
          cartItems = arguments['cartItems'] as Map<dynamic, int>? ?? {};
          salonName = arguments['salonName'] as String?;
          salonImage = arguments['salonImage'] as String?;
          salonAddress = arguments['salonAddress'] as String?;

          log('cartItems length: ${cartItems?.length ?? 0}');
          log('salonName: $salonName');
          log('salonImage: $salonImage');
          log('salonAddress: $salonAddress');

          // Initialize selectedProfessionals with cartItems
          cartItems?.forEach((service, _) {
            selectedProfessionals[service] = null;
          });
        });
      } else {
        log('No valid arguments passed to SelectProfessionals');
        setState(() {
          cartItems = {};
        });
      }
    });
  }

  Widget _buildProfessionalSelector(Service service) {
    // Create a list of professionals including "Any"
    List<String> professionals = ['Any'];
    if (service.professionals != null) {
      professionals
          .addAll(service.professionals!.map((p) => p.name ?? 'Unknown'));
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(right: 12, left: 12, top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              service.name ?? 'Service',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: professionals.map((professional) {
                bool isSelected =
                    selectedProfessionals[service] == professional;
                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: RawChip(
                      label: Text(
                        professional,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: kPrimaryDarkColor,
                      checkmarkColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      shape: const StadiumBorder(),
                      onSelected: (selected) {
                        setState(() {
                          selectedProfessionals[service] =
                              selected ? professional : null;
                        });
                      },
                    ));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealItem(dynamic deal) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(right: 12, left: 12, top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              deal.name ?? 'Deal',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: RawChip(
              label: const Text(
                'Any',
                style: TextStyle(color: Colors.white),
              ),
              selected: true,
              selectedColor: kPrimaryDarkColor,
              avatar: const Icon(
                Icons.check,
                color: Colors.white,
                size: 18,
              ),
              shape: const StadiumBorder(),
              onSelected: (_) {},
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canProceed = selectedProfessionals.entries
        .where((entry) => entry.key is Service)
        .every((entry) => entry.value != null);

    return Scaffold(
      appBar: CustomAppBar(
        salonName: salonName,
        salonAddress: salonAddress,
        salonImage: salonImage,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              color: kScreenBg,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (cartItems == null || cartItems!.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No services in cart. Please add services to continue.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ...cartItems!.keys.map((item) {
                        if (item is Service) {
                          return _buildProfessionalSelector(item);
                        } else {
                          return _buildDealItem(item);
                        }
                      }).toList(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: CartSummarySection(
                  totalItems: cartItems?.length ?? 0,
                  totalAmount: cartItems?.entries.fold<double>(
                        0.0,
                        (sum, entry) {
                          final item = entry.key;
                          final quantity = entry.value;
                          final price = _getItemPrice(item);
                          return sum + (price * quantity);
                        },
                      ) ??
                      0.0,
                  buttonColor: canProceed ? kPrimaryDarkColor : Colors.grey,
                  onContinue: () {
                    if (canProceed) {
                      Navigator.pushNamed(
                        context,
                        SelectDateScreen.routeName,
                        arguments: {
                          'selectedProfessionals': selectedProfessionals,
                          'cartItems': cartItems,
                          'salonName': salonName,
                          'salonImage': salonImage,
                          'salonAddress': salonAddress,
                        },
                      );
                    }
                  },
                )),
          ),
        ],
      ),
    );
  }

  double _getItemPrice(dynamic item) {
    if (item is Service) return (item.price ?? 0).toDouble();
    if (item is Deal) return (item.totalPrice ?? 0).toDouble();
    return 0.0;
  }
}
