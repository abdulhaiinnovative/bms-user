import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:app/models/SearchSalonResponse.dart';
import '../models/SalonMain.dart';

// Future<List<SalonMain>> searchSalonAPI({required String salon, required String service}) async {
//   const String url = 'https://bookmyspot.arca9.com/api/salons/search?page=1';
//   final Map<String, dynamic> body = {
//     "salon": salon,
//     "service": service, // Added service parameter
//   };
//
//   try {
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//       body: jsonEncode(body),
//     );
//
//     if (response.statusCode == 200) {
//       final searchResponse = SearchSalonResponse.fromJson(jsonDecode(response.body));
//
//       // if (searchResponse.status) {
//       //   final salons = searchResponse.response.data.salons;
//       //
//       //   if (salons.isNotEmpty) {
//       //     return salons;
//       //   } else {
//       //     log('No salons found.');
//       //     return [];
//       //   }
//       // } else {
//       //   log('Error: ${searchResponse.message}');
//       //   return [];
//       // }
//     } else {
//       log('Failed to load data. Status Code: ${response.statusCode}');
//       return [];
//     }
//   } catch (e) {
//     log('Error: $e');
//     return [];
//   }
// }
