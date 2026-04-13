import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:app/constants.dart';
import '../models/SalonDetailApiResponse.dart';
import '../models/HomePageResponse.dart';
import '../features/auth/utils/auth_manager.dart';

/// Response class for categorized services
class ServiceCategoryResponse {
  final int categoryId;
  final String categoryName;
  final List<Service> services;

  ServiceCategoryResponse({
    required this.categoryId,
    required this.categoryName,
    required this.services,
  });
}

class SalonDetailAPI {
  SalonDetailAPI();

  Future<SalonData?> fetchSalonDetailData(String salonId) async {
    log('');
    log('═══════════════════════════════════════════════════════════════');
    log('🏪 FETCHING SALON DETAILS');
    log('═══════════════════════════════════════════════════════════════');
    log('📍 Endpoint: GET $BASE_URL/salons/$salonId');
    log('🆔 Salon ID: $salonId');
    
    // Check if user is authenticated
    final token = await AuthManager.getToken();
    final isAuthenticated = token != null && token.isNotEmpty;
    
    log('🔐 Authentication Status: ${isAuthenticated ? "Authenticated ✅" : "Guest 👤"}');
    if (isAuthenticated) {
      log('🎫 Token: ${token.substring(0, 20)}...');
    }
    log('');

    try {
      // Build headers - add Authorization if authenticated
      final headers = {
        'Content-Type': 'application/json',
        if (isAuthenticated) 'Authorization': 'Bearer $token',
      };
      
      log('📤 Request Headers:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          log('   ├─ $key: Bearer ${value.toString().substring(7, 27)}...');
        } else {
          log('   ├─ $key: $value');
        }
      });
      log('');

      final response = await http.get(
        Uri.parse('$BASE_URL/salons/$salonId'),
        headers: headers,
      );

      log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('✅ SUCCESS - Parsing response body');
        log('');
        log('📄 RAW RESPONSE:');
        log('───────────────────────────────────────────────────────────────');
        log(response.body);
        log('───────────────────────────────────────────────────────────────');
        log('');

        final apiResponse =
            SalonDetailApiResponse.fromJson(jsonDecode(response.body));

        SalonData? salonDetails = apiResponse.response.data;

        log('📊 PARSED SALON DATA:');
        log('   ├─ ID: ${salonDetails.id}');
        log('   ├─ Name: ${salonDetails.name}');
        log('   ├─ Gender: ${salonDetails.gender}');
        log('   ├─ Type: ${salonDetails.type}');
        log('   ├─ Logo: ${salonDetails.logo}');
        log('   ├─ Star Rating: ${salonDetails.star}');
        log('   ├─ Review Count: ${salonDetails.review_count}');
        log('   ├─ Is Favourite: ${salonDetails.isFavourite}');
        log('   ├─ Images Count: ${salonDetails.images.length}');
        log('   ├─ About: ${salonDetails.about?.substring(0, salonDetails.about!.length > 50 ? 50 : salonDetails.about!.length)}...');
        log('   ├─ Location: ${salonDetails.location?.address}');
        log('   ├─ Active Days: ${salonDetails.activeDays?.length}');
        log('   └─ Sections: ${salonDetails.sections?.length}');
        log('');
        log('✅ SALON DETAILS FETCHED SUCCESSFULLY');
        log('═══════════════════════════════════════════════════════════════');
        log('');

