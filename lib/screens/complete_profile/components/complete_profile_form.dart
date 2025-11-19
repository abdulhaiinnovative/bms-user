import 'dart:developer';

import 'package:app/models/UserIsAlreadyRegisteredModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../api_services/ProfileUpdateAPI.dart';
import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';
import 'package:app/features/auth/data/models/social_auth_response.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import '../../../services/fcm_token_service.dart';
import '../../init_screen.dart';

class CompleteProfileForm extends StatefulWidget {
  final UserIsAlreadyRegisteredModel? user;
  final bool isSocialAuth;
  final SocialUserData? socialUser;
  final String? email;

  const CompleteProfileForm({
    super.key,
    this.user,
    this.isSocialAuth = false,
    this.socialUser,
    this.email,
  });

  @override
  _CompleteProfileFormState createState() => _CompleteProfileFormState();
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String?> errors = [];
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? email;
  String? gender = "female";
  String? country = "pakistan";
  String? state = "sindh";
  String? city = "karachi";
  String? address;

  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isSocialAuth && widget.socialUser != null) {
      // Pre-fill from social auth data
      emailController.text = widget.email ?? widget.socialUser?.email ?? "";
      firstNameController.text = widget.socialUser?.firstName ?? "";
      lastNameController.text = widget.socialUser?.lastName ?? "";

      firstName = widget.socialUser?.firstName;
      lastName = widget.socialUser?.lastName;
      email = widget.email ?? widget.socialUser?.email;

      print('📝 CompleteProfileForm: Pre-filled social auth data');
      print('   Email: $email');
      print('   First Name: $firstName');
      print('   Last Name: $lastName');
    } else if (widget.user != null) {
      // Pre-fill from regular registration
      emailController.text = widget.user?.email ?? "";
      email = widget.user?.email;
    }
  }

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          //fname
          TextFormField(
            controller: firstNameController,
            readOnly: widget.isSocialAuth, // Read-only for social auth
            onSaved: (newValue) => firstName = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: kFNameNullError);
              }
              return;
            },
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: kFNameNullError);
                return "";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "First Name",
              hintText: "Enter your first name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon:
                  const CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
              // Show indicator for pre-filled social auth fields
              helperText:
                  widget.isSocialAuth ? "From your Google account" : null,
              helperStyle: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 20),
          //lname
          TextFormField(
            controller: lastNameController,
            readOnly: widget.isSocialAuth, // Read-only for social auth
            onSaved: (newValue) => lastName = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: kLNameNullError);
              }
              return;
            },
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: kLNameNullError);
                return "";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Last Name",
              hintText: "Enter your last name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon:
                  const CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
              helperText:
                  widget.isSocialAuth ? "From your Google account" : null,
              helperStyle: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 20),
          //email
          TextFormField(
            controller: emailController,
            readOnly: true,
            onSaved: (newValue) => email = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: kEmailNullError);
              }
              return;
            },
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: kEmailNullError);
                return "";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "Enter your email address",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon:
                  const CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
              helperText:
                  widget.isSocialAuth ? "From your Google account" : null,
              helperStyle: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 20),
          //phone
          IntlPhoneField(
            decoration: const InputDecoration(
              labelText: "Phone Number",
              hintText: "Enter your phone number",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(),
            ),
            initialCountryCode: 'PK', // Pakistan as default
            onChanged: (phone) {
              phoneNumber = phone.completeNumber;
              if (phone.completeNumber.isNotEmpty) {
                removeError(error: kPhoneNumberNullError);
              }
            },
            onSaved: (phone) {
              if (phone != null) {
                phoneNumber = phone.completeNumber;
              }
            },
            validator: (phone) {
              if (phone == null || phone.completeNumber.isEmpty) {
                addError(error: kPhoneNumberNullError);
                return "";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // gender
          DropdownButtonFormField<String>(
            initialValue: gender,
            icon: const SizedBox.shrink(), // Hides the default dropdown icon
            onChanged: (newValue) {
              setState(() {
                gender = newValue;
              });
              if (newValue != null && newValue.isNotEmpty) {
                removeError(error: kGenderNullError);
              }
            },
            onSaved: (newValue) {
              gender = newValue;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError(error: kGenderNullError);
                return "";
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Gender",
              hintText: "Select your gender",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
            ),
            items: const [
              DropdownMenuItem(value: "male", child: Text("Male")),
              DropdownMenuItem(value: "female", child: Text("Female")),
            ],
          ),
          const SizedBox(height: 20),
          // country
          DropdownButtonFormField<String>(
            initialValue: country,
            icon: const SizedBox.shrink(), // Hides the default dropdown icon
            onChanged: (newValue) {
              setState(() {
                country = newValue;
              });
              if (newValue != null && newValue.isNotEmpty) {
                removeError(error: kGenderNullError);
              }
            },
            onSaved: (newValue) {
              country = newValue;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError(error: kCountryNullError);
                return "";
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Country",
              hintText: "Select your country",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon:
                  CustomSurffixIcon(svgIcon: "assets/icons/Location point.svg"),
            ),
            items: const [
              DropdownMenuItem(value: "pakistan", child: Text("Pakistan")),
            ],
          ),
          const SizedBox(height: 20),
          // state
          DropdownButtonFormField<String>(
            initialValue: state,
            icon: const SizedBox.shrink(), // Hides the default dropdown icon
            onChanged: (newValue) {
              setState(() {
                state = newValue;
              });
              if (newValue != null && newValue.isNotEmpty) {
                removeError(error: kStateNullError);
              }
            },
            onSaved: (newValue) {
              state = newValue;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError(error: kStateNullError);
                return "";
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "State",
              hintText: "Select your state",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon:
                  CustomSurffixIcon(svgIcon: "assets/icons/Location point.svg"),
            ),
            items: const [
              DropdownMenuItem(value: "sindh", child: Text("Sindh")),
            ],
          ),
          const SizedBox(height: 20),
          // city
          DropdownButtonFormField<String>(
            initialValue: city,
            icon: const SizedBox.shrink(), // Hides the default dropdown icon
            onChanged: (newValue) {
              setState(() {
                city = newValue;
              });
              if (newValue != null && newValue.isNotEmpty) {
                removeError(error: kCityNullError);
              }
            },
            onSaved: (newValue) {
              city = newValue;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                addError(error: kCityNullError);
                return "";
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "City",
              hintText: "Select your city",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon:
                  CustomSurffixIcon(svgIcon: "assets/icons/Location point.svg"),
            ),
            items: const [
              DropdownMenuItem(value: "karachi", child: Text("Karachi")),
            ],
          ),
          const SizedBox(height: 20),
          // address
          TextFormField(
            onSaved: (newValue) => address = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: kAddressNullError);
              }
              return;
            },
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: kAddressNullError);
                return "";
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Address",
              hintText: "Enter your address",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon:
                  CustomSurffixIcon(svgIcon: "assets/icons/Location point.svg"),
            ),
          ),
          const SizedBox(height: 20),
          FormError(errors: errors),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              _formKey.currentState!.save();
              if (_formKey.currentState!.validate()) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );

                log('firstName::: $firstName');
                log('lastName::: $lastName');
                log('email::: $email');
                log('phoneNumber::: $phoneNumber');
                log('gender::: $gender');
                log('country::: $country');
                log('state::: $state');
                log('city::: $city');
                log('address::: $address');

                try {
                  if (widget.isSocialAuth && widget.socialUser != null) {
                    // Handle social auth profile completion
                    print(
                        '🔵 CompleteProfileForm: Completing social auth profile...');

                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    final fcmToken = await FCMTokenService.getFCMToken();

                    final success = await authProvider.completeSocialProfile(
                      email: email!,
                      phone: phoneNumber,
                      gender: gender,
                      country: country,
                      state: state,
                      city: city,
                      address: address,
                      fcmToken: fcmToken,
                    );

                    Navigator.pop(context); // Close loading dialog

                    if (!mounted) return;

                    if (success) {
                      print(
                          '✅ CompleteProfileForm: Social profile completed successfully');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Profile completed successfully")),
                      );
                      Navigator.pushReplacementNamed(
                          context, InitScreen.routeName);
                    } else {
                      print(
                          '❌ CompleteProfileForm: Failed to complete social profile');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(authProvider.errorMessage ??
                              "Failed to complete profile"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    // Handle regular profile update
                    print(
                        '🔵 CompleteProfileForm: Updating regular profile...');
                    final response = await ProfileUpdateAPI.updateUserProfile({
                      "first_name": firstName,
                      "last_name": lastName,
                      "name": "$firstName $lastName",
                      "email": email,
                      "device_id": "device-123",
                      "provider": "google",
                      "provider_id": "117038108082662535502",
                      "image": "",
                      "phone": phoneNumber,
                      "dob": "2000-01-01",
                      "gender": gender,
                      "country": country,
                      "state": state,
                      "city": city,
                      "latitude": "24.8607",
                      "longitude": "67.0011",
                      "address": address
                    });

                    Navigator.pop(context); // Close loading dialog

                    log("Profile updated: lastname ${response.response?.data?.lastName}");

                    if (response.status == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Profile updated successfully")),
                      );
                      Navigator.pushNamed(context, InitScreen.routeName);
                    } else {
                      log("Profile update failed: ${response.message}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("Error: ${response.message.toString()}")),
                      );
                    }
                  }
                } catch (e) {
                  Navigator.pop(context); // Close the loading spinner
                  log("Profile completion/update failed: $e");

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: ${e.toString()}"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }
}
