import 'dart:convert';
import 'dart:developer';

import 'package:app/models/UserIsAlreadyRegisteredModel.dart';
import 'package:flutter/material.dart';

import '../../../api_services/ProfileUpdateAPI.dart';
import '../../../api_services/home_screen_api.dart';
import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';
import '../../../models/update_profile_response.dart';
import '../../home/home_screen.dart';
import '../../init_screen.dart';
import '../../otp/otp_screen.dart';

class CompleteProfileForm extends StatefulWidget {

  final UserIsAlreadyRegisteredModel user;

  const CompleteProfileForm({super.key, required this.user});


  @override
  _CompleteProfileFormState createState() => _CompleteProfileFormState();
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String?> errors = [];
  String? firstName;
  String? lastName;
  String? phoneNumber;
  // String? address;
  String? email;
  String? gender = "female";
  String? country = "pakistan";
  String? state = "sindh";
  String? city = "karachi";
  String? address;





  TextEditingController emailController = TextEditingController();


  @override
  _CompleteProfileFormState createState() => _CompleteProfileFormState();


  @override
  void initState() {
    super.initState();
    emailController.text = widget.user.email ?? "";
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
            decoration: const InputDecoration(
              labelText: "First Name",
              hintText: "Enter your first name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
            ),
          ),
          const SizedBox(height: 20),
          //lname
          TextFormField(
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
            decoration: const InputDecoration(
              labelText: "Last Name",
              hintText: "Enter your last name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
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
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter your email address",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon:
              CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
            ),
          ),
          const SizedBox(height: 20),
          //phone
          TextFormField(
            keyboardType: TextInputType.phone,
            onSaved: (newValue) => phoneNumber = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: kPhoneNumberNullError);
              }
              return;
            },
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: kPhoneNumberNullError);
                return "";
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Phone Number",
              hintText: "Enter your phone number",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
            ),
          ),
          const SizedBox(height: 20),
          // gender
          DropdownButtonFormField<String>(
            value: gender,
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
            value: country,
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
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Location point.svg"),
            ),
            items: const [
              DropdownMenuItem(value: "pakistan", child: Text("Pakistan")),
            ],
          ),
          const SizedBox(height: 20),
          // state
          DropdownButtonFormField<String>(
            value: state,
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
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Location point.svg"),
            ),
            items: const [
              DropdownMenuItem(value: "sindh", child: Text("Sindh")),
            ],
          ),
          const SizedBox(height: 20),
          // city
          DropdownButtonFormField<String>(
            value: city,
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
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Location point.svg"),
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
                  builder: (_) => const Center(child: CircularProgressIndicator()),
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




                // {
                // "first_name": "John",
                // "last_name": "Doe",
                // "name": "John Doe",
                // "email": "muhammad.usman89@icloud.com",
                // "device_id": "device-123",
                // "provider": "google",
                // "provider_id": "google-uid-123",
                // "image": "",
                // "phone": "+1234567890",
                // "dob": "1990-01-01",
                // "gender": "male",
                // "country": "USA",
                // "state": "California",
                // "latitude": "34.0522",
                // "longitude": "-118.2437",
                // "city": "Los Angeles",
                // "address": "123 Main St"
                // }


                try {
                  final response = await ProfileUpdateAPI.updateUserProfile({
                    "first_name": firstName,
                    "last_name": lastName,
                    "name": "${firstName} ${lastName}",
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

                  // Navigator.pop(context);


                  // final updateProfileResponse = UpdateProfileResponse.fromJson(
                  //   jsonDecode(response),
                  // );

                  log("Profile updated: lastanem ${response.response?.data?.lastName}");

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile updated successfully")),
                  );


                  if(response.status == true){
                    Navigator.pushNamed(context, InitScreen.routeName);
                  }else{
                    log("Profile update failed: ${response.message}");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${response.message.toString()}")),
                    );
                  }

                  // Navigator.pop(context);
                  //Navigator.pushNamed(context, OtpScreen.routeName);

                } catch (e) {
                  Navigator.pop(context); // Close the loading spinner


                  log("Profile update failed: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }

                //Navigator.pushNamed(context, OtpScreen.routeName);
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
