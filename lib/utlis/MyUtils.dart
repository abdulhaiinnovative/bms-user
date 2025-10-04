import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/UserIsAlreadyRegisteredModelResponse.dart';


class MyUtils {

  // Private constructor
  MyUtils._internal();

  // Static instance
  static final MyUtils _instance = MyUtils._internal();

  // Static method to get the instance
  static MyUtils get instance => _instance;



  Future<void> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    print("User ID saved: $userId");
  }


  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    print("Retrieved User ID:--: $userId");
    return userId;
  }

  Future<void> removeUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    print("User ID removed");
  }


// Save user to SharedPreferences
  Future<void> saveUser(
      User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    await prefs.setString('userIsAlreadyRegisteredModel', userJson);
    print("User data saved: $userJson");
  }

// Retrieve user from SharedPreferences
  Future<User?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('userIsAlreadyRegisteredModel');
    print("object");
    print(userJson);

    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);

      return User.fromJson(userMap);
    }

    return null;
  }

// Remove user from SharedPreferences
  Future<void> removeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userIsAlreadyRegisteredModel');
    print("User data removed");
  }


  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isNotEmpty) {
        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      }
      return word;
    }).join(' ');
  }

  String cleanContent(String content) {

    content = content.replaceAll('\t', '');    // Remove tabs
    content = content.replaceAll('\r\n\r\n', '\r\n');  // Replace double newlines with single newlines
    content = content.trim();  // Trim leading and trailing spaces

    return content;
  }

  String removeHtmlTags(String input) {
    // Regular expression to match HTML tags
    final regExp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);

    // Replace all HTML tags with an empty string
    return input.replaceAll(regExp, '');
  }



// Function to format the date
  String formatDateTime(String dateTimeString) {

    print('dateTimeString $dateTimeString');

    // Parse the input date string
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Define the date formatter for '4th September 2024'
    String daySuffix = getDaySuffix(dateTime.day);
    String formattedDate = DateFormat('d').format(dateTime) + daySuffix + ' ' + DateFormat('MMM yyyy').format(dateTime);

    // Define the time formatter for '08:04 PM'
    String formattedTime = DateFormat('hh:mm a').format(dateTime);

    // Combine date and time
    return '$formattedDate - $formattedTime';
  }

// Function to get the day suffix (e.g., "st", "nd", "rd", "th")
  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      //return 'th';
      return '';
    }
    switch (day % 10) {
      case 1:
      //return 'st';
        return '';
      case 2:
      //return 'nd';
        return '';
      case 3:
      //return 'rd';
        return '';
      default:
      //return 'th';
        return '';
    }
  }



  void showOkDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          title: Text(title),
          content: SingleChildScrollView(
            child: Text(content,
              style: TextStyle(
                  fontSize: 12
              ),),
          ),
          // actions: [
          //   TextButton(
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //     child: Text('OK'),
          //   ),
          // ],
        );
      },
    );
  }


  static void showLoadingDialog(BuildContext context, String text) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 20),
                  Transform.scale(
                    scale: 0.8,
                    child: CircularProgressIndicator(
                      color: kPrimaryDarkColor.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    text,
                    style: TextStyle(
                        color: kTextColor, fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

}

