import 'package:app/screens/search_final/search_provider_new.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/auth/auth_provider.dart';
import 'package:app/presentation/viewmodels/home/home_view_model.dart';
import 'package:app/presentation/viewmodels/favourites/favourites_view_model.dart';
import 'package:app/presentation/viewmodels/profile/profile_view_model.dart';
import 'package:app/presentation/viewmodels/notifications/notifications_view_model.dart';
import 'package:app/presentation/viewmodels/salon/salon_view_model.dart';
import 'package:app/presentation/viewmodels/salon_detail/salon_detail_view_model.dart';
import 'package:app/presentation/viewmodels/bookings/bookings_view_model.dart';
import 'package:app/presentation/viewmodels/category/category_view_model.dart';
import 'package:app/presentation/viewmodels/salon_services/salon_services_view_model.dart';
import 'package:app/screens/splash/splash_screen.dart';
import 'firebase_options.dart';
import 'routes.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  GoogleSignIn.instance.initialize(
    serverClientId:
        '55638853518-g0g84a7rsoolhi6ugo76se0o0seovf9b.apps.googleusercontent.com',
  );

  runApp(
    MultiProvider(
      providers: [
        // Authentication Provider (keep for auth infrastructure)
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        
        // MVVM ViewModels
        ChangeNotifierProvider(create: (context) => SearchProviderNew()),
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
        ChangeNotifierProvider(create: (context) => FavouritesViewModel()),
        ChangeNotifierProvider(create: (context) => ProfileViewModel()),
        ChangeNotifierProvider(create: (context) => NotificationsViewModel()),
        ChangeNotifierProvider(create: (context) => SalonViewModel()),
        ChangeNotifierProvider(create: (context) => SalonDetailViewModel()),
        ChangeNotifierProvider(create: (context) => BookingsViewModel()),
        ChangeNotifierProvider(create: (context) => CategoryViewModel()),
        ChangeNotifierProvider(create: (context) => SalonServicesViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BookMySpot',
      theme: AppTheme.lightTheme(context),
      initialRoute: SplashScreen.routeName,
      // initialRoute: SearchFetchAPIData.routeName,
      routes: routes,
    );
  }
}
