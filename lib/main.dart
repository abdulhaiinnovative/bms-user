import 'package:app/screens/search_final/search_provider_new.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/SearchProvider.dart';
import 'package:app/providers/auth/auth_provider.dart';
import 'package:app/providers/notification/notification_provider.dart';
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
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => SearchProvider()),
        ChangeNotifierProvider(create: (context) => SearchProviderNew()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
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
