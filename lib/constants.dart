import 'package:flutter/material.dart';

const logo = 'https://play-lh.googleusercontent.com/YkCoSKpuEeemtGep3Fey9FVKxb2xcwNEUkhQBaO1Zo-1Zicg-uT1-fHB4YxutMXi6_s=w480-h960-rw';
const salonImage = 'https://i.pinimg.com/564x/8f/6b/92/8f6b921927eecbcdab4b886a0e345160.jpg';
const placeHolder = 'assets/images/place_holder.png';

const Color backgroundColor = Color.fromARGB(255, 255, 241, 159);
const Color commentColor = Color.fromARGB(255, 255, 246, 196);
const Color blackColor = Colors.black;
const Color greyColor = Colors.grey;
const Color greenColor = Colors.green;
const Color redColor = Colors.red;
const Color blueColor = Colors.blue;
const Color greenAccent = Colors.greenAccent;
final Color blackAndWhiteDimmedColor =  Colors.transparent.withOpacity(.3);
final Color blackAndWhiteSuperDimmedColor =  Color(0xaaFFFFFF);
const Color whiteColor = Colors.white;
const Color amberColor = Colors.amber;
const Color purpleColor = Colors.purple;
Color dimmedWhiteColor = Color(0x99FFFFFF);
Color superDimmedWhiteColor = Color(0x55FFFFFF);

//const BASE_URL = "https://bookmyspot.arca9.com";
const BASE_URL = "https://bms.innovativewidget.com/api";

const BASE_URL_IMAGE = "$BASE_URL/imageUpload/image";
const NO_IMAGE_FOUND_URL = "https://i.pinimg.com/564x/00/e7/62/00e76210732e10be1a82ea509a3bbb4d.jpg";




const kPrimaryColor = Color(0xFFE21C6A);
const kPrimaryDarkColor = Color(0xFF7F2884);
const kPrimaryLightColor = Color(0xFFFFECDF);
const kWhiteTransparent = Color(0x55FFFFFF);
const kPrimaryColor3 = Color(0x77DE2B72);

const kPrimaryColor2 = Color(0xAADE2B72);
const kPrimaryDarkColor2 = Color(0xAAE445EE);


const kGradientColorRing = [kPrimaryColor, kPrimaryDarkColor];


const kShadow = Color(0x55000000);
const kShadow2 = Color(0x33000000);
//const kScreenBg = Color(0xccF2F0F1);
// const kShadow = Color(0xaaf1f1f1);
const kShadowWithPrimary = Color(0x55E21C6A);
//const kCardBG = Color(0xFFF5F5F7);
const kCardBG = Color(0xFFFFFFFF);
const kScreenBg = Color(0xFFeFeFeF);
const double kRadius = 15;


const kCardWhiteBG = Color(0xFFFFFFFF);


const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFE21C6A), Color(0xFF7F2884)],
);
const kSecondaryColor = Color(0xFF979797);
const kGridUnselected = Color(0xFFf4f4f4);
const kTextColor = Colors.black;

const kPrice = kPrimaryColor;
const kBeforeDiscount = kPrimaryDarkColor;
const kDiscount = kPrimaryColor;


const kAnimationDuration = Duration(milliseconds: 200);

const headingStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your email";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNamelNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";
const String kPasswordNullError = "Please Enter your password";


const String kFNameNullError = "Please enter your first name";
const String kLNameNullError = "Please enter your last name";
const String kCountryNullError = "Please Enter Your Country";
const String kStateNullError = "Please Enter Your State";
const String kCityNullError = "Please Enter Your City";
const String kGenderNullError = "Please Enter Your Gender";



final otpInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 16),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: kTextColor),
  );
}
