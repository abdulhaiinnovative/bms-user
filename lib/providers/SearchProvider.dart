import 'package:flutter/material.dart';
import 'package:app/api_services/search_service_api.dart';
import 'package:app/models/SalonMain.dart';
import 'package:app/models/ServiceMain.dart';

import '../api_services/search_salon_api.dart';

class SearchProvider extends ChangeNotifier {
  List<SalonMain> _salons = [];
  List<ServiceMain> _services = [];
  bool _isLoading = false;

  List<SalonMain> get salons => _salons;
  List<ServiceMain> get services => _services;

  bool get isLoading => _isLoading;

  Future<void> searchSalons(String salon, String service) async {
    _isLoading = true;
    notifyListeners();

    //_salons = await searchSalonAPI(salon: salon, service: service);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchServices(String salon, String service) async {
    _isLoading = true;
    notifyListeners();

    _services = await searchServiceAPI(salon: salon, service: service);

    _isLoading = false;
    notifyListeners();
  }


}

