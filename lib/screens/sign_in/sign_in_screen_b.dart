import 'dart:developer' as developer;
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FB_User;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/constants.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../api_services/check_user_already_registered_api.dart';
import '../../models/CreateUserViewModel.dart';
import '../../models/UserIsAlreadyRegisteredModel.dart';
import '../../models/create_user/CreateUserResponse.dart';
import '../../my_widget/CustomButton.dart';
import '../../my_widget/CustomButtonGoogle.dart';
import '../../utlis/DialogUtils.dart';
import '../../utlis/MyUtils.dart';
import '../../utlis/UtilsExtra.dart';
import '../complete_profile/complete_profile_screen.dart';
import '../init_screen.dart';

class SignInScreenB extends StatelessWidget {
  static String routeName = "/sign_in_b";

  // Sign in to Firebase with the OAuth credential
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SignInScreenB({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateUserViewModel(), 
      child: Consumer<CreateUserViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: kScreenBg,
            body: Column(
              children: [
                Flexible(
                  flex: 5,
                  child: Container(
                    color: kScreenBg,
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        Row(
                          children: [
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => DashboardScreen()),
                                // );
                              },
                              child: const Text("Skip for now"),
                            ),
                          ],
                        ),
                        Image.asset(
                          'assets/images/splash_logo.png',
                          width: 230,
                          height: 150,
                        ),
                        const Spacer(),
                        const Text(
                          'Last Minute Brought \nto Life',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 7,
                  child: Container(
                    color: kScreenBg,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: const Text(
                            'Register',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          child: Text(
                            'Already have an account? Login here',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade900,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomButtonGoogle(
                          text: 'Continue with Google',
                          color: Colors.white,
                          onPressed: () => handleGoogleSignIn(context),
                        ),
                        const SizedBox(height: 10),
                        CustomButton(
                          text: 'Continue with Apple',
                          color: Colors.black,
                          onPressed: () async {
                            // _signInWithApple(context);
                            try {
                              // if(isConnected){
                              DialogLoadingUtils.showLoadingDialog(context,
                                  message: 'Please wait');
                              await _signInWithAppleNew(context);

                              // print('isConnected:: $isConnected');
                              // }else{
                              //   print('isConnected- $isConnected');
                              // _checkConnectivity();
                              // }
                            } catch (e) {
                              print('SignInWithAppleButton Error: $e');
                            }
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 25, right: 25, top: 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.0),
                                child: Text(
                                  "Or",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomButton(
                          text: 'Sign in with email',
                          color: kPrimaryColor,
                          onPressed: () async {
                            log('signInWithGoogle....');
                            //DialogLoadingUtils.showLoadingDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    developer.log("googleSignIn..");
    try {
      // Simple alternative implementation using Firebase Auth directly
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Add scopes if needed
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);
      final User? user = userCredential.user;

      developer.log("====--- try");
      developer.log('result: $user');

      if (user != null) {
        DialogLoadingUtils.showLoadingDialog(context);

        CreateUserResponse? ss = await CreateUserViewModel.createUser(
          "google",
          user.uid,
          user.uid,
          user.email ?? '',
          "1234",
          "-",
          user.displayName ?? '-',
          user.displayName?.split(' ').first ?? '-',
          (user.displayName?.split(' ').length ?? 0) > 1
              ? user.displayName?.split(' ')[1] ?? '-'
              : '-',
          "-",
        );
        // DialogLoadingUtils.dismissDialog(context);
        await UtilsExtra.saveUserDetails(ss?.data?.user);
        await UtilsExtra.saveToken(ss?.data?.accessToken ?? "-");
        String s = await UtilsExtra.getToken() ?? '';
        developer.log('Token:New: $s');
        final mUser = await UtilsExtra.getUserDetails();
        if (mUser != null) {
          UserIsAlreadyRegisteredModel userIsAlreadyRegisteredModel =
              UserIsAlreadyRegisteredModel(
            id: '${mUser.id}',
            first_name: '${mUser.firstName}',
            last_name: '${mUser.lastName}',
            name: "${mUser.firstName} ${mUser.lastName}".trim(),
            email: mUser.email ?? "",
            profile_image: '',
          );

          await _saveUserProfile(context, userIsAlreadyRegisteredModel);
        } else {
          developer.log('No user details found.');
        }
      } else {
        developer.log('Sign-in canceled or failed.');
      }
    } catch (error) {
      developer.log("====-- error: $error ");

      DialogLoadingUtils.dismissDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $error')),
      );
    }
  }

  Future<bool> _checkUserInFirestore(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    return userDoc.exists;
  }

  // Function to get user data from Firestore
  Future<Map<String, dynamic>?> _getUserFromFirestore(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc.data();
    }
    return null;
  }

  Future<void> _signInWithAppleNew(BuildContext context) async {
    try {
      // Trigger Apple Sign-In
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuth credential from the Apple credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);

      FB_User.User? user = userCredential.user;

      print('user ::email::  ${userCredential.user?.email}');
      print('user ::displayName::  ${userCredential.user?.displayName}');

      final firstName = credential.givenName?.trim() ?? '';
      final lastName = credential.familyName?.trim() ?? '';

      print('user ::firstName::  $firstName');
      print('user ::lastName::  $lastName');

      if (user != null) {
        // Check if the user exists in Firestore
        final userExistsInFirestore =
            await _checkUserInFirestore(credential.userIdentifier.toString());

        print('credential.state :  ${credential.state}');
        print('credential.state :  ${credential.email}');
        print('credential.familyName :  ${credential.familyName}');
        print('credential.givenName :  ${credential.givenName}');
        print('credential.userIdentifier :  ${credential.userIdentifier}');
        print('credential.identityToken :  ${credential.identityToken}');
        print(
            'credential.authorizationCode :  ${credential.authorizationCode}');
        print('credential.user :  $user');
        print('credential.user.uid :  ${user.uid}');

        if (userExistsInFirestore) {
          final userData =
              await _getUserFromFirestore(credential.userIdentifier.toString());
          if (userData != null) {
            print('User data from Firestore: $userData');

            // Access specific fields from the userData map
            print('userExistsInFirestore id: ${userData['uid']}');
            print('userExistsInFirestore fullname: ${userData['displayName']}');
            print('userExistsInFirestore email: ${userData['email']}');
          } else {
            print('User data not found in Firestore');
          }

          // CreateUserResponse? ss = await CreateUserViewModel.createUser(
          //   "google",
          //   result.id,
          //   result.id,
          //   result.email ?? '-',
          //   "1234",
          //   "-",
          //   result.displayName ?? '-',
          //   result.displayName?.split(' ')[0] ?? '-',
          //   result.displayName?.split(' ')[1] ?? '-',
          //   "-",
          // );

          // Check if the user exists in the server database
          UserIsAlreadyRegisteredModel userIsAlreadyRegisteredModel =
              UserIsAlreadyRegisteredModel(
            id: userData?['uid'].toString() ?? "",
            name: '-', //'${ userData?['name'].toString() ?? ""}',
            first_name: '-', //'${ userData?['firstName'].toString() ?? ""}',
            last_name: '-', //'${ userData?['familyName'].toString() ?? ""}',
            email: userData?['email']?.toString() ?? "",
            profile_image: '-', //'',
          );

          await _saveUserProfile(context, userIsAlreadyRegisteredModel);
        } else {
          await _saveUserInFirestore(
            user,
            userCredential.user?.email ?? 'no-email',
            userCredential.user?.displayName ?? '',
            credential.familyName ?? '',
            credential.userIdentifier.toString(),
          );

          print('userNotExistsInFirestore :  $userExistsInFirestore');
          print('userNotExistsInFirestore :  $userExistsInFirestore');
          print('userNotExistsInFirestore :  $userExistsInFirestore');
          print('userNotExistsInFirestore :  $userExistsInFirestore');

          // Check if the user exists in the server database
          UserIsAlreadyRegisteredModel userIsAlreadyRegisteredModel =
              UserIsAlreadyRegisteredModel(
            id: credential.userIdentifier.toString(),
            name: "${credential.givenName ?? ''} ${credential.familyName ?? ''}"
                .trim(),
            email: credential.email ?? "",
            profile_image: '',
          );

          await _saveUserProfile(context, userIsAlreadyRegisteredModel);
        }
      } else {
        print('Else error signing in with Apple:');
      }
    } catch (e) {
      print('Error signing in with Apple: $e');
      DialogLoadingUtils.dismissDialog(context);
    }
  }

  Future<void> _saveUserInFirestore(FB_User.User user, String email,
      String firstName, String lastName, String userIdentifier) async {
    await _firestore.collection('users').doc(userIdentifier).set({
      'uid': userIdentifier,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'photoURL': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _saveUserProfile(BuildContext context,
      UserIsAlreadyRegisteredModel userIsAlreadyRegisteredModel) async {
    try {
      userIsAlreadyRegisteredModel.profile_image =
          userIsAlreadyRegisteredModel.profile_image ?? '';

      log('==--userIsAlreadyRegisteredModel::  ${userIsAlreadyRegisteredModel.toJson()}');

      final response = await CheckUserRegistered().checkUserRegistered(
          userIsAlreadyRegisteredModel: userIsAlreadyRegisteredModel);

      log('==--customReturn::  ${response.data}');
      log('==--customReturn:accessToken:  ${response.data.accessToken}');

      UtilsExtra.saveToken(response.data.accessToken);

      if (response.status) {
        print('----------------${response.data.toString()}');

        print('==-- 4====');
        print('----------------52');
        if (response.isComplete == false) {
          print('----------------6 -- ${userIsAlreadyRegisteredModel.name}');
          print('----------------6 -- ${userIsAlreadyRegisteredModel.email}');
          print('----------------6 -- ${userIsAlreadyRegisteredModel.id}');
          log('==-- 7');

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Complete your profile to continue.')));

          MyUtils.hideLoadingDialog(context);
          await Future.delayed(const Duration(seconds: 2));

          Navigator.pushNamed(
            context,
            CompleteProfileScreen.routeName,
            arguments: userIsAlreadyRegisteredModel,
          );
        } else {
          print('----------------7');

          await MyUtils.instance.saveUser(response.data.user);
          await MyUtils.instance.saveUserId('${response.data.user.id}');
          MyUtils.hideLoadingDialog(context);
          //await Future.delayed(Duration(seconds);

          Navigator.pushNamed(context, InitScreen.routeName);
        }
      } else {
        MyUtils.hideLoadingDialog(context);
        print('----------------8');
        log('==-- 5');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${response.message} !   ')),
        );
      }
    } catch (error) {
      MyUtils.hideLoadingDialog(context);
      print('----------------9');
      log('saveUserId:1: model resp:  $error');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errors: $error')),
      );
    }
  }
}
