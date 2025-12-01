import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:app/constants.dart';
import '../models/SalonDetailApiResponse.dart';

class SalonDetailAPI {
  SalonDetailAPI();

  Future<SalonData?> fetchSalonDetailData(String salonId) async {
    try {
      log('════════════════════════════════════════════════════════');
      log('🏢 SALON DETAIL API - REQUEST');
      log('════════════════════════════════════════════════════════');
      log('📤 Request Details:');
      log('   Endpoint: /salons/$salonId');
      log('   Method: GET');
      log('   Salon ID: $salonId');
      log('   Auth Required: false (public data)');
      log('════════════════════════════════════════════════════════');

      final response = await http.get(
        Uri.parse('$BASE_URL/salons/$salonId'),
        headers: {'Content-Type': 'application/json'},
      );

      log('');
      log('════════════════════════════════════════════════════════');
      log('📥 SALON DETAIL API - RESPONSE');
      log('════════════════════════════════════════════════════════');
      log('Status Code: ${response.statusCode}');
      log('');
      log('📄 RAW JSON RESPONSE:');
      log('────────────────────────────────────────────────────────');

      try {
        final jsonResponse = jsonDecode(response.body);
        final prettyJson =
            const JsonEncoder.withIndent('  ').convert(jsonResponse);
        log(prettyJson);
      } catch (e) {
        log(response.body);
      }

      log('────────────────────────────────────────────────────────');
      log('════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        log('');
        log('✅ SUCCESS - Parsing salon details...');

        final apiResponse =
            SalonDetailApiResponse.fromJson(jsonDecode(response.body));

        SalonData? salonDetails = apiResponse.response.data;

        log('');
        log('📊 PARSED SALON DETAILS SUMMARY:');
        log('────────────────────────────────────────────────────────');
        log('🏢 Salon Name: ${salonDetails.name}');
        log('📍 Location: ${salonDetails.location?.address ?? "N/A"}');
        log(' Gender: ${salonDetails.gender ?? "N/A"}');
        log('❤️ Is Favourite: ${salonDetails.isFavourite}');
        log('📅 Created: ${salonDetails.createdAt ?? "N/A"}');
        log('');
        log('📜 Sections (${salonDetails.sections?.length ?? 0}):');

        if (salonDetails.sections != null) {
          for (var i = 0; i < salonDetails.sections!.length; i++) {
            final section = salonDetails.sections![i];
            log('   [$i] ${section.name} (Type: ${section.type})');
            log('       Data items: ${section.data?.length ?? 0}');

            if (section.data != null && section.data!.isNotEmpty) {
              final dataCount = section.data!.length;
              final preview = dataCount > 3 ? 3 : dataCount;

              for (var j = 0; j < preview; j++) {
                final item = section.data![j];
                if (section.type == 2) {
                  // Services
                  log('       - Service $j: ${item.name} (ID: ${item.id}, Price: ${item.price})');
                } else if (section.type == 6) {
                  // Deals
                  log('       - Deal $j: ${item.name} (ID: ${item.id}, Total: ${item.totalPrice})');
                } else if (section.type == 4) {
                  // Staff
                  log('       - Staff $j: ${item.name} (ID: ${item.id}, Email: ${item.email})');
                }
              }

              if (dataCount > 3) {
                log('       ... and ${dataCount - 3} more items');
              }
            }
          }
        }

        log('────────────────────────────────────────────────────────');
        log('════════════════════════════════════════════════════════');

        return salonDetails;
      } else {
        log('');
        log('❌ ERROR - HTTP ${response.statusCode}');
        log('════════════════════════════════════════════════════════');
        return null;
      }
    } catch (error, stackTrace) {
      log('');
      log('════════════════════════════════════════════════════════');
      log('💥 EXCEPTION IN SALON DETAIL API');
      log('════════════════════════════════════════════════════════');
      log('Error: $error');
      log('Stack Trace: $stackTrace');
      log('════════════════════════════════════════════════════════');
      throw Exception('Failed to load salon details: $error');
    }
  }
}
