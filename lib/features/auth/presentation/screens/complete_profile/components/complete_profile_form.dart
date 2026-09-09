import 'package:app/models/UserIsAlreadyRegisteredModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../../../api_services/ProfileUpdateAPI.dart';
import '../../../../../../components/form_error.dart';
import '../../../../../../constants.dart';
import '../../../../data/models/social_auth_response.dart';
import '../../../providers/auth_provider.dart';
import '../../../../../../services/fcm_token_service.dart';
import '../../../../../home/presentation/screens/init_screen.dart';

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
bool isPhoneValid = false;
  String? email;
  String? gender = "male";
  String? country = "pakistan";
  String? state = "sindh";
  String? city = "karachi";
  String? address = '';

  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
        letterSpacing: 0.2,
      ),
      hintStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey[400],
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.grey[600],
        size: 22,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: kPrimaryColor.withOpacity(0.8), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

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
    final authProvider = Provider.of<AuthProvider>(context);

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
            decoration: _buildInputDecoration(
              label: "First Name",
              hint: "Enter your first name",
              icon: Icons.person_outline,
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
            decoration: _buildInputDecoration(
              label: "Last Name",
              hint: "Enter your last name",
              icon: Icons.person_outline,
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
            decoration: _buildInputDecoration(
              label: "Email",
              hint: "Enter your email address",
              icon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 20),
          //phone
          IntlPhoneField(
  style: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  ),
  dropdownTextStyle: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  ),
  initialCountryCode: 'PK',
  showCountryFlag: true,

  decoration: InputDecoration(
    labelText: "Phone Number *",
    hintText: "Enter your phone number",
    floatingLabelBehavior: FloatingLabelBehavior.always,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  onChanged: (phone) {
    final number = phone.number.trim();

    if (number.isEmpty) {
      phoneNumber = null;
      isPhoneValid = false;
      return;
    }

    phoneNumber = "${phone.countryCode}$number";
    isPhoneValid = number.length >= 10;
  },

  onSaved: (phone) {
    final number = phone?.number.trim() ?? "";

    phoneNumber = number.isEmpty ? null : "${phone?.countryCode}$number";
  },

  validator: (phone) {
    final number = phone?.number.trim() ?? "";

    if (number.isEmpty) {
      return "Phone number is required";
    }

    if (number.length < 10) {
      return "Enter a valid phone number";
    }

    return null;
  },
),
          const SizedBox(height: 20),
          // gender
          DropdownButtonFormField<String>(
            initialValue: gender,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey[600],
            ),
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
            decoration: _buildInputDecoration(
              label: "Gender",
              hint: "Select your gender",
              icon: Icons.wc_outlined,
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
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey[600],
            ),
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
            decoration: _buildInputDecoration(
              label: "Country",
              hint: "Select your country",
              icon: Icons.public,
            ),
            items: const [
              DropdownMenuItem(value: "pakistan", child: Text("Pakistan")),
            ],
          ),
          const SizedBox(height: 20),
          // state
          DropdownButtonFormField<String>(
            initialValue: state,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey[600],
            ),
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
            decoration: _buildInputDecoration(
              label: "State",
              hint: "Select your state",
              icon: Icons.location_on_outlined,
            ),
            items: const [
              DropdownMenuItem(value: "sindh", child: Text("Sindh")),
            ],
          ),
          const SizedBox(height: 20),
          // city
          DropdownButtonFormField<String>(
            initialValue: city,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey[600],
            ),
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
            decoration: _buildInputDecoration(
              label: "City",
              hint: "Select your city",
              icon: Icons.location_city_outlined,
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
  // address is optional
  return null;
},
            decoration: _buildInputDecoration(
              label: "Address (Optional)",
              hint: "Enter your address",
              icon: Icons.home_outlined,
            ),
          ),
          const SizedBox(height: 20),
          FormError(errors: errors),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                if (!isPhoneValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid phone number"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                _formKey.currentState!.save();
                if (_formKey.currentState!.validate()) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    if (widget.isSocialAuth && widget.socialUser != null) {
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Profile completed successfully")),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InitScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authProvider.errorMessage ??
                                "Failed to complete profile"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      final response =
                          await ProfileUpdateAPI.updateUserProfile({
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
                        "address": address ?? ""
                      });
  
                      Navigator.pop(context); // Close loading dialog

                      if (response.status == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Profile updated successfully")),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InitScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Error: ${response.message.toString()}")),
                        );
                      }
                    }
                  } catch (e) {
                    Navigator.pop(context); // Close the loading spinner

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
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
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
