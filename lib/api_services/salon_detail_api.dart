import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/SalonDetailApiResponse.dart';


class SalonDetailAPI {
  // String baseURL = 'https://bookmyspot.arca9.com/api';
  String baseURL = 'https://bms.innovativewidget.com/api';



  SalonDetailAPI();

  Future<SalonData?> fetchSalonDetailData(String salonId) async {
    try {
      final response = await http.get(Uri.parse('$baseURL/salons/$salonId'));


      log('SalonDetailAPI URL::: ${'$baseURL/salons/$salonId'}');

      if (response.statusCode == 200) {

        //log('SalonDetailAPI Response ${response.body}');


        //Usage example:
        final response = await http.get(Uri.parse('$baseURL/salons/$salonId'));
        if (response.statusCode == 200) {

          // Fixing the incorrect assignment
          final apiResponse = SalonDetailApiResponse.fromJson(jsonDecode(response.body));

          SalonData? salonDetails = apiResponse.response?.data;

          // final apiResponse = SalonDetailApiResponse.fromJson(jsonDecode(response.body));
          // SalonDetailApiResponse? salonDetails = apiResponse.response();

          if (salonDetails != null) {

            log('SalonDetailAPI Name::: ${salonDetails.name}');
            log('SalonDetailAPI 0001--- ${apiResponse.response?.data!.sections?[0].name}');
            log('SalonDetailAPI 0002--- ${apiResponse.response?.data?.sections?[0].type}');
            log('SalonDetailAPI 0003--- ${apiResponse.response?.data?.sections?[0].data}');

            return salonDetails;
          }else{

            print('SalonDetailAPI 00Salon11111');
            return null;
          }
        }else{
          print('SalonDetailAPI 111112222');
        }



        // SalonDetailsClass salonDetailsClass = SalonDetailsClass.fromJson(jsonDecode(response.body));
        //
        // print('SalonDetailAPI: ${salonDetailsClass.name}');
        //
        //
        // print('SalonDetailAPI ${salonDetailsClass.name}');
        //print('SalonDetailAPI ${salonDetailsClass.tags}');

        //return HomePageResponse.fromJson(jsonDecode(response.body));
        //return salonDetailsClass;
      } else {
        throw Exception('SalonDetailAPI Failed to load data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('SalonDetailAPI Failed to load data: $error');
    }
  }
}

