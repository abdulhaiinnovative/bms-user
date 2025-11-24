import 'dart:convert';
import 'dart:developer';
import '../models/SalonServicesCategorizedResponse.dart';
import 'base_api_service.dart';

class SalonServicesCategorizedAPI {
  SalonServicesCategorizedAPI();

  Future<SalonServicesCategorizedResponse?>
      fetchAllServicesAndDealsCategorizedData(int salonId) async {
    try {
      log('════════════════════════════════════════════════════════');
      log('🔵 SALON SERVICES CATEGORIZED API - REQUEST');
      log('════════════════════════════════════════════════════════');
      log('📤 Request Details:');
      log('   Endpoint: /categorized_services');
      log('   Method: POST');
      log('   Salon ID: $salonId');
      log('   Auth Required: true');
      log('════════════════════════════════════════════════════════');

      final response = await BaseApiService.post(
        '/categorized_services',
        data: {"salon_id": salonId},
        requiresAuth: true,
        logTag: 'SalonServicesCategorized',
      );

      log('');
      log('════════════════════════════════════════════════════════');
      log('📥 SALON SERVICES CATEGORIZED API - RESPONSE');
      log('════════════════════════════════════════════════════════');
      log('Status Code: ${response.statusCode}');
      log('');
      log('📄 RAW JSON RESPONSE:');
      log('────────────────────────────────────────────────────────');
      
      // Pretty print JSON
      final prettyJson = JsonEncoder.withIndent('  ').convert(response.data);
      log(prettyJson);
      
      log('────────────────────────────────────────────────────────');
      log('════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        log('');
        log('✅ SUCCESS - Parsing response data...');
        final parsedResponse = SalonServicesCategorizedResponse.fromJson(response.data);
        
        log('');
        log('📊 PARSED DATA SUMMARY:');
        log('────────────────────────────────────────────────────────');
        log('Status Code: ${parsedResponse.statusCode}');
        log('Total Categories: ${parsedResponse.response?.data?.length ?? 0}');
        
        if (parsedResponse.response?.data != null) {
          for (var category in parsedResponse.response!.data!) {
            log('');
            log('📁 Category: ${category.name}');
            log('   ID: ${category.id}');
            log('   Description: ${category.description ?? "N/A"}');
            log('   Has Services: ${category.isServices}');
            
            if (category.items != null && category.items!.isNotEmpty) {
              log('   Items Count: ${category.items!.length}');
              
              if (category.isServices == true) {
                log('   Services:');
                for (var item in category.items!) {
                  log('      • ${item.name} (ID: ${item.id})');
                  log('        - Price: PKR ${item.price}');
                  log('        - Old Price: PKR ${item.oldPrice ?? "N/A"}');
                  log('        - Discount: ${item.discountAmount ?? 0}');
                  log('        - Duration: ${item.duration ?? "N/A"}');
                  log('        - Professionals: ${item.professionals?.length ?? 0}');
                }
              } else {
                log('   Deals:');
                for (var item in category.items!) {
                  log('      • ${item.name} (ID: ${item.id})');
                  log('        - Price: PKR ${item.price}');
                  log('        - Total Price: PKR ${item.totalPrice ?? "N/A"}');
                  log('        - Discount: PKR ${item.discountValue ?? 0}');
                }
              }
            } else {
              log('   No items in this category');
            }
          }
        }
        log('────────────────────────────────────────────────────────');
        log('════════════════════════════════════════════════════════');
        
        return parsedResponse;
      } else {
        log('');
        log('❌ ERROR - HTTP ${response.statusCode}');
        log('Response Data: ${response.data}');
        log('════════════════════════════════════════════════════════');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error, stackTrace) {
      log('');
      log('════════════════════════════════════════════════════════');
      log('💥 EXCEPTION IN SALON SERVICES CATEGORIZED API');
      log('════════════════════════════════════════════════════════');
      log('Error: $error');
      log('Stack Trace: $stackTrace');
      log('════════════════════════════════════════════════════════');
      throw Exception('Failed to load data: $error');
    }
  }
}
