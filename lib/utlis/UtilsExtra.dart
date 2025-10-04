
import 'dart:convert';
import 'package:app/models/create_user/User.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UtilsExtra {
  static Future<User?> getUserDetails() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString("_userKey");

    if (userJson != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return User.fromJson(userMap);
    }
     return null;

  }

  static Future<void> clearUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("_userKey");
    print('User details cleared from SharedPreferences.');
  }


  static Future<void> saveUserDetails(User? user) async {
    print('User details saved in SharedPreferences.1');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userJson = jsonEncode(user?.toJson());
    await prefs.setString("_userKey", userJson);
    print('User details saved in SharedPreferences.2');
  }


  static Future<void> saveToken(String token) async {
    print('User token saved in SharedPreferences.1');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("_tokenKey", token);
    print('User token saved in SharedPreferences.2');
  }


  static Future<String?> getToken() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("_tokenKey");

    return token;

  }






}