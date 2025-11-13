import 'dart:convert';
import 'dart:developer';
import 'package:app/services/protected_http_client.dart';
import '../models/HomePageResponse.dart';

class HomeScreenAPI {
  HomeScreenAPI();

  Future<HomePageResponse> fetchHomePageData() async {
    try {
      // Using ProtectedHttpClient with authentication required
      final response = await ProtectedHttpClient.get('/home-page');

      if (response.statusCode == 200) {
        log('-----++ fetchHomePageData API called with auth');
        log('----- fetchHomePageData start');
        log('----- fetchHomePageData end');

        HomePageResponse homePageResponse =
            HomePageResponse.fromJson(jsonDecode(response.body));
        log('1==1== $homePageResponse');

        log('1==Slider=== ${homePageResponse.response.data.type1}');
        log('1===== ${homePageResponse.response.data.type1[0].data[0].image}');

        log('2==Categories=== ${homePageResponse.response.data.type2}');
        log('2===== ${homePageResponse.response.data.type2[0].data[0].name}');

        log('3==Salons===--- ${homePageResponse.response.data.type3}');
        log('3=====++++ ${homePageResponse.response.data.type3[0].data[0].name}');

        log('4==Deals=== ${homePageResponse.response.data.type4}');
        log('4===== ${homePageResponse.response.data.type4[0].data[0].name}');

        log('5==Services===: ${homePageResponse.response.data.type5}');
        log('5=====: ${homePageResponse.response.data.type5[0].data[0].name}');

        return homePageResponse;
      } else {
        log('❌ Failed to load home page data: ${response.statusCode}');
        throw Exception(
            'Failed to load data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } on UnauthorizedException catch (e) {
      log('❌ Unauthorized: $e');
      throw Exception('Session expired. Please login again.');
    } on ApiException catch (e) {
      log('❌ API Error: $e');
      throw Exception('Failed to load data: $e');
    } catch (error) {
      log('❌ Unexpected error: $error');
      throw Exception('Failed to load data: $error');
    }
  }
}