        return salonDetails;
      } else {
        log('❌ ERROR - Status: ${response.statusCode}');
        log('Response Body: ${response.body}');
        log('═══════════════════════════════════════════════════════════════');
        log('');
        return null;
      }
    } catch (error) {
      log('');
      log('💥 EXCEPTION IN FETCH SALON DETAILS');
      log('Error: $error');
      log('═══════════════════════════════════════════════════════════════');
      log('');
      throw Exception('Failed to load salon details: $error');
    }
  }

  /// Fetch services for a specific category with pagination
  Future<ServiceCategoryResponse?> fetchSalonServices(String salonId,
      {int categoryId = 1, int perPage = 50}) async {
    log('');
    log('═══════════════════════════════════════════════════════════════');
    log('🛎️ FETCHING SALON SERVICES');
    log('═══════════════════════════════════════════════════════════════');
    log('📍 Endpoint: GET $BASE_URL/salons/$salonId/services/$categoryId?per_page=$perPage');
    log('🆔 Salon ID: $salonId');
    log('📂 Category ID: $categoryId');
    log('📄 Per Page: $perPage');
    log('');

    try {
      final response = await http.get(
        Uri.parse(
            '$BASE_URL/salons/$salonId/services/$categoryId?per_page=$perPage'),
        headers: {'Content-Type': 'application/json'},
      );

      log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('✅ SUCCESS - Parsing response body');
        log('');
        log('📄 RAW RESPONSE:');
        log('───────────────────────────────────────────────────────────────');
        log(response.body);
        log('───────────────────────────────────────────────────────────────');
        log('');

        final jsonData = jsonDecode(response.body);

        log('🔍 ANALYZING RESPONSE STRUCTURE:');
        log('   ├─ Has "status" key: ${jsonData.containsKey('status')}');
        log('   ├─ Has "success" key: ${jsonData.containsKey('success')}');
        log('   ├─ Has "response" key: ${jsonData.containsKey('response')}');
        log('   ├─ Has "data" key: ${jsonData.containsKey('data')}');
        log('   └─ Status value: ${jsonData['status']}');
        log('');

        // Handle new API structure: {statusCode, response: {data: {...}}, message, status, errors}
        dynamic responseData;
        if (jsonData['status'] == true && jsonData['response'] != null) {
          responseData = jsonData['response']['data'];
          log('✅ Using NEW API structure (status/response/data)');
        } else if (jsonData['success'] == true && jsonData['data'] != null) {
          responseData = jsonData['data'];
          log('✅ Using OLD API structure (success/data)');
        } else {
          log('❌ Unknown API response structure');
          log('   Response keys: ${jsonData.keys.toList()}');
          return null;
        }

        if (responseData != null) {
          final servicesData = responseData['services'];
          log('');
          log('📦 SERVICES DATA STRUCTURE:');
          log('   ├─ Category ID: ${responseData['category_id']}');
          log('   ├─ Category Name: ${responseData['category_name']}');
          log('   ├─ Services is null: ${servicesData == null}');
          log('   ├─ Services has "data": ${servicesData?.containsKey('data')}');
          log('   └─ Services type: ${servicesData.runtimeType}');
          log('');

          if (servicesData != null && servicesData['data'] != null) {
            final servicesList = (servicesData['data'] as List)
                .map((service) => Service.fromJson(service))
                .toList();

            log('📊 PARSED SERVICES DATA:');
            log('   ├─ Category ID: ${responseData['category_id']}');
            log('   ├─ Category Name: ${responseData['category_name']}');
            log('   ├─ Total Services: ${servicesList.length}');
            log('   ├─ Current Page: ${servicesData['current_page']}');
            log('   ├─ Last Page: ${servicesData['last_page']}');
            log('   └─ Total Items: ${servicesData['total']}');
            log('');

            if (servicesList.isNotEmpty) {
              log('🔍 SERVICES DETAILS:');
              for (int i = 0; i < servicesList.length && i < 3; i++) {
                final service = servicesList[i];
                log('   Service ${i + 1}:');
                log('      ├─ ID: ${service.id}');
                log('      ├─ Name: ${service.name}');
                log('      ├─ Price: ${service.price}');
                log('      ├─ Duration: ${service.duration}');
                log('      ├─ Discount: ${service.percentageDiscount}%');
                log('      ├─ Old Price: ${service.oldPrice}');
                log('      ├─ Gender: ${service.gender}');
                log('      └─ Professionals: ${service.professionals?.length ?? 0}');
              }
              if (servicesList.length > 3) {
                log('   ... and ${servicesList.length - 3} more services');
              }
            }

            log('');
            log('✅ SERVICES FETCHED SUCCESSFULLY');
            log('═══════════════════════════════════════════════════════════════');
            log('');

            return ServiceCategoryResponse(
              categoryId: responseData['category_id'] ?? categoryId,
              categoryName:
                  responseData['category_name'] ?? 'Category $categoryId',
              services: servicesList,
            );
          }
        }
        log('⚠️ No services data found in response');
        log('   Response data is null: ${responseData == null}');
        log('═══════════════════════════════════════════════════════════════');
        log('');
        return null;
      } else {
        log('❌ ERROR - Status: ${response.statusCode}');
        log('Response Body: ${response.body}');
        log('═══════════════════════════════════════════════════════════════');
        log('');
        return null;
      }
    } catch (error) {
      log('');
      log('💥 EXCEPTION IN FETCH SERVICES');
      log('Error: $error');
      log('═══════════════════════════════════════════════════════════════');
      log('');
      throw Exception('Failed to load services: $error');
    }
  }

  /// Fetch staff/team members with pagination
  Future<List<Staff>> fetchSalonStaff(String salonId,
      {int perPage = 50}) async {
    log('');
    log('═══════════════════════════════════════════════════════════════');
    log('👥 FETCHING SALON STAFF');
    log('═══════════════════════════════════════════════════════════════');
    log('📍 Endpoint: GET $BASE_URL/salons/$salonId/staff?per_page=$perPage');
    log('🆔 Salon ID: $salonId');
    log('📄 Per Page: $perPage');
    log('');

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/salons/$salonId/staff?per_page=$perPage'),
        headers: {'Content-Type': 'application/json'},
      );

      log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('✅ SUCCESS - Parsing response body');
        log('');
        log('📄 RAW RESPONSE:');
        log('───────────────────────────────────────────────────────────────');
        log(response.body);
        log('───────────────────────────────────────────────────────────────');
        log('');

        final jsonData = jsonDecode(response.body);

        log('🔍 ANALYZING STAFF RESPONSE STRUCTURE:');
        log('   ├─ Has "status": ${jsonData.containsKey('status')}');
        log('   ├─ Has "success": ${jsonData.containsKey('success')}');
        log('   ├─ Has "response": ${jsonData.containsKey('response')}');
        log('   └─ Status/Success value: ${jsonData['status'] ?? jsonData['success']}');
        log('');

        dynamic staffResponseData;
        if (jsonData['status'] == true && jsonData['response'] != null) {
          staffResponseData = jsonData['response']['data'];
          log('✅ Using NEW API structure (status/response/data)');
        } else if (jsonData['success'] == true && jsonData['data'] != null) {
          staffResponseData = jsonData['data'];
          log('✅ Using OLD API structure (success/data)');
        } else {
          log('❌ Unknown staff API response structure');
          return [];
        }

        if (staffResponseData != null) {
          final staffData = staffResponseData['data'];
          if (staffData != null) {
            final staffList = (staffData as List)
                .map((staff) => Staff.fromJson(staff))
                .toList();

            log('📊 PARSED STAFF DATA:');
            log('   ├─ Total Staff: ${staffList.length}');
            log('   ├─ Current Page: ${staffResponseData['current_page']}');
            log('   ├─ Last Page: ${staffResponseData['last_page']}');
            log('   └─ Total Items: ${staffResponseData['total']}');
            log('');

            if (staffList.isNotEmpty) {
              log('🔍 STAFF DETAILS (first 3):');
              for (int i = 0; i < staffList.length && i < 3; i++) {
                final staff = staffList[i];
                log('   Staff ${i + 1}:');
                log('      ├─ ID: ${staff.id}');
                log('      ├─ Name: ${staff.name}');
                log('      ├─ Email: ${staff.email}');
                log('      ├─ Experience: ${staff.experience}');
                log('      └─ Status: ${staff.status}');
              }
              if (staffList.length > 3) {
                log('   ... and ${staffList.length - 3} more staff members');
              }
            }

            log('');
            log('✅ STAFF FETCHED SUCCESSFULLY');
            log('═══════════════════════════════════════════════════════════════');
            log('');

            return staffList;
          }
        }
        log('⚠️ No staff data found in response');
        log('═══════════════════════════════════════════════════════════════');
        log('');
        return [];
      } else {
        log('❌ ERROR - Status: ${response.statusCode}');
        log('Response Body: ${response.body}');
        log('═══════════════════════════════════════════════════════════════');
        log('');
        return [];
      }
    } catch (error) {
      log('');
      log('💥 EXCEPTION IN FETCH STAFF');
      log('Error: $error');
      log('═══════════════════════════════════════════════════════════════');
      log('');
      throw Exception('Failed to load staff: $error');
    }
  }

  /// Fetch deals with pagination
  Future<List<Deal>> fetchSalonDeals(String salonId, {int perPage = 50}) async {
    log('');
    log('═══════════════════════════════════════════════════════════════');
    log('💰 FETCHING SALON DEALS');
    log('═══════════════════════════════════════════════════════════════');
    log('📍 Endpoint: GET $BASE_URL/salons/$salonId/deals?per_page=$perPage');
    log('🆔 Salon ID: $salonId');
    log('📄 Per Page: $perPage');
    log('');

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/salons/$salonId/deals?per_page=$perPage'),
        headers: {'Content-Type': 'application/json'},
      );

      log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('✅ SUCCESS - Parsing response body');
        log('');
        log('📄 RAW RESPONSE:');
        log('───────────────────────────────────────────────────────────────');
        log(response.body);
        log('───────────────────────────────────────────────────────────────');
        log('');

        final jsonData = jsonDecode(response.body);

        log('🔍 ANALYZING DEALS RESPONSE STRUCTURE:');
        log('   ├─ Has "status": ${jsonData.containsKey('status')}');
        log('   ├─ Has "success": ${jsonData.containsKey('success')}');
        log('   ├─ Has "response": ${jsonData.containsKey('response')}');
        log('   └─ Status/Success value: ${jsonData['status'] ?? jsonData['success']}');
        log('');

        dynamic dealsResponseData;
        if (jsonData['status'] == true && jsonData['response'] != null) {
          dealsResponseData = jsonData['response']['data'];
          log('✅ Using NEW API structure (status/response/data)');
        } else if (jsonData['success'] == true && jsonData['data'] != null) {
          dealsResponseData = jsonData['data'];
          log('✅ Using OLD API structure (success/data)');
        } else {
          log('❌ Unknown deals API response structure');
          return [];
        }

        if (dealsResponseData != null) {
          final dealsData = dealsResponseData['data'];
          if (dealsData != null) {
            final dealsList =
                (dealsData as List).map((deal) => Deal.fromJson(deal)).toList();

            log('📊 PARSED DEALS DATA:');
            log('   ├─ Total Deals: ${dealsList.length}');
            log('   ├─ Current Page: ${dealsResponseData['current_page']}');
            log('   ├─ Last Page: ${dealsResponseData['last_page']}');
            log('   └─ Total Items: ${dealsResponseData['total']}');
            log('');

            if (dealsList.isNotEmpty) {
              log('🔍 DEALS DETAILS (first 3):');
              for (int i = 0; i < dealsList.length && i < 3; i++) {
                final deal = dealsList[i];
                log('   Deal ${i + 1}:');
                log('      ├─ ID: ${deal.id}');
                log('      ├─ Name: ${deal.name}');
                log('      ├─ Price: ${deal.price}');
                log('      ├─ Discount Type: ${deal.discountType}');
                log('      ├─ Discount Value: ${deal.discountValue}');
                log('      ├─ Total Price: ${deal.totalPrice}');
                log('      ├─ Start Date: ${deal.startDate}');
                log('      ├─ End Date: ${deal.endDate}');
                log('      ├─ Image: ${deal.image}');
                log('      └─ Services Count: ${deal.services?.length ?? 0}');

                if (deal.services != null &&
                    deal.services!.isNotEmpty &&
                    i == 0) {
                  log('      Services in Deal (first 2):');
                  for (int j = 0; j < deal.services!.length && j < 2; j++) {
                    final service = deal.services![j];
                    log('         ${j + 1}. ${service.name} (₨${service.price})');
                  }
                }
              }
              if (dealsList.length > 3) {
                log('   ... and ${dealsList.length - 3} more deals');
              }
            }

            log('');
            log('✅ DEALS FETCHED SUCCESSFULLY');
            log('═══════════════════════════════════════════════════════════════');
            log('');

            return dealsList;
          }
        }
        log('⚠️ No deals data found in response');
        log('═══════════════════════════════════════════════════════════════');
        log('');
        return [];
      } else {
        log('❌ ERROR - Status: ${response.statusCode}');
        log('Response Body: ${response.body}');
        log('═══════════════════════════════════════════════════════════════');
        log('');
        return [];
      }
    } catch (error) {
      log('');
      log('💥 EXCEPTION IN FETCH DEALS');
      log('Error: $error');
      log('═══════════════════════════════════════════════════════════════');
      log('');
      throw Exception('Failed to load deals: $error');
    }
  }

  /// Toggle salon favorite status
  /// Returns the new isFavourite status on success, null on failure
  Future<bool?> toggleFavorite(int salonId, String? token) async {
    log('');
    log('═══════════════════════════════════════════════════════════════');
    log('❤️ TOGGLING SALON FAVORITE');
    log('═══════════════════════════════════════════════════════════════');
    log('📍 Endpoint: POST $BASE_URL/salons/add-to-favourites');
    log('🆔 Salon ID: $salonId');
    log('🔐 Has Token: ${token != null}');
    log('');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        'share_id': salonId.toString(),
        'share_type': 'salon',
      });

      log('📤 Request Body: $body');

      final response = await http.post(
        Uri.parse('$BASE_URL/salons/add-to-favourites'),
        headers: headers,
        body: body,
      );

      log('📥 Response Status: ${response.statusCode}');
      log('📄 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final newFavoriteStatus =
            responseData['response']?['data']?['is_favourite'] as bool?;

        log('✅ SUCCESS - New favorite status: $newFavoriteStatus');
        log('═══════════════════════════════════════════════════════════════');
        log('');

        return newFavoriteStatus;
      } else {
        log('❌ ERROR - Status: ${response.statusCode}');
        log('═══════════════════════════════════════════════════════════════');
        log('');
        return null;
      }
    } catch (error) {
      log('');
      log('💥 EXCEPTION IN TOGGLE FAVORITE');
      log('Error: $error');
      log('═══════════════════════════════════════════════════════════════');
      log('');
      return null;
    }
  }
}
